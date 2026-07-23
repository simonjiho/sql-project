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
