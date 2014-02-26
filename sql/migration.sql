--
-- MEMBERS
--

ALTER TABLE accounts_bluebottleuser RENAME TO members_member;
ALTER TABLE members_member
	ADD COLUMN skypename character varying(32) DEFAULT '' NOT NULL,
	ADD COLUMN facebook character varying(50) DEFAULT '' NOT NULL,
	ADD COLUMN twitter character varying(15) DEFAULT '' NOT NULL;

-- Renaming indexes & sequences
ALTER INDEX accounts_bluebottleuser_pkey RENAME TO members_member_pkey;
ALTER INDEX accounts_bluebottleuser_email_key RENAME TO members_member_email_key;
ALTER INDEX accounts_bluebottleuser_username_key RENAME TO members_member_username_key;

ALTER INDEX accounts_bluebottleuser_email_like RENAME TO members_member_email_like;
ALTER INDEX accounts_bluebottleuser_username_like RENAME TO members_member_username_like;
ALTER INDEX accounts_bluebottleuser_user_permissions_pkey RENAME TO members_member_user_permissions_pkey;
ALTER INDEX accounts_bluebottleuser_user_permissions_bluebottleuser_id RENAME TO members_member_user_permissions_bluebottleuser_id;
ALTER INDEX accounts_bluebottleuser_user_permissions_permission_id RENAME TO members_member_user_permissions_permission_id;

ALTER SEQUENCE accounts_bluebottleuser_id_seq RENAME TO members_member_id_seq;

-- Change permission table
ALTER TABLE accounts_bluebottleuser_user_permissions RENAME TO members_member_user_permissions;
ALTER SEQUENCE accounts_bluebottleuser_user_permissions_id_seq RENAME TO members_member_user_permissions_id_seq;
ALTER INDEX accounts_bluebottleuser_user_permissions_pkey RENAME TO members_member_user_permissions_pkey;

ALTER TABLE members_member_user_permissions RENAME bluebottleuser_id TO member_id;
ALTER INDEX accounts_bluebottleuser_user_permissions_bluebottleuser_id RENAME TO members_member_user_permissions_user_id;
ALTER INDEX accounts_bluebottleuser_user_permissions_id RENAME TO members_member_user_permissions_permission_id;

ALTER TABLE members_member_user_permissions DROP CONSTRAINT accounts_bluebottleuser_bluebottleuser_id_147f9109b2c6aedf_uniq;
ALTER TABLE members_member_user_permissions
  ADD CONSTRAINT members_member_user_id_147f9109b2c6aedf_uniq UNIQUE(member_id, permission_id);

ALTER TABLE members_member_user_permissions DROP CONSTRAINT bluebottleuser_id_refs_id_00516181;
ALTER TABLE members_member_user_permissions
  ADD CONSTRAINT member_id_refs_id_00516181 FOREIGN KEY (member_id)
      REFERENCES members_member (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;

-- Change group table
ALTER TABLE accounts_bluebottleuser_groups RENAME TO members_member_groups;
ALTER SEQUENCE accounts_bluebottleuser_groups_id_seq RENAME TO members_member_groups_id_seq;
ALTER INDEX accounts_bluebottleuser_groups_pkey RENAME TO members_member_groups_pkey;

ALTER TABLE members_member_groups RENAME bluebottleuser_id TO member_id;
ALTER INDEX accounts_bluebottleuser_groups_bluebottleuser_id RENAME TO members_member_groups_member_id;
ALTER INDEX accounts_bluebottleuser_groups_group_id RENAME TO members_member_groups_group_id;

ALTER TABLE members_member_groups DROP CONSTRAINT accounts_bluebottleuser_bluebottleuser_id_1d988989311d97dc_uniq;
ALTER TABLE members_member_groups
  ADD CONSTRAINT members_member_groups_member_id_1d988989311d97dc_uniq UNIQUE(member_id, group_id);

ALTER TABLE members_member_groups DROP CONSTRAINT bluebottleuser_id_refs_id_87beb27c;
ALTER TABLE members_member_groups
  ADD CONSTRAINT member_id_refs_id_87beb27c FOREIGN KEY (member_id)
      REFERENCES members_member (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;


--
-- PROJECTS
--

-- Project Phase

CREATE SEQUENCE projects_projectphase_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE TABLE bb_projects_projectphase (
	id integer DEFAULT nextval('projects_projectphase_id_seq'::regclass) NOT NULL,
	name character varying(100) NOT NULL,
	description character varying(400) NOT NULL,
	"sequence" integer NOT NULL,
	active boolean NOT NULL,
	editable boolean NOT NULL,
	viewable boolean NOT NULL
);

-- Set default phases

INSERT INTO bb_projects_projectphase (id, name, description, sequence, active, editable, viewable) VALUES
  (1, 'Plan - New', '', 1, true, true, false),
  (2, 'Plan - Submitted', '', 2, true, false, false),
  (3, 'Plan - Needs Work', '', 3, true, true, false),
  (4, 'Plan - Rejected', '', 4, true, false, false),
  (6, 'Campaign', '', 6, true, true, true),
  (7, 'Stopped', '', 6, true, false, false),
  (8, 'Done - Complete', '', 8, true, true, true),
  (9, 'Done - Incomplete', '', 9, true, false, true),
  (10, 'Done - Stopped', '', 10, true, false, false);

-- Project Theme

ALTER TABLE projects_projecttheme RENAME TO bb_projects_projecttheme;
-- change sequence
ALTER SEQUENCE projects_projecttheme_id_seq RENAME TO bb_projects_projecttheme_id_seq;
ALTER SEQUENCE bb_projects_projecttheme_id_seq	OWNED BY bb_projects_projecttheme.id;
--change index


-- Project

ALTER TABLE projects_project
	ADD COLUMN status_id integer DEFAULT 0 NOT NULL,
	ADD COLUMN pitch text DEFAULT '' NOT NULL,
	ADD COLUMN favorite boolean DEFAULT false NOT NULL,
	ADD COLUMN description text DEFAULT '' NOT NULL,
	ADD COLUMN image character varying(255) DEFAULT '' NOT NULL,
	ADD COLUMN organization_id integer,
	ADD COLUMN country_id integer,
	ADD COLUMN theme_id integer DEFAULT 0 NOT NULL,
	ADD COLUMN latitude numeric(21,18),
	ADD COLUMN longitude numeric(21,18),
	ADD COLUMN reach integer,
	ADD COLUMN video_url character varying(100),
	ADD COLUMN deadline timestamp with time zone;


-- Migrate phases to status

UPDATE projects_project SET status_id = 1 WHERE phase IN ('pitch', 'plan');
UPDATE projects_project SET status_id = 2 WHERE id in (SELECT project_id FROM projects_projectpitch WHERE status = 'submitted');
UPDATE projects_project SET status_id = 6 WHERE phase = 'campaign';
UPDATE projects_project SET status_id = 8 WHERE phase IN ('acts', 'results', 'realized');
UPDATE projects_project SET status_id = 10 WHERE phase = 'failed';


-- Migrate info from pitch or plan

UPDATE projects_project p
  SET pitch = pp.pitch,
      description = pp.description,
      image = pp.image,
      country_id = pp.country_id
  FROM projects_projectpitch AS pp
  WHERE pp.project_id = p.id
  AND p.phase = 'pitch';

UPDATE projects_project p
  SET theme_id = pp.theme_id
  FROM projects_projectpitch AS pp
  WHERE pp.project_id = p.id
  AND p.phase = 'pitch' AND pp.theme_id IS NOT NULL;


UPDATE projects_project p
  SET pitch = pp.pitch,
      description = pp.description,
      image = pp.image,
      country_id = pp.country_id,
      latitude = pp.latitude,
      longitude = pp.longitude
  FROM projects_projectplan AS pp
  WHERE pp.project_id = p.id
  AND p.phase <> 'pitch';

UPDATE projects_project p
  SET theme_id = pp.theme_id
  FROM projects_projectplan AS pp
  WHERE pp.project_id = p.id
  AND p.phase <> 'pitch' AND pp.theme_id IS NOT NULL;


--
-- TASKS
--

-- Task File

ALTER TABLE tasks_taskfile RENAME TO bb_tasks_taskfile;

ALTER SEQUENCE tasks_taskfile_id_seq OWNED BY bb_tasks_taskfile.id;

CREATE SEQUENCE tasks_task_files_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE TABLE tasks_task_files (
	id integer DEFAULT nextval('tasks_task_files_id_seq'::regclass) NOT NULL,
	task_id integer NOT NULL,
	taskfile_id integer NOT NULL
);

ALTER SEQUENCE tasks_task_files_id_seq OWNED BY tasks_task_files.id;

-- Task Member

CREATE SEQUENCE tasks_task_members_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE TABLE tasks_task_members (
	id integer DEFAULT nextval('tasks_task_members_id_seq'::regclass) NOT NULL,
	task_id integer NOT NULL,
	taskmember_id integer NOT NULL
);

ALTER TABLE tasks_taskmember RENAME TO bb_tasks_taskmember;
ALTER SEQUENCE tasks_taskmember_id_seq RENAME TO bb_tasks_taskmember_id_seq;
ALTER TABLE bb_tasks_taskmember ADD COLUMN	time_spent double precision;


-- Task Skill

ALTER TABLE tasks_skill RENAME TO bb_tasks_skill;

--
-- SLIDES
--

ALTER TABLE banners_slide RENAME TO slides_slide;
ALTER INDEX banners_slide_pkey RENAME TO slides_slide_pkey;
ALTER INDEX banners_slide_author_id RENAME TO slides_slide_author_id;
ALTER INDEX banners_slide_publication_date RENAME TO slides_slide_publication_date;
ALTER INDEX banners_slide_publication_end_date RENAME TO slides_slide_publication_end_date;
ALTER INDEX banners_slide_slug RENAME TO slides_slide_slug;
ALTER INDEX banners_slide_slug_like RENAME TO slides_slide_slug_like;
ALTER INDEX banners_slide_status RENAME TO slides_slide_status;
ALTER INDEX banners_slide_status_like RENAME TO slides_slide_status_like;



--
-- GEO
--

ALTER TABLE geo_country ALTER COLUMN numeric_code DROP NOT NULL;

ALTER TABLE geo_region ALTER COLUMN numeric_code DROP NOT NULL;

ALTER TABLE geo_subregion ALTER COLUMN numeric_code DROP NOT NULL;


------------
-- TODO: See if we need these DB changes


-- ALTER TABLE payouts_organizationpayoutlog
-- 	DROP CONSTRAINT payout_id_refs_id_d601d93e;
--
-- ALTER TABLE payouts_payoutlog
-- 	DROP CONSTRAINT payout_id_refs_id_3585d806;
--
-- ALTER TABLE projects_projectpitch
-- 	DROP CONSTRAINT theme_id_refs_id_8d479809;
--
-- ALTER TABLE projects_projectplan
-- 	DROP CONSTRAINT theme_id_refs_id_e9f7d0d1;


-- ALTER SEQUENCE members_member_groups_id_seq
-- 	OWNED BY members_member_groups.id;
--
-- ALTER SEQUENCE members_member_id_seq
-- 	OWNED BY members_member.id;
--
-- ALTER SEQUENCE members_member_user_permissions_id_seq
-- 	OWNED BY members_member_user_permissions.id;
--
-- ALTER SEQUENCE tasks_task_files_id_seq
-- 	OWNED BY tasks_task_files.id;
--
-- ALTER SEQUENCE tasks_task_members_id_seq
-- 	OWNED BY tasks_task_members.id;
--
-- ALTER TABLE members_member
-- 	ADD CONSTRAINT members_member_pkey PRIMARY KEY (id);
--
-- ALTER TABLE members_member_groups
-- 	ADD CONSTRAINT members_member_groups_pkey PRIMARY KEY (id);
--
-- ALTER TABLE members_member_user_permissions
-- 	ADD CONSTRAINT members_member_user_permissions_pkey PRIMARY KEY (id);
--
-- ALTER TABLE tasks_task_files
-- 	ADD CONSTRAINT tasks_task_files_pkey PRIMARY KEY (id);
--
-- ALTER TABLE tasks_task_members
-- 	ADD CONSTRAINT tasks_task_members_pkey PRIMARY KEY (id);
--
-- ALTER TABLE bb_projects_projectphase
-- 	ADD CONSTRAINT projects_projectphase_name_key UNIQUE (name);
--
-- ALTER TABLE bb_projects_projectphase
-- 	ADD CONSTRAINT projects_projectphase_sequence_key UNIQUE (sequence);
--
-- ALTER TABLE bb_projects_projecttheme
-- 	ADD CONSTRAINT projects_projecttheme_name_key UNIQUE (name);
--
-- ALTER TABLE bb_projects_projecttheme
-- 	ADD CONSTRAINT projects_projecttheme_slug_key UNIQUE (slug);
--
-- ALTER TABLE bb_tasks_skill
-- 	ADD CONSTRAINT bb_tasks_skill_name_key UNIQUE (name);
--
-- ALTER TABLE bb_tasks_skill
-- 	ADD CONSTRAINT bb_tasks_skill_name_nl_key UNIQUE (name_nl);
--
-- ALTER TABLE bb_tasks_taskfile
-- 	ADD CONSTRAINT bb_tasks_taskfile_author_id_fkey FOREIGN KEY (author_id) REFERENCES members_member(id) DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE bb_tasks_taskmember
-- 	ADD CONSTRAINT member_id_refs_id_861b83e0 FOREIGN KEY (member_id) REFERENCES accounts_bluebottleuser(id) DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE bb_tasks_taskmember
-- 	ADD CONSTRAINT task_id_refs_id_e6a84bbf FOREIGN KEY (task_id) REFERENCES tasks_task(id) DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE members_member
-- 	ADD CONSTRAINT members_member_email_key UNIQUE (email);
--
-- ALTER TABLE members_member
-- 	ADD CONSTRAINT members_member_username_key UNIQUE (username);
--
-- ALTER TABLE members_member_groups
-- 	ADD CONSTRAINT members_member_groups_member_id_group_id_key UNIQUE (member_id, group_id);
--
-- ALTER TABLE members_member_groups
-- 	ADD CONSTRAINT member_id_refs_id_6f23d3dd FOREIGN KEY (member_id) REFERENCES members_member(id) DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE members_member_groups
-- 	ADD CONSTRAINT members_member_groups_group_id_fkey FOREIGN KEY (group_id) REFERENCES auth_group(id) DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE members_member_user_permissions
-- 	ADD CONSTRAINT members_member_user_permissions_member_id_permission_id_key UNIQUE (member_id, permission_id);
--
-- ALTER TABLE members_member_user_permissions
-- 	ADD CONSTRAINT member_id_refs_id_f7e99d7b FOREIGN KEY (member_id) REFERENCES members_member(id) DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE members_member_user_permissions
-- 	ADD CONSTRAINT members_member_user_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES auth_permission(id) DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE payouts_organizationpayoutlog
-- 	ADD CONSTRAINT payouts_organizationpayoutlog_payout_id_fkey FOREIGN KEY (payout_id) REFERENCES payouts_organizationpayout(id) DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE payouts_payoutlog
-- 	ADD CONSTRAINT payouts_payoutlog_payout_id_fkey FOREIGN KEY (payout_id) REFERENCES payouts_payout(id) DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE projects_project
-- 	ADD CONSTRAINT ck_reach_pstv_2632592547ec141a CHECK ((reach >= 0));
--
-- ALTER TABLE projects_project
-- 	ADD CONSTRAINT projects_project_reach_check CHECK ((reach >= 0));
--
-- ALTER TABLE projects_project
-- 	ADD CONSTRAINT country_id_refs_id_3a57922e FOREIGN KEY (country_id) REFERENCES geo_country(id) DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE projects_project
-- 	ADD CONSTRAINT organization_id_refs_id_e42a8fc9 FOREIGN KEY (organization_id) REFERENCES organizations_organization(id) DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE projects_project
-- 	ADD CONSTRAINT status_id_refs_id_7b0c43f9 FOREIGN KEY (status_id) REFERENCES bb_projects_projectphase(id) DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE projects_project
-- 	ADD CONSTRAINT theme_id_refs_id_2a01adf5 FOREIGN KEY (theme_id) REFERENCES bb_projects_projecttheme(id) DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE projects_projectpitch
-- 	ADD CONSTRAINT theme_id_refs_id_8d479809 FOREIGN KEY (theme_id) REFERENCES bb_projects_projecttheme(id) DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE projects_projectplan
-- 	ADD CONSTRAINT theme_id_refs_id_e9f7d0d1 FOREIGN KEY (theme_id) REFERENCES bb_projects_projecttheme(id) DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE tasks_task_files
-- 	ADD CONSTRAINT tasks_task_files_task_id_78ceab895d23dc42_uniq UNIQUE (task_id, taskfile_id);
--
-- ALTER TABLE tasks_task_files
-- 	ADD CONSTRAINT task_id_refs_id_68a7e47c FOREIGN KEY (task_id) REFERENCES tasks_task(id) DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE tasks_task_files
-- 	ADD CONSTRAINT taskfile_id_refs_id_8915c958 FOREIGN KEY (taskfile_id) REFERENCES bb_tasks_taskfile(id) DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE tasks_task_members
-- 	ADD CONSTRAINT tasks_task_members_task_id_ebfef1d4a7ceede_uniq UNIQUE (task_id, taskmember_id);
--
-- ALTER TABLE tasks_task_members
-- 	ADD CONSTRAINT task_id_refs_id_d6afa2e6 FOREIGN KEY (task_id) REFERENCES tasks_task(id) DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE tasks_task_members
-- 	ADD CONSTRAINT taskmember_id_refs_id_964503d2 FOREIGN KEY (taskmember_id) REFERENCES bb_tasks_taskmember(id) DEFERRABLE INITIALLY DEFERRED;
--
-- CREATE INDEX projects_projectphase_name_like ON bb_projects_projectphase USING btree (name varchar_pattern_ops);
--
-- CREATE INDEX projects_projecttheme_name_like ON bb_projects_projecttheme USING btree (name varchar_pattern_ops);
--
-- CREATE INDEX projects_projecttheme_slug_like ON bb_projects_projecttheme USING btree (slug varchar_pattern_ops);
--
-- CREATE INDEX bb_tasks_skill_name_like ON bb_tasks_skill USING btree (name varchar_pattern_ops);
--
-- CREATE INDEX bb_tasks_skill_name_nl_like ON bb_tasks_skill USING btree (name_nl varchar_pattern_ops);
--
-- CREATE INDEX bb_tasks_taskfile_author_id ON bb_tasks_taskfile USING btree (author_id);
--
-- CREATE INDEX tasks_taskmember_member_id ON bb_tasks_taskmember USING btree (member_id);
--
-- CREATE INDEX tasks_taskmember_task_id ON bb_tasks_taskmember USING btree (task_id);
--
-- CREATE INDEX members_member_email_like ON members_member USING btree (email varchar_pattern_ops);
--
-- CREATE INDEX members_member_username_like ON members_member USING btree (username varchar_pattern_ops);
--
-- CREATE INDEX members_member_groups_group_id ON members_member_groups USING btree (group_id);
--
-- CREATE INDEX members_member_groups_member_id ON members_member_groups USING btree (member_id);
--
-- CREATE INDEX members_member_user_permissions_member_id ON members_member_user_permissions USING btree (member_id);
--
-- CREATE INDEX members_member_user_permissions_permission_id ON members_member_user_permissions USING btree (permission_id);
--
-- CREATE INDEX projects_project_country_id ON projects_project USING btree (country_id);
--
-- CREATE INDEX projects_project_organization_id ON projects_project USING btree (organization_id);
--
-- CREATE INDEX projects_project_status_id ON projects_project USING btree (status_id);
--
-- CREATE INDEX projects_project_theme_id ON projects_project USING btree (theme_id);
--
-- CREATE INDEX tasks_task_files_task_id ON tasks_task_files USING btree (task_id);
--
-- CREATE INDEX tasks_task_files_taskfile_id ON tasks_task_files USING btree (taskfile_id);
--
-- CREATE INDEX tasks_task_members_task_id ON tasks_task_members USING btree (task_id);
--
-- CREATE INDEX tasks_task_members_taskmember_id ON tasks_task_members USING btree (taskmember_id);
--
