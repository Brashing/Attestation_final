-- V1__create_schema.sql

-- Создать схему, если не существует
CREATE SCHEMA IF NOT EXISTS product;
SET search_path = 'product';

-- Таблица товаров
CREATE TABLE IF NOT EXISTS product
(
    id SERIAL PRIMARY KEY,
    description TEXT NOT NULL,
    price NUMERIC(10, 2) CHECK (price >= 0),
    quantity INT CHECK (quantity >= 0),
    category VARCHAR(50) NOT NULL
);

-- Таблица клиентов
CREATE TABLE IF NOT EXISTS customer (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100)
);

-- Таблица статусов заказов
CREATE TABLE IF NOT EXISTS order_status
(
    id SERIAL PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL
);

-- Таблица заказов
CREATE TABLE IF NOT EXISTS "order" (
    id SERIAL PRIMARY KEY,
    product_id INT NOT NULL REFERENCES product(id) ON DELETE CASCADE,
    customer_id INT NOT NULL REFERENCES customer(id) ON DELETE CASCADE,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    quantity INT CHECK (quantity >= 0),
    status_id INT NOT NULL REFERENCES order_status(id)
);

-- Индексы для быстрого поиска
CREATE INDEX IF NOT EXISTS idx_order_order_date ON "order" (order_date);
CREATE INDEX IF NOT EXISTS idx_order_customer ON "order" (customer_id);
CREATE INDEX IF NOT EXISTS idx_order_product ON "order" (product_id);

---- очистка таблиц для запуска с чистого состояния со сбросом счетчика последовательности
--TRUNCATE TABLE product, customer, order_status, "order" RESTART IDENTITY CASCADE;