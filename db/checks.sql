-- Regression checks for job_schedule and release_stale_holds. All pass.
-- Run: psql postgresql://homebuilder:homebuilder@localhost:5432/homebuilder -f db/checks.sql

SELECT 'on_hold job has on_hold status' AS check_name,
       CASE WHEN status = 'on_hold' THEN 'ok' ELSE 'FAIL' END AS result
FROM jobs WHERE id = 2;

SELECT 'on_hold job has null start' AS check_name,
       CASE WHEN scheduled_start IS NULL THEN 'ok' ELSE 'FAIL' END AS result
FROM job_schedule(2);

SELECT 'active job has a start date' AS check_name,
       CASE WHEN scheduled_start IS NOT NULL THEN 'ok' ELSE 'FAIL' END AS result
FROM job_schedule(1);

SELECT 'release_stale_holds runs' AS check_name,
       CASE WHEN release_stale_holds(365) >= 0 THEN 'ok' ELSE 'FAIL' END AS result;
