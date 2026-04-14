USE SupplyChainDB;
GO

-- ============================================================
-- 05_cost_erosion_analysis.sql
-- ============================================================
-- BUSINESS QUESTION: Which routes are shipping us into
-- losses and where do we fix it?
--
-- APPROACH: Since DataCo has no standalone Shipping Cost
-- column, we use implied_total_cost (Sales - Profit).
-- We analyse which combinations of Market, Region,
-- Shipping Mode, and Category have the worst margins.
--
-- THRESHOLD: 80% cost/revenue ratio used as High Cost flag
-- because anything above this leaves less than 20% gross
-- margin which is unsustainable for consumer goods.
--
-- DOWNSTREAM: Dashboard 4, Excel Sheet 1
-- ============================================================

SELECT
    Market,
    Order_Region,
    Shipping_Mode,
    Category_Name,
    COUNT(*)                                        AS total_orders,
    ROUND(SUM(Sales), 2)                            AS total_revenue,
    ROUND(SUM(Order_Profit_Per_Order), 2)           AS total_profit,
    ROUND(SUM(implied_total_cost), 2)               AS total_implied_cost,
    ROUND(
        SUM(implied_total_cost) * 100.0 /
        NULLIF(SUM(Sales), 0)
    , 2)                                            AS cost_pct_revenue,
    ROUND(
        SUM(Order_Profit_Per_Order) * 100.0 /
        NULLIF(SUM(Sales), 0)
    , 2)                                            AS profit_margin_pct,
    ROUND(
        AVG(Order_Item_Discount_Rate) * 100
    , 2)                                            AS avg_discount_pct,
    CASE
        WHEN SUM(implied_total_cost) * 100.0 /
            NULLIF(SUM(Sales), 0) > 80
            THEN 'High Cost Route'
        ELSE 'Normal'
    END                                             AS cost_flag,
    CASE
        WHEN SUM(Order_Profit_Per_Order) < 0
            THEN 'UNPROFITABLE'
        ELSE 'Profitable'
    END                                             AS profitability_flag
FROM delivery_analysis
GROUP BY Market, Order_Region, Shipping_Mode, Category_Name
HAVING COUNT(*) >= 20
ORDER BY profit_margin_pct ASC;