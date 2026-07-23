-- ------------------------------------------------------------
-- 문항 10. "모든 학생 기준" 과목 분포 → LEFT JOIN + 집계
--   기대 행 수: 22 (Course_1~20 + DB + 미수강 NULL 그룹)
-- ------------------------------------------------------------
SELECT e.course,
       COUNT(s.student_id) AS student_count
FROM lab.student s
LEFT JOIN lab.enroll e
       ON e.student_id = s.student_id
GROUP BY e.course
ORDER BY e.course NULLS LAST;
