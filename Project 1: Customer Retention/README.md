# Customer Retention Analysis

## 📌 Deskripsi
Tujuan project ini adalah menghitung **monthly customer retention rate** dari dataset transaksi e-commerce.  
Retention dihitung sebagai persentase pelanggan yang melakukan pembelian di bulan berikutnya.

Dijalankan di environment: **DbGate (Postgres)**.

## 🗂️ Dataset
- Dataset: [E-commerce Transactions (Kaggle)](https://www.kaggle.com/datasets/carrie1/ecommerce-data)
- Tabel utama: `d1`  
  - `InvoiceNo`
  - `StockCode`
  - `Description`
  - `Quantity`
  - `InvoiceDate`
  - `UnitPrice`
  - `CustomerID`
  - `Country`

## 💻 SQL Query
Lihat [query.sql](./query.sql)

## 📈 Output
| month      | active_users | retained_users | retention_rate |
|------------|--------------|----------------|----------------|
| 2010-12    | 948          | 0              | 0.00           |
| 2011-01    | 783          | 362            | 46.00          |
| 2011-02    | 798          | 299            | 37.00          |
| 2011-03    | 1020         | 345            | 34.00          |
| 2011-04    | 899          | 346            | 38.00          |
| 2011-05    | 1079         | 399            | 37.00          |
| 2011-06    | 1051         | 464            | 44.00          |
| 2011-07    | 993          | 415            | 42.00          |
| 2011-08    | 980          | 433            | 44.00          |
| 2011-09    | 1302         | 465            | 36.00          |
| 2011-10    | 1425         | 552            | 39.00          |
| 2011-11    | 1711         | 690            | 40.00          |
| 2011-12    | 686          | 443            | 65.00          |


## 🔍 Insight
Retention pelanggan stabil di kisaran **35–45%**, artinya sekitar sepertiga pelanggan melakukan repeat purchase di bulan berikutnya.
