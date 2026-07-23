-- ------------------------------------------------------------
-- 문항 4. 학생/수강 모두 포함 (FULL OUTER JOIN)
--   기대 행 수: 2,402 (수강 2,300 + 수강 없는 학생 100 + 고아 수강 2)
-- ------------------------------------------------------------
SELECT s.student_id AS student_side_id, s.name,
       e.student_id AS enroll_side_id, e.course
FROM lab.student s
FULL OUTER JOIN lab.enroll e
             ON e.student_id = s.student_id;
