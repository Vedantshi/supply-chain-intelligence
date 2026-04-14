USE SupplyChainDB;
GO

-- Drop existing view if it exists
IF OBJECT_ID('dbo.delivery_analysis', 'V') IS NOT NULL
    DROP VIEW dbo.delivery_analysis;
GO

CREATE VIEW dbo.delivery_analysis AS
SELECT
    Order_Id,
    order_date,
    shipping_date,
    actual_delivery_date,
    scheduled_delivery_date,
    Days_for_shipping_real          AS actual_lead_time_days,
    Days_for_shipment_scheduled     AS scheduled_lead_time_days,
    delay_days,
    CASE
        WHEN delay_days > 0 THEN 'Late'
        WHEN delay_days = 0 THEN 'On Time'
        WHEN delay_days < 0 THEN 'Early'
    END                             AS calc_delivery_status,
    Delivery_Status                 AS original_delivery_status,
    Late_delivery_risk,
    Shipping_Mode,
    Market,
    Order_Region,
    route_segment,
    Category_Name,
    Order_Status,
    Customer_Segment,
    Sales,
    Order_Profit_Per_Order,
    implied_total_cost,
    cost_pct_revenue,
    Order_Item_Discount_Rate,
    Order_Item_Profit_Ratio,
    Product_Card_Id,
    Product_Name,
    Order_Item_Quantity,
    Latitude,
    Longitude,
    Order_Country
FROM shipments;
GO

-- Validation Check 1: Row count
SELECT COUNT(*) AS total_rows
FROM delivery_analysis;

-- Validation Check 2: Status breakdown
SELECT
    calc_delivery_status,
    COUNT(*)                                        AS order_count,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER()
        AS DECIMAL(5,2))                            AS pct
FROM delivery_analysis
GROUP BY calc_delivery_status
ORDER BY order_count DESC;

-- Validation Check 3: Compare our status vs DataCo original
SELECT
    calc_delivery_status,
    original_delivery_status,
    COUNT(*)                                        AS count
FROM delivery_analysis
GROUP BY calc_delivery_status, original_delivery_status
ORDER BY calc_delivery_status, count DESC;