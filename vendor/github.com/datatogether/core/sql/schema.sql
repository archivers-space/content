-- name: drop-all
DROP TABLE IF EXISTS urls, links, primers, sources, subprimers, alerts, context, metadata, supress_alerts, snapshots, collections, collection_items, archive_requests, uncrawlables, data_repos;

-- name: create-primers
CREATE TABLE IF NOT EXISTS primers (
  id               UUID PRIMARY KEY NOT NULL,
  created          timestamp NOT NULL default (now() at time zone 'utc'),
  updated          timestamp NOT NULL default (now() at time zone 'utc'),
  short_title      text NOT NULL default '',
  title            text NOT NULL default '',
  description      text NOT NULL default '',
  parent_id        text NOT NULL default '', -- this should be "UUID references primers(id)", but then we'd need to accept null values, no bueno
  stats            json,
  meta             json,
  deleted          boolean default false
);

-- name: create-sources
CREATE TABLE IF NOT EXISTS sources (
  id               UUID PRIMARY KEY NOT NULL,
  created          timestamp NOT NULL default (now() at time zone 'utc'),
  updated          timestamp NOT NULL default (now() at time zone 'utc'),
  title            text NOT NULL default '',
  description      text NOT NULL default '',
  url              text UNIQUE NOT NULL,
  primer_id        UUID references primers(id) ON DELETE CASCADE,
  crawl            boolean default true,
  stale_duration   integer NOT NULL DEFAULT 43200000, -- defaults to 12 hours, column needs to be multiplied by 1000000 to become a poper duration
  last_alert_sent  timestamp,
  stats            json,
  meta             json,
  deleted          boolean default false
);

-- name: create-urls
CREATE TABLE IF NOT EXISTS urls (
  url              text PRIMARY KEY NOT NULL,
  created          timestamp NOT NULL,
  updated          timestamp NOT NULL,
  last_head        timestamp,
  last_get         timestamp,
  status           integer NOT NULL default 0,
  content_type     text NOT NULL default '',
  content_sniff    text NOT NULL default '',
  content_length   bigint NOT NULL default 0,
  file_name        text NOT NULL default '',
  title            text NOT NULL default '',
  id               text NOT NULL default '',
  headers_took     integer NOT NULL default 0,
  download_took    integer NOT NULL default 0,
  headers          json,
  meta             json,
  hash             text NOT NULL default ''
);

-- name: create-links
CREATE TABLE IF NOT EXISTS links (
  created          timestamp NOT NULL,
  updated          timestamp NOT NULL,
  src              text NOT NULL references urls(url) ON DELETE CASCADE,
  dst              text NOT NULL references urls(url) ON DELETE CASCADE,
  PRIMARY KEY      (src, dst)
);

-- name: create-metadata
CREATE TABLE IF NOT EXISTS metadata (
  hash             text NOT NULL default '',
  time_stamp       timestamp NOT NULL,
  key_id           text NOT NULL default '',
  subject          text NOT NULL,
  prev             text NOT NULL default '',
  meta             json,
  deleted          boolean default false
);

-- name: create-snapshots
CREATE TABLE IF NOT EXISTS snapshots (
  url              text NOT NULL references urls(url) ON DELETE CASCADE,
  created          timestamp NOT NULL,
  status           integer NOT NULL DEFAULT 0,
  duration         integer NOT NULL DEFAULT 0,
  meta             json,
  hash             text NOT NULL DEFAULT ''
);

-- name: create-collections
CREATE TABLE IF NOT EXISTS collections (
  id               UUID PRIMARY KEY,
  created          timestamp NOT NULL,
  updated          timestamp NOT NULL,
  creator          text NOT NULL DEFAULT '',
  description      text NOT NULL DEFAULT '',
  title            text NOT NULL DEFAULT '',
  url              text NOT NULL DEFAULT '',
  schema           json,
  contents         json
);

-- name: create-collection_items
CREATE TABLE IF NOT EXISTS collection_items (
  collection_id    UUID NOT NULL,
  url_id           text NOT NULL default '',
  index            integer NOT NULL default -1,
  description      text NOT NULL default '',
  PRIMARY KEY      (collection_id, url_id)
);

-- name: create-uncrawlables
CREATE TABLE IF NOT EXISTS uncrawlables (
  id               text NOT NULL default '',
  url              text PRIMARY KEY NOT NULL,
  created          timestamp NOT NULL default (now() at time zone 'utc'),
  updated          timestamp NOT NULL default (now() at time zone 'utc'),
  creator_key_id   text NOT NULL default '',
  name             text NOT NULL default '',
  email            text NOT NULL default '',
  event_name       text NOT NULL default '',
  agency_name      text NOT NULL default '',
  agency_id        text NOT NULL default '',
  subagency_id     text NOT NULL default '',
  org_id           text NOT NULL default '',
  suborg_id        text NOT NULL default '',
  subprimer_id     text NOT NULL default '',
  ftp              boolean default false,
  database         boolean default false,
  interactive      boolean default false,
  many_files       boolean default false,
  comments         text NOT NULL default '',
  deleted          boolean NOT NULL default false
);

-- name: create-archive_requests
CREATE TABLE IF NOT EXISTS archive_requests (
  id               serial primary key,
  created          timestamp NOT NULL default (now() at time zone 'utc'),
  url              text NOT NULL,
  user_id          text NOT NULL default ''
);

-- name: create-data_repos
CREATE TABLE IF NOT EXISTS data_repos (
  id               UUID PRIMARY KEY NOT NULL,
  created          timestamp NOT NULL default (now() at time zone 'utc'),
  updated          timestamp NOT NULL default (now() at time zone 'utc'),
  title            text NOT NULL default '',
  description      text NOT NULL default '',
  url              text NOT NULL default '',
  deleted          boolean default false
);

-- name: create-custom_crawls
CREATE TABLE IF NOT EXISTS custom_crawls (
  id               UUID PRIMARY KEY NOT NULL,
  created          timestamp NOT NULL default (now() at time zone 'utc'),
  updated          timestamp NOT NULL default (now() at time zone 'utc'),
  jwt              text NOT NULL default '',
  morphRunId       text NOT NULL default '',
  dateCompleted    timestamp NOT NULL default (now() at time zone 'utc'),
  githubRepo       text NOT NULL default '',
  originalUrl      text NOT NULL default '',
  sqliteChecksum   text NOT NULL default ''
);

-- CREATE TABLE IF NOT EXISTS alerts (
--   id   UUID UNIQUE NOT NULL,
--   created   integer NOT NULL,
--   updated   integer NOT NULL,
--   dismissed   boolean default false,
--   domain   UUID references primers(id),
--   message   text
-- );