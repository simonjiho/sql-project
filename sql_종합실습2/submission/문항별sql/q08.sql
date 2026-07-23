-- ------------------------------------------------------------
-- 문항 8. 총액 상위 10명과 금액
--   동점 대비 customer_id 오름차순을 2차 정렬로 명시
-- ------------------------------------------------------------
SELECT c.customer_id, c.customer_name,
       SUM(o.amount) AS total_amount
FROM lab.customers c
INNER JOIN lab.orders o
        ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_amount DESC, c.customer_id
LIMIT 10;
