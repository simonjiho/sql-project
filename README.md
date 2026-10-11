# sql-project

SKALA 4기의 PostgreSQL 종합실습 1~3을 모은 저장소다. 실습마다 폴더가 하나씩 있다.

## sql_종합실습1 — 학사관리시스템 ERD와 기초 SQL

- `erd-01` ~ `erd-07`: 요구사항 명세, 엔티티·속성, 정규화·비정규화 검토, 관계·카디널리티, dbdiagram용 DBML(`erd-06-01`), DDL(`erd-06-03`), 최종 검토 순으로 단계마다 문서를 남겼다. `erd-00-progress.md`가 진행표다
- 설계는 `academic` 스키마 6개, `audit` 스키마 12개, 모두 18개 테이블이다
- `erd-08-dml/`: `academic`의 6개 테이블을 실제로 만들고 조회하는 스크립트. `01-schema.sql`(DB와 테이블), `02-sample-data.sql`(예시 자료), `03-queries.sql`(8문항: `WHERE`·`ORDER BY`, `COALESCE`, `CASE WHEN`, 날짜 함수, 수강신청 `JOIN`, 강좌별 잔여석 등). `*-dbeaver-*.sql`은 DBeaver용, `results/`는 실행 로그다
- `submission/`: 제출용 ERD 이미지와 보고서(PDF). `sql_종합실습1.zip`은 이 폴더를 압축한 파일이다

## sql_종합실습2 — JOIN·서브쿼리·윈도 함수 25문항

- `종합실습2_postgres_join_lab_large*.sql`: 실습 환경 스크립트. `skala_db` 데이터베이스의 `lab` 스키마에 `student`, `enroll`, `customers`, `orders`, `emp` 테이블을 만들고 자료를 채운다. `(psql)` 파일은 psql용 한 파일이고 `_1`, `_2`는 DBeaver용으로 나눈 것이다
- `01-basic-join.sql`(1~10): INNER·LEFT·RIGHT·FULL OUTER JOIN, Anti·Semi Join, SELF JOIN, 집계
- `02-subquery.sql`(11~20): 서브쿼리, CROSS JOIN, EXISTS·NOT EXISTS, ANY·ALL, UNION
- `03-advanced.sql`(21~25): ROLLUP, 재귀 CTE, 윈도 함수(순위, LAG, 누적합·이동평균)
- `results/`는 실행 결과, `submission/`은 문항별 SQL(`q01`~`q25`)·psql 실행 출력·전체 쿼리·보고서(PDF)다. `00-progress.md`가 진행표다

## sql_종합실습3 — HR DB 쿼리 튜닝

스크립트 하나만 있다. `hr` 스키마에 직원 약 5만 건을 만든 뒤, 느린 쿼리를 `EXPLAIN (ANALYZE, BUFFERS)`로 재고 인덱스를 만들어 다시 재는 LAB A~E가 들어 있다. A는 `lower(email)` 함수 인덱스, B는 앞쪽 와일드카드 `LIKE`, C는 조인·정렬 복합 인덱스, D는 `OR` 조건, E는 `ANALYZE` 통계 갱신이다.

## 실행

모두 PostgreSQL에서 돌린다. 종합실습1은 `postgres` 데이터베이스에 접속한 psql에서 `01-schema.sql`, `02-sample-data.sql`, `03-queries.sql` 순서로 실행하면 `academic_management` 데이터베이스가 만들어진다. 종합실습2는 환경 스크립트로 `skala_db`를 만든 뒤 문항 파일을 실행한다.

```bash
psql -U postgres -f "sql_종합실습2/(psql) 종합실습2_postgres_join_lab_large.sql"   # 실행 중 비밀번호를 묻는다
psql -h localhost -U skala_user -d skala_db -f sql_종합실습2/01-basic-join.sql
```
