BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "calendar_event" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "calendar_event" (
    "id" bigserial PRIMARY KEY,
    "title" text NOT NULL,
    "startTime" timestamp without time zone NOT NULL,
    "endTime" timestamp without time zone NOT NULL,
    "description" text,
    "userId" text NOT NULL
);

--
-- ACTION DROP TABLE
--
DROP TABLE "task" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "task" (
    "id" bigserial PRIMARY KEY,
    "title" text NOT NULL,
    "isCompleted" boolean NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "userId" text NOT NULL
);


--
-- MIGRATION VERSION FOR butler
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('butler', '20260124124033210', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260124124033210', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20251208110333922-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110333922-v3-0-0', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260109031533194', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260109031533194', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth', '20250825102351908-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20250825102351908-v3-0-0', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20251208110412389-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110412389-v3-0-0', "timestamp" = now();


COMMIT;
