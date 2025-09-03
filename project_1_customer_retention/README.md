# Customer Retention Analysis

## 📌 Deskripsi
Proyek ini bertujuan menghitung **customer retention bulanan** dari dataset transaksi e-commerce.  
Retention diukur sebagai persentase pelanggan yang kembali bertransaksi di bulan berikutnya.

## 🗂️ Dataset
- Sumber: [E-commerce Transactions (Kaggle)](https://www.kaggle.com/datasets/carrie1/ecommerce-data)
- Tabel utama: `transactions`
  - `customer_id`
  - `order_id`
  - `order_date`
  - `amount`

## 💻 SQL Query
Lihat file [query.sql](./query.sql) untuk kode lengkap.

## 📈 Output (contoh)
| month   | active_users | retained_users | retention_rate |
|---------|--------------|----------------|----------------|
| 2021-01 | 1200         | 450            | 37.5%          |
| 2021-02 | 980          | 400            | 40.8%          |

## 🔍 Insight
Retention pelanggan stabil di kisaran **35–40%**, artinya sekitar sepertiga pelanggan melakukan repeat purchase di bulan berikutnya.
