# Backend Java Interview Task

## The business

You are building for a national home builder. Every house under construction is a job. Customers log in to see when their build starts. Builders see every job. A job goes on hold when financing or permits stall, and comes off hold when the hold is released. An on hold job has no start date, the schedule is unknown, not zero. Getting this wrong means a customer sees a date that isn't real.

## The task

Build one secured endpoint with an AI coding agent, then be ready to review what it produced with us live.

**Database.** Provided here. A `jobs` table (`id`, `customer_id`, `status`, `scheduled_start`), a `holds` table (`id`, `job_id`, `reason`, `placed_on`, `released_on`), and a PostgreSQL function `job_schedule(job_id)` that returns the schedule.

**Endpoint.** `GET /jobs/{id}/schedule` in Spring Boot. Returns JSON. Secured with Keycloak as the OIDC provider, bearer token required. Role `builder` can read any job. Role `customer` can read only jobs where `customer_id` matches the `customer_id` claim in their token.

**Contract.** Match this exactly. `scheduledStart` is always present and is `null` when the job is on hold.

```
GET /jobs/1/schedule
200 {"jobId":1,"customerId":"cust-100","status":"active","scheduledStart":"2026-10-06"}
```

Status codes: `200` job returned. `401` missing or invalid token. `403` a `customer` requesting another customer's job. `404` job does not exist.

Do not modify `db/` or `keycloak/`. Build on top of them.

**Agent.** Use Claude Code or Cursor to produce the endpoint. Have the agent work on a branch in your copy of this repo and open a pull request from that branch into `main`. Keep the pull request exactly as the agent produced it. Do not fix it before the call. You will review it with us live. Your repo must be public. Send the pull request link to your recruiter before the call.

## Time box

One hour. Unpolished is fine. An incomplete build you can explain beats a polished one you can't.

## What to have open on the call

* The pull request the agent produced (the diff)
* The prompt you gave the agent, and any rules or context files you gave it
* The stack and your app running, so you can hit the endpoint with each token
* Claude Code or Cursor open

## What we will do on the call

Thirty minutes. You walk us through what you built and how. Then you review the agent's pull request out loud: what you keep, what you toss, what you redo, and for each one how you know. We are grading how you think about generated code, not how much you built.

Areas we may cover:

* How you verified what the agent produced
* Where the business rules live, and why
* What you would test first, and why
* How this would fit beside a legacy system
* What breaks first under load

There is one open pull request on this repository. It is not part of the task and you do not need to touch it. If you read it before the call, we may ask what you think of it.

## Quick Start

Click "Use this template" on https://github.com/cconway141/vice-java-test to create your own public copy, then clone your copy. You need Docker, Java 17 or newer, and Maven or Gradle. Ports 5432, 8080 and 8081 must be free.

### 1. Start the stack

This returns when Postgres and Keycloak are both ready, about 30 seconds:

```
docker compose up -d --wait
```

Keycloak admin console is at http://localhost:8081 (login `admin` / `admin`).

### 2. Get a token

Three users, all with password `password`: `builder1`, `customer100`, `customer200`.

Mac, Linux, Git Bash or WSL:

```
./get-token.sh builder1
```

Windows PowerShell:

```
.\get-token.ps1 builder1
```

### 3. Build the endpoint

Have the agent build the Spring Boot app in your copy of this repo, running on port 8080, against the stack from step 1.

### 4. Call it

With a builder token (any job) and with a customer200 token (forbidden for job 1 once your app enforces the rule):

Mac, Linux, Git Bash or WSL:

```
curl -H "Authorization: Bearer $(./get-token.sh builder1)" http://localhost:8080/jobs/1/schedule
curl -H "Authorization: Bearer $(./get-token.sh customer200)" http://localhost:8080/jobs/1/schedule
```

Windows PowerShell:

```
curl.exe -H "Authorization: Bearer $(.\get-token.ps1 builder1)" http://localhost:8080/jobs/1/schedule
curl.exe -H "Authorization: Bearer $(.\get-token.ps1 customer200)" http://localhost:8080/jobs/1/schedule
```

To reset the database and realm: `docker compose down -v`, then start again.
