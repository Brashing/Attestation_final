/*
"C:\Users\roman\.jdks\jdk-21.0.7\bin\java.exe" -jar "C:\Users\roman\IdeaProjects\Attestation_final\target\Attestation_final-1.0-SNAPSHOT.jar"
 */
package org.example;

import java.io.InputStream;
import java.math.BigDecimal;
import java.sql.*;
import java.util.Properties;

public class App {
    public static void main(String[] args) {
        // Загрузка конфигурации через classpath
        Properties properties = new Properties();
        try (InputStream in = App.class.getClassLoader().getResourceAsStream("application.properties")) {
            if (in == null) {
                System.out.println("Файл application.properties не найден");
                return;
            }
            properties.load(in);
        } catch (Exception e) {
            e.printStackTrace();
            return;
        }

        String url = properties.getProperty("jdbs.url");
        String user = properties.getProperty("jdbs.user");
        String password = properties.getProperty("jdbs.password");

        // Подключение к БД
        try (Connection conn = DriverManager.getConnection(url, user, password)) {
            System.out.println("Подключение успешно");

            // Начинаем транзакцию
            conn.setAutoCommit(false);

            try {
                // Проверка наличия данных в таблицах
                if (!hasData(conn, "product")) {
                    System.out.println("В таблице product нет данных — завершение.");
                    conn.rollback();
                    return;
                }
                if (!hasData(conn, "customer")) {
                    System.out.println("В таблице customer нет данных — завершение.");
                    conn.rollback();
                    return;
                }
                if (!hasData(conn, "order")) {
                    System.out.println("В таблице \"order\" нет данных — завершение.");
                    conn.rollback();
                    return;
                }

                // 1. Вставка нового товара и покупателя, получение их ID
                int productId, customerId;
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO product (description, price, quantity, category) VALUES (?, ?, ?, ?)",
                        Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, "Новинка");
                    ps.setBigDecimal(2, new BigDecimal("199.99"));
                    ps.setInt(3, 100);
                    ps.setString(4, "Electronics");
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        rs.next();
                        productId = rs.getInt(1);
                    }
                }
                System.out.println("1.1) Добавлен товар ID: " + productId);

                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO customer (first_name, last_name, phone, email) VALUES (?, ?, ?, ?)",
                        Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, "Иван");
                    ps.setString(2, "Иванов");
                    ps.setString(3, "+79991112233");
                    ps.setString(4, "ivanov@mail.com");
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        rs.next();
                        customerId = rs.getInt(1);
                    }
                }
                System.out.println("\n1.2) Создан клиент ID: " + customerId);


                // 2. Создание заказа, используем полученные ID
                int orderId = -1;
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO \"order\" (product_id, customer_id, quantity, status_id) VALUES (?, ?, ?, ?)",
                        Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, productId);
                    ps.setInt(2, customerId);
                    ps.setInt(3, 3);
                    ps.setInt(4, 1); // статус "New", если есть ID=1
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            orderId = rs.getInt(1);
                        }
                    }
                }
                System.out.println("\n2) Создан заказ с ID: " + orderId);

                // 3. Чтение последних 5 заказов
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT o.id, o.order_date, c.first_name, c.last_name, p.description, o.quantity, s.status_name " +
                                "FROM \"order\" o " +
                                "JOIN customer c ON o.customer_id = c.id " +
                                "JOIN product p ON o.product_id = p.id " +
                                "JOIN order_status s ON o.status_id = s.id " +
                                "ORDER BY o.order_date DESC LIMIT 5")) {
                    ResultSet rs = ps.executeQuery();
                    System.out.println("\n3) Вывод 5 последних заказов:");
                    System.out.println("----------------------------------------------------------------------------------------------------------------------");
                    System.out.printf("%-5s | %-26s | %-15s | %-15s | %-20s | %-7s | %-10s%n",
                            "ID", "Дата заказа", "Имя", "Фамилия", "Товар", "Кол-во", "Статус");
                    System.out.println("----------------------------------------------------------------------------------------------------------------------");
                    while (rs.next()) {
                        System.out.printf("%-5d | %-20s | %-15s | %-15s | %-20s | %-7d | %-10s%n",
                                rs.getInt("id"),
                                rs.getString("order_date"),
                                rs.getString("first_name"),
                                rs.getString("last_name"),
                                rs.getString("description"),
                                rs.getInt("quantity"),
                                rs.getString("status_name"));
                    }
                    System.out.println("----------------------------------------------------------------------------------------------------------------------");
                }

                // 4. Обновление цены и количества товара
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE product SET price = price + 10, quantity = quantity + 5 WHERE id = ?")) {
                    ps.setInt(1, productId);
                    int count = ps.executeUpdate();
                    System.out.println("\n4) Обновлено товаров: " + count);
                }

                // 5. Удаление тестового заказа (по ID)
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM \"order\" WHERE id = ?")) {
                    ps.setInt(1, orderId);
                    ps.executeUpdate();
                    System.out.println("\n5) Тестовый заказ №" + orderId + " удален.");
                }

                // Завершаем транзакцию
                conn.commit();
                System.out.println("\nТранзакция завершена успешно");
            } catch (Exception e) {
                conn.rollback();
                System.out.println("\nОткат транзакции из-за ошибки");
                e.printStackTrace();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    private static boolean hasData(Connection conn, String tableName) throws SQLException {
        String query = "SELECT EXISTS (SELECT 1 FROM \"" + tableName + "\")";
        try (Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(query)) {
            rs.next();
            return rs.getBoolean(1);
        }
    }
}