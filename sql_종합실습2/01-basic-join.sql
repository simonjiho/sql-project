-- ============================================================
-- 종합실습 2 — 기본 과제 (문항 1~10) : JOIN
-- 실행 환경: skala_db / lab 스키마 / skala_user
--   psql -h localhost -U skala_user -d skala_db -f 01-basic-join.sql
-- 화면 캡처 시 대량 결과는 슬라이드 안내에 따라 LIMIT 5를 덧붙여 확인 가능
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
