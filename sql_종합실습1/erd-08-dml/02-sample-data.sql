\set ON_ERROR_STOP on
\connect academic_management
SET search_path TO academic, public;

BEGIN;

INSERT INTO department (department_code, department_name) VALUES
('CSE', '컴퓨터공학과'),
('AID', '인공지능학과'),
('DSC', '데이터사이언스학과'),
('BIZ', '경영학과'),
('DES', '디자인학과'),
('MEC', '기계공학과'),
('EEE', '전자공학과'),
('CHM', '화학공학과'),
('MAT', '수학과'),
('PHY', '물리학과');

INSERT INTO professor (employee_number, professor_name, email, employment_status, department_id) VALUES
('P001', '김현우', 'hyunwoo.kim@univ.ac.kr', 'ACTIVE', 1),
('P002', '이수진', 'sujin.lee@univ.ac.kr', 'ACTIVE', 1),
('P003', '박지훈', 'jihoon.park@univ.ac.kr', 'ACTIVE', 2),
('P004', '최예린', 'yerin.choi@univ.ac.kr', 'ACTIVE', 2),
('P005', '정도윤', 'doyoon.jeong@univ.ac.kr', 'ACTIVE', 3),
('P006', '한서연', 'seoyeon.han@univ.ac.kr', 'ACTIVE', 3),
('P007', '윤민석', 'minseok.yoon@univ.ac.kr', 'ACTIVE', 4),
('P008', '송하은', 'haeun.song@univ.ac.kr', 'ACTIVE', 4),
('P009', '강준호', 'junho.kang@univ.ac.kr', 'ACTIVE', 5),
('P010', '임채원', 'chaewon.lim@univ.ac.kr', 'RETIRED', 5);

INSERT INTO subject (subject_code, subject_name, credits) VALUES
('CS101', '프로그래밍기초', 3),
('CS201', '자료구조', 3),
('CS301', '데이터베이스', 3),
('CS302', '운영체제', 3),
('AI201', '인공지능개론', 3),
('AI301', '머신러닝', 3),
('AI302', '딥러닝', 3),
('DS201', '데이터분석', 3),
('DS301', '데이터시각화', 2),
('BA101', '경영학원론', 3),
('DE101', '디자인사고', 2),
('GE101', '대학생활과진로', 1);

INSERT INTO student
    (student_number, student_name, email, grade_year, academic_status, admission_date, phone_number, department_id)
VALUES
('2026001', '김민준', 'minjun.kim@student.ac.kr', 1, 'ENROLLED', '2026-03-02', '010-1000-0001', 1),
('2026002', '이서윤', 'seoyoon.lee@student.ac.kr', 1, 'ENROLLED', '2026-03-02', NULL, 2),
('2025003', '박도현', 'dohyun.park@student.ac.kr', 2, 'ENROLLED', '2025-03-04', '010-1000-0003', 1),
('2025004', '최지우', 'jiwoo.choi@student.ac.kr', 2, 'LEAVE', '2025-03-04', NULL, 3),
('2024005', '정하준', 'hajun.jeong@student.ac.kr', 3, 'ENROLLED', '2024-03-04', '010-1000-0005', 2),
('2024006', '한유나', 'yuna.han@student.ac.kr', 3, 'ENROLLED', '2024-03-04', '010-1000-0006', 3),
('2023007', '윤시우', 'siwoo.yoon@student.ac.kr', 4, 'ENROLLED', '2023-03-02', NULL, 4),
('2023008', '송서아', 'seoa.song@student.ac.kr', 4, 'GRADUATED', '2023-03-02', '010-1000-0008', 5),
('2026009', '강주원', 'juwon.kang@student.ac.kr', 1, 'ENROLLED', '2026-03-02', NULL, 3),
('2025010', '임다은', 'daeun.lim@student.ac.kr', 2, 'ENROLLED', '2025-03-04', '010-1000-0010', 4),
('2024011', '오지호', 'jiho.oh@student.ac.kr', 3, 'ENROLLED', '2024-03-04', '010-1000-0011', 1),
('2023012', '서아린', 'arin.seo@student.ac.kr', 4, 'EXPELLED', '2023-03-02', NULL, 2);

INSERT INTO course_offering
    (subject_id, professor_id, opening_year, semester, section, capacity, opening_status)
VALUES
(1, 1, 2026, 1, '01', 30, 'RECRUITING'),
(2, 2, 2026, 1, '01', 25, 'RECRUITING'),
(3, 1, 2026, 1, '01', 30, 'RECRUITING'),
(4, 2, 2026, 1, '01', 25, 'CLOSED'),
(5, 3, 2026, 1, '01', 35, 'RECRUITING'),
(6, 4, 2026, 1, '01', 25, 'RECRUITING'),
(7, 4, 2026, 1, '01', 20, 'CLOSED'),
(8, 5, 2026, 1, '01', 30, 'RECRUITING'),
(9, 6, 2026, 1, '01', 20, 'RECRUITING'),
(10, 7, 2026, 1, '01', 40, 'RECRUITING'),
(11, 9, 2026, 1, '01', 20, 'CANCELLED'),
(12, 8, 2026, 1, '01', 50, 'RECRUITING');

INSERT INTO enrollment
    (student_id, class_id, enrollment_status, enrolled_at, cancelled_at, grade)
VALUES
(1, 1, 'ENROLLED', '2026-03-03 09:00+09', NULL, 'A0'),
(1, 3, 'ENROLLED', '2026-03-03 09:05+09', NULL, 'B+'),
(2, 1, 'ENROLLED', '2026-03-03 09:10+09', NULL, NULL),
(2, 5, 'ENROLLED', '2026-03-03 09:12+09', NULL, 'A+'),
(3, 2, 'ENROLLED', '2026-03-03 09:15+09', NULL, 'B0'),
(3, 3, 'ENROLLED', '2026-03-03 09:17+09', NULL, 'A0'),
(4, 8, 'CANCELLED', '2026-03-03 09:20+09', '2026-03-10 15:00+09', NULL),
(5, 5, 'ENROLLED', '2026-03-03 09:22+09', NULL, 'A+'),
(5, 6, 'ENROLLED', '2026-03-03 09:25+09', NULL, 'A0'),
(6, 8, 'ENROLLED', '2026-03-03 09:30+09', NULL, 'B+'),
(6, 9, 'ENROLLED', '2026-03-03 09:33+09', NULL, NULL),
(7, 10, 'ENROLLED', '2026-03-03 09:35+09', NULL, 'B0'),
(7, 12, 'ENROLLED', '2026-03-03 09:38+09', NULL, 'A0'),
(8, 11, 'CANCELLED', '2026-03-03 09:40+09', '2026-03-12 10:00+09', NULL),
(9, 1, 'ENROLLED', '2026-03-03 09:42+09', NULL, NULL),
(9, 8, 'ENROLLED', '2026-03-03 09:45+09', NULL, 'B+'),
(10, 10, 'ENROLLED', '2026-03-03 09:48+09', NULL, 'A0'),
(10, 12, 'ENROLLED', '2026-03-03 09:50+09', NULL, NULL),
(11, 2, 'ENROLLED', '2026-03-03 09:52+09', NULL, 'A+'),
(11, 3, 'ENROLLED', '2026-03-03 09:55+09', NULL, 'A0'),
(12, 5, 'CANCELLED', '2026-03-03 10:00+09', '2026-03-05 11:00+09', NULL),
(3, 4, 'ENROLLED', '2026-03-03 10:05+09', NULL, 'B+'),
(5, 7, 'ENROLLED', '2026-03-03 10:10+09', NULL, 'A0'),
(6, 6, 'ENROLLED', '2026-03-03 10:15+09', NULL, 'B0');

COMMIT;

\echo '샘플 데이터 입력 완료'
SELECT 'department' AS table_name, COUNT(*) AS row_count FROM department
UNION ALL SELECT 'professor', COUNT(*) FROM professor
UNION ALL SELECT 'subject', COUNT(*) FROM subject
UNION ALL SELECT 'student', COUNT(*) FROM student
UNION ALL SELECT 'course_offering', COUNT(*) FROM course_offering
UNION ALL SELECT 'enrollment', COUNT(*) FROM enrollment
ORDER BY table_name;
