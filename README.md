# 🛍️ E-commerce Customer & Revenue Analytics (BigQuery SQL)

## 📌 Overview
This project analyzes a large-scale e-commerce dataset (`thelook_ecommerce`) available in Google BigQuery to uncover insights into customer behavior, product performance, and marketing channel effectiveness.  

Using advanced SQL, the analysis focuses on key business metrics such as revenue, average order value (AOV), customer lifetime value (LTV), and repeat purchase behavior to drive data-informed decision making.

---

## 🎯 Objectives
- Analyze overall business performance and revenue trends  
- Understand customer behavior and segmentation  
- Evaluate marketing channel effectiveness  
- Identify high-performing products and categories  
- Detect churn risk and repeat purchase patterns  

---

## 🗂️ Dataset
Source: `bigquery-public-data.thelook_ecommerce`

### Key Tables:
- **orders** → order-level information  
- **order_items** → item-level revenue data  
- **users** → customer demographics & acquisition source  
- **products** → product category, brand, pricing  
- **inventory_items** → product distribution data  
- **distribution_centers** → logistics network  

---

## 🛠️ Tools & Technologies
- **SQL (BigQuery)**
- Data Modeling with Joins & CTEs
- Window Functions
- Aggregations & KPI calculations  

---

## 📊 Key Analyses Performed

### 1. Business Performance Metrics
- Total revenue (excluding cancelled/returned orders)
- Average Order Value (AOV)
- Monthly revenue trends
- Order volume by year

---

### 2. Customer Analytics
- Unique customers and order distribution
- Repeat purchase rate
- Customer lifetime value (LTV)
- RFM-style segmentation (recency, frequency, monetary)

---

### 3. Marketing & Channel Performance
- Revenue by traffic source
- Customer acquisition analysis
- Channel efficiency (revenue per user / per order)

---

### 4. Product & Category Insights
- Revenue by category and brand
- Top-selling products (volume & revenue)
- Discount analysis (retail vs sale price)
- High-volume vs low-price categories

---

### 5. Demographic & Geographic Analysis
- Revenue by age groups
- Customer distribution by country
- Country-level order activity

---

### 6. Advanced Analytics
- Month-over-Month (MoM) revenue growth
- Top products within each category (window functions)
- Customer churn risk identification (recency-based)
- Traffic source contribution to LTV
- Product markdown percentage analysis

---

## 🔍 Sample Business Insights

- Identified high-value customer segments driving the majority of revenue  
- Found significant variation in performance across traffic sources  
- Highlighted top-performing product categories and brands  
- Detected potential churn-risk customers based on inactivity  
- Uncovered pricing and discounting patterns impacting revenue  

---

## 📈 Key SQL Techniques Used
- Common Table Expressions (CTEs)
- Window Functions (RANK, DENSE_RANK, LAG)
- Aggregations (SUM, AVG, COUNT)
- Conditional Logic (CASE WHEN)
- Joins across multiple tables
- Cohort-style and segmentation analysis  

---

## 🚀 How to Run
1. Open Google BigQuery Console  
2. Use dataset: https://console.cloud.google.com/bigquery?ws=!1m4!1m3!3m2!1sbigquery-public-data!2sthelook_ecommerce

3. Run queries from `Ecommerce Analysis.sql`  

---

## 💼 Business Value
This project demonstrates the ability to:
- Translate raw data into actionable business insights  
- Analyze customer behavior and marketing performance  
- Build scalable SQL-based analytics solutions  
- Support strategic decisions in retail and e-commerce  

---

## 📌 Future Enhancements
- Build Power BI / Tableau dashboard  
- Add predictive modeling (customer churn / LTV forecasting)  
- Integrate A/B testing framework  
- Extend to multi-channel attribution modeling 
