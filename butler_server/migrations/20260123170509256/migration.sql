BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "chat_message" (
    "id" bigserial PRIMARY KEY,
    "content" text NOT NULL,
    "isUser" boolean NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "userId" bigint NOT NULL
);


--
-- MIGRATION VERSION FOR butler
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('butler', '20260123170509256', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260123170509256', "timestamp" = now();

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
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20251208110412389-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110412389-v3-0-0', "timestamp" = now();


COMMIT;
