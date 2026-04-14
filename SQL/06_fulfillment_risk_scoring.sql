USE SupplyChainDB;
GO

-- ============================================================
-- 06_fulfillment_risk_scoring.sql
-- ============================================================
-- BUSINESS QUESTION: Which fulfillment corridors carry
-- the highest operational risk from cancellations, fraud,
-- late deliveries, and discount erosion?
--
-- APPROACH: PERCENT_RANK() normalization with 30/30/20/20
-- weights across four risk dimensions.
--
-- DOWNSTREAM: Dashboard 5
-- ============================================================

WITH corridor_metrics AS (
    SELECT
        route_segment,
        Shipping_Mode,
        Market,
        Order_Region,
        COUNT(*)                                        AS total_orders,
        SUM(CASE WHEN Order_Status IN
            ('CANCELED', 'SUSPECTED_FRAUD')
            THEN 1 ELSE 0 END) * 100.0 /
            NULLIF(COUNT(*), 0)                         AS cancel_fraud_rate,
        AVG(CAST(Late_delivery_risk AS FLOAT))
            * 100                                       AS late_delivery_rate,
        AVG(Order_Item_Discount_Rate) * 100             AS avg_discount_pct,
        STDEV(Order_Item_Profit_Ratio)                  AS profit_volatility,
        SUM(Sales)                                      AS total_revenue,
        SUM(CASE WHEN Order_Profit_Per_Order < 0
            THEN 1 ELSE 0 END)                          AS negative_profit_orders
    FROM delivery_analysis
    GROUP BY route_segment, Shipping_Mode, Market, Order_Region
    HAVING COUNT(*) >= 50
),
normalized AS (
    SELECT
        *,
        PERCENT_RANK() OVER (
            ORDER BY cancel_fraud_rate ASC
        )                                               AS norm_cancel_risk,
        PERCENT_RANK() OVER (
            ORDER BY late_delivery_rate ASC
        )                                               AS norm_late_risk,
        PERCENT_RANK() OVER (
            ORDER BY avg_discount_pct ASC
        )                                               AS norm_discount_risk,
        PERCENT_RANK() OVER (
            ORDER BY ISNULL(profit_volatility, 0) ASC
        )                                               AS norm_volatility_risk
    FROM corridor_metrics
)
SELECT
    route_segment,
    Shipping_Mode,
    Market,
    Order_Region,
    total_orders,
    ROUND(cancel_fraud_rate, 2)                         AS cancel_fraud_rate_pct,
    ROUND(late_delivery_rate, 2)                        AS late_delivery_rate_pct,
    ROUND(avg_discount_pct, 2)                          AS avg_discount_pct,
    ROUND(ISNULL(profit_volatility, 0), 4)              AS profit_volatility,
    ROUND(total_revenue, 2)                             AS total_revenue,
    ROUND(
        (norm_cancel_risk    * 0.30 +
         norm_late_risk      * 0.30 +
         norm_discount_risk  * 0.20 +
         norm_volatility_risk * 0.20) * 100
    , 2)                                                AS risk_score,
    CASE
        WHEN (norm_cancel_risk    * 0.30 +
              norm_late_risk      * 0.30 +
              norm_discount_risk  * 0.20 +
              norm_volatility_risk * 0.20) * 100 >= 70
            THEN 'High Risk'
        WHEN (norm_cancel_risk    * 0.30 +
              norm_late_risk      * 0.30 +
              norm_discount_risk  * 0.20 +
              norm_volatility_risk * 0.20) * 100 >= 40
            THEN 'Moderate Risk'
        ELSE 'Low Risk'
    END                                                 AS risk_tier,
    CASE
        WHEN cancel_fraud_rate > 5
            THEN 'Investigate Fraud Pattern'
        WHEN avg_discount_pct > 15
            THEN 'Reduce Discount'
        WHEN late_delivery_rate > 60
            THEN 'Restrict Shipping Mode'
        WHEN ISNULL(profit_volatility, 0) > 0.5
            THEN 'Stabilise Pricing'
        ELSE 'Monitor'
    END                                                 AS recommendation
FROM normalized
ORDER BY risk_score DESC;