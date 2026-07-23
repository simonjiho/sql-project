-- ------------------------------------------------------------
-- 문항 16. 자신의 학과 평균 GPA보다 높은 학생 (Correlated Subquery)
-- ------------------------------------------------------------
SELECT s.student_id, s.name, s.major, s.gpa
FROM lab.student s
WHERE s.gpa > (SELECT AVG(s2.gpa)
               FROM lab.student s2
               WHERE s2.major = s.major)
ORDER BY s.student_id;
