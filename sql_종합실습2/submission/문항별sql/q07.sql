-- ------------------------------------------------------------
-- 문항 7. 고객별 주문건수/총액
--   기대 행 수: 500, 전 고객 주문건수 6건
-- ------------------------------------------------------------
SELECT c.customer_id, c.customer_name,
       COUNT(o.order_id)            AS order_count,
       COALESCE(SUM(o.amount), 0)   AS total_amount
FROM lab.customers c
LEFT JOIN lab.orders o
       ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY c.customer_id;
