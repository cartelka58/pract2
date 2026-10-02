import '../models/models.dart';

final seedCategories = <Category>[
  const Category(
    id: 1,
    name: 'Розы',
    description: 'Классические букеты из роз',
  ),
  const Category(id: 2, name: 'Тюльпаны', description: 'Весенние тюльпаны'),
  const Category(id: 3, name: 'Пионы', description: 'Пышные пионы'),
  const Category(id: 4, name: 'Микс', description: 'Смешанные букеты'),
  const Category(id: 5, name: 'Сезонные', description: 'Сезонные цветы'),
];

final seedSuppliers = <Supplier>[
  const Supplier(
    id: 1,
    name: 'Цветочная база «Пион»',
    phone: '+7 495 111-11-11',
    city: 'Москва',
  ),
  const Supplier(
    id: 2,
    name: 'Оранжерея «Роза ветров»',
    phone: '+7 812 222-22-22',
    city: 'Санкт-Петербург',
  ),
  const Supplier(
    id: 3,
    name: 'Голландские поставки',
    phone: '+31 20 333-33-33',
    city: 'Амстердам',
  ),
  const Supplier(
    id: 4,
    name: 'Местная ферма',
    phone: '+7 861 444-44-44',
    city: 'Краснодар',
  ),
];

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

final seedCustomers = <Customer>[
  Customer(
    id: 1,
    firstName: 'Иван',
    lastName: 'Сидоров',
    email: 'ivan@example.com',
    phone: '+7 900 111-22-33',
    card: LoyaltyCard(
      number: 'LC-0001',
      discountPercent: 5,
      issuedAt: DateTime(2023, 3, 15),
    ),
  ),
  Customer(
    id: 2,
    firstName: 'Мария',
    lastName: 'Ковалёва',
    email: 'maria@example.com',
    phone: '+7 900 222-33-44',
    card: LoyaltyCard(
      number: 'LC-0002',
      discountPercent: 10,
      issuedAt: DateTime(2022, 11, 1),
    ),
  ),
  Customer(
    id: 3,
    firstName: 'Пётр',
    lastName: 'Никитин',
    email: 'petr@example.com',
    phone: '+7 900 333-44-55',
  ),
  Customer(
    id: 4,
    firstName: 'Анна',
    lastName: 'Фёдорова',
    email: 'anna@example.com',
    phone: '+7 900 444-55-66',
    card: LoyaltyCard(
      number: 'LC-0003',
      discountPercent: 15,
      issuedAt: DateTime(2021, 6, 20),
    ),
  ),
  Customer(
    id: 5,
    firstName: 'Сергей',
    lastName: 'Попов',
    email: 'sergey@example.com',
    phone: '+7 900 555-66-77',
  ),
  Customer(
    id: 6,
    firstName: 'Елена',
    lastName: 'Орлова',
    email: 'elena@example.com',
    phone: '+7 900 666-77-88',
    card: LoyaltyCard(
      number: 'LC-0004',
      discountPercent: 7,
      issuedAt: DateTime(2024, 1, 10),
    ),
  ),
];
