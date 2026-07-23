-- ------------------------------------------------------------
-- 문항 9. 모든 직원과 그 매니저 이름 (SELF JOIN)
--   기대 행 수: 311 (CEO는 manager_name NULL)
-- ------------------------------------------------------------
SELECT e.emp_id, e.name, m.name AS manager_name
FROM lab.emp e
LEFT JOIN lab.emp m
       ON m.emp_id = e.manager_id
ORDER BY e.emp_id;
