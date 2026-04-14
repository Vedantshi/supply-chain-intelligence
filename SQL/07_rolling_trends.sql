USE SupplyChainDB;
GO

-- ============================================================
-- 07_rolling_trends.sql
-- ============================================================
-- BUSINESS QUESTION: Are shipping modes getting better or
-- worse over time, even if their overall average looks OK?
--
-- APPROACH: 30-day rolling averages using window functions
-- with ROWS BETWEEN 29 PRECEDING AND CURRENT ROW.
-- Rolling averages smooth out day-to-day noise and reveal
-- genuine trends that simple averages hide.
--
-- DOWNSTREAM: Dashboard 2 trend panel
-- ============================================================

WITH daily_stats AS (
    SELECT
        CAST(order_date AS DATE)                        AS order_day,
        Shipping_Mode,
        COUNT(*)                                        AS daily_orders,
        AVG(CAST(delay_days AS FLOAT))                  AS daily_avg_delay,
        AVG(implied_total_cost)                         AS daily_avg_cost,
        SUM(CASE WHEN delay_days <= 0
            THEN 1 ELSE 0 END) * 100.0 /
            NULLIF(COUNT(*), 0)                         AS daily_on_time_pct
    FROM delivery_analysis
    GROUP BY CAST(order_date AS DATE), Shipping_Mode
)
SELECT
    order_day,
    Shipping_Mode,
    daily_orders,
    ROUND(AVG(daily_avg_delay) OVER (
        PARTITION BY Shipping_Mode
        ORDER BY order_day
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ), 2)                                               AS rolling_30d_avg_delay,
    ROUND(AVG(daily_avg_cost) OVER (
        PARTITION BY Shipping_Mode
        ORDER BY order_day
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ), 2)                                               AS rolling_30d_avg_cost,
    ROUND(AVG(daily_on_time_pct) OVER (
        PARTITION BY Shipping_Mode
        ORDER BY order_day
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ), 2)                                               AS rolling_30d_on_time_pct
FROM daily_stats
ORDER BY Shipping_Mode, order_day;