-- ------------------------------------------------------------
-- 문항 14. 스칼라 서브쿼리(SELECT 절)로 학생 + 소속 학과명 붙이기
--   별도 학과 테이블이 없어 student를 스칼라 서브쿼리로 재참조하는 형태로 작성
-- ------------------------------------------------------------
SELECT s.student_id,
       s.name,
       (SELECT s2.major
        FROM lab.student s2
        WHERE s2.student_id = s.student_id) AS major_name
FROM lab.student s
ORDER BY s.student_id;
