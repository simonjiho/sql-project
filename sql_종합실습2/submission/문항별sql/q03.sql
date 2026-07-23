-- ------------------------------------------------------------
-- 문항 3. 수강이 기준. 학생이 없으면 학생 정보가 NULL
--   기대 행 수: 2,302 (고아 수강 1001·1010 포함, 해당 행 name IS NULL)
-- ------------------------------------------------------------
SELECT e.student_id, e.course, e.grade, s.name
FROM lab.student s
RIGHT JOIN lab.enroll e
        ON e.student_id = s.student_id;
