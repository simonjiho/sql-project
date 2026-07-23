-- ------------------------------------------------------------
-- 문항 22. WITH RECURSIVE — 조직 계층 경로와 깊이
--   - depth: 0=CEO, 1=매니저, 2=개발자
--   - path 예: 'CEO > Mgr_2 > Dev_15'
--   기대 행 수: 311
--   ※ 실측 depth 분포는 0:1 / 1:40 / 2:270 —
--     적재 수식상 Dev 30명이 CEO 직속으로 배정되어 슬라이드 배경(1/10/300)과 다름
-- ------------------------------------------------------------
WITH RECURSIVE org AS (
    SELECT emp_id, name, 0 AS depth, name::text AS path
    FROM lab.emp
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.emp_id, e.name, o.depth + 1, o.path || ' > ' || e.name
    FROM lab.emp e
    JOIN org o ON e.manager_id = o.emp_id
)
SELECT emp_id, name, depth, path
FROM org
ORDER BY path;

-- 22-보조. 매니저별 직속 부하 직원 수 (direct_reports)
--   ※ 실측: 적재 수식이 manager_id = 1+((gs-1)%10) 이어서
--     Dev 30명이 CEO 직속, Mgr_11은 부하 0명 (슬라이드 배경과 다름)
--     → 부하 0명인 Mgr_11도 보이도록 LEFT JOIN 사용
SELECT m.emp_id, m.name, COUNT(e.emp_id) AS direct_reports
FROM lab.emp m
LEFT JOIN lab.emp e ON e.manager_id = m.emp_id
WHERE m.manager_id IS NULL          -- CEO
   OR m.name LIKE 'Mgr\_%'          -- 매니저 10명
GROUP BY m.emp_id, m.name
ORDER BY m.emp_id;
