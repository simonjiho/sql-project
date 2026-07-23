-- ============================================================
-- 종합실습 2 — 심화 과제 (문항 21~25) : 집계 ROLLUP·재귀 CTE·Window Function
-- 실행 환경: skala_db / lab 스키마 / skala_user
--   psql -h localhost -U skala_user -d skala_db -f 03-advanced.sql
-- ============================================================

-- ------------------------------------------------------------
-- 문항 21. 학과별·GPA 구간별 인원 집계 + 소계/총계 (ROLLUP)
--   - gpa_tier 파생: 3.0 미만 / 3.0~3.5 / 3.5 초과
--   - GROUP BY ROLLUP(major, gpa_tier)
--   - GROUPING(major)로 총계 행에 '전체' 라벨
--   - major, gpa_tier 순 정렬 + 소계·총계는 하단 배치
--   기대 행 수: 25 (상세 18 + 학과 소계 6 + 총계 1), 총계 1,000명
-- ------------------------------------------------------------
WITH s AS (
    SELECT major,
           CASE WHEN gpa < 3.0  THEN '3.0 미만'
                WHEN gpa <= 3.5 THEN '3.0~3.5'
                ELSE                 '3.5 초과'
           END AS gpa_tier
    FROM lab.student
)
SELECT CASE WHEN GROUPING(major)    = 1 THEN '전체'   ELSE major    END AS major,
       CASE WHEN GROUPING(gpa_tier) = 1 THEN '(소계)' ELSE gpa_tier END AS gpa_tier,
       COUNT(*) AS student_count
FROM s
GROUP BY ROLLUP(major, gpa_tier)
ORDER BY GROUPING(major),          -- 총계(전체)를 맨 하단으로
         major,
         GROUPING(gpa_tier),       -- 각 학과의 소계를 해당 학과 하단으로
         gpa_tier;

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

-- ------------------------------------------------------------
-- 문항 23. 학과별 GPA 상위 3명 (Window Function)
--   - ROW_NUMBER() OVER (PARTITION BY major ORDER BY gpa DESC, student_id)
--   - RANK() / DENSE_RANK() 동점 처리 비교
--   - COUNT() OVER (PARTITION BY major) → total_in_major
--   기대 행 수: 18 (6개 학과 × 3명)
-- ------------------------------------------------------------

-- 23-1. CTE 방식
WITH ranked AS (
    SELECT student_id, name, major, gpa,
           ROW_NUMBER()  OVER (PARTITION BY major ORDER BY gpa DESC, student_id) AS row_no,
           RANK()        OVER (PARTITION BY major ORDER BY gpa DESC)             AS rank_no,
           DENSE_RANK()  OVER (PARTITION BY major ORDER BY gpa DESC)             AS dense_rank_no,
           COUNT(*)      OVER (PARTITION BY major)                               AS total_in_major
    FROM lab.student
)
SELECT student_id, name, major, gpa, row_no, rank_no, dense_rank_no, total_in_major
FROM ranked
WHERE row_no <= 3
ORDER BY major, row_no;

-- 23-2. 서브쿼리(인라인 뷰) 방식
SELECT student_id, name, major, gpa, row_no, rank_no, dense_rank_no, total_in_major
FROM (
    SELECT student_id, name, major, gpa,
           ROW_NUMBER()  OVER (PARTITION BY major ORDER BY gpa DESC, student_id) AS row_no,
           RANK()        OVER (PARTITION BY major ORDER BY gpa DESC)             AS rank_no,
           DENSE_RANK()  OVER (PARTITION BY major ORDER BY gpa DESC)             AS dense_rank_no,
           COUNT(*)      OVER (PARTITION BY major)                               AS total_in_major
    FROM lab.student
) ranked
WHERE row_no <= 3
ORDER BY major, row_no;

-- ------------------------------------------------------------
-- 문항 24. LAG() — 학생별 이전 수강 과목 대비 성적 변화
--   - grade → 점수 변환: A=4, B=3, C=2, D=1
--   - LAG(score) OVER (PARTITION BY student_id ORDER BY course)
--   - diff = 현재 점수 - 이전 점수, 상승/유지/하락 표시
--   - score_range = 학생별 최고점 - 최저점 (Window Function)
--   기대 행 수: 2,302 (enroll 전체)
-- ------------------------------------------------------------
SELECT student_id, course, score,
       LAG(score) OVER w                AS prev_score,
       score - LAG(score) OVER w        AS diff,
       CASE
           WHEN LAG(score) OVER w IS NULL       THEN '(첫 과목)'
           WHEN score - LAG(score) OVER w > 0   THEN '상승'
           WHEN score - LAG(score) OVER w = 0   THEN '유지'
           ELSE                                      '하락'
       END AS trend,
       MAX(score) OVER (PARTITION BY student_id)
     - MIN(score) OVER (PARTITION BY student_id) AS score_range
FROM (
    SELECT student_id, course,
           CASE grade WHEN 'A' THEN 4 WHEN 'B' THEN 3
                      WHEN 'C' THEN 2 WHEN 'D' THEN 1 END AS score
    FROM lab.enroll
) e
WINDOW w AS (PARTITION BY student_id ORDER BY course)
ORDER BY student_id, course;

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
