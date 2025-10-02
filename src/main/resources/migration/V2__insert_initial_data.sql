-- V2__insert_reference_data.sql

-- Вставляем статусы заказов
INSERT INTO order_status (status_name) VALUES
('New'), ('Processing'), ('Shipped'), ('Delivered'), ('Cancelled')
ON CONFLICT DO NOTHING;

-- Вставляем товары
INSERT INTO product (description, price, quantity, category) VALUES
('Laptop', 700, 10, 'Electronics'),
('Smartphone', 500, 20, 'Electronics'),
('Book', 15, 50, 'Books'),
('Desk Chair', 75, 15, 'Furniture'),
('Headphones', 50, 30, 'Electronics'),
('Backpack', 40, 25, 'Accessories'),
('Coffee Maker', 80, 8, 'Kitchen'),
('Gaming Mouse', 25, 40, 'Electronics'),
('Notebook', 4, 100, 'Stationery'),
('Water Bottle', 10, 60, 'Accessories')
ON CONFLICT DO NOTHING;

-- Вставляем клиентов
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
('Natalia', 'Smirnova', '+79061234567', 'natalia@mail.com');