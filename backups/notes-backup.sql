--
-- PostgreSQL database dump
--

\restrict fcNAsf4bUAQEmfE6YEU7Ibz1bg5QqDmdLVBt3jaXcyfQLMzY5NsmLuTbrE76WSC

-- Dumped from database version 17.11
-- Dumped by pg_dump version 17.11

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.notes DROP CONSTRAINT IF EXISTS notes_pkey;
ALTER TABLE IF EXISTS public.notes ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.notes_id_seq;
DROP TABLE IF EXISTS public.notes;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: notes; Type: TABLE; Schema: public; Owner: lab4
--

CREATE TABLE public.notes (
    id integer NOT NULL,
    text text NOT NULL,
    created_by text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.notes OWNER TO lab4;

--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: lab4
--

CREATE SEQUENCE public.notes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notes_id_seq OWNER TO lab4;

--
-- Name: notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lab4
--

ALTER SEQUENCE public.notes_id_seq OWNED BY public.notes.id;


--
-- Name: notes id; Type: DEFAULT; Schema: public; Owner: lab4
--

ALTER TABLE ONLY public.notes ALTER COLUMN id SET DEFAULT nextval('public.notes_id_seq'::regclass);


--
-- Data for Name: notes; Type: TABLE DATA; Schema: public; Owner: lab4
--

COPY public.notes (id, text, created_by, created_at) FROM stdin;
1	Seed note from db/init.sql	init.sql	2026-09-26 05:35:16.278955+00
2	First note from curl	2120a34a2ca4	2026-09-26 05:35:39.208259+00
3	This note must survive docker compose down	2120a34a2ca4	2026-09-26 05:36:02.0536+00
\.


--
-- Name: notes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lab4
--

SELECT pg_catalog.setval('public.notes_id_seq', 3, true);


--
-- Name: notes notes_pkey; Type: CONSTRAINT; Schema: public; Owner: lab4
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

\unrestrict fcNAsf4bUAQEmfE6YEU7Ibz1bg5QqDmdLVBt3jaXcyfQLMzY5NsmLuTbrE76WSC

