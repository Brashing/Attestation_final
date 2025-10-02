-- V3__insert_sample_orders.sql

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