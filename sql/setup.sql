
drop table if exists users;
drop table if exists sessions;
drop table if exists issues;
drop table if exists projects;
drop table if exists categories;
drop table if exists priorities;
drop table if exists statuses;
drop table if exists organizations;
drop table if exists queries;
drop table if exists posts;
drop table if exists post_attachments;
drop table if exists registration_requests;
drop table if exists reset_password_requests;
drop table if exists outgoing_email_queue;

create table users
(
us_id serial,
us_username varchar(20) not null,
us_email_address varchar(64) not null,
us_password varchar(48) not null default '',
us_is_admin boolean default false,
us_is_active boolean default true,
us_is_report_only boolean default false,
us_organization int not null default 0,
us_created_date timestamptz default CURRENT_TIMESTAMP not null
);

CREATE UNIQUE INDEX us_username_index ON users (us_username);
CREATE UNIQUE INDEX us_email_address_index ON users (us_email_address);

create table sessions
(
	se_id varchar(40) not null,
	se_timestamp timestamptz default CURRENT_TIMESTAMP not null,
	se_user int not null
);

CREATE UNIQUE INDEX se_id_index ON sessions (se_id);

create table projects
(
pj_id serial,
pj_name varchar(30) not null,
pj_is_active boolean default true,
pj_is_default boolean default false
);

CREATE UNIQUE INDEX pj_name_index ON projects (pj_name);

create table categories
(
ca_id serial,
ca_name varchar(30) not null,
ca_is_active boolean default true,
ca_is_default boolean default false
);

CREATE UNIQUE INDEX ca_name_index ON categories (ca_name);

create table statuses
(
st_id serial,
st_name varchar(30) not null,
st_is_active boolean default true,
st_is_default boolean default false
);

CREATE UNIQUE INDEX st_name_index ON statuses (st_name);

create table priorities
(
pr_id serial,
pr_name varchar(30) not null,
pr_is_active boolean default true,
pr_is_default boolean default false
);

CREATE UNIQUE INDEX pr_name_index ON priorities (pr_name);

create table organizations
(
og_id serial,
og_name varchar(30) not null,
og_is_active boolean default true,
og_is_default boolean default false
);

CREATE UNIQUE INDEX og_name_index ON organizations (og_name);

create table queries
(
qu_id serial,
qu_name varchar(60) not null,
qu_sql text not null,
qu_description text not null default '',
qu_is_active boolean default true,
qu_is_default boolean default false
);

create unique index qu_name_index on queries (qu_name);

create table issues 
(
i_id serial,
i_description varchar(200) not null,
i_details text not null default '',
i_created_by_user int not null default 0,
i_created_date timestamptz default CURRENT_TIMESTAMP,
i_status int not null default 0,
i_priority int not null default 0,
i_category int not null default 0,
i_project int not null default 0,
i_organization int not null default 0,
i_assigned_to_user int null default 0,
i_last_updated_user int null default 0,
i_last_updated_date timestamptz null,
i_last_post_user int null default 0,
i_last_post_date timestamptz null
);

create table posts 
(
p_id serial,
p_issue int not null,
p_post_type varchar(8) not null,
p_text text not null default '',
p_email_to text not null default '',
p_created_by_user int not null,
p_created_date timestamptz default CURRENT_TIMESTAMP
);

create index p_issue_index on posts (p_issue);

create table post_attachments
(
pa_id serial,
pa_post int not null,
pa_issue int not null, 
pa_file_name text not null default '',
pa_file_length int not null default 0,
pa_file_content_type text not null default '',
pa_content bytea null
);

create index pa_post_index on post_attachments (pa_post);

create table registration_requests
(
rr_guid varchar(36) not null,
rr_created_date timestamptz default CURRENT_TIMESTAMP,
rr_email_address varchar(64) not null,
rr_username varchar(20) not null,
rr_password varchar(48) not null
);

create unique index rr_guid_index on registration_requests (rr_guid);

create table reset_password_requests
(
rp_guid varchar(36) not null,
rp_created_date timestamptz default CURRENT_TIMESTAMP,
rp_email_address varchar(64) not null,
rp_user_id int not null
);

create unique index rp_guid_index on reset_password_requests (rp_guid);

create table outgoing_email_queue 
(
oq_id serial,
oq_date_created timestamptz default CURRENT_TIMESTAMP,
oq_email_type varchar(10) not null, /* post, registration, forgot password */
oq_post_id int null, /* if related to post - get the attachments from it, don't store twice */
oq_retry_count int not null default 0,
oq_last_retry_date timestamptz null,
oq_last_exception text not null default '',
oq_email_to text not null,
oq_email_subject text not null,
oq_email_body text not null
);

create index oq_id_index on outgoing_email_queue (oq_date_created);


insert into users (us_username, us_email_address, us_is_admin, us_password) 
values('admin', '', true, 'anything');

insert into projects (pj_name) values ('proj 1');
insert into projects (pj_name) values ('proj 2');
insert into projects (pj_name) values ('proj 3');

insert into categories (ca_name) values ('bug');
insert into categories (ca_name) values ('task');
insert into categories (ca_name) values ('question');

insert into priorities (pr_name) values ('1-high');
insert into priorities (pr_name) values ('2-medium');
insert into priorities (pr_name) values ('3-low');

insert into statuses (st_name, st_is_default) values ('new', true);
insert into statuses (st_name) values ('in progress');
insert into statuses (st_name) values ('done');

insert into organizations (og_name) values ('org 1');
insert into organizations (og_name) values ('org 2');
insert into organizations (og_name) values ('org 3');

insert into queries (qu_name, qu_sql) values (
'Raw "select * from issues" Please run queries.sql',
'select * from issues order by i_id desc');
