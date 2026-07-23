-- ------------------------------------------------------------
-- 문항 19. HR 학과 학생 일부와의 비교 데모 (ANY / ALL)
-- ------------------------------------------------------------
-- 19-1. > ANY : HR 학과의 최소 GPA(2.0)보다 높은 학생 → 967명
SELECT s.student_id, s.name, s.gpa
FROM lab.student s
WHERE s.gpa > ANY (SELECT gpa FROM lab.student WHERE major = 'HR')
ORDER BY s.student_id;

-- 19-2. > ALL : HR 학과의 최대 GPA(4.9)보다 높은 학생 → 0명 (의도된 결과)
SELECT s.student_id, s.name, s.gpa
FROM lab.student s
WHERE s.gpa > ALL (SELECT gpa FROM lab.student WHERE major = 'HR')
ORDER BY s.student_id;
