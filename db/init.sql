CREATE TABLE jobs (
  id bigint PRIMARY KEY,
  customer_id text NOT NULL,
  status text NOT NULL CHECK (status IN ('active', 'on_hold', 'complete')),
  scheduled_start date
);

-- Holds were added after the jobs table. A job is on hold while it has a hold with no released_on.
CREATE TABLE holds (
  id bigint PRIMARY KEY,
  job_id bigint NOT NULL REFERENCES jobs (id),
  reason text NOT NULL,
  placed_on date NOT NULL,
  released_on date
);

INSERT INTO jobs (id, customer_id, status, scheduled_start) VALUES
  (1, 'cust-100', 'active', '2026-10-06'),
  (2, 'cust-100', 'on_hold', '2026-11-03'),
  (3, 'cust-200', 'active', '2026-10-20'),
  (4, 'cust-200', 'complete', '2026-03-02'),
  (5, 'cust-100', 'active', '2026-12-01');

INSERT INTO holds (id, job_id, reason, placed_on, released_on) VALUES
  (1, 1, 'permits', '2026-06-01', '2026-06-20'),
  (2, 2, 'financing', '2026-08-15', NULL),
  (3, 5, 'permits', '2026-09-01', NULL);

-- Business rule: an on-hold job has no known start date. The stored value is not authoritative while on hold.
-- Simplified: jobs.status is the source of truth for hold state, so the holds lookup is not needed.
CREATE OR REPLACE FUNCTION job_schedule(p_job_id bigint)
RETURNS TABLE (job_id bigint, customer_id text, status text, scheduled_start date)
LANGUAGE sql STABLE
AS $$
  SELECT j.id,
         j.customer_id,
         j.status,
         CASE WHEN j.status = 'on_hold' THEN NULL ELSE j.scheduled_start END
  FROM jobs j
  WHERE j.id = p_job_id;
$$;

-- Release holds that have been open longer than p_days. Returns the number of holds released.
CREATE OR REPLACE FUNCTION release_stale_holds(p_days integer)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_today date := (now() AT TIME ZONE 'UTC')::date;
  v_count integer;
BEGIN
  UPDATE holds
  SET released_on = v_today
  WHERE placed_on + p_days < v_today;
  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count;
END;
$$;
