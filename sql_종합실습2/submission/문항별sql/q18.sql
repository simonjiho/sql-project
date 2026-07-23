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
