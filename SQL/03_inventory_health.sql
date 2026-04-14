USE SupplyChainDB;
GO

WITH daily_demand AS (
    SELECT
        Product_Card_Id,
        CAST(order_date AS DATE)            AS order_day,
        SUM(Order_Item_Quantity)            AS daily_qty
    FROM delivery_analysis
    GROUP BY Product_Card_Id, CAST(order_date AS DATE)
),
rolling_demand AS (
    SELECT
        Product_Card_Id,
        order_day,
        daily_qty,
        AVG(CAST(daily_qty AS FLOAT)) OVER (
            PARTITION BY Product_Card_Id
            ORDER BY order_day
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        )                                   AS rolling_avg_demand_30d
    FROM daily_demand
),
latest_rolling AS (
    SELECT
        Product_Card_Id,
        rolling_avg_demand_30d,
        ROW_NUMBER() OVER (
            PARTITION BY Product_Card_Id
            ORDER BY order_day DESC
        )                                   AS rn
    FROM rolling_demand
)
SELECT
    i.product_id,
    i.category_name,
    i.revenue_quartile,
    i.avg_daily_demand_30d,
    i.simulated_stock,
    i.days_of_stock,
    i.stock_status,
    i.priority_critical,
    COALESCE(lr.rolling_avg_demand_30d, 0) AS latest_rolling_demand,
    CASE
        WHEN COALESCE(lr.rolling_avg_demand_30d, 0) > 0
        THEN ROUND(
            i.simulated_stock / lr.rolling_avg_demand_30d
        , 1)
        ELSE 999
    END                                     AS adjusted_days_of_stock
FROM inventory i
LEFT JOIN latest_rolling lr
    ON  i.product_id = lr.Product_Card_Id
    AND lr.rn = 1
ORDER BY i.days_of_stock ASC;