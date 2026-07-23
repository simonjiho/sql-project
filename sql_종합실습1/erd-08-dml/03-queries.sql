\set ON_ERROR_STOP on
\connect academic_management
SET search_path TO academic, public;
\pset null '(NULL)'

\echo '[문항 1] PostgreSQL 접속 및 환경 확인'
SELECT current_database() AS database_name,
       current_user AS user_name,
       current_schema() AS schema_name,
       version() AS postgresql_version;

\echo '[문항 2] WHERE + ORDER BY: 재학 중인 2학년 이상 학생'
SELECT s.student_number AS 학번,
       s.student_name AS 이름,
       d.department_name AS 학과,
       s.grade_year AS 학년
FROM student s
JOIN department d ON d.department_id = s.department_id
WHERE s.academic_status = 'ENROLLED'
  AND s.grade_year >= 2
ORDER BY s.grade_year DESC, s.student_name ASC;

\echo '[문항 3] COALESCE: 전화번호가 없으면 미등록 표시'
SELECT student_number AS 학번,
       student_name AS 이름,
       COALESCE(phone_number, '미등록') AS 전화번호
FROM student
ORDER BY student_number;

\echo '[문항 4] CASE WHEN: 학년별 안내 문구 표시'
SELECT student_number AS 학번,
       student_name AS 이름,
       grade_year AS 학년,
       CASE
           WHEN grade_year = 1 THEN '신입생'
           WHEN grade_year IN (2, 3) THEN '재학생'
           WHEN grade_year = 4 THEN '졸업반'
           ELSE '확인 필요'
       END AS 학년구분
FROM student
ORDER BY grade_year, student_number;

\echo '[문항 5] 날짜 함수: 입학 연도와 재학 기간 계산'
SELECT student_number AS 학번,
       student_name AS 이름,
       admission_date AS 입학일,
       EXTRACT(YEAR FROM admission_date)::INTEGER AS 입학연도,
       AGE(CURRENT_DATE, admission_date) AS 경과기간
FROM student
ORDER BY admission_date, student_number;

\echo '[문항 6] 수강신청 교차 테이블 JOIN 조회'
SELECT s.student_number AS 학번,
       s.student_name AS 학생명,
       sub.subject_code AS 교과목코드,
       sub.subject_name AS 교과목명,
       co.opening_year AS 개설연도,
       co.semester AS 학기,
       co.section AS 분반,
       p.professor_name AS 담당교수,
       e.enrollment_status AS 수강상태,
       COALESCE(e.grade::TEXT, '미정') AS 성적
FROM enrollment e
JOIN student s ON s.student_id = e.student_id
JOIN course_offering co ON co.class_id = e.class_id
JOIN subject sub ON sub.subject_id = co.subject_id
JOIN professor p ON p.professor_id = co.professor_id
ORDER BY s.student_number, sub.subject_code;

\echo '[문항 7] 강좌별 현재 수강 인원과 잔여석'
SELECT sub.subject_code AS 교과목코드,
       sub.subject_name AS 교과목명,
       co.section AS 분반,
       co.capacity AS 정원,
       COUNT(e.enrollment_id) FILTER (
           WHERE e.enrollment_status = 'ENROLLED'
       ) AS 현재수강인원,
       co.capacity - COUNT(e.enrollment_id) FILTER (
           WHERE e.enrollment_status = 'ENROLLED'
       ) AS 잔여석
FROM course_offering co
JOIN subject sub ON sub.subject_id = co.subject_id
LEFT JOIN enrollment e ON e.class_id = co.class_id
WHERE co.opening_year = 2026
  AND co.semester = 1
GROUP BY co.class_id, sub.subject_code, sub.subject_name,
         co.section, co.capacity
ORDER BY sub.subject_code, co.section;

\echo '[문항 8] 제약조건 확인용 테이블 목록과 건수'
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'academic'
ORDER BY table_name;

SELECT 'department' AS table_name, COUNT(*) AS row_count FROM department
UNION ALL SELECT 'professor', COUNT(*) FROM professor
UNION ALL SELECT 'subject', COUNT(*) FROM subject
UNION ALL SELECT 'student', COUNT(*) FROM student
UNION ALL SELECT 'course_offering', COUNT(*) FROM course_offering
UNION ALL SELECT 'enrollment', COUNT(*) FROM enrollment
ORDER BY table_name;
