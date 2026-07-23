-- ------------------------------------------------------------
-- 문항 13. 학생 × 과목 전체 조합(추천 후보), 샘플 100건만
--   CROSS JOIN 폭발 주의: 1,000명 × 23과목 = 23,000 조합 → LIMIT 100
-- ------------------------------------------------------------
SELECT s.student_id, s.name, c.course
FROM lab.student s
CROSS JOIN (SELECT DISTINCT course FROM lab.enroll) c
ORDER BY s.student_id, c.course
LIMIT 100;
