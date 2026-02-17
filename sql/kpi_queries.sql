CREATE DATABASE telecom_bi;
USE telecom_bi;

#Create Raw Table
CREATE TABLE telco_raw (
    customerID VARCHAR(50),
    gender VARCHAR(10),
    SeniorCitizen INT,
    Partner VARCHAR(10),
    Dependents VARCHAR(10),
    tenure INT,
    PhoneService VARCHAR(10),
    MultipleLines VARCHAR(20),
    InternetService VARCHAR(20),
    OnlineSecurity VARCHAR(20),
    OnlineBackup VARCHAR(20),
    DeviceProtection VARCHAR(20),
    TechSupport VARCHAR(20),
    StreamingTV VARCHAR(20),
    StreamingMovies VARCHAR(20),
    Contract VARCHAR(20),
    PaperlessBilling VARCHAR(10),
    PaymentMethod VARCHAR(50),
    MonthlyCharges DECIMAL(10,2),
    TotalCharges DECIMAL(10,2),
    Churn VARCHAR(10)
);

#Check Missing TotalCharges
SELECT * 
FROM telco_raw
WHERE TotalCharges IS NULL;

#Create Star Schema
##Create Dimension Table
CREATE TABLE dim_customer AS
SELECT 
    customerID AS customer_id,
    gender,
    SeniorCitizen,
    Partner,
    Dependents,
    tenure,
    Contract,
    Churn
FROM telco_raw;

#Create Fact Table
CREATE TABLE fact_billing AS
SELECT
    customerID AS customer_id,
    MonthlyCharges,
    TotalCharges,
    tenure
FROM telco_raw;

##Core Telecom KPI Queries
#Total Revenue
SELECT SUM(TotalCharges) AS total_revenue
FROM fact_billing;

#Average Revenue Per User (ARPU)
SELECT 
    SUM(TotalCharges)/COUNT(DISTINCT customer_id) AS ARPU
FROM fact_billing;

#Churn Rate
SELECT 
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) 
    / COUNT(*) * 100 AS churn_rate_percentage
FROM dim_customer;

#Revenue by Contract Type
SELECT 
    d.Contract,
    SUM(f.TotalCharges) AS revenue
FROM fact_billing f
JOIN dim_customer d 
ON f.customer_id = d.customer_id
GROUP BY d.Contract;

#High-Value Customers
SELECT 
    customer_id,
    TotalCharges
FROM fact_billing
ORDER BY TotalCharges DESC
LIMIT 10;

#Churn by Contract Type
SELECT 
    Contract,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) 
          / COUNT(*) * 100,2) AS churn_rate
FROM dim_customer
GROUP BY Contract;

#Revenue vs Churn
SELECT 
    d.Churn,
    AVG(f.TotalCharges) AS avg_revenue
FROM fact_billing f
JOIN dim_customer d 
ON f.customer_id = d.customer_id
GROUP BY d.Churn;
