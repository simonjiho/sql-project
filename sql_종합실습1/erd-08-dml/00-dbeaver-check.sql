SELECT
    current_database() AS database_name,
    current_user AS user_name,
    current_schema() AS schema_name,
    COUNT(*) FILTER (WHERE table_schema = 'academic') AS academic_tables
FROM information_schema.tables;

SELECT 'department' AS table_name, COUNT(*) AS row_count FROM academic.department
UNION ALL SELECT 'professor', COUNT(*) FROM academic.professor
UNION ALL SELECT 'subject', COUNT(*) FROM academic.subject
UNION ALL SELECT 'student', COUNT(*) FROM academic.student
UNION ALL SELECT 'course_offering', COUNT(*) FROM academic.course_offering
UNION ALL SELECT 'enrollment', COUNT(*) FROM academic.enrollment
ORDER BY table_name;
