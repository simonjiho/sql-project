-- ------------------------------------------------------------
-- 문항 20. CS 학과 학생 또는 DB 과목을 수강한 학생 목록 (UNION, 중복 제거)
-- ------------------------------------------------------------
SELECT s.student_id, s.name
FROM lab.student s
WHERE s.major = 'CS'

UNION

SELECT s.student_id, s.name
FROM lab.student s
JOIN lab.enroll e
  ON e.student_id = s.student_id
 AND e.course     = 'DB'

ORDER BY student_id;
