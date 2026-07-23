-- ------------------------------------------------------------
-- 문항 1. 학생과 수강을 INNER JOIN하여 수강 존재 학생의 과목/성적을 조회
--   기대 행 수: 2,300 (고아 수강 2건은 학생이 없어 제외됨)
-- ------------------------------------------------------------
SELECT s.student_id, s.name, e.course, e.grade
FROM lab.student s
INNER JOIN lab.enroll e
        ON e.student_id = s.student_id;
