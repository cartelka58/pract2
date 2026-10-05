#!/usr/bin/env node
/**
 * Мок-сервер учебного API «Цветочный магазин».
 * Адаптация учебного сервера «Библиотека» под предметную область ПР2–ПР4.
 *
 * Запуск:
 *   node mock-server.js --port 8080 --origin http://localhost:5555
 *
 * Учебные возможности:
 *   ?__delay=1500   задержка ответа
 *   ?__fail=500     принудительный код ошибки
 *
 * ВНИМАНИЕ: авторизация отключена — все CRUD-операции доступны без токена.
 * Это сделано для учебных целей ПР4, чтобы не писать экран входа.
 */

'use strict';

const http = require('node:http');
const crypto = require('node:crypto');

// ─────────────────────────── параметры запуска ───────────────────────────

const args = process.argv.slice(2);
function arg(name, fallback) {
  const i = args.indexOf('--' + name);
  return i !== -1 && args[i + 1] ? args[i + 1] : fallback;
}

const PORT = Number(arg('port', 8080));
const ORIGIN = arg('origin', '*');
const SECRET = 'учебный-ключ-не-для-продакшена';
const ACCESS_TTL = Number(arg('ttl', 900));
const REFRESH_TTL = 60 * 60 * 24 * 7;

// ─────────────────────────────── токены ───────────────────────────────

function b64url(buf) {
  return Buffer.from(buf).toString('base64url');
}

function sign(payload) {
  const withId = { ...payload, jti: crypto.randomUUID() };
  const body = b64url(JSON.stringify(withId));
  const mac = crypto.createHmac('sha256', SECRET).update(body).digest('base64url');
  return body + '.' + mac;
}

function verify(token) {
  if (typeof token !== 'string' || !token.includes('.')) return null;
  const [body, mac] = token.split('.');
  const expected = crypto.createHmac('sha256', SECRET).update(body).digest('base64url');
  if (mac !== expected) return null;
  let payload;
  try {
    payload = JSON.parse(Buffer.from(body, 'base64url').toString('utf8'));
  } catch {
    return null;
  }
  if (payload.exp && payload.exp * 1000 < Date.now()) return null;
  return payload;
}

// ─────────────────────────────── данные ───────────────────────────────

let db;

function seed() {
  db = {
    seq: {},
    categories: [],
    suppliers: [],
    florists: [],
    bouquets: [],
    customers: [],
    loyaltyCards: [],
    users: [],
    refreshTokens: new Set(),
  };

  const C = (name, description) => push('categories', { name, description });
  const S = (name, phone, city) => push('suppliers', { name, phone, city });
  const F = (firstName, lastName, city, experienceYear) =>
    push('florists', { firstName, lastName, city, experienceYear });

  const roses = C('Розы', 'Классические букеты из роз');
  const tulips = C('Тюльпаны', 'Весенние тюльпаны');
  const peonies = C('Пионы', 'Пышные пионы');
  const mix = C('Микс', 'Смешанные букеты');
  const seasonal = C('Сезонные', 'Сезонные цветы');

  const pion = S('Цветочная база «Пион»', '+7 495 111-11-11', 'Москва');
  const rosa = S('Оранжерея «Роза ветров»', '+7 812 222-22-22', 'Санкт-Петербург');
  const holland = S('Голландские поставки', '+31 20 333-33-33', 'Амстердам');
  const local = S('Местная ферма', '+7 861 444-44-44', 'Краснодар');

  F('Анна', 'Иванова', 'Москва', 2015);
  F('Мария', 'Петрова', 'Санкт-Петербург', 2012);
  F('Ольга', 'Смирнова', 'Казань', 2018);
  F('Екатерина', 'Кузнецова', 'Новосибирск', 2010);
  F('Дарья', 'Соколова', 'Екатеринбург', 2019);
  F('Ирина', 'Морозова', 'Москва', 2016);
  F('Светлана', 'Новикова', 'Краснодар', 2013);
  F('Татьяна', 'Волкова', 'Сочи', 2020);

  const B = (title, sku, price, stemCount, supplierId, categoryIds, stockTotal, stockAvailable) =>
    push('bouquets', {
      title, sku, price, stemCount, supplierId, categoryIds,
      stockTotal, stockAvailable,
    });

  const titles = [
    'Букет нежности', 'Розовое утро', 'Весенний ветер', 'Пионовый рай',
    'Тюльпанный сад', 'Романтичный вечер', 'Свадебный шик', 'Летнее настроение',
    'Осенний вальс', 'Нежная лаванда', 'Красная страсть', 'Белый танец',
    'Солнечный луч', 'Ромашковое поле', 'Французский поцелуй', 'Миланский день',
    'Изумрудный сад', 'Персиковый закат', 'Хрустальный дождь', 'Лунная соната',
    'Императорский', 'Сказка фей',
  ];
  const suppliers = [pion, rosa, holland, local];
  const categories = [roses, tulips, peonies, mix, seasonal];

  titles.forEach((title, i) => {
    B(
      title,
      'FL-' + String(100 + i).padStart(3, '0'),
      800 + (i * 137) % 4200,
      5 + (i * 3) % 45,
      suppliers[i % 4],
      [categories[i % 5]],
      5 + (i % 10),
      1 + (i % 5),
    );
  });

  const customers = [
    { firstName: 'Иван', lastName: 'Сидоров', email: 'ivan@example.com', phone: '+7 900 111-22-33', card: { number: 'LC-0001', discountPercent: 5, issuedAt: iso(2023, 3, 15) } },
    { firstName: 'Мария', lastName: 'Ковалёва', email: 'maria@example.com', phone: '+7 900 222-33-44', card: { number: 'LC-0002', discountPercent: 10, issuedAt: iso(2022, 11, 1) } },
    { firstName: 'Пётр', lastName: 'Никитин', email: 'petr@example.com', phone: '+7 900 333-44-55', card: null },
    { firstName: 'Анна', lastName: 'Фёдорова', email: 'anna@example.com', phone: '+7 900 444-55-66', card: { number: 'LC-0003', discountPercent: 15, issuedAt: iso(2021, 6, 20) } },
    { firstName: 'Сергей', lastName: 'Попов', email: 'sergey@example.com', phone: '+7 900 555-66-77', card: null },
    { firstName: 'Елена', lastName: 'Орлова', email: 'elena@example.com', phone: '+7 900 666-77-88', card: { number: 'LC-0004', discountPercent: 7, issuedAt: iso(2024, 1, 10) } },
  ];

  customers.forEach((c) => {
    const customerId = push('customers', {
      firstName: c.firstName,
      lastName: c.lastName,
      email: c.email,
      phone: c.phone,
    });
    if (c.card) {
      push('loyaltyCards', {
        customerId: customerId,
        number: c.card.number,
        discountPercent: c.card.discountPercent,
        issuedAt: c.card.issuedAt,
      });
    }
  });

  push('users', { username: 'admin', passwordHash: hash('admin123'), fullName: 'Администратор', email: 'admin@shop.local', role: 'admin', customerId: null });
  push('users', { username: 'florist', passwordHash: hash('florist123'), fullName: 'Иванова А. П.', email: 'florist@shop.local', role: 'florist', customerId: null });
  push('users', { username: 'customer', passwordHash: hash('customer123'), fullName: 'Сидоров И. А.', email: 'ivan@example.com', role: 'customer', customerId: 1 });
}

function push(collection, obj) {
  db.seq[collection] = (db.seq[collection] || 0) + 1;
  const id = db.seq[collection];
  db[collection].push({ id, ...obj, createdAt: new Date().toISOString(), deletedAt: null });
  return id;
}

function iso(y, m, d) {
  return new Date(Date.UTC(y, m - 1, d)).toISOString();
}

function hash(password) {
  return crypto.createHash('sha256').update(password + SECRET).digest('hex');
}

// ──────────────────────── развёртывание объектов ────────────────────────

function slimSupplier(id) {
  const s = db.suppliers.find((x) => x.id === id);
  return s ? { id: s.id, name: s.name } : null;
}

function slimCategory(id) {
  const c = db.categories.find((x) => x.id === id);
  return c ? { id: c.id, name: c.name } : null;
}

function expandBouquet(b) {
  return {
    id: b.id,
    title: b.title,
    sku: b.sku,
    price: b.price,
    stemCount: b.stemCount,
    supplier: slimSupplier(b.supplierId),
    categories: (b.categoryIds || []).map(slimCategory).filter(Boolean),
    stockTotal: b.stockTotal,
    stockAvailable: b.stockAvailable,
    createdAt: b.createdAt,
    deletedAt: b.deletedAt,
  };
}

function expandCustomer(c) {
  const card = db.loyaltyCards.find((x) => x.customerId === c.id && !x.deletedAt);
  return {
    id: c.id,
    firstName: c.firstName,
    lastName: c.lastName,
    email: c.email,
    phone: c.phone,
    card: card
      ? { id: card.id, number: card.number, discountPercent: card.discountPercent, issuedAt: card.issuedAt }
      : null,
    createdAt: c.createdAt,
    deletedAt: c.deletedAt,
  };
}

function expandUser(u) {
  return { id: u.id, username: u.username, fullName: u.fullName, email: u.email, role: u.role, customerId: u.customerId };
}

const EXPANDERS = {
  bouquets: expandBouquet,
  customers: expandCustomer,
  florists: (f) => f,
  categories: (c) => c,
  suppliers: (s) => s,
};

// ─────────────────────────── общие операции ───────────────────────────

function searchableText(collection, item) {
  switch (collection) {
    case 'bouquets': return [item.title, item.sku].join(' ');
    case 'florists': return [item.firstName, item.lastName, item.city].join(' ');
    case 'categories': return [item.name, item.description].join(' ');
    case 'suppliers': return [item.name, item.city, item.phone].join(' ');
    case 'customers': return [item.firstName, item.lastName, item.email, item.phone].join(' ');
    default: return '';
  }
}

function applyFilters(collection, rows, q) {
  let result = rows;

  if (q.search) {
    const needle = String(q.search).toLowerCase();
    result = result.filter((x) => searchableText(collection, x).toLowerCase().includes(needle));
  }

  if (collection === 'bouquets') {
    if (q.categoryId) result = result.filter((b) => (b.categoryIds || []).includes(Number(q.categoryId)));
    if (q.supplierId) result = result.filter((b) => b.supplierId === Number(q.supplierId));
    if (q.priceFrom) result = result.filter((b) => b.price >= Number(q.priceFrom));
    if (q.priceTo) result = result.filter((b) => b.price <= Number(q.priceTo));
  }

  return result;
}

function applySort(rows, sort) {
  if (!sort) return rows;
  const [field, dirRaw] = String(sort).split(',');
  const dir = (dirRaw || 'asc').toLowerCase() === 'desc' ? -1 : 1;
  return [...rows].sort((a, b) => {
    const av = a[field];
    const bv = b[field];
    if (av == null && bv == null) return 0;
    if (av == null) return 1;
    if (bv == null) return -1;
    if (typeof av === 'number' && typeof bv === 'number') return (av - bv) * dir;
    return String(av).localeCompare(String(bv), 'ru') * dir;
  });
}

function paginate(rows, q) {
  const page = Math.max(1, Number(q.page) || 1);
  const size = Math.min(100, Math.max(1, Number(q.size) || 10));
  const total = rows.length;
  const totalPages = Math.max(1, Math.ceil(total / size));
  return { items: rows.slice((page - 1) * size, page * size), page, size, total, totalPages };
}

// ─────────────────────────────── валидация ───────────────────────────────

function validate(collection, body, id = null) {
  const e = {};
  const str = (v) => (typeof v === 'string' ? v.trim() : '');
  const num = (v) => (v == null || v === '' ? null : Number(v));

  if (collection === 'bouquets') {
    if (!str(body.title)) e.title = 'Укажите название';
    else if (str(body.title).length > 200) e.title = 'Не длиннее 200 символов';
    if (!str(body.sku)) e.sku = 'Укажите артикул';
    else {
      const dup = db.bouquets.find((b) => b.sku === str(body.sku) && b.id !== id && !b.deletedAt);
      if (dup) e.sku = 'Букет с таким артикулом уже существует';
    }
    const price = num(body.price);
    if (price == null || price < 50) e.price = 'Цена не меньше 50';
    else if (price > 1000000) e.price = 'Цена не больше 1 000 000';
    const stem = num(body.stemCount);
    if (stem == null || !Number.isInteger(stem) || stem < 1) e.stemCount = 'Число стеблей — положительное целое';
    if (body.supplierId != null && !db.suppliers.find((s) => s.id === Number(body.supplierId) && !s.deletedAt)) {
      e.supplierId = 'Поставщик не найден';
    }
    if (body.stockTotal != null) {
      const t = num(body.stockTotal);
      if (t != null && (!Number.isInteger(t) || t < 0)) e.stockTotal = 'Всего на складе — целое, не меньше нуля';
    }
  }

  if (collection === 'florists') {
    if (!str(body.firstName)) e.firstName = 'Укажите имя';
    if (!str(body.lastName)) e.lastName = 'Укажите фамилию';
    if (body.experienceYear != null) {
      const y = num(body.experienceYear);
      if (!Number.isInteger(y) || y < 1950 || y > new Date().getFullYear()) e.experienceYear = 'Некорректный год';
    }
  }

  if (collection === 'categories') {
    if (!str(body.name)) e.name = 'Укажите название категории';
    else {
      const dup = db.categories.find((c) => c.name.toLowerCase() === str(body.name).toLowerCase() && c.id !== id && !c.deletedAt);
      if (dup) e.name = 'Такая категория уже существует';
    }
  }

  if (collection === 'suppliers') {
    if (!str(body.name)) e.name = 'Укажите название поставщика';
    if (!str(body.phone)) e.phone = 'Укажите телефон';
  }

  if (collection === 'customers') {
    if (!str(body.firstName)) e.firstName = 'Укажите имя';
    if (!str(body.lastName)) e.lastName = 'Укажите фамилию';
    if (!str(body.email)) e.email = 'Укажите адрес почты';
    else if (!/^[\w.+-]+@[\w-]+\.[\w.-]+$/.test(str(body.email))) e.email = 'Некорректный адрес почты';
    else {
      const dup = db.customers.find((c) => c.email === str(body.email) && c.id !== id && !c.deletedAt);
      if (dup) e.email = 'Покупатель с такой почтой уже зарегистрирован';
    }
  }

  return e;
}

// ──────────────────────────── HTTP-обвязка ────────────────────────────

function cors(res) {
  res.setHeader('Access-Control-Allow-Origin', ORIGIN);
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.setHeader('Access-Control-Max-Age', '86400');
  res.setHeader('Vary', 'Origin');
}

function send(res, status, payload) {
  cors(res);
  if (payload === undefined || status === 204) {
    res.writeHead(204);
    res.end();
    return;
  }
  const body = JSON.stringify(payload, null, 2);
  res.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Content-Length': Buffer.byteLength(body),
  });
  res.end(body);
}

function fail(res, status, message) {
  send(res, status, { message });
}

async function readBody(req) {
  const chunks = [];
  for await (const chunk of req) chunks.push(chunk);
  if (!chunks.length) return {};
  try {
    return JSON.parse(Buffer.concat(chunks).toString('utf8'));
  } catch {
    return null;
  }
}

function currentUser(req) {
  const header = req.headers['authorization'] || '';
  if (!header.startsWith('Bearer ')) return null;
  const payload = verify(header.slice(7));
  if (!payload || payload.type !== 'access') return null;
  return db.users.find((u) => u.id === payload.sub && !u.deletedAt) || null;
}

/// ВНИМАНИЕ: авторизация отключена для учебных целей ПР4.
/// Все CRUD-операции разрешены без токена. В реальном проекте так нельзя.
function requireRole(res, user, minRole) {
  return true;
}

const COLLECTIONS = ['bouquets', 'florists', 'categories', 'suppliers', 'customers'];

// ─────────────────────────────── маршруты ───────────────────────────────

async function handle(req, res, url) {
  const q = Object.fromEntries(url.searchParams.entries());
  const path = url.pathname.replace(/\/+$/, '') || '/';
  const method = req.method.toUpperCase();
  const user = currentUser(req);

  if (q.__fail) {
    return fail(res, Number(q.__fail), 'Ошибка вызвана намеренно параметром __fail');
  }

  if (path === '/api/__reset' && method === 'POST') {
    seed();
    return send(res, 200, { message: 'Данные восстановлены' });
  }

  if (path === '/api/__health' && method === 'GET') {
    return send(res, 200, { status: 'ok', time: new Date().toISOString() });
  }

  // ── аутентификация ──
  if (path === '/api/auth/login' && method === 'POST') {
    const body = await readBody(req);
    if (!body) return fail(res, 400, 'Тело запроса не является корректным JSON');

    const found = db.users.find(
      (u) => u.username === String(body.username || '').trim() && !u.deletedAt
    );
    if (!found || found.passwordHash !== hash(String(body.password || ''))) {
      return fail(res, 401, 'Неверный логин или пароль');
    }

    const now = Math.floor(Date.now() / 1000);
    const accessToken = sign({ sub: found.id, role: found.role, type: 'access', exp: now + ACCESS_TTL });
    const refreshToken = sign({ sub: found.id, type: 'refresh', exp: now + REFRESH_TTL });
    db.refreshTokens.add(refreshToken);

    return send(res, 200, {
      accessToken, refreshToken, expiresIn: ACCESS_TTL,
      user: expandUser(found),
    });
  }

  if (path === '/api/auth/me' && method === 'GET') {
    if (!user) return fail(res, 401, 'Требуется аутентификация');
    return send(res, 200, expandUser(user));
  }

  if (path === '/api/auth/logout' && method === 'POST') {
    const body = await readBody(req);
    if (body && body.refreshToken) db.refreshTokens.delete(body.refreshToken);
    return send(res, 204);
  }

  // ── единообразный CRUD ──
  const bulk = path.match(/^\/api\/([a-z]+)\/bulk-delete$/);
  const m = path.match(/^\/api\/([a-z]+)(?:\/(\d+))?(?:\/(restore))?$/);

  if (bulk && method === 'POST') {
    const collection = bulk[1];
    if (!COLLECTIONS.includes(collection)) return fail(res, 404, 'Ресурс не найден');

    const body = await readBody(req);
    const ids = Array.isArray(body && body.ids) ? body.ids.map(Number) : [];
    if (!ids.length) return send(res, 422, { message: 'Ошибка валидации', errors: { ids: 'Передайте непустой список идентификаторов' } });

    let deleted = 0;
    for (const row of db[collection]) {
      if (ids.includes(row.id) && !row.deletedAt) {
        row.deletedAt = new Date().toISOString();
        deleted += 1;
      }
    }
    return send(res, 200, { deleted });
  }

  if (m) {
    const collection = m[1];
    const id = m[2] ? Number(m[2]) : null;
    const action = m[3] || null;

    if (!COLLECTIONS.includes(collection)) return fail(res, 404, 'Ресурс не найден');
    const expand = EXPANDERS[collection];

    if (action === 'restore' && method === 'POST') {
      const row = db[collection].find((x) => x.id === id);
      if (!row) return fail(res, 404, 'Объект не найден');
      row.deletedAt = null;
      return send(res, 200, expand(row));
    }

    if (id === null && method === 'GET') {
      let rows = db[collection];
      if (q.includeDeleted !== 'true') rows = rows.filter((x) => !x.deletedAt);
      rows = applyFilters(collection, rows, q);
      rows = applySort(rows, q.sort);
      const page = paginate(rows, q);
      return send(res, 200, { ...page, items: page.items.map(expand) });
    }

    if (id !== null && method === 'GET') {
      const row = db[collection].find((x) => x.id === id && (q.includeDeleted === 'true' || !x.deletedAt));
      if (!row) return fail(res, 404, 'Объект не найден');
      return send(res, 200, expand(row));
    }

    if (id === null && method === 'POST') {
      const body = await readBody(req);
      if (!body) return fail(res, 400, 'Тело запроса не является корректным JSON');

      const errors = validate(collection, body);
      if (Object.keys(errors).length) return send(res, 422, { message: 'Ошибка валидации', errors });

      const data = normalize(collection, body);
      const newId = push(collection, data);
      const row = db[collection].find((x) => x.id === newId);
      return send(res, 201, expand(row));
    }

    if (id !== null && (method === 'PUT' || method === 'PATCH')) {
      const row = db[collection].find((x) => x.id === id && !x.deletedAt);
      if (!row) return fail(res, 404, 'Объект не найден');

      const body = await readBody(req);
      if (!body) return fail(res, 400, 'Тело запроса не является корректным JSON');

      const merged = method === 'PATCH' ? { ...row, ...body } : body;
      const errors = validate(collection, merged, id);
      if (Object.keys(errors).length) return send(res, 422, { message: 'Ошибка валидации', errors });

      Object.assign(row, normalize(collection, merged));
      return send(res, 200, expand(row));
    }

    if (id !== null && method === 'DELETE') {
      const hard = q.hard === 'true';

      const index = db[collection].findIndex((x) => x.id === id);
      if (index === -1) return fail(res, 404, 'Объект не найден');

      if (hard) {
        // Проверки целостности
        if (collection === 'suppliers') {
          const linked = db.bouquets.filter((b) => b.supplierId === id && !b.deletedAt).length;
          if (linked > 0) return fail(res, 409, `Нельзя удалить: с поставщиком связано ${linked} букетов`);
        }
        if (collection === 'categories') {
          const linked = db.bouquets.filter((b) => (b.categoryIds || []).includes(id) && !b.deletedAt).length;
          if (linked > 0) return fail(res, 409, `Нельзя удалить: с категорией связано ${linked} букетов`);
        }
        db[collection].splice(index, 1);
      } else {
        // Логическое удаление тоже проверяет связи у поставщиков
        if (collection === 'suppliers') {
          const linked = db.bouquets.filter((b) => b.supplierId === id && !b.deletedAt).length;
          if (linked > 0) return fail(res, 409, `Нельзя удалить: с поставщиком связано ${linked} букетов`);
        }
        db[collection][index].deletedAt = new Date().toISOString();
      }
      return send(res, 204);
    }
  }

  return fail(res, 404, `Адрес ${method} ${path} не обслуживается`);
}

function normalize(collection, body) {
  const num = (v) => (v == null || v === '' ? null : Number(v));
  const str = (v) => (v == null ? '' : String(v).trim());
  const ids = (v) => (Array.isArray(v) ? v.map(Number).filter((n) => Number.isInteger(n)) : []);

  switch (collection) {
    case 'bouquets':
      return {
        title: str(body.title),
        sku: str(body.sku),
        price: num(body.price) ?? 0,
        stemCount: num(body.stemCount) ?? 0,
        supplierId: num(body.supplierId),
        categoryIds: ids(body.categoryIds),
        stockTotal: num(body.stockTotal) ?? 0,
        stockAvailable: num(body.stockAvailable) ?? 0,
      };
    case 'florists':
      return {
        firstName: str(body.firstName),
        lastName: str(body.lastName),
        city: str(body.city),
        experienceYear: num(body.experienceYear),
      };
    case 'categories':
      return { name: str(body.name), description: str(body.description) };
    case 'suppliers':
      return { name: str(body.name), phone: str(body.phone), city: str(body.city) };
    case 'customers':
      return {
        firstName: str(body.firstName),
        lastName: str(body.lastName),
        email: str(body.email),
        phone: str(body.phone),
      };
    default:
      return { ...body };
  }
}

// ─────────────────────────────── запуск ───────────────────────────────

seed();

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);

  if (req.method === 'OPTIONS') {
    cors(res);
    res.writeHead(204);
    return res.end();
  }

  const delay = Number(url.searchParams.get('__delay') || 0);
  if (delay > 0) await new Promise((r) => setTimeout(r, Math.min(delay, 10000)));

  const started = Date.now();
  try {
    await handle(req, res, url);
  } catch (err) {
    console.error(err);
    if (!res.headersSent) fail(res, 500, 'Внутренняя ошибка сервера: ' + err.message);
  }
  console.log(
    `${req.method.padEnd(6)} ${url.pathname}${url.search}  → ${res.statusCode}  ${Date.now() - started} мс`
  );
});

server.listen(PORT, () => {
  console.log('');
  console.log('  Мок-сервер «Цветочный магазин»');
  console.log(`  Адрес:              http://localhost:${PORT}/api`);
  console.log(`  Разрешённый источник: ${ORIGIN}`);
  console.log('');
  console.log('  ⚠️  Авторизация ОТКЛЮЧЕНА — все CRUD-операции без токена');
  console.log('');
  console.log('  Сброс данных:    POST /api/__reset');
  console.log('  Задержка ответа: любой запрос с ?__delay=1500');
  console.log('  Ошибка по требованию: любой запрос с ?__fail=500');
  console.log('');
});