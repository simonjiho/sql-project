-- ------------------------------------------------------------
-- 문항 6. 한 과목 이상 수강한 학생 목록(중복 제거) (Semi-Join)
--   기대 행 수: 900 (1,000 - 수강 없는 학생 100)
-- ------------------------------------------------------------
SELECT DISTINCT s.student_id, s.name
FROM lab.student s
INNER JOIN lab.enroll e
        ON e.student_id = s.student_id
ORDER BY s.student_id;
