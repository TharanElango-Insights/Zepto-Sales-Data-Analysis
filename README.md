# Zepto SQL Data Analysis Project

## 📌 Project Overview
This project performs a deep-dive analysis of Zepto's product data using **MySQL**. The goal was to clean raw data, perform exploratory data analysis (EDA), and derive actionable business insights regarding inventory, pricing, and profitability.

## 🛠️ Tech Stack
- **Database:** MySQL
- **Tool:** SQL Workbench
- **Concepts:** Data Cleaning, Aggregations, Window Functions (ROW_NUMBER), CTEs, and Case Statements.

## 🧹 Key Data Cleaning Steps
- **Unit Normalization:** Converted pricing from Paise to Rupees for accurate reporting.
- **Handling Inconsistencies:** Identified and removed rows with zero MRP to ensure data integrity.
- **Missing Value Check:** Performed NULL value analysis across all critical columns.

## 📊 Business Insights Derived
- **Inventory Management:** Identified high-value products that are currently out of stock to prioritize restocking.
- **Revenue Analysis:** Calculated estimated revenue per category to identify top-performing segments.
- **Pricing Strategy:** Analyzed price-per-gram to identify "Value for Money" products for internal pricing adjustments.
- **Profit/Loss Tracking:** Identified the top 5 loss-making categories due to aggressive discounting strategies.

## 📂 Project Structure
- `zepto_analysis.sql`: Contains the full end-to-end SQL script from table creation to advanced business queries.

---
*Note: This project was inspired by a case study by Amlan Mohanty, which I expanded with additional queries for loss-making category identification and premium product ranking.*
