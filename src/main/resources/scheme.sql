-- очистка таблиц для запуска с чистого состояния со сбросом счетчика последовательности
TRUNCATE TABLE product, customer, order_status, "order" RESTART IDENTITY CASCADE;

SELECT * FROM product;
SELECT * FROM order_status;
SELECT * FROM customer;
SELECT * FROM "order";

-- Таблица статусов заказов
CREATE TABLE IF NOT EXISTS order_status (
    id SERIAL PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL
);

-- Вставка статусов
INSERT INTO order_status (status_name) VALUES
('New'),
('Processing'),
('Shipped'),
('Delivered'),
('Cancelled')
ON CONFLICT DO NOTHING;

-- Таблица товаров
CREATE TABLE IF NOT EXISTS product (
    id SERIAL PRIMARY KEY,
    description TEXT NOT NULL,
    price NUMERIC(10, 2) CHECK (price >= 0),
    quantity INT CHECK (quantity >= 0),
    category VARCHAR(50) NOT NULL
);

-- Вставка товаров
INSERT INTO product (description, price, quantity, category) VALUES
('Laptop', 700.00, 10, 'Electronics'),
('Smartphone', 500.00, 20, 'Electronics'),
('Book', 15.00, 50, 'Books'),
('Desk Chair', 75.00, 15, 'Furniture'),
('Headphones', 50.00, 30, 'Electronics'),
('Backpack', 40.00, 25, 'Accessories'),
('Coffee Maker', 80.00, 8, 'Kitchen'),
('Gaming Mouse', 25.00, 40, 'Electronics'),
('Notebook', 4.00, 100, 'Stationery'),
('Water Bottle', 10.00, 60, 'Accessories');

-- Таблица клиентов
CREATE TABLE IF NOT EXISTS customer (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100)
);

-- Вставка клиентов
INSERT INTO customer (first_name, last_name, phone, email) VALUES
('Ivan', 'Ivanov', '+79161234567', 'ivanov@mail.com'),
('Maria', 'Petrova', '+79261234567', 'petrova@mail.com'),
('Alex', 'Kuznetsov', '+79361234567', 'alex@mail.com'),
('Anna', 'Sidorova', '+79461234567', 'anna@mail.com'),
('Sergey', 'Fedorov', '+79561234567', 'sergey@mail.com'),
('Olga', 'Morozova', '+79661234567', 'olga@mail.com'),
('Dmitry', 'Semenov', '+79761234567', 'dmitry@mail.com'),
('Elena', 'Ivanova', '+79861234567', 'elena@mail.com'),
('Andrey', 'Volkov', '+79961234567', 'andrey@mail.com'),
('Natalia', 'Smirnova', '+79061234567', 'natalia@mail.com')


-- Таблица заказов
CREATE TABLE IF NOT EXISTS "order" (
    id SERIAL PRIMARY KEY,
    product_id INT NOT NULL REFERENCES product(id) ON DELETE CASCADE,
    customer_id INT NOT NULL REFERENCES customer(id) ON DELETE CASCADE,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    quantity INT CHECK (quantity >= 0),
    status_id INT NOT NULL REFERENCES order_status(id)
);

-- Вставка заказов
INSERT INTO "order" (product_id, customer_id, order_date, quantity, status_id) VALUES
(1, 1, NOW() - INTERVAL '2 days', 1, 1),
(2, 2, NOW() - INTERVAL '1 day', 2, 2),
(3, 3, NOW(), 3, 3),
(4, 4, NOW() - INTERVAL '3 days', 1, 2),
(5, 5, NOW() - INTERVAL '5 days', 2, 4),
(6, 6, NOW() - INTERVAL '7 days', 1, 1),
(7, 7, NOW() - INTERVAL '4 days', 1, 5),
(8, 8, NOW() - INTERVAL '6 days', 2, 3),
(9, 9, NOW() - INTERVAL '2 days', 5, 2),
(10, 10, NOW() - INTERVAL '1 day', 10, 1);

-- Индексы для быстрого поиска
CREATE INDEX IF NOT EXISTS idx_order_date ON "order" (order_date);
CREATE INDEX IF NOT EXISTS idx_order_customer ON "order" (customer_id);
CREATE INDEX IF NOT EXISTS idx_order_product ON "order" (product_id);

