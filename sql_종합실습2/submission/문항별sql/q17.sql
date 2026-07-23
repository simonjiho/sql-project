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
