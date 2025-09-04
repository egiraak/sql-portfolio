# Customer Retention Analysis

## 📌 Deskripsi
Tujuan project ini adalah menghitung **monthly customer retention rate** dari dataset transaksi e-commerce.  
Retention dihitung sebagai persentase pelanggan yang melakukan pembelian di bulan berikutnya.

## 🗂️ Dataset
- Dataset: [E-commerce Transactions (Kaggle)](https://www.kaggle.com/datasets/carrie1/ecommerce-data)
- Tabel utama: `transactions`  
  - `customer_id`  
  - `order_date`  
  - `order_id`  

## 💻 SQL Query
Lihat [query.sql](./query.sql)

## 📈 Output
| month      | active_users | retained_users | retention_rate |
|------------|--------------|----------------|----------------|
| 2021-01    | 1200         | 450            | 37.5%          |
| 2021-02    | 980          | 400            | 40.8%          |

## 🔍 Insight
Retention pelanggan stabil di kisaran **35–40%**, artinya sekitar sepertiga pelanggan melakukan repeat purchase di bulan berikutnya.
