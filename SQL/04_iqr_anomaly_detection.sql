USE SupplyChainDB;
GO

-- ============================================================
-- 04_iqr_anomaly_detection.sql
-- ============================================================
-- BUSINESS QUESTION: Which shipments are statistically
-- unusual outliers in delivery delay?
--
-- APPROACH: IQR (Interquartile Range) method.
-- WHY IQR OVER Z-SCORE: Delivery delays are right-skewed
-- (many small delays, few extreme ones). Z-score assumes
-- normal distribution. IQR does not, making it more robust
-- for skewed data.
--
-- DOWNSTREAM: Dashboard 1 anomaly alert table
-- ============================================================

WITH percentiles AS (
    SELECT DISTINCT
        PERCENTILE_CONT(0.25) WITHIN GROUP
            (ORDER BY delay_days) OVER ()   AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP
            (ORDER BY delay_days) OVER ()   AS Q3
    FROM delivery_analysis
),
bounds AS (
    SELECT
        Q1,
        Q3,
        Q3 - Q1                             AS IQR,
        Q1 - 1.5 * (Q3 - Q1)               AS lower_bound_mild,
        Q3 + 1.5 * (Q3 - Q1)               AS upper_bound_mild,
        Q1 - 3.0 * (Q3 - Q1)               AS lower_bound_extreme,
        Q3 + 3.0 * (Q3 - Q1)               AS upper_bound_extreme
    FROM percentiles
)
SELECT
    da.Order_Id,
    da.route_segment,
    da.Shipping_Mode,
    da.Market,
    da.Order_Region,
    da.Category_Name,
    da.delay_days,
    da.Sales,
    da.Order_Profit_Per_Order,
    ROUND(b.Q1, 2)                          AS Q1,
    ROUND(b.Q3, 2)                          AS Q3,
    ROUND(b.IQR, 2)                         AS IQR,
    ROUND(b.lower_bound_mild, 2)            AS lower_bound,
    ROUND(b.upper_bound_mild, 2)            AS upper_bound,
    CONCAT(
        CAST(ROUND(b.lower_bound_mild, 0) AS INT),
        ' to ',
        CAST(ROUND(b.upper_bound_mild, 0) AS INT)
    )                                       AS expected_range,
    CASE
        WHEN da.delay_days < b.lower_bound_extreme
          OR da.delay_days > b.upper_bound_extreme
            THEN 'Extreme'
        WHEN da.delay_days < b.lower_bound_mild
          OR da.delay_days > b.upper_bound_mild
            THEN 'Outlier'
        ELSE 'Normal'
    END                                     AS anomaly_flag,
    CASE
        WHEN da.delay_days > b.upper_bound_mild
            THEN 'Unusually Late'
        WHEN da.delay_days < b.lower_bound_mild
            THEN 'Unusually Early'
        ELSE 'Within Range'
    END                                     AS anomaly_direction
FROM delivery_analysis da
CROSS JOIN bounds b
WHERE da.delay_days < b.lower_bound_mild
   OR da.delay_days > b.upper_bound_mild
ORDER BY ABS(da.delay_days - (b.Q1 + b.Q3) / 2) DESC;