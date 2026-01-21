/* =========================================================
   PROJECT: Nota Makanan & Minuman (Restoran + Takeaway)
   DBMS   : MySQL 8+
   Author : (isi nama kelompokmu)
   ========================================================= */

-- Biar gampang rerun (sesuai ketentuan file sql harus bisa dijalankan ulang)
DROP DATABASE IF EXISTS db_nota_resto;
CREATE DATABASE db_nota_resto
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE db_nota_resto;

SET sql_safe_updates = 0;

-- =========================================================
-- 1) DDL: TABLE MASTER
-- =========================================================

CREATE TABLE roles (
  role_id INT AUTO_INCREMENT PRIMARY KEY,
  role_name VARCHAR(30) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  role_id INT NOT NULL,
  full_name VARCHAR(80) NOT NULL,
  username VARCHAR(40) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_users_role
    FOREIGN KEY (role_id) REFERENCES roles(role_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE dining_tables (
  table_id INT AUTO_INCREMENT PRIMARY KEY,
  table_no VARCHAR(10) NOT NULL UNIQUE,
  is_active TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  category_id INT NOT NULL,
  product_name VARCHAR(120) NOT NULL,
  unit VARCHAR(20) NOT NULL DEFAULT 'porsi',
  base_price DECIMAL(12,2) NOT NULL CHECK (base_price >= 0),
  stock_qty INT NOT NULL DEFAULT 0 CHECK (stock_qty >= 0),
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_products_category
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX idx_products_category ON products(category_id);

-- =========================================================
-- 2) DDL: TRANSAKSI / NOTA
-- =========================================================

CREATE TABLE orders (
  order_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_no VARCHAR(30) NOT NULL UNIQUE,
  order_type ENUM('DINE_IN','TAKEAWAY') NOT NULL,
  table_id INT NULL,
  user_id INT NOT NULL,
  customer_name VARCHAR(80) NULL,
  order_datetime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status ENUM('DRAFT','PAID','CANCELLED') NOT NULL DEFAULT 'DRAFT',

  subtotal DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (subtotal >= 0),
  discount_amount DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (discount_amount >= 0),
  tax_amount DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (tax_amount >= 0),
  total DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (total >= 0),

  note VARCHAR(255) NULL,

  CONSTRAINT fk_orders_table
    FOREIGN KEY (table_id) REFERENCES dining_tables(table_id)
    ON UPDATE CASCADE
    ON DELETE SET NULL,
  CONSTRAINT fk_orders_user
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX idx_orders_datetime ON orders(order_datetime);
CREATE INDEX idx_orders_user ON orders(user_id);

CREATE TABLE order_items (
  order_item_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT NOT NULL,
  product_id INT NOT NULL,
  qty INT NOT NULL CHECK (qty > 0),
  unit_price DECIMAL(12,2) NOT NULL CHECK (unit_price >= 0),
  line_total DECIMAL(12,2) NOT NULL CHECK (line_total >= 0),

  CONSTRAINT fk_items_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT fk_items_product
    FOREIGN KEY (product_id) REFERENCES products(product_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX idx_items_order ON order_items(order_id);
CREATE INDEX idx_items_product ON order_items(product_id);

CREATE TABLE payments (
  payment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT NOT NULL,
  method ENUM('CASH','QRIS','DEBIT','CREDIT') NOT NULL,
  paid_amount DECIMAL(12,2) NOT NULL CHECK (paid_amount >= 0),
  paid_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  pay_status ENUM('PAID','REFUND') NOT NULL DEFAULT 'PAID',
  CONSTRAINT fk_payments_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_payments_order ON payments(order_id);

-- =========================================================
-- 3) TRIGGER: KONTROL & UPDATE STOK OTOMATIS
--    - Stok berkurang saat insert order_items
--    - Stok menyesuaikan saat update qty/product
--    - Stok kembali saat delete item
--    Catatan: Aman untuk demo tugas. Untuk produksi, biasanya pakai stock_movements.
-- =========================================================

DELIMITER $$

CREATE TRIGGER bi_order_items_check_stock
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
  DECLARE v_stock INT;
  SELECT stock_qty INTO v_stock
  FROM products
  WHERE product_id = NEW.product_id
  FOR UPDATE;

  IF v_stock < NEW.qty THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Stok tidak cukup untuk item yang ditambahkan.';
  END IF;

  SET NEW.line_total = NEW.qty * NEW.unit_price;
END$$

CREATE TRIGGER ai_order_items_reduce_stock
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
  UPDATE products
  SET stock_qty = stock_qty - NEW.qty
  WHERE product_id = NEW.product_id;
END$$

CREATE TRIGGER bu_order_items_check_stock
BEFORE UPDATE ON order_items
FOR EACH ROW
BEGIN
  DECLARE v_stock INT;
  DECLARE v_delta INT;

  -- delta = qty baru - qty lama (kalau naik, stok harus cukup)
  SET v_delta = NEW.qty - OLD.qty;

  IF v_delta > 0 THEN
    SELECT stock_qty INTO v_stock
    FROM products
    WHERE product_id = NEW.product_id
    FOR UPDATE;

    IF v_stock < v_delta THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stok tidak cukup untuk update qty item.';
    END IF;
  END IF;

  SET NEW.line_total = NEW.qty * NEW.unit_price;
END$$

CREATE TRIGGER au_order_items_adjust_stock
AFTER UPDATE ON order_items
FOR EACH ROW
BEGIN
  -- Jika product_id berubah, balikin stok lama lalu kurangi stok baru
  IF NEW.product_id <> OLD.product_id THEN
    UPDATE products SET stock_qty = stock_qty + OLD.qty WHERE product_id = OLD.product_id;
    UPDATE products SET stock_qty = stock_qty - NEW.qty WHERE product_id = NEW.product_id;
  ELSE
    -- product sama: stok menyesuaikan delta
    UPDATE products
    SET stock_qty = stock_qty - (NEW.qty - OLD.qty)
    WHERE product_id = NEW.product_id;
  END IF;
END$$

CREATE TRIGGER ad_order_items_restore_stock
AFTER DELETE ON order_items
FOR EACH ROW
BEGIN
  UPDATE products
  SET stock_qty = stock_qty + OLD.qty
  WHERE product_id = OLD.product_id;
END$$

DELIMITER ;

-- =========================================================
-- 4) DML: SEED DATA (biar query agregasi tidak menyedihkan)
-- =========================================================

INSERT INTO roles(role_name) VALUES ('admin'), ('kasir');

INSERT INTO users(role_id, full_name, username, password_hash)
VALUES
  (1, 'Admin Sistem', 'admin', 'hash_admin'),
  (2, 'Kasir 1', 'kasir1', 'hash_kasir1'),
  (2, 'Kasir 2', 'kasir2', 'hash_kasir2');

INSERT INTO dining_tables(table_no) VALUES ('T1'), ('T2'), ('T3'), ('T4');

INSERT INTO categories(category_name)
VALUES ('Makanan'), ('Minuman'), ('Snack');

INSERT INTO products(category_id, product_name, unit, base_price, stock_qty)
VALUES
  (1, 'Nasi Goreng Spesial', 'porsi', 18000, 50),
  (1, 'Mie Goreng', 'porsi', 16000, 40),
  (1, 'Ayam Geprek', 'porsi', 20000, 35),
  (2, 'Es Teh', 'gelas', 5000, 100),
  (2, 'Es Jeruk', 'gelas', 7000, 80),
  (2, 'Kopi Susu', 'gelas', 12000, 60),
  (3, 'Kentang Goreng', 'porsi', 15000, 30),
  (3, 'Tahu Crispy', 'porsi', 10000, 45);

-- =========================================================
-- 5) PROCEDURE + TCL: SKENARIO TRANSAKSI PEMBUATAN ORDER
--    (biar ada contoh TCL yang jelas)
-- =========================================================

DELIMITER $$

CREATE PROCEDURE sp_create_order_demo (
  IN p_order_no VARCHAR(30),
  IN p_order_type ENUM('DINE_IN','TAKEAWAY'),
  IN p_table_id INT,
  IN p_user_id INT,
  IN p_customer_name VARCHAR(80),
  IN p_discount DECIMAL(12,2),
  IN p_tax_rate DECIMAL(6,4)  -- misal 0.10 = 10%
)
BEGIN
  DECLARE v_order_id BIGINT;

  START TRANSACTION;

  INSERT INTO orders(order_no, order_type, table_id, user_id, customer_name, status)
  VALUES (p_order_no, p_order_type,
          CASE WHEN p_order_type = 'DINE_IN' THEN p_table_id ELSE NULL END,
          p_user_id, p_customer_name, 'DRAFT');

  SET v_order_id = LAST_INSERT_ID();

  -- Contoh item: (ambil harga dari products saat itu)
  -- kamu bisa ganti item sesuai kebutuhan demo
  INSERT INTO order_items(order_id, product_id, qty, unit_price, line_total)
  SELECT v_order_id, product_id, 2, base_price, 0
  FROM products WHERE product_name = 'Nasi Goreng Spesial';

  INSERT INTO order_items(order_id, product_id, qty, unit_price, line_total)
  SELECT v_order_id, product_id, 1, base_price, 0
  FROM products WHERE product_name = 'Es Teh';

  -- hitung subtotal
  UPDATE orders o
  JOIN (
    SELECT order_id, SUM(line_total) AS subtotal
    FROM order_items
    WHERE order_id = v_order_id
    GROUP BY order_id
  ) x ON o.order_id = x.order_id
  SET o.subtotal = x.subtotal;

  -- set diskon + pajak + total
  UPDATE orders
  SET discount_amount = IFNULL(p_discount, 0),
      tax_amount = ROUND((subtotal - IFNULL(p_discount,0)) * IFNULL(p_tax_rate,0), 2),
      total = (subtotal - IFNULL(p_discount,0)) + ROUND((subtotal - IFNULL(p_discount,0)) * IFNULL(p_tax_rate,0), 2)
  WHERE order_id = v_order_id;

  COMMIT;
END$$

DELIMITER ;

-- Jalankan demo transaksi:
CALL sp_create_order_demo('INV-0001', 'DINE_IN', 1, 2, 'Budi', 2000, 0.10);
CALL sp_create_order_demo('INV-0002', 'TAKEAWAY', NULL, 3, 'Sari', 0, 0.10);

-- =========================================================
-- 6) VIEW: Tampilan nota lengkap (buat presentasi & query gampang)
-- =========================================================

CREATE OR REPLACE VIEW v_invoice_detail AS
SELECT
  o.order_id,
  o.order_no,
  o.order_datetime,
  o.order_type,
  dt.table_no,
  u.full_name AS cashier,
  o.customer_name,
  p.product_name,
  c.category_name,
  oi.qty,
  oi.unit_price,
  oi.line_total,
  o.subtotal,
  o.discount_amount,
  o.tax_amount,
  o.total,
  o.status
FROM orders o
JOIN users u ON u.user_id = o.user_id
LEFT JOIN dining_tables dt ON dt.table_id = o.table_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
JOIN categories c ON c.category_id = p.category_id;

-- =========================================================
-- 7) CONTOH QUERY WAJIB: JOIN, GROUP BY, HAVING, SUBQUERY
-- =========================================================

-- (A) JOIN: tampilkan nota lengkap untuk 1 order_no
SELECT *
FROM v_invoice_detail
WHERE order_no = 'INV-0001'
ORDER BY product_name;

-- (B) GROUP BY: total penjualan per hari
SELECT
  DATE(order_datetime) AS tanggal,
  COUNT(DISTINCT order_id) AS jumlah_nota,
  SUM(total) AS total_penjualan
FROM orders
WHERE status <> 'CANCELLED'
GROUP BY DATE(order_datetime)
ORDER BY tanggal;

-- (C) GROUP BY + HAVING: produk yang terjual > 2 item (qty total)
SELECT
  p.product_name,
  SUM(oi.qty) AS total_qty
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status <> 'CANCELLED'
GROUP BY p.product_name
HAVING SUM(oi.qty) > 2
ORDER BY total_qty DESC;

-- (D) SUBQUERY: cek order dengan total di atas rata-rata total order
SELECT
  order_no,
  total
FROM orders
WHERE status <> 'CANCELLED'
  AND total > (SELECT AVG(total) FROM orders WHERE status <> 'CANCELLED')
ORDER BY total DESC;

-- =========================================================
-- 8) DML TAMBAHAN: contoh pembayaran + update status PAID
-- =========================================================

-- Bayar order INV-0001
INSERT INTO payments(order_id, method, paid_amount)
SELECT order_id, 'CASH', total
FROM orders
WHERE order_no = 'INV-0001';

UPDATE orders
SET status = 'PAID'
WHERE order_no = 'INV-0001';

-- Lihat stok setelah transaksi
SELECT product_id, product_name, stock_qty
FROM products
ORDER BY product_id;

-- =========================================================
-- END
-- =========================================================
