BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "user_profile" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "user_profile" (
    "id" bigserial PRIMARY KEY,
    "userId" uuid NOT NULL,
    "name" text NOT NULL,
    "bio" text,
    "goals" text,
    "preferences" text,
    "phoneNumber" text,
    "timezone" text,
    "dateOfBirth" timestamp without time zone,
    "location" text
);


--
-- MIGRATION VERSION FOR butler
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('butler', '20260124105242278', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260124105242278', "timestamp" = now();

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
