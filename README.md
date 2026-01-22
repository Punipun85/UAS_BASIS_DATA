📦 Sistem Basis Data Nota Makanan dan Minuman

Ujian Akhir Semester – Pemrograman Basis Data

📖 Deskripsi Proyek

Proyek ini merupakan implementasi sistem basis data transaksi nota makanan dan minuman yang dirancang sebagai bagian dari Ujian Akhir Semester mata kuliah Pemrograman Basis Data.

Sistem ini memodelkan proses transaksi restoran yang mencakup:

Pengelolaan pengguna (admin & kasir)

Pengelolaan produk dan kategori

Pengelolaan meja (dine-in)

Transaksi pesanan (dine-in & takeaway)

Detail item pesanan

Pembayaran

Otomasi stok dan perhitungan transaksi

Basis data dirancang menggunakan MySQL dengan pendekatan relasional, dilengkapi Primary Key, Foreign Key, Normalisasi hingga 3NF, Stored Procedure, Trigger, View, serta query JOIN dan agregasi.

🎯 Tujuan Proyek

Tujuan dari proyek ini adalah:

Merancang Entity Relationship Diagram (ERD) sistem nota restoran

Menerapkan normalisasi data hingga Third Normal Form (3NF)

Mengimplementasikan basis data menggunakan DDL, DML, dan TCL

Menjaga integritas data transaksi dan stok melalui constraint dan trigger

Menyajikan laporan transaksi menggunakan query SQL (JOIN, GROUP BY, HAVING, agregasi)

🧩 Fitur Utama Basis Data

✅ Manajemen user dengan role (admin, kasir)

✅ Manajemen produk, kategori, dan stok

✅ Transaksi pesanan dine-in dan takeaway

✅ Otomatisasi pengurangan dan validasi stok (trigger)

✅ Pengendalian transaksi menggunakan TCL (COMMIT & ROLLBACK)

✅ View untuk tampilan nota/invoice

✅ Query laporan penjualan dan analisis data

🗂️ Struktur Tabel Utama

Basis data db_nota_resto terdiri dari tabel berikut:

roles

users

categories

products

dining_tables

orders

order_items

payments

Seluruh tabel dihubungkan menggunakan Foreign Key dengan aturan ON UPDATE CASCADE, ON DELETE RESTRICT, ON DELETE CASCADE, dan ON DELETE SET NULL untuk menjaga konsistensi data.

🛠️ Teknologi yang Digunakan

DBMS: MySQL

Bahasa: SQL

Tools: MySQL Workbench

Konsep:

ERD

Normalisasi 1NF, 2NF, 3NF

DDL, DML, TCL

Stored Procedure

Trigger

View

Query JOIN & Agregasi

📁 Struktur Folder Repository
UAS_BASIS_DATA/
│
├── laporan/
│   ├── laporan.pdf
│   └── laporan.docx
│
├── sql/
│   └── UAS_BASIS_DATA.sql
│
└── README.md

🚀 Cara Menjalankan Project

Buka MySQL Workbench

Jalankan file SQL:

sql/UAS_BASIS_DATA.sql


Database db_nota_resto akan otomatis dibuat

Seluruh tabel, relasi, trigger, procedure, dan view akan ter-generate

Gunakan query yang tersedia untuk melihat data transaksi dan laporan

📊 Contoh Query yang Diimplementasikan

Detail nota menggunakan JOIN

Total penjualan harian menggunakan GROUP BY

Filter transaksi tertentu menggunakan HAVING

Analisis penjualan menggunakan fungsi agregasi dan subquery

🧪 Hasil Pengujian

Berdasarkan pengujian:

Seluruh perintah DDL, DML, dan TCL berhasil dijalankan

Relasi PK & FK berjalan dengan baik

Trigger berhasil mencegah stok negatif

Transaksi bersifat atomik dan konsisten

Query menghasilkan data yang akurat

👥 Penyusun

Program Studi S1 Teknik Informatika
Fakultas Ilmu Komputer
Universitas Duta Bangsa Surakarta

Disusun oleh:

Osama Habib Candranata (240103199)

Samuel Rinlady (240103202)

Khotijah Naishilla Ariyanto (240103194)

Dosen Pengampu:
Ridwan Dwi Irawan, M.Kom
