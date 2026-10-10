import 'package:flutter_test/flutter_test.dart';
import 'package:library_web/models/models.dart';

void main() {
  group('Role — уровни ролей', () {
    test('уровень customer меньше уровня florist', () {
      expect(Role.customer.level, lessThan(Role.florist.level));
    });

    test('уровень florist меньше уровня admin', () {
      expect(Role.florist.level, lessThan(Role.admin.level));
    });

    test('admin имеет максимальный уровень', () {
      expect(Role.admin.level, 3);
    });
  });

  group('Role.fromApi', () {
    test('строка "admin" превращается в Role.admin', () {
      expect(Role.fromApi('admin'), Role.admin);
    });

    test('строка "florist" превращается в Role.florist', () {
      expect(Role.fromApi('florist'), Role.florist);
    });

    test('строка "customer" превращается в Role.customer', () {
      expect(Role.fromApi('customer'), Role.customer);
    });

    test('неизвестная строка превращается в Role.customer', () {
      expect(Role.fromApi('unknown'), Role.customer);
      expect(Role.fromApi(null), Role.customer);
    });
  });

  group('AppUser — проверка прав', () {
    AppUser userWith(Role role) => AppUser(
      id: 1,
      username: 'test',
      fullName: 'Тест Тестов',
      email: 'test@example.com',
      role: role,
    );

    test('customer имеет доступ только к customer-операциям', () {
      final user = userWith(Role.customer);
      expect(user.role.level >= Role.customer.level, true);
      expect(user.role.level >= Role.florist.level, false);
      expect(user.role.level >= Role.admin.level, false);
    });

    test('florist имеет доступ к florist- и customer-операциям', () {
      final user = userWith(Role.florist);
      expect(user.role.level >= Role.customer.level, true);
      expect(user.role.level >= Role.florist.level, true);
      expect(user.role.level >= Role.admin.level, false);
    });

    test('admin имеет доступ ко всем операциям', () {
      final user = userWith(Role.admin);
      expect(user.role.level >= Role.customer.level, true);
      expect(user.role.level >= Role.florist.level, true);
      expect(user.role.level >= Role.admin.level, true);
    });
  });

  group('Role.title', () {
    test('у каждой роли есть отображаемое имя', () {
      expect(Role.customer.title, isNotEmpty);
      expect(Role.florist.title, isNotEmpty);
      expect(Role.admin.title, isNotEmpty);
    });

    test('admin.title = «Администратор»', () {
      expect(Role.admin.title, 'Администратор');
    });

    test('florist.title = «Флорист»', () {
      expect(Role.florist.title, 'Флорист');
    });

    test('customer.title = «Покупатель»', () {
      expect(Role.customer.title, 'Покупатель');
    });
  });
}
