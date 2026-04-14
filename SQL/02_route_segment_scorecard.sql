USE SupplyChainDB;
GO

-- ============================================================
-- 02_route_segment_scorecard.sql
-- ============================================================
-- BUSINESS QUESTION: Which route segments (Shipping Mode x
-- Market x Region) deliver value and which should we
-- restructure?
--
-- APPROACH: PERCENT_RANK() normalizes each metric to 0-1
-- before applying weights. This avoids raw metric bias
-- where cost (in dollars) would dominate delay (in days).
--
-- WEIGHTS: 35/25/25/15
-- On-time rate: 35% — most direct measure of service quality
-- Delay penalty: 25% — magnitude of lateness matters
-- Cost efficiency: 25% — rising costs are co-equal problem
-- Volume: 15% — higher volume = more reliable sample
--
-- DOWNSTREAM: Dashboard 2, Excel Sheet 1 and 3
-- ============================================================

WITH segment_metrics AS (
    SELECT
        route_segment,
        Shipping_Mode,
        Market,
        Order_Region,
        COUNT(*)                                        AS total_shipments,
        AVG(CAST(delay_days AS FLOAT))                  AS avg_delay_days,
        SUM(CASE WHEN delay_days > 0
            THEN 1 ELSE 0 END) * 100.0 /
            NULLIF(COUNT(*), 0)                         AS late_rate_pct,
        100.0 - (SUM(CASE WHEN delay_days > 0
            THEN 1 ELSE 0 END) * 100.0 /
            NULLIF(COUNT(*), 0))                        AS on_time_rate_pct,
        AVG(implied_total_cost)                         AS avg_implied_cost,
        AVG(Order_Profit_Per_Order)                     AS avg_profit,
        SUM(Sales)                                      AS total_revenue
    FROM delivery_analysis
    GROUP BY route_segment, Shipping_Mode, Market, Order_Region
    HAVING COUNT(*) >= 50
),
normalized AS (
    SELECT
        *,
        PERCENT_RANK() OVER (
            ORDER BY on_time_rate_pct ASC
        )                                               AS norm_on_time,
        1 - PERCENT_RANK() OVER (
            ORDER BY avg_delay_days ASC
        )                                               AS norm_delay_penalty,
        1 - PERCENT_RANK() OVER (
            ORDER BY avg_implied_cost ASC
        )                                               AS norm_cost_efficiency,
        PERCENT_RANK() OVER (
            ORDER BY total_shipments ASC
        )                                               AS norm_volume
    FROM segment_metrics
)
SELECT
    route_segment,
    Shipping_Mode,
    Market,
    Order_Region,
    total_shipments,
    ROUND(on_time_rate_pct, 2)                          AS on_time_rate_pct,
    ROUND(avg_delay_days, 2)                            AS avg_delay_days,
    ROUND(avg_implied_cost, 2)                          AS avg_implied_cost,
    ROUND(avg_profit, 2)                                AS avg_profit,
    ROUND(total_revenue, 2)                             AS total_revenue,
    ROUND(
        (norm_on_time         * 0.35 +
         norm_delay_penalty   * 0.25 +
         norm_cost_efficiency * 0.25 +
         norm_volume          * 0.15) * 100
    , 2)                                                AS reliability_score,
    CASE
        WHEN (norm_on_time         * 0.35 +
              norm_delay_penalty   * 0.25 +
              norm_cost_efficiency * 0.25 +
              norm_volume          * 0.15) * 100 >= 80
            THEN 'Preferred'
        WHEN (norm_on_time         * 0.35 +
              norm_delay_penalty   * 0.25 +
              norm_cost_efficiency * 0.25 +
              norm_volume          * 0.15) * 100 >= 60
            THEN 'Acceptable'
        ELSE 'Under Review'
    END                                                 AS tier
FROM normalized
ORDER BY reliability_score DESC;