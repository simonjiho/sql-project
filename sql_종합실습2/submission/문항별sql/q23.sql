-- ------------------------------------------------------------
-- 문항 23. 학과별 GPA 상위 3명 (Window Function)
--   - ROW_NUMBER() OVER (PARTITION BY major ORDER BY gpa DESC, student_id)
--   - RANK() / DENSE_RANK() 동점 처리 비교
--   - COUNT() OVER (PARTITION BY major) → total_in_major
--   기대 행 수: 18 (6개 학과 × 3명)
-- ------------------------------------------------------------

-- 23-1. CTE 방식
WITH ranked AS (
    SELECT student_id, name, major, gpa,
           ROW_NUMBER()  OVER (PARTITION BY major ORDER BY gpa DESC, student_id) AS row_no,
           RANK()        OVER (PARTITION BY major ORDER BY gpa DESC)             AS rank_no,
           DENSE_RANK()  OVER (PARTITION BY major ORDER BY gpa DESC)             AS dense_rank_no,
           COUNT(*)      OVER (PARTITION BY major)                               AS total_in_major
    FROM lab.student
)
SELECT student_id, name, major, gpa, row_no, rank_no, dense_rank_no, total_in_major
FROM ranked
WHERE row_no <= 3
ORDER BY major, row_no;

-- 23-2. 서브쿼리(인라인 뷰) 방식
SELECT student_id, name, major, gpa, row_no, rank_no, dense_rank_no, total_in_major
FROM (
    SELECT student_id, name, major, gpa,
           ROW_NUMBER()  OVER (PARTITION BY major ORDER BY gpa DESC, student_id) AS row_no,
           RANK()        OVER (PARTITION BY major ORDER BY gpa DESC)             AS rank_no,
           DENSE_RANK()  OVER (PARTITION BY major ORDER BY gpa DESC)             AS dense_rank_no,
           COUNT(*)      OVER (PARTITION BY major)                               AS total_in_major
    FROM lab.student
) ranked
WHERE row_no <= 3
ORDER BY major, row_no;
