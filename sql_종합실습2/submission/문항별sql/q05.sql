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
