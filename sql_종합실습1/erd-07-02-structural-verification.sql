-- 7단계 ERD/DDL 구조 검증용 읽기 전용 SQL
-- erd-06-03-ddl.sql 실행 후 같은 데이터베이스에서 실행한다.

WITH actual AS (
    SELECT COUNT(*) AS count
    FROM information_schema.schemata
    WHERE schema_name IN ('academic', 'audit')
)
SELECT
    'schemas' AS check_item,
    2 AS expected_count,
    count AS actual_count,
    CASE WHEN count = 2 THEN 'PASS' ELSE 'FAIL' END AS result
FROM actual;

WITH expected(schema_name, expected_count) AS (
    VALUES ('academic', 6), ('audit', 12)
), actual AS (
    SELECT table_schema AS schema_name, COUNT(*) AS actual_count
    FROM information_schema.tables
    WHERE table_schema IN ('academic', 'audit')
      AND table_type = 'BASE TABLE'
    GROUP BY table_schema
)
SELECT
    e.schema_name || '_tables' AS check_item,
    e.expected_count,
    COALESCE(a.actual_count, 0) AS actual_count,
    CASE WHEN COALESCE(a.actual_count, 0) = e.expected_count THEN 'PASS' ELSE 'FAIL' END AS result
FROM expected AS e
LEFT JOIN actual AS a USING (schema_name)
ORDER BY e.schema_name;

WITH actual AS (
    SELECT COUNT(*) AS count
    FROM information_schema.table_constraints
    WHERE constraint_schema IN ('academic', 'audit')
      AND constraint_type = 'PRIMARY KEY'
)
SELECT
    'primary_keys' AS check_item,
    18 AS expected_count,
    count AS actual_count,
    CASE WHEN count = 18 THEN 'PASS' ELSE 'FAIL' END AS result
FROM actual;

WITH actual AS (
    SELECT COUNT(*) AS count
    FROM information_schema.table_constraints
    WHERE constraint_schema IN ('academic', 'audit')
      AND constraint_type = 'FOREIGN KEY'
)
SELECT
    'foreign_keys' AS check_item,
    24 AS expected_count,
    count AS actual_count,
    CASE WHEN count = 24 THEN 'PASS' ELSE 'FAIL' END AS result
FROM actual;

WITH expected(constraint_name) AS (
    VALUES
        ('A_R01'), ('A_R02'), ('A_R03'), ('A_R04'), ('A_R05'), ('A_R06'),
        ('U_R01'), ('U_R02'), ('U_R03'), ('U_R04'), ('U_R05'),
        ('U_R06'), ('U_R07'), ('U_R08'), ('U_R09'), ('U_R10'),
        ('U_R11'), ('U_R12'), ('U_R13'), ('U_R14'), ('U_R15'),
        ('U_R16'), ('U_R17'), ('U_R18')
), actual AS (
    SELECT constraint_name
    FROM information_schema.table_constraints
    WHERE constraint_schema IN ('academic', 'audit')
      AND constraint_type = 'FOREIGN KEY'
)
SELECT
    'relationship_ids' AS check_item,
    24 AS expected_count,
    COUNT(a.constraint_name) AS actual_count,
    CASE WHEN COUNT(a.constraint_name) = 24 THEN 'PASS' ELSE 'FAIL' END AS result
FROM expected AS e
LEFT JOIN actual AS a USING (constraint_name);

WITH expected(column_name) AS (
    VALUES ('changed_columns')
), actual AS (
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = 'audit'
      AND table_name = 'change_record'
      AND column_name = 'changed_columns'
      AND data_type = 'ARRAY'
)
SELECT
    'change_record_changed_columns' AS check_item,
    1 AS expected_count,
    COUNT(a.column_name) AS actual_count,
    CASE WHEN COUNT(a.column_name) = 1 THEN 'PASS' ELSE 'FAIL' END AS result
FROM expected AS e
LEFT JOIN actual AS a USING (column_name);

WITH actual AS (
    SELECT COUNT(*) AS count
    FROM information_schema.tables
    WHERE table_schema = 'audit'
      AND table_name = 'change_record_column'
      AND table_type = 'BASE TABLE'
)
SELECT
    'change_record_column_table_absent' AS check_item,
    0 AS expected_count,
    count AS actual_count,
    CASE WHEN count = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM actual;

WITH cross_schema_fk AS (
    SELECT COUNT(*) AS count
    FROM information_schema.referential_constraints AS rc
    WHERE rc.constraint_schema = 'audit'
      AND rc.unique_constraint_schema = 'academic'
)
SELECT
    'audit_to_academic_physical_fk' AS check_item,
    0 AS expected_count,
    count AS actual_count,
    CASE WHEN count = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM cross_schema_fk;

WITH expected(schema_name, expected_count) AS (
    VALUES ('academic', 5), ('audit', 10)
), actual AS (
    SELECT n.nspname AS schema_name, COUNT(*) AS actual_count
    FROM pg_type AS t
    JOIN pg_namespace AS n ON n.oid = t.typnamespace
    WHERE n.nspname IN ('academic', 'audit')
      AND t.typtype = 'e'
    GROUP BY n.nspname
)
SELECT
    e.schema_name || '_enums' AS check_item,
    e.expected_count,
    COALESCE(a.actual_count, 0) AS actual_count,
    CASE WHEN COALESCE(a.actual_count, 0) = e.expected_count THEN 'PASS' ELSE 'FAIL' END AS result
FROM expected AS e
LEFT JOIN actual AS a USING (schema_name)
ORDER BY e.schema_name;
