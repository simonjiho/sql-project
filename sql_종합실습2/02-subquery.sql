-- ============================================================
-- 종합실습 2 — 심화 과제 (문항 11~20) : 서브쿼리·집합 연산
-- 실행 환경: skala_db / lab 스키마 / skala_user
--   psql -h localhost -U skala_user -d skala_db -f 02-subquery.sql
-- ============================================================

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
