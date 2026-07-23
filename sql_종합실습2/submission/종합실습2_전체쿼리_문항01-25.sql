-- ============================================================
-- 종합실습 2 — 전체 제출 쿼리 (문항 1~25)
-- 환경: PostgreSQL / skala_db / lab 스키마 / skala_user
-- 문항 12 선행 조건(관리자 계정에서 1회):
--   GRANT REFERENCES ON lab.emp TO skala_user;
-- ============================================================

-- ------------------------------------------------------------
-- 문항 1. 학생과 수강을 INNER JOIN하여 수강 존재 학생의 과목/성적을 조회
--   기대 행 수: 2,300 (고아 수강 2건은 학생이 없어 제외됨)
-- ------------------------------------------------------------
SELECT s.student_id, s.name, e.course, e.grade
FROM lab.student s
INNER JOIN lab.enroll e
        ON e.student_id = s.student_id;

-- ------------------------------------------------------------
-- 문항 2. 모든 학생 기준으로 수강을 붙이고, 과목(없으면 NULL)까지 보이기
--   기대 행 수: 2,400 (수강 2,300 + 수강 없는 학생 100)
-- ------------------------------------------------------------
SELECT s.student_id, s.name, e.course
FROM lab.student s
LEFT JOIN lab.enroll e
       ON e.student_id = s.student_id;

-- ------------------------------------------------------------
-- 문항 3. 수강이 기준. 학생이 없으면 학생 정보가 NULL
--   기대 행 수: 2,302 (고아 수강 1001·1010 포함, 해당 행 name IS NULL)
-- ------------------------------------------------------------
SELECT e.student_id, e.course, e.grade, s.name
FROM lab.student s
RIGHT JOIN lab.enroll e
        ON e.student_id = s.student_id;

-- ------------------------------------------------------------
-- 문항 4. 학생/수강 모두 포함 (FULL OUTER JOIN)
--   기대 행 수: 2,402 (수강 2,300 + 수강 없는 학생 100 + 고아 수강 2)
-- ------------------------------------------------------------
SELECT s.student_id AS student_side_id, s.name,
       e.student_id AS enroll_side_id, e.course
FROM lab.student s
FULL OUTER JOIN lab.enroll e
             ON e.student_id = s.student_id;

-- ------------------------------------------------------------
-- 문항 5. 한 번도 수강하지 않은 학생 목록 (Anti-Join)
--   기대 행 수: 100 (실측: student_id % 10 = 0인 학생)
-- ------------------------------------------------------------
SELECT s.student_id, s.name
FROM lab.student s
LEFT JOIN lab.enroll e
       ON e.student_id = s.student_id
WHERE e.student_id IS NULL
ORDER BY s.student_id;

-- ------------------------------------------------------------
-- 문항 6. 한 과목 이상 수강한 학생 목록(중복 제거) (Semi-Join)
--   기대 행 수: 900 (1,000 - 수강 없는 학생 100)
-- ------------------------------------------------------------
SELECT DISTINCT s.student_id, s.name
FROM lab.student s
INNER JOIN lab.enroll e
        ON e.student_id = s.student_id
ORDER BY s.student_id;

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

-- ------------------------------------------------------------
-- 문항 9. 모든 직원과 그 매니저 이름 (SELF JOIN)
--   기대 행 수: 311 (CEO는 manager_name NULL)
-- ------------------------------------------------------------
SELECT e.emp_id, e.name, m.name AS manager_name
FROM lab.emp e
LEFT JOIN lab.emp m
       ON m.emp_id = e.manager_id
ORDER BY e.emp_id;

-- ------------------------------------------------------------
-- 문항 10. "모든 학생 기준" 과목 분포 → LEFT JOIN + 집계
--   기대 행 수: 22 (Course_1~20 + DB + 미수강 NULL 그룹)
-- ------------------------------------------------------------
SELECT e.course,
       COUNT(s.student_id) AS student_count
FROM lab.student s
LEFT JOIN lab.enroll e
       ON e.student_id = s.student_id
GROUP BY e.course
ORDER BY e.course NULLS LAST;

-- ------------------------------------------------------------
-- 문항 11. DB 과목을 듣지 않은 모든 학생을 나열
--   기대 행 수: 893 (전체 1,000 - DB 수강 107)
-- ------------------------------------------------------------
SELECT s.student_id, s.name
FROM lab.student s
WHERE NOT EXISTS (
    SELECT 1
    FROM lab.enroll e
    WHERE e.student_id = s.student_id
      AND e.course     = 'DB'
)
ORDER BY s.student_id;

-- ------------------------------------------------------------
-- 문항 12. 과목별 운영 책임 매니저 매핑 테이블 course_owner 생성 후
--          과목별 수강 인원 + 책임 매니저 이름 리포트
--   매핑 규칙: enroll의 전체 과목(23개: Course_1~20, DB, AI, ML)을
--             과목명 순으로 매니저(Mgr_2~Mgr_11, emp_id 2~11)에 라운드로빈 배정
--   ※ 사전 권한: skala_user로 FK를 만들려면 관리자 계정에서
--      GRANT REFERENCES ON lab.emp TO skala_user;  가 선행되어야 함
-- ------------------------------------------------------------
DROP TABLE IF EXISTS lab.course_owner;

CREATE TABLE lab.course_owner (
    course     VARCHAR(50) PRIMARY KEY,
    manager_id INT NOT NULL REFERENCES lab.emp(emp_id)
);

INSERT INTO lab.course_owner (course, manager_id)
SELECT course,
       2 + (ROW_NUMBER() OVER (ORDER BY course) - 1) % 10 AS manager_id
FROM (SELECT DISTINCT course FROM lab.enroll) c;

-- 리포트: 과목별 수강 인원 + 책임 매니저 이름
SELECT co.course,
       COUNT(e.student_id) AS enroll_count,
       m.name              AS manager_name
FROM lab.course_owner co
LEFT JOIN lab.enroll e ON e.course  = co.course
JOIN lab.emp        m ON m.emp_id   = co.manager_id
GROUP BY co.course, m.name
ORDER BY co.course;

-- ------------------------------------------------------------
-- 문항 13. 학생 × 과목 전체 조합(추천 후보), 샘플 100건만
--   CROSS JOIN 폭발 주의: 1,000명 × 23과목 = 23,000 조합 → LIMIT 100
-- ------------------------------------------------------------
SELECT s.student_id, s.name, c.course
FROM lab.student s
CROSS JOIN (SELECT DISTINCT course FROM lab.enroll) c
ORDER BY s.student_id, c.course
LIMIT 100;

-- ------------------------------------------------------------
-- 문항 14. 스칼라 서브쿼리(SELECT 절)로 학생 + 소속 학과명 붙이기
--   별도 학과 테이블이 없어 student를 스칼라 서브쿼리로 재참조하는 형태로 작성
-- ------------------------------------------------------------
SELECT s.student_id,
       s.name,
       (SELECT s2.major
        FROM lab.student s2
        WHERE s2.student_id = s.student_id) AS major_name
FROM lab.student s
ORDER BY s.student_id;

-- ------------------------------------------------------------
-- 문항 15. 전체 평균 GPA보다 높은 학생 (WHERE 서브쿼리)
--   기대 행 수: 495 (전체 평균 3.441, gpa 3.5 이상인 학생)
-- ------------------------------------------------------------
SELECT s.student_id, s.name, s.gpa
FROM lab.student s
WHERE s.gpa > (SELECT AVG(gpa) FROM lab.student)
ORDER BY s.student_id;

-- ------------------------------------------------------------
-- 문항 16. 자신의 학과 평균 GPA보다 높은 학생 (Correlated Subquery)
-- ------------------------------------------------------------
SELECT s.student_id, s.name, s.major, s.gpa
FROM lab.student s
WHERE s.gpa > (SELECT AVG(s2.gpa)
               FROM lab.student s2
               WHERE s2.major = s.major)
ORDER BY s.student_id;

-- ------------------------------------------------------------
-- 문항 17. 수강(enroll) 기록이 있는 학생만 (EXISTS)
--   기대 행 수: 900 (문항 6과 동일 집합)
-- ------------------------------------------------------------
SELECT s.student_id, s.name
FROM lab.student s
WHERE EXISTS (
    SELECT 1
    FROM lab.enroll e
    WHERE e.student_id = s.student_id
)
ORDER BY s.student_id;

-- ------------------------------------------------------------
-- 문항 18. 한 번도 수강하지 않은 학생 (NOT EXISTS)
--   기대 행 수: 100 (문항 5의 Anti-Join과 동일 결과)
-- ------------------------------------------------------------
SELECT s.student_id, s.name
FROM lab.student s
WHERE NOT EXISTS (
    SELECT 1
    FROM lab.enroll e
    WHERE e.student_id = s.student_id
)
ORDER BY s.student_id;

-- ------------------------------------------------------------
-- 문항 19. HR 학과 학생 일부와의 비교 데모 (ANY / ALL)
-- ------------------------------------------------------------
-- 19-1. > ANY : HR 학과의 최소 GPA(2.0)보다 높은 학생 → 967명
SELECT s.student_id, s.name, s.gpa
FROM lab.student s
WHERE s.gpa > ANY (SELECT gpa FROM lab.student WHERE major = 'HR')
ORDER BY s.student_id;

-- 19-2. > ALL : HR 학과의 최대 GPA(4.9)보다 높은 학생 → 0명 (의도된 결과)
SELECT s.student_id, s.name, s.gpa
FROM lab.student s
WHERE s.gpa > ALL (SELECT gpa FROM lab.student WHERE major = 'HR')
ORDER BY s.student_id;

-- ------------------------------------------------------------
-- 문항 20. CS 학과 학생 또는 DB 과목을 수강한 학생 목록 (UNION, 중복 제거)
-- ------------------------------------------------------------
SELECT s.student_id, s.name
FROM lab.student s
WHERE s.major = 'CS'

UNION

SELECT s.student_id, s.name
FROM lab.student s
JOIN lab.enroll e
  ON e.student_id = s.student_id
 AND e.course     = 'DB'

ORDER BY student_id;

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

