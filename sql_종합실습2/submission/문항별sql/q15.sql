-- ------------------------------------------------------------
-- 문항 15. 전체 평균 GPA보다 높은 학생 (WHERE 서브쿼리)
--   기대 행 수: 495 (전체 평균 3.441, gpa 3.5 이상인 학생)
-- ------------------------------------------------------------
SELECT s.student_id, s.name, s.gpa
FROM lab.student s
WHERE s.gpa > (SELECT AVG(gpa) FROM lab.student)
ORDER BY s.student_id;
