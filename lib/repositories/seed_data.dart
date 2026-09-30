import '../models/models.dart';

const kCategories = <int, String>{
  1: 'Розы',
  2: 'Тюльпаны',
  3: 'Пионы',
  4: 'Микс',
  5: 'Сезонные',
};

const kSuppliers = <int, String>{
  1: 'Цветочная база «Пион»',
  2: 'Оранжерея «Роза ветров»',
  3: 'Голландские поставки',
  4: 'Местная ферма',
};

final seedFlorists = <Florist>[
  const Florist(
    id: 1,
    firstName: 'Анна',
    lastName: 'Иванова',
    city: 'Москва',
    experienceYear: 2015,
  ),
  const Florist(
    id: 2,
    firstName: 'Мария',
    lastName: 'Петрова',
    city: 'Санкт-Петербург',
    experienceYear: 2012,
  ),
  const Florist(
    id: 3,
    firstName: 'Ольга',
    lastName: 'Смирнова',
    city: 'Казань',
    experienceYear: 2018,
  ),
  const Florist(
    id: 4,
    firstName: 'Екатерина',
    lastName: 'Кузнецова',
    city: 'Новосибирск',
    experienceYear: 2010,
  ),
  const Florist(
    id: 5,
    firstName: 'Дарья',
    lastName: 'Соколова',
    city: 'Екатеринбург',
    experienceYear: 2019,
  ),
  const Florist(
    id: 6,
    firstName: 'Ирина',
    lastName: 'Морозова',
    city: 'Москва',
    experienceYear: 2016,
  ),
  const Florist(
    id: 7,
    firstName: 'Светлана',
    lastName: 'Новикова',
    city: 'Краснодар',
    experienceYear: 2013,
  ),
  const Florist(
    id: 8,
    firstName: 'Татьяна',
    lastName: 'Волкова',
    city: 'Сочи',
    experienceYear: 2020,
  ),
];

final seedBouquets = List<Bouquet>.generate(22, (i) {
  const titles = [
    'Букет нежности',
    'Розовое утро',
    'Весенний ветер',
    'Пионовый рай',
    'Тюльпанный сад',
    'Романтичный вечер',
    'Свадебный шик',
    'Летнее настроение',
    'Осенний вальс',
    'Нежная лаванда',
    'Красная страсть',
    'Белый танец',
    'Солнечный луч',
    'Ромашковое поле',
    'Французский поцелуй',
    'Миланский день',
    'Изумрудный сад',
    'Персиковый закат',
    'Хрустальный дождь',
    'Лунная соната',
    'Императорский',
    'Сказка фей',
  ];
  return Bouquet(
    id: i + 1,
    title: titles[i],
    sku: 'FL-${(100 + i).toString().padLeft(3, '0')}',
    price: 800 + (i * 137) % 4200,
    stemCount: 5 + (i * 3) % 45,
    supplierId: (i % 4) + 1,
    categoryIds: [(i % 5) + 1],
    stockTotal: 5 + (i % 10),
    stockAvailable: 1 + (i % 5),
  );
});
