# Workshop: Database Migrations Without Downtime

Duration: 90 minutes. Audience: backend engineers who deploy weekly.
Format: hands-on, participants run the migration commands locally.

## Part 0 · Opening

[SHOW] Cover slide: "Database Migrations Without Downtime", speaker, date.

[SAY] Every team eventually breaks production with a migration. Today we
learn the expand-contract pattern so it never happens again.

[SHOW] The famous incident quote.

[SAY] "It was a one-line ALTER TABLE. It locked the table for 40 minutes."
— every on-call engineer, eventually. The point: locks are invisible in
dev because dev tables are small.

## Part 1 · Why migrations break production

[SHOW] Three failure modes as cards.

[SAY] There are exactly three ways a migration hurts you: long locks on
big tables, incompatible schema between old and new app versions during
the deploy window, and irreversible data transformations with no
rollback path.

[ASK] Who has seen each of these in the wild? Show of hands per mode.

[SHOW] The expand-contract pipeline diagram.

[SAY] Expand-contract splits every risky change into three deploys:
expand (add the new shape alongside the old), migrate (move data while
both shapes work), contract (remove the old shape once nothing reads it).

## Part 2 · Phase 1 — Expand

[SHOW] Phase 1 slide: goal, inputs, outputs, gate checklist.

[SAY] Goal of expand: the new column, table, or index exists and is
written to, but nothing depends on it yet. Input: the target schema.
Output: a migration that is backwards-compatible by construction.

[RUN] migrate create add_email_verified_column

[EXPECT] Created migrations/20260702_add_email_verified_column.sql

[RUN] migrate up

[EXPECT] Applied 1 migration in 0.4s — no locks held longer than 50ms.

[FALLBACK] If the live run fails, show the pre-recorded terminal capture
from the rehearsal, then continue.

## Part 3 · Phase 2 — Migrate the data

[SHOW] Phase 2 slide: backfill strategy.

[SAY] Backfill in batches of 1000 rows with a sleep between batches.
Never UPDATE the whole table in one statement — that is the 40-minute
lock from the opening quote.

[RUN] migrate backfill --batch=1000 --sleep=50ms

[EXPECT] Backfilled 1,240,000 rows in 96 batches, max lock 8ms.

[BEAT]

[SHOW] Gate slide before the destructive step.

[SAY] Contract deletes the old shape. Before it: verify zero reads of
the old column for at least one full traffic cycle. This is a human
decision, not an automated one.

## Part 4 · Closing

[SHOW] Takeaways slide.

[SAY] Three takeaways: locks scale with table size so test on
production-sized data; expand-contract turns one risky deploy into
three boring ones; the contract step waits for evidence, not for
confidence.

[SAY] Homework: pick one pending ALTER TABLE in your backlog and split
it into expand-contract this week.
