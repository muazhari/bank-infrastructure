-- install pggcrypto
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- create table account
DROP TABLE IF EXISTS account;
CREATE TABLE account
(
    id         uuid PRIMARY KEY,
    email      text unique,
    password   text,
    created_at timestamptz,
    updated_at timestamptz
);

-- create table account_type
DROP TABLE IF EXISTS account_type;
CREATE TABLE account_type
(
    id         uuid PRIMARY KEY,
    name       text unique,
    created_at timestamptz,
    updated_at timestamptz
);

-- create table account_type_map
DROP TABLE IF EXISTS account_type_map;
CREATE TABLE account_type_map
(
    id              uuid PRIMARY KEY,
    account_id      uuid,
    account_type_id uuid,
    created_at      timestamptz,
    updated_at      timestamptz
);

-- create table ledger
DROP TABLE IF EXISTS ledger;
CREATE TABLE ledger
(
    id         uuid PRIMARY KEY,
    account_id uuid,
    amount     numeric,
    created_at timestamptz,
    updated_at timestamptz
);

-- create table transaction
DROP TABLE IF EXISTS transaction;
CREATE TABLE transaction
(
    id            uuid PRIMARY KEY,
    ledger_id     uuid,
    amount_before numeric,
    amount_after  numeric,
    timestamp     timestamptz,
    created_at    timestamptz,
    updated_at    timestamptz
);

-- populate account
INSERT INTO account (id, email, password, created_at, updated_at)
VALUES ('1da428b8-e9f8-4ff9-9278-12c811e7a980'::uuid, 'email0@mail.com', crypt('password0', gen_salt('bf')),
        now()::timestamptz,
        now()::timestamptz),
       ('1da428b8-e9f8-4ff9-9278-12c811e7a981'::uuid, 'email1@mail.com', crypt('password1', gen_salt('bf')),
        now()::timestamptz,
        now()::timestamptz);

-- populate account_type
INSERT INTO account_type (id, name, created_at, updated_at)
VALUES ('44bf8838-e8e6-455c-bedd-06e27e0b7340'::uuid, 'admin', now()::timestamptz, now()::timestamptz),
       ('44bf8838-e8e6-455c-bedd-06e27e0b7341'::uuid, 'user', now()::timestamptz, now()::timestamptz);

-- populate account_type_map
INSERT INTO account_type_map (id, account_id, account_type_id, created_at, updated_at)
VALUES ('e76e9561-2156-4ba3-8479-54bbe4bf90b0'::uuid, '1da428b8-e9f8-4ff9-9278-12c811e7a980'::uuid,
        '44bf8838-e8e6-455c-bedd-06e27e0b7340'::uuid,
        now()::timestamptz, now()::timestamptz),
       ('e76e9561-2156-4ba3-8479-54bbe4bf90b1'::uuid, '1da428b8-e9f8-4ff9-9278-12c811e7a981'::uuid,
        '44bf8838-e8e6-455c-bedd-06e27e0b7341'::uuid,
        now()::timestamptz, now()::timestamptz);

-- populate ledger
INSERT INTO ledger (id, account_id, amount, created_at, updated_at)
VALUES ('9c8a0f91-ff2b-400d-9bfb-4e49a7616850'::uuid, '1da428b8-e9f8-4ff9-9278-12c811e7a980'::uuid, -100,
        now()::timestamptz, now()::timestamptz),
       ('9c8a0f91-ff2b-400d-9bfb-4e49a7616851'::uuid, '1da428b8-e9f8-4ff9-9278-12c811e7a980'::uuid, 100,
        now()::timestamptz, now()::timestamptz);

-- populate transaction
INSERT INTO transaction (id, ledger_id, amount_before, amount_after, timestamp, created_at, updated_at)
VALUES ('9a1a9cd3-7cb1-4d5c-85fe-b79f709d1200'::uuid, '9c8a0f91-ff2b-400d-9bfb-4e49a7616850'::uuid, 100, 0,
        (now() - '2 second'::interval)::timestamptz, (now() - '2 second'::interval)::timestamptz,
        (now() - '2 second'::interval)::timestamptz),
       ('9a1a9cd3-7cb1-4d5c-85fe-b79f709d1201'::uuid, '9c8a0f91-ff2b-400d-9bfb-4e49a7616850'::uuid, 0, -100,
        (now() - '1 second'::interval)::timestamptz, (now() - '1 second'::interval)::timestamptz,
        (now() - '1 second'::interval)::timestamptz),
       ('9a1a9cd3-7cb1-4d5c-85fe-b79f709d1202'::uuid, '9c8a0f91-ff2b-400d-9bfb-4e49a7616851'::uuid, -100, 0,
        (now() - '2 second'::interval)::timestamptz, (now() - '2 second'::interval)::timestamptz,
        (now() - '2 second'::interval)::timestamptz),
       ('9a1a9cd3-7cb1-4d5c-85fe-b79f709d1203'::uuid, '9c8a0f91-ff2b-400d-9bfb-4e49a7616851'::uuid, 0, 100,
        (now() - '1 second'::interval)::timestamptz, (now() - '1 second'::interval)::timestamptz,
        (now() - '1 second'::interval)::timestamptz);

-- validate last transaction amount_after is equal to current ledger amount
-- break down with the subqueries to make it easier to understand
select l1.id,
       l1.amount,
       t1.id,
       t1.amount_after,
       l1.amount = t1.amount_after as is_valid
from ledger l1
         inner join
     (SELECT t1.id,
             t1.ledger_id,
             t1.amount_after
      FROM transaction t1
      where t1.updated_at = (select max(t1.updated_at) from transaction t1)) t1
     on l1.id = t1.ledger_id;


select *
from account;







