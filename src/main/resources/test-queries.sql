-- 0. Очистка таблиц для запуска с чистого состояния со сбросом счетчика последовательности.
-- Скрипт полностью очищает указанные таблицы и сбрасывает их автонумерацию ID, чтобы при следующем вставке ID начинался с 1.
-- Идеально подходит при подготовке базы к новым данным или для тестовых сценариев.
truncate table product, customer, order_status, "order" restart identity cascade;

-- 1. (ЧТЕНИЕ) Список всех заказов за последние 7 дней с информацией о клиенте и товаре
select o.id, o.order_date, c.first_name || ' ' || c.last_name as customer_name, p.description as product_description
from "order" o
join customer c on o.customer_id = c.id
join product p on o.product_id = p.id
where o.order_date >= current_date - interval '7 days';

-- 2. (ЧТЕНИЕ) Топ-3 самых популярных товара
select p.description, sum(o.quantity) as total_sold
from "order" o
join product p on o.product_id = p.id
group by p.id
order by total_sold desc
limit 3;

-- 3. (ЧТЕНИЕ) Количество заказов по статусам (агрегат с группировкой)
select
    s.status_name,
    count(*) as order_count
from "order" o
join order_status s on o.status_id = s.id
group by s.status_name
order by order_count desc;

-- 4. (ЧТЕНИЕ) Средняя цена товаров по категориям, отсортировано по убыванию средней цены
select
    category,
    avg(price) as avg_price
from product
group by category
order by avg_price desc;

-- 5. (ЧТЕНИЕ) Детальный список заказов с фильтром по названию товара, отсортировано по дате заказа
select
    o.id as order_id,
    o.order_date,
    c.first_name || ' ' || c.last_name as customer_name,
    p.description,
    o.quantity,
    s.status_name
from "order" o
join customer c on o.customer_id = c.id
join product p on o.product_id = p.id
join order_status s on o.status_id = s.id
where p.description ilike '%Laptop%'  -- поиск товаров с 'Laptop' в названии
order by o.order_date desc;

-- 1. (ИЗМЕНЕНИЕ) Обновление количества товара после покупки
update product
set quantity = quantity - 1
where id = 1 and quantity > 0;
select * from product;

-- 2. (ИЗМЕНЕНИЕ) Обновление данных покупателя по email
update customer
set phone = '+ 79461234567', -- обновляем телефон
    last_name = 'UpdatedLastName'
where email = 'ivanov@mail.com'; -- по уникальному email
select * from customer;

-- 3. (ИЗМЕНЕНИЕ) Обновление статуса заказа по ID
update "order"
set status_id = (select id from order_status where status_name = 'Shipped')
where id = 10;  -- обновить статус заказа с ID равным 10
select * from "order";

-- 1. (УДАЛЕНИЕ) Удаление клиентов без заказов
delete from customer c
where not exists (select 1 from "order" o where o.customer_id = c.id);
select * from customer;

-- 2. (УДАЛЕНИЕ) Удалить заказ по ID
delete from "order"
where id = 9;
select * from "order";