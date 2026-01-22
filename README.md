<div align="center">

# 🍽️ Sistem Basis Data  
## Nota Makanan dan Minuman

**Ujian Akhir Semester – Pemrograman Basis Data**  
Program Studi S1 Teknik Informatika  
Fakultas Ilmu Komputer  
Universitas Duta Bangsa Surakarta  

</div>

---

## 📌 Deskripsi Proyek
Proyek ini merupakan implementasi **sistem basis data transaksi nota makanan dan minuman** yang dirancang sebagai bagian dari **Ujian Akhir Semester mata kuliah Pemrograman Basis Data**.

Sistem ini memodelkan proses transaksi restoran secara terstruktur dan terintegrasi, mulai dari pengelolaan data master hingga transaksi dan pembayaran.

---

## 🧠 Gambaran Umum Sistem
Sistem basis data ini menangani proses berikut:
- 👤 Pengelolaan pengguna (**admin & kasir**)
- 🍔 Pengelolaan produk dan kategori
- 🪑 Pengelolaan meja restoran (**dine-in**)
- 🧾 Transaksi pesanan (**dine-in & takeaway**)
- 📦 Detail item pesanan
- 💳 Pembayaran
- 🔄 Otomatisasi stok dan perhitungan transaksi

Basis data dirancang menggunakan **MySQL** dengan pendekatan **relasional**, serta menerapkan:
**Primary Key, Foreign Key, Normalisasi hingga 3NF, Stored Procedure, Trigger, View, JOIN, dan agregasi**.

---

## 🎯 Tujuan Proyek
Tujuan dari pengembangan sistem basis data ini adalah:
- 📐 Merancang **Entity Relationship Diagram (ERD)** sistem nota restoran
- 🧹 Menerapkan **normalisasi data hingga Third Normal Form (3NF)**
- 🛠️ Mengimplementasikan basis data menggunakan **DDL, DML, dan TCL**
- 🔐 Menjaga **integritas data transaksi dan stok**
- 📊 Menghasilkan laporan transaksi menggunakan **query SQL**

---

## ✨ Fitur Utama
- ✅ Manajemen user dengan role (admin & kasir)
- ✅ Manajemen produk, kategori, dan stok
- ✅ Transaksi pesanan dine-in dan takeaway
- ✅ Trigger untuk validasi dan pemotongan stok otomatis
- ✅ Transaction control (COMMIT & ROLLBACK)
- ✅ View untuk tampilan invoice/nota
- ✅ Query laporan dan analisis penjualan

---

## 🗃️ Struktur Basis Data
Database **`db_nota_resto`** terdiri dari tabel:
- `roles`
- `users`
- `categories`
- `products`
- `dining_tables`
- `orders`
- `order_items`
- `payments`

Seluruh tabel saling terhubung menggunakan **Foreign Key** untuk menjaga konsistensi dan integritas data.

---

## 🛠️ Teknologi yang Digunakan
| Komponen | Teknologi |
|--------|----------|
| DBMS | MySQL |
| Bahasa | SQL |
| Tools | MySQL Workbench |
| Konsep | ERD, Normalisasi (1NF–3NF), DDL, DML, TCL, Trigger, View |

---

