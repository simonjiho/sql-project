-- ------------------------------------------------------------
-- 문항 24. LAG() — 학생별 이전 수강 과목 대비 성적 변화
--   - grade → 점수 변환: A=4, B=3, C=2, D=1
--   - LAG(score) OVER (PARTITION BY student_id ORDER BY course)
--   - diff = 현재 점수 - 이전 점수, 상승/유지/하락 표시
--   - score_range = 학생별 최고점 - 최저점 (Window Function)
--   기대 행 수: 2,302 (enroll 전체)
-- ------------------------------------------------------------
SELECT student_id, course, score,
       LAG(score) OVER w                AS prev_score,
       score - LAG(score) OVER w        AS diff,
       CASE
           WHEN LAG(score) OVER w IS NULL       THEN '(첫 과목)'
           WHEN score - LAG(score) OVER w > 0   THEN '상승'
           WHEN score - LAG(score) OVER w = 0   THEN '유지'
           ELSE                                      '하락'
       END AS trend,
       MAX(score) OVER (PARTITION BY student_id)
     - MIN(score) OVER (PARTITION BY student_id) AS score_range
FROM (
    SELECT student_id, course,
           CASE grade WHEN 'A' THEN 4 WHEN 'B' THEN 3
                      WHEN 'C' THEN 2 WHEN 'D' THEN 1 END AS score
    FROM lab.enroll
) e
WINDOW w AS (PARTITION BY student_id ORDER BY course)
ORDER BY student_id, course;
