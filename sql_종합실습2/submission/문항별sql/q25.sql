-- ------------------------------------------------------------
-- 문항 25. orders 누적 주문금액과 3개 주문 이동평균 (ROWS BETWEEN)
--   - 전체 누적합: SUM() OVER (ORDER BY order_id ROWS BETWEEN
--                  UNBOUNDED PRECEDING AND CURRENT ROW)
--   - 3개 이동평균: AVG() OVER (... ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
--   - 고객별 누적 구매금액: PARTITION BY customer_id
--   기대 행 수: 3,000
-- ------------------------------------------------------------
SELECT order_id, customer_id, amount,
       SUM(amount) OVER (ORDER BY order_id
                         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
       ROUND(AVG(amount) OVER (ORDER BY order_id
                               ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3,
       SUM(amount) OVER (PARTITION BY customer_id ORDER BY order_id
                         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cust_running_total
FROM lab.orders
ORDER BY order_id;

-- 25-보조. 누적합이 전체 합의 50%를 초과하는 첫 번째 order_id
WITH r AS (
    SELECT order_id,
           SUM(amount) OVER (ORDER BY order_id
                             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
           SUM(amount) OVER () AS grand_total
    FROM lab.orders
)
SELECT order_id, running_total, grand_total
FROM r
WHERE running_total > grand_total * 0.5
ORDER BY order_id
LIMIT 1;
