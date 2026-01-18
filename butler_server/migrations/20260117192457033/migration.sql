BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "google_calendar_connection" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "google_calendar_connection" (
    "id" bigserial PRIMARY KEY,
    "userId" text NOT NULL,
    "accessToken" text NOT NULL,
    "refreshToken" text NOT NULL,
    "tokenExpiry" timestamp without time zone NOT NULL,
    "googleEmail" text,
    "isActive" boolean NOT NULL,
    "connectedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastSyncAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "user_idx" ON "google_calendar_connection" USING btree ("userId");


--
-- MIGRATION VERSION FOR butler
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('butler', '20260117192457033', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260117192457033', "timestamp" = now();

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
    VALUES ('serverpod_auth_idp', '20251208110420531-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110420531-v3-0-0', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20251208110412389-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110412389-v3-0-0', "timestamp" = now();


COMMIT;
