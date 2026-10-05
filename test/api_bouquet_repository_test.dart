import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'package:library_web/core/api_exceptions.dart';
import 'package:library_web/models/models.dart';
import 'package:library_web/repositories/api_bouquet_repository.dart';

/// Создаёт Dio с тем же интерсептором, что в реальном приложении.
/// Без этого тесты 4xx не сработают: DioAdapter отдаёт ответ,
/// но не превращает его в DioException с нашим ApiException.
Dio _buildTestDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8080/api',
      validateStatus: (s) => s != null && s < 500,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onResponse: (response, handler) {
        final status = response.statusCode ?? 0;
        if (status >= 400) {
          return handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
              error: mapHttpError(status, response.data),
            ),
            true,
          );
        }
        return handler.next(response);
      },
    ),
  );

  return dio;
}

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late ApiBouquetRepository repo;

  setUp(() {
    dio = _buildTestDio();
    adapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = adapter;
    repo = ApiBouquetRepository(dio);
  });

  group('ApiBouquetRepository.find', () {
    test('успешный разбор ответа с развёрнутыми объектами', () async {
      adapter.onGet(
        '/bouquets',
        (server) => server.reply(200, {
          'items': [
            {
              'id': 1,
              'title': 'Букет нежности',
              'sku': 'FL-100',
              'price': 800,
              'stemCount': 5,
              'supplier': {'id': 1, 'name': 'Цветочная база «Пион»'},
              'categories': [
                {'id': 1, 'name': 'Розы'},
                {'id': 2, 'name': 'Тюльпаны'},
              ],
              'stockTotal': 5,
              'stockAvailable': 1,
              'deletedAt': null,
            },
          ],
          'page': 1,
          'size': 10,
          'total': 1,
          'totalPages': 1,
        }),
        queryParameters: {'sort': 'title,asc', 'page': 1, 'size': 10},
      );

      final result = await repo.find(const BouquetQuery());

      expect(result.items, hasLength(1));
      final b = result.items.first;
      expect(b.id, 1);
      expect(b.title, 'Букет нежности');
      expect(b.sku, 'FL-100');
      expect(b.price, 800);
      expect(b.stemCount, 5);
      expect(b.supplierId, 1);
      expect(b.categoryIds, [1, 2]);
      expect(result.page, 1);
      expect(result.total, 1);
    });
  });

  group('ApiBouquetRepository.find — ошибки', () {
    test('422 → ValidationException с разбором полей', () async {
      adapter.onGet(
        '/bouquets',
        (server) => server.reply(422, {
          'message': 'Ошибка валидации',
          'errors': {
            'sku': 'Букет с таким артикулом уже существует',
            'price': 'Цена не меньше 50',
          },
        }),
        queryParameters: {'sort': 'title,asc', 'page': 1, 'size': 10},
      );

      expect(
        () => repo.find(const BouquetQuery()),
        throwsA(
          isA<ValidationException>()
              .having((e) => e.message, 'message', 'Ошибка валидации')
              .having(
                (e) => e.errors['sku'],
                'sku error',
                'Букет с таким артикулом уже существует',
              )
              .having(
                (e) => e.errors['price'],
                'price error',
                'Цена не меньше 50',
              ),
        ),
      );
    });

    test('404 → NotFoundException', () async {
      adapter.onGet(
        '/bouquets',
        (server) => server.reply(404, {'message': 'Запись не найдена'}),
        queryParameters: {'sort': 'title,asc', 'page': 1, 'size': 10},
      );

      expect(
        () => repo.find(const BouquetQuery()),
        throwsA(
          isA<NotFoundException>().having(
            (e) => e.message,
            'message',
            'Запись не найдена',
          ),
        ),
      );
    });

    test('500 → ServerException', () async {
      adapter.onGet(
        '/bouquets',
        (server) => server.reply(500, {'message': 'Ошибка сервера'}),
        queryParameters: {'sort': 'title,asc', 'page': 1, 'size': 10},
      );

      expect(
        () => repo.find(const BouquetQuery()),
        throwsA(isA<ServerException>()),
      );
    });

    test('сетевой сбой → NetworkException', () async {
      adapter.onGet(
        '/bouquets',
        (server) => server.throws(
          0,
          DioException(
            requestOptions: RequestOptions(path: '/bouquets'),
            type: DioExceptionType.connectionError,
          ),
        ),
        queryParameters: {'sort': 'title,asc', 'page': 1, 'size': 10},
      );

      expect(
        () => repo.find(const BouquetQuery()),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('ApiBouquetRepository.findById', () {
    test('успешный разбор одной записи', () async {
      adapter.onGet(
        '/bouquets/1',
        (server) => server.reply(200, {
          'id': 1,
          'title': 'Букет нежности',
          'sku': 'FL-100',
          'price': 800,
          'stemCount': 5,
          'supplier': {'id': 1, 'name': 'Пион'},
          'categories': [
            {'id': 3, 'name': 'Пионы'},
          ],
          'stockTotal': 5,
          'stockAvailable': 1,
          'deletedAt': null,
        }),
      );

      final b = await repo.findById(1);
      expect(b, isNotNull);
      expect(b!.supplierId, 1);
      expect(b.categoryIds, [3]);
    });
  });

  group('ApiBouquetRepository.create', () {
    test('успешное создание возвращает разобранный объект', () async {
      adapter.onPost(
        '/bouquets',
        (server) => server.reply(201, {
          'id': 25,
          'title': 'Тестовый букет',
          'sku': 'FL-999',
          'price': 1000,
          'stemCount': 7,
          'supplier': {'id': 2, 'name': 'Роза ветров'},
          'categories': [
            {'id': 4, 'name': 'Микс'},
          ],
          'stockTotal': 5,
          'stockAvailable': 5,
          'deletedAt': null,
        }),
        data: Matchers.any,
      );

      final created = await repo.create(
        const Bouquet(
          id: 0,
          title: 'Тестовый букет',
          sku: 'FL-999',
          price: 1000,
          stemCount: 7,
          supplierId: 2,
          categoryIds: [4],
          stockTotal: 5,
          stockAvailable: 5,
        ),
      );

      expect(created.id, 25);
      expect(created.supplierId, 2);
      expect(created.categoryIds, [4]);
    });
  });
}
