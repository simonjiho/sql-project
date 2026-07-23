-- ------------------------------------------------------------
-- 문항 12. 과목별 운영 책임 매니저 매핑 테이블 course_owner 생성 후
--          과목별 수강 인원 + 책임 매니저 이름 리포트
--   매핑 규칙: enroll의 전체 과목(23개: Course_1~20, DB, AI, ML)을
--             과목명 순으로 매니저(Mgr_2~Mgr_11, emp_id 2~11)에 라운드로빈 배정
--   ※ 사전 권한: skala_user로 FK를 만들려면 관리자 계정에서
--      GRANT REFERENCES ON lab.emp TO skala_user;  가 선행되어야 함
-- ------------------------------------------------------------
DROP TABLE IF EXISTS lab.course_owner;

CREATE TABLE lab.course_owner (
    course     VARCHAR(50) PRIMARY KEY,
    manager_id INT NOT NULL REFERENCES lab.emp(emp_id)
);

INSERT INTO lab.course_owner (course, manager_id)
SELECT course,
       2 + (ROW_NUMBER() OVER (ORDER BY course) - 1) % 10 AS manager_id
FROM (SELECT DISTINCT course FROM lab.enroll) c;

-- 리포트: 과목별 수강 인원 + 책임 매니저 이름
SELECT co.course,
       COUNT(e.student_id) AS enroll_count,
       m.name              AS manager_name
FROM lab.course_owner co
LEFT JOIN lab.enroll e ON e.course  = co.course
JOIN lab.emp        m ON m.emp_id   = co.manager_id
GROUP BY co.course, m.name
ORDER BY co.course;
