--
-- PostgreSQL database dump
--

-- Dumped from database version 16.2
-- Dumped by pg_dump version 16.4

-- Started on 2024-09-18 20:01:29 CST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 10 (class 2615 OID 23863060)
-- Name: acostarep; Type: SCHEMA; Schema: -; Owner: -
-- Data Pos: 0
--

CREATE SCHEMA acostarep;


--
-- TOC entry 11 (class 2615 OID 23863061)
-- Name: hdb_catalog; Type: SCHEMA; Schema: -; Owner: -
-- Data Pos: 0
--

CREATE SCHEMA hdb_catalog;


--
-- TOC entry 9 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
-- Data Pos: 0
--

-- *not* creating schema, since initdb creates it


--
-- TOC entry 4564 (class 0 OID 0)
-- Dependencies: 9
-- Name: SCHEMA "public"; Type: COMMENT; Schema: -; Owner: -
-- Data Pos: 0
--

COMMENT ON SCHEMA "public" IS 'standard public schema';


--
-- TOC entry 2 (class 3079 OID 23862146)
-- Dependencies: 9
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
-- Data Pos: 0
--

CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "public";


--
-- TOC entry 4565 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION "pg_stat_statements"; Type: COMMENT; Schema: -; Owner: -
-- Data Pos: 0
--

COMMENT ON EXTENSION "pg_stat_statements" IS 'track planning and execution statistics of all SQL statements executed';


--
-- TOC entry 3 (class 3079 OID 23863062)
-- Dependencies: 9
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
-- Data Pos: 0
--

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "public";


--
-- TOC entry 4566 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION "pgcrypto"; Type: COMMENT; Schema: -; Owner: -
-- Data Pos: 0
--

COMMENT ON EXTENSION "pgcrypto" IS 'cryptographic functions';


--
-- TOC entry 4 (class 3079 OID 23863099)
-- Dependencies: 9
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
-- Data Pos: 0
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "public";


--
-- TOC entry 4567 (class 0 OID 0)
-- Dependencies: 4
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
-- Data Pos: 0
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- TOC entry 929 (class 1247 OID 23863111)
-- Dependencies: 9
-- Name: user_roles_enum; Type: TYPE; Schema: public; Owner: -
-- Data Pos: 0
--

CREATE TYPE "public"."user_roles_enum" AS ENUM (
    'admin',
    'gerente_area',
    'seller'
);


--
-- TOC entry 932 (class 1247 OID 23863118)
-- Dependencies: 9
-- Name: user_sucursal_enum; Type: TYPE; Schema: public; Owner: -
-- Data Pos: 0
--

CREATE TYPE "public"."user_sucursal_enum" AS ENUM (
    'Santa Ana',
    'Metapan'
);


--
-- TOC entry 935 (class 1247 OID 23863124)
-- Dependencies: 9
-- Name: users_roles_enum; Type: TYPE; Schema: public; Owner: -
-- Data Pos: 0
--

CREATE TYPE "public"."users_roles_enum" AS ENUM (
    'admin',
    'gerente_area',
    'seller'
);


--
-- TOC entry 938 (class 1247 OID 23863132)
-- Dependencies: 9
-- Name: users_sucursal_enum; Type: TYPE; Schema: public; Owner: -
-- Data Pos: 0
--

CREATE TYPE "public"."users_sucursal_enum" AS ENUM (
    'Santa Ana',
    'Metapan'
);


--
-- TOC entry 308 (class 1255 OID 23863137)
-- Dependencies: 10
-- Name: set_current_timestamp_updated_at(); Type: FUNCTION; Schema: acostarep; Owner: -
-- Data Pos: 0
--

CREATE FUNCTION "acostarep"."set_current_timestamp_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."updated_at" = NOW();
  RETURN _new;
END;
$$;


--
-- TOC entry 307 (class 1255 OID 23863138)
-- Dependencies: 11
-- Name: gen_hasura_uuid(); Type: FUNCTION; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

CREATE FUNCTION "hdb_catalog"."gen_hasura_uuid"() RETURNS "uuid"
    LANGUAGE "sql"
    AS $$select gen_random_uuid()$$;


--
-- TOC entry 309 (class 1255 OID 24170108)
-- Dependencies: 9
-- Name: update_stock_before_insert(); Type: FUNCTION; Schema: public; Owner: -
-- Data Pos: 0
--

CREATE FUNCTION "public"."update_stock_before_insert"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Declare variables
    DECLARE
        v_cede TEXT;
    BEGIN
        -- Get the cede value from the ordenes table using the id_orden in the NEW row
        SELECT o.cede
        INTO v_cede
        FROM acostarep.ordenes o
        WHERE o.id = NEW.id_orden;

        -- Reduce the stock based on cede value
        IF v_cede = 'Santa Ana' THEN
            UPDATE acostarep.productos
            SET stock_prod_sta_ana = GREATEST(stock_prod_sta_ana - NEW.cantidad, 0)
            WHERE id = NEW.id_producto;
        ELSIF v_cede = 'Metapan' THEN
            UPDATE acostarep.productos
            SET stock_prod_metapan = GREATEST(stock_prod_metapan - NEW.cantidad, 0)
            WHERE id = NEW.id_producto;
        END IF;

        -- Return the new row to continue with the insert operation
        RETURN NEW;
    END;
END;
$$;


--
-- TOC entry 223 (class 1259 OID 23863139)
-- Dependencies: 9
-- Name: categorias_id_seq; Type: SEQUENCE; Schema: public; Owner: -
-- Data Pos: 0
--

CREATE SEQUENCE "public"."categorias_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 224 (class 1259 OID 23863140)
-- Dependencies: 223 10
-- Name: categorias; Type: TABLE; Schema: acostarep; Owner: -
-- Data Pos: 0
--

CREATE TABLE "acostarep"."categorias" (
    "id" integer DEFAULT "nextval"('"public"."categorias_id_seq"'::"regclass") NOT NULL,
    "nombre_categoria" character varying NOT NULL,
    "descripcion_categoria" character varying,
    "is_active_categoria" boolean DEFAULT true
);


--
-- TOC entry 4568 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE "categorias"; Type: COMMENT; Schema: acostarep; Owner: -
-- Data Pos: 0
--

COMMENT ON TABLE "acostarep"."categorias" IS 'categorias';


--
-- TOC entry 225 (class 1259 OID 23863147)
-- Dependencies: 10
-- Name: cliente; Type: TABLE; Schema: acostarep; Owner: -
-- Data Pos: 0
--

CREATE TABLE "acostarep"."cliente" (
    "id" integer NOT NULL,
    "name" character varying NOT NULL,
    "last_name" character varying,
    "email" character varying,
    "direccion" character varying,
    "telefono" character varying,
    "empresa" character varying,
    "activo_cliente" boolean DEFAULT true,
    "dui" character varying,
    "created_by" "uuid" DEFAULT '1d3314f6-5123-49c6-b60b-3874ac8d574c'::"uuid",
    "updated_by" "uuid" DEFAULT '1d3314f6-5123-49c6-b60b-3874ac8d574c'::"uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone
);


--
-- TOC entry 4569 (class 0 OID 0)
-- Dependencies: 225
-- Name: TABLE "cliente"; Type: COMMENT; Schema: acostarep; Owner: -
-- Data Pos: 0
--

COMMENT ON TABLE "acostarep"."cliente" IS 'cliente';


--
-- TOC entry 226 (class 1259 OID 23863153)
-- Dependencies: 225 10
-- Name: cliente_id_seq; Type: SEQUENCE; Schema: acostarep; Owner: -
-- Data Pos: 0
--

CREATE SEQUENCE "acostarep"."cliente_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4570 (class 0 OID 0)
-- Dependencies: 226
-- Name: cliente_id_seq; Type: SEQUENCE OWNED BY; Schema: acostarep; Owner: -
-- Data Pos: 0
--

ALTER SEQUENCE "acostarep"."cliente_id_seq" OWNED BY "acostarep"."cliente"."id";


--
-- TOC entry 227 (class 1259 OID 23863154)
-- Dependencies: 9
-- Name: marcas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
-- Data Pos: 0
--

CREATE SEQUENCE "public"."marcas_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


--
-- TOC entry 228 (class 1259 OID 23863155)
-- Dependencies: 227 10
-- Name: marcas; Type: TABLE; Schema: acostarep; Owner: -
-- Data Pos: 0
--

CREATE TABLE "acostarep"."marcas" (
    "id" integer DEFAULT "nextval"('"public"."marcas_id_seq"'::"regclass") NOT NULL,
    "nombre_marca" character varying NOT NULL,
    "descripcion_marca" character varying,
    "is_active_marca" boolean DEFAULT true
);


--
-- TOC entry 4571 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE "marcas"; Type: COMMENT; Schema: acostarep; Owner: -
-- Data Pos: 0
--

COMMENT ON TABLE "acostarep"."marcas" IS 'marcas';


--
-- TOC entry 229 (class 1259 OID 23863162)
-- Dependencies: 9
-- Name: ordenes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
-- Data Pos: 0
--

CREATE SEQUENCE "public"."ordenes_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


--
-- TOC entry 230 (class 1259 OID 23863163)
-- Dependencies: 229 10
-- Name: ordenes; Type: TABLE; Schema: acostarep; Owner: -
-- Data Pos: 0
--

CREATE TABLE "acostarep"."ordenes" (
    "id" integer DEFAULT "nextval"('"public"."ordenes_id_seq"'::"regclass") NOT NULL,
    "is_active_orden" boolean DEFAULT true NOT NULL,
    "metodo_pago_id" integer NOT NULL,
    "tipo_distribucion_id" integer NOT NULL,
    "total_orden" double precision NOT NULL,
    "status_id" integer NOT NULL,
    "tipo_orden_id" integer NOT NULL,
    "cliente_id" integer NOT NULL,
    "observaciones_orden" character varying,
    "cede" "text",
    "created_by" "uuid" DEFAULT '1d3314f6-5123-49c6-b60b-3874ac8d574c'::"uuid",
    "updated_by" "uuid" DEFAULT '1d3314f6-5123-49c6-b60b-3874ac8d574c'::"uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone
);


--
-- TOC entry 4572 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE "ordenes"; Type: COMMENT; Schema: acostarep; Owner: -
-- Data Pos: 0
--

COMMENT ON TABLE "acostarep"."ordenes" IS 'ordenes';


--
-- TOC entry 231 (class 1259 OID 23863170)
-- Dependencies: 9
-- Name: productos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
-- Data Pos: 0
--

CREATE SEQUENCE "public"."productos_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


--
-- TOC entry 232 (class 1259 OID 23863171)
-- Dependencies: 231 10
-- Name: productos; Type: TABLE; Schema: acostarep; Owner: -
-- Data Pos: 0
--

CREATE TABLE "acostarep"."productos" (
    "nombre_producto" character varying NOT NULL,
    "id" integer DEFAULT "nextval"('"public"."productos_id_seq"'::"regclass") NOT NULL,
    "upc" character varying NOT NULL,
    "id_marca" integer NOT NULL,
    "id_categoria" integer NOT NULL,
    "foto" character varying NOT NULL,
    "precio_taller" double precision NOT NULL,
    "precio_mayoreo" double precision NOT NULL,
    "precio_publico" double precision NOT NULL,
    "stock_prod_sta_ana" double precision DEFAULT '0'::double precision,
    "stock_prod_metapan" double precision DEFAULT '0'::double precision,
    "uom_id" integer,
    "is_active_producto" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "created_by" "uuid" DEFAULT '1d3314f6-5123-49c6-b60b-3874ac8d574c'::"uuid" NOT NULL,
    "updated_by" "uuid" DEFAULT '1d3314f6-5123-49c6-b60b-3874ac8d574c'::"uuid"
);


--
-- TOC entry 4573 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE "productos"; Type: COMMENT; Schema: acostarep; Owner: -
-- Data Pos: 0
--

COMMENT ON TABLE "acostarep"."productos" IS 'productos';


--
-- TOC entry 233 (class 1259 OID 23863184)
-- Dependencies: 10
-- Name: productos_orden; Type: TABLE; Schema: acostarep; Owner: -
-- Data Pos: 0
--

CREATE TABLE "acostarep"."productos_orden" (
    "id" integer NOT NULL,
    "id_orden" integer NOT NULL,
    "id_producto" integer NOT NULL,
    "cantidad" double precision NOT NULL,
    "precio" double precision NOT NULL,
    "descuento" double precision,
    "sub_total" double precision NOT NULL,
    "stock" integer,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- TOC entry 4574 (class 0 OID 0)
-- Dependencies: 233
-- Name: TABLE "productos_orden"; Type: COMMENT; Schema: acostarep; Owner: -
-- Data Pos: 0
--

COMMENT ON TABLE "acostarep"."productos_orden" IS 'productos_orden';


--
-- TOC entry 234 (class 1259 OID 23863187)
-- Dependencies: 233 10
-- Name: productos_orden_id_seq; Type: SEQUENCE; Schema: acostarep; Owner: -
-- Data Pos: 0
--

CREATE SEQUENCE "acostarep"."productos_orden_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4575 (class 0 OID 0)
-- Dependencies: 234
-- Name: productos_orden_id_seq; Type: SEQUENCE OWNED BY; Schema: acostarep; Owner: -
-- Data Pos: 0
--

ALTER SEQUENCE "acostarep"."productos_orden_id_seq" OWNED BY "acostarep"."productos_orden"."id";


--
-- TOC entry 235 (class 1259 OID 23863188)
-- Dependencies: 10
-- Name: types; Type: TABLE; Schema: acostarep; Owner: -
-- Data Pos: 0
--

CREATE TABLE "acostarep"."types" (
    "code" character varying,
    "id" integer NOT NULL,
    "name" character varying,
    "combo_objeto" character varying NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL
);


--
-- TOC entry 4576 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE "types"; Type: COMMENT; Schema: acostarep; Owner: -
-- Data Pos: 0
--

COMMENT ON TABLE "acostarep"."types" IS 'types';


--
-- TOC entry 236 (class 1259 OID 23863194)
-- Dependencies: 10 235
-- Name: types_id_seq; Type: SEQUENCE; Schema: acostarep; Owner: -
-- Data Pos: 0
--

CREATE SEQUENCE "acostarep"."types_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4577 (class 0 OID 0)
-- Dependencies: 236
-- Name: types_id_seq; Type: SEQUENCE OWNED BY; Schema: acostarep; Owner: -
-- Data Pos: 0
--

ALTER SEQUENCE "acostarep"."types_id_seq" OWNED BY "acostarep"."types"."id";


--
-- TOC entry 237 (class 1259 OID 23863195)
-- Dependencies: 307 11
-- Name: hdb_action_log; Type: TABLE; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

CREATE TABLE "hdb_catalog"."hdb_action_log" (
    "id" "uuid" DEFAULT "hdb_catalog"."gen_hasura_uuid"() NOT NULL,
    "action_name" "text",
    "input_payload" "jsonb" NOT NULL,
    "request_headers" "jsonb" NOT NULL,
    "session_variables" "jsonb" NOT NULL,
    "response_payload" "jsonb",
    "errors" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "response_received_at" timestamp with time zone,
    "status" "text" NOT NULL,
    CONSTRAINT "hdb_action_log_status_check" CHECK (("status" = ANY (ARRAY['created'::"text", 'processing'::"text", 'completed'::"text", 'error'::"text"])))
);


--
-- TOC entry 238 (class 1259 OID 23863203)
-- Dependencies: 307 11
-- Name: hdb_cron_event_invocation_logs; Type: TABLE; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

CREATE TABLE "hdb_catalog"."hdb_cron_event_invocation_logs" (
    "id" "text" DEFAULT "hdb_catalog"."gen_hasura_uuid"() NOT NULL,
    "event_id" "text",
    "status" integer,
    "request" "json",
    "response" "json",
    "created_at" timestamp with time zone DEFAULT "now"()
);


--
-- TOC entry 239 (class 1259 OID 23863210)
-- Dependencies: 307 11
-- Name: hdb_cron_events; Type: TABLE; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

CREATE TABLE "hdb_catalog"."hdb_cron_events" (
    "id" "text" DEFAULT "hdb_catalog"."gen_hasura_uuid"() NOT NULL,
    "trigger_name" "text" NOT NULL,
    "scheduled_time" timestamp with time zone NOT NULL,
    "status" "text" DEFAULT 'scheduled'::"text" NOT NULL,
    "tries" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "next_retry_at" timestamp with time zone,
    CONSTRAINT "valid_status" CHECK (("status" = ANY (ARRAY['scheduled'::"text", 'locked'::"text", 'delivered'::"text", 'error'::"text", 'dead'::"text"])))
);


--
-- TOC entry 240 (class 1259 OID 23863220)
-- Dependencies: 11
-- Name: hdb_metadata; Type: TABLE; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

CREATE TABLE "hdb_catalog"."hdb_metadata" (
    "id" integer NOT NULL,
    "metadata" "json" NOT NULL,
    "resource_version" integer DEFAULT 1 NOT NULL
);


--
-- TOC entry 241 (class 1259 OID 23863226)
-- Dependencies: 307 11
-- Name: hdb_scheduled_event_invocation_logs; Type: TABLE; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

CREATE TABLE "hdb_catalog"."hdb_scheduled_event_invocation_logs" (
    "id" "text" DEFAULT "hdb_catalog"."gen_hasura_uuid"() NOT NULL,
    "event_id" "text",
    "status" integer,
    "request" "json",
    "response" "json",
    "created_at" timestamp with time zone DEFAULT "now"()
);


--
-- TOC entry 242 (class 1259 OID 23863233)
-- Dependencies: 307 11
-- Name: hdb_scheduled_events; Type: TABLE; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

CREATE TABLE "hdb_catalog"."hdb_scheduled_events" (
    "id" "text" DEFAULT "hdb_catalog"."gen_hasura_uuid"() NOT NULL,
    "webhook_conf" "json" NOT NULL,
    "scheduled_time" timestamp with time zone NOT NULL,
    "retry_conf" "json",
    "payload" "json",
    "header_conf" "json",
    "status" "text" DEFAULT 'scheduled'::"text" NOT NULL,
    "tries" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "next_retry_at" timestamp with time zone,
    "comment" "text",
    CONSTRAINT "valid_status" CHECK (("status" = ANY (ARRAY['scheduled'::"text", 'locked'::"text", 'delivered'::"text", 'error'::"text", 'dead'::"text"])))
);


--
-- TOC entry 243 (class 1259 OID 23863243)
-- Dependencies: 11
-- Name: hdb_schema_notifications; Type: TABLE; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

CREATE TABLE "hdb_catalog"."hdb_schema_notifications" (
    "id" integer NOT NULL,
    "notification" "json" NOT NULL,
    "resource_version" integer DEFAULT 1 NOT NULL,
    "instance_id" "uuid" NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "hdb_schema_notifications_id_check" CHECK (("id" = 1))
);


--
-- TOC entry 244 (class 1259 OID 23863251)
-- Dependencies: 307 11
-- Name: hdb_version; Type: TABLE; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

CREATE TABLE "hdb_catalog"."hdb_version" (
    "hasura_uuid" "uuid" DEFAULT "hdb_catalog"."gen_hasura_uuid"() NOT NULL,
    "version" "text" NOT NULL,
    "upgraded_on" timestamp with time zone NOT NULL,
    "cli_state" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "console_state" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "ee_client_id" "text",
    "ee_client_secret" "text"
);


--
-- TOC entry 245 (class 1259 OID 23863259)
-- Dependencies: 4 9 9 935 938
-- Name: users; Type: TABLE; Schema: public; Owner: -
-- Data Pos: 0
--

CREATE TABLE "public"."users" (
    "id" "uuid" DEFAULT "public"."uuid_generate_v4"() NOT NULL,
    "name" character varying(20) NOT NULL,
    "email" character varying(100) NOT NULL,
    "password" character varying(100) NOT NULL,
    "active" boolean DEFAULT true NOT NULL,
    "created_on" timestamp without time zone DEFAULT "now"() NOT NULL,
    "sucursal" "public"."users_sucursal_enum"[] NOT NULL,
    "roles" "public"."users_roles_enum"[] NOT NULL
);


--
-- TOC entry 4288 (class 2604 OID 23863326)
-- Dependencies: 226 225
-- Name: cliente id; Type: DEFAULT; Schema: acostarep; Owner: -
-- Data Pos: 0
--

ALTER TABLE ONLY "acostarep"."cliente" ALTER COLUMN "id" SET DEFAULT "nextval"('"acostarep"."cliente_id_seq"'::"regclass");


--
-- TOC entry 4307 (class 2604 OID 23863327)
-- Dependencies: 234 233
-- Name: productos_orden id; Type: DEFAULT; Schema: acostarep; Owner: -
-- Data Pos: 0
--

ALTER TABLE ONLY "acostarep"."productos_orden" ALTER COLUMN "id" SET DEFAULT "nextval"('"acostarep"."productos_orden_id_seq"'::"regclass");


--
-- TOC entry 4309 (class 2604 OID 23863328)
-- Dependencies: 236 235
-- Name: types id; Type: DEFAULT; Schema: acostarep; Owner: -
-- Data Pos: 0
--

ALTER TABLE ONLY "acostarep"."types" ALTER COLUMN "id" SET DEFAULT "nextval"('"acostarep"."types_id_seq"'::"regclass");


--
-- TOC entry 4535 (class 0 OID 23863140)
-- Dependencies: 224
-- Data for Name: categorias; Type: TABLE DATA; Schema: acostarep; Owner: -
-- Data Pos: 0
--

COPY "acostarep"."categorias" ("id", "nombre_categoria", "descripcion_categoria", "is_active_categoria") FROM stdin;
\.


--
-- TOC entry 4536 (class 0 OID 23863147)
-- Dependencies: 225
-- Data for Name: cliente; Type: TABLE DATA; Schema: acostarep; Owner: -
-- Data Pos: 0
--

COPY "acostarep"."cliente" ("id", "name", "last_name", "email", "direccion", "telefono", "empresa", "activo_cliente", "dui", "created_by", "updated_by", "created_at", "updated_at") FROM stdin;
1	Usuario Por	Defecto	\N	\N	\N	\N	t	\N	1d3314f6-5123-49c6-b60b-3874ac8d574c	1d3314f6-5123-49c6-b60b-3874ac8d574c	2024-09-17 17:59:52.229564+00	\N
2	Cristian	Ayala Chacón	cristianaaron10@gmail.com	Ecoterra Maquilishuat carretera Chalchuapa km 70.8	74705832		f	05648490-1	ce022fbe-7d28-46c7-abc7-af41066cf103	ce022fbe-7d28-46c7-abc7-af41066cf103	2024-09-18 00:29:30.286238+00	2024-09-18 00:29:40.325346+00
\.


--
-- TOC entry 4539 (class 0 OID 23863155)
-- Dependencies: 228
-- Data for Name: marcas; Type: TABLE DATA; Schema: acostarep; Owner: -
-- Data Pos: 0
--

COPY "acostarep"."marcas" ("id", "nombre_marca", "descripcion_marca", "is_active_marca") FROM stdin;
\.


--
-- TOC entry 4541 (class 0 OID 23863163)
-- Dependencies: 230
-- Data for Name: ordenes; Type: TABLE DATA; Schema: acostarep; Owner: -
-- Data Pos: 0
--

COPY "acostarep"."ordenes" ("id", "is_active_orden", "metodo_pago_id", "tipo_distribucion_id", "total_orden", "status_id", "tipo_orden_id", "cliente_id", "observaciones_orden", "cede", "created_by", "updated_by", "created_at", "updated_at") FROM stdin;
\.


--
-- TOC entry 4543 (class 0 OID 23863171)
-- Dependencies: 232
-- Data for Name: productos; Type: TABLE DATA; Schema: acostarep; Owner: -
-- Data Pos: 0
--

COPY "acostarep"."productos" ("nombre_producto", "id", "upc", "id_marca", "id_categoria", "foto", "precio_taller", "precio_mayoreo", "precio_publico", "stock_prod_sta_ana", "stock_prod_metapan", "uom_id", "is_active_producto", "created_at", "updated_at", "created_by", "updated_by") FROM stdin;
\.


--
-- TOC entry 4544 (class 0 OID 23863184)
-- Dependencies: 233
-- Data for Name: productos_orden; Type: TABLE DATA; Schema: acostarep; Owner: -
-- Data Pos: 0
--

COPY "acostarep"."productos_orden" ("id", "id_orden", "id_producto", "cantidad", "precio", "descuento", "sub_total", "stock", "created_at") FROM stdin;
\.


--
-- TOC entry 4546 (class 0 OID 23863188)
-- Dependencies: 235
-- Data for Name: types; Type: TABLE DATA; Schema: acostarep; Owner: -
-- Data Pos: 0
--

COPY "acostarep"."types" ("code", "id", "name", "combo_objeto", "is_active") FROM stdin;
	1	UN - Unidades	uom	t
	2	KG - Kilogramo	uom	t
	3	TN - Tonelada	uom	t
	4	PR - Par	uom	t
	5	BK - Balde	uom	t
	6	BX - Caja	uom	t
	7	BT - botella	uom	t
	8	GM - Gramos	uom	t
	9	LT - Litro	uom	t
	10	M3 - Metro cubico	uom	t
	11	MT - Metro	uom	t
	12	CM3 - Cm cubico	uom	t
	13	CM - Cm	uom	t
	14	ML - Mililitro	uom	t
	15	Tarjeta de Crédito	payment_method	t
	16	Tarjeta de Débito	payment_method	t
	17	Efectivo	payment_method	t
	18	Credito Fiscal	payment_method	t
	19	Criptomoneda	payment_method	t
\N	20	Público	tipo_distribucion	t
\N	21	Mayoreo	tipo_distribucion	t
\N	22	Taller	tipo_distribucion	t
\N	25	En proceso	order_status	t
\N	26	En camino	order_status	t
\N	27	Completado	order_status	t
27	23	Local	order_type	t
25	24	Delivery	order_type	t
\.


--
-- TOC entry 4548 (class 0 OID 23863195)
-- Dependencies: 237
-- Data for Name: hdb_action_log; Type: TABLE DATA; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

COPY "hdb_catalog"."hdb_action_log" ("id", "action_name", "input_payload", "request_headers", "session_variables", "response_payload", "errors", "created_at", "response_received_at", "status") FROM stdin;
\.


--
-- TOC entry 4549 (class 0 OID 23863203)
-- Dependencies: 238
-- Data for Name: hdb_cron_event_invocation_logs; Type: TABLE DATA; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

COPY "hdb_catalog"."hdb_cron_event_invocation_logs" ("id", "event_id", "status", "request", "response", "created_at") FROM stdin;
\.


--
-- TOC entry 4550 (class 0 OID 23863210)
-- Dependencies: 239
-- Data for Name: hdb_cron_events; Type: TABLE DATA; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

COPY "hdb_catalog"."hdb_cron_events" ("id", "trigger_name", "scheduled_time", "status", "tries", "created_at", "next_retry_at") FROM stdin;
\.


--
-- TOC entry 4551 (class 0 OID 23863220)
-- Dependencies: 240
-- Data for Name: hdb_metadata; Type: TABLE DATA; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

COPY "hdb_catalog"."hdb_metadata" ("id", "metadata", "resource_version") FROM stdin;
1	{"backend_configs":{"dataconnector":{"athena":{"uri":"http://localhost:8081/api/v1/athena"},"mariadb":{"uri":"http://localhost:8081/api/v1/mariadb"},"mongodb":{"uri":"http://localhost:8082"},"mysql8":{"uri":"http://localhost:8081/api/v1/mysql"},"oracle":{"uri":"http://localhost:8081/api/v1/oracle"},"snowflake":{"uri":"http://localhost:8081/api/v1/snowflake"}}},"sources":[{"configuration":{"connection_info":{"database_url":{"from_env":"DB_URL_FROM_ENV"},"isolation_level":"read-committed","use_prepared_statements":false}},"kind":"postgres","name":"postgres","tables":[{"insert_permissions":[{"comment":"","permission":{"check":{},"columns":["descripcion_categoria","id","nombre_categoria"]},"role":"gerente_area"}],"select_permissions":[{"comment":"","permission":{"allow_aggregations":true,"columns":["descripcion_categoria","id","is_active_categoria","nombre_categoria"],"filter":{}},"role":"gerente_area"},{"comment":"","permission":{"allow_aggregations":true,"columns":["descripcion_categoria","id","is_active_categoria","nombre_categoria"],"filter":{}},"role":"seller"}],"table":{"name":"categorias","schema":"acostarep"},"update_permissions":[{"comment":"","permission":{"check":null,"columns":["descripcion_categoria","id","is_active_categoria","nombre_categoria"],"filter":{}},"role":"gerente_area"}]},{"insert_permissions":[{"comment":"","permission":{"check":{},"columns":["activo_cliente","direccion","dui","email","empresa","id","last_name","name","telefono"],"set":{"created_by":"x-hasura-user-email"}},"role":"gerente_area"},{"comment":"","permission":{"check":{},"columns":["activo_cliente","direccion","dui","email","empresa","id","last_name","name","telefono"],"set":{"created_by":"x-hasura-user-email"}},"role":"seller"}],"select_permissions":[{"comment":"","permission":{"allow_aggregations":true,"columns":["activo_cliente","direccion","dui","email","empresa","last_name","name","telefono","id","created_by","updated_by","created_at","updated_at"],"filter":{}},"role":"gerente_area"},{"comment":"","permission":{"allow_aggregations":true,"columns":["activo_cliente","direccion","dui","email","empresa","last_name","name","telefono","id","created_by","updated_by","created_at","updated_at"],"filter":{}},"role":"seller"}],"table":{"name":"cliente","schema":"acostarep"},"update_permissions":[{"comment":"","permission":{"check":{},"columns":["activo_cliente","direccion","dui","email","empresa","id","last_name","name","telefono"],"filter":{},"set":{"updated_by":"x-hasura-user-email"}},"role":"gerente_area"},{"comment":"","permission":{"check":{},"columns":["activo_cliente","direccion","dui","email","empresa","id","last_name","name","telefono"],"filter":{},"set":{"updated_by":"x-hasura-user-email"}},"role":"seller"}]},{"insert_permissions":[{"comment":"","permission":{"check":{},"columns":["descripcion_marca","id","nombre_marca"]},"role":"gerente_area"}],"select_permissions":[{"comment":"","permission":{"allow_aggregations":true,"columns":["descripcion_marca","id","is_active_marca","nombre_marca"],"filter":{}},"role":"gerente_area"},{"comment":"","permission":{"allow_aggregations":true,"columns":["descripcion_marca","id","is_active_marca","nombre_marca"],"filter":{}},"role":"seller"}],"table":{"name":"marcas","schema":"acostarep"},"update_permissions":[{"comment":"","permission":{"check":null,"columns":["descripcion_marca","id","is_active_marca","nombre_marca"],"filter":{}},"role":"gerente_area"}]},{"insert_permissions":[{"comment":"","permission":{"check":{},"columns":["cede","cliente_id","id","metodo_pago_id","observaciones_orden","status_id","tipo_distribucion_id","tipo_orden_id","total_orden"],"set":{"created_by":"x-hasura-user-email"}},"role":"gerente_area"},{"comment":"","permission":{"check":{},"columns":["cede","cliente_id","id","metodo_pago_id","observaciones_orden","status_id","tipo_distribucion_id","tipo_orden_id","total_orden"],"set":{"created_by":"x-hasura-user-email"}},"role":"seller"}],"object_relationships":[{"name":"cliente","using":{"manual_configuration":{"column_mapping":{"cliente_id":"id"},"insertion_order":null,"remote_table":{"name":"cliente","schema":"acostarep"}}}},{"name":"metodo_pago","using":{"manual_configuration":{"column_mapping":{"metodo_pago_id":"id"},"insertion_order":null,"remote_table":{"name":"types","schema":"acostarep"}}}},{"name":"status","using":{"manual_configuration":{"column_mapping":{"status_id":"id"},"insertion_order":null,"remote_table":{"name":"types","schema":"acostarep"}}}},{"name":"tipo_distribucion","using":{"manual_configuration":{"column_mapping":{"tipo_distribucion_id":"id"},"insertion_order":null,"remote_table":{"name":"types","schema":"acostarep"}}}},{"name":"tipo_orden","using":{"manual_configuration":{"column_mapping":{"tipo_orden_id":"id"},"insertion_order":null,"remote_table":{"name":"types","schema":"acostarep"}}}}],"select_permissions":[{"comment":"","permission":{"allow_aggregations":true,"columns":["is_active_orden","observaciones_orden","total_orden","cliente_id","id","metodo_pago_id","status_id","tipo_distribucion_id","tipo_orden_id","cede","created_by","updated_by","created_at","updated_at"],"filter":{}},"role":"gerente_area"},{"comment":"","permission":{"allow_aggregations":true,"columns":["is_active_orden","observaciones_orden","total_orden","cliente_id","id","metodo_pago_id","status_id","tipo_distribucion_id","tipo_orden_id","cede","created_by","updated_by","created_at","updated_at"],"filter":{}},"role":"seller"}],"table":{"name":"ordenes","schema":"acostarep"},"update_permissions":[{"comment":"","permission":{"check":{},"columns":["cede","cliente_id","id","is_active_orden","metodo_pago_id","observaciones_orden","status_id","tipo_distribucion_id","tipo_orden_id","total_orden"],"filter":{},"set":{"updated_by":"x-hasura-user-email"}},"role":"gerente_area"},{"comment":"","permission":{"check":{},"columns":["cede","cliente_id","id","is_active_orden","metodo_pago_id","observaciones_orden","status_id","tipo_distribucion_id","tipo_orden_id","total_orden"],"filter":{},"set":{"updated_by":"x-hasura-user-email"}},"role":"seller"}]},{"insert_permissions":[{"comment":"","permission":{"check":{},"columns":["foto","id","id_categoria","id_marca","is_active_producto","nombre_producto","precio_mayoreo","precio_publico","precio_taller","stock_prod_metapan","stock_prod_sta_ana","uom_id","upc"],"set":{"created_by":"x-hasura-user-email"}},"role":"gerente_area"}],"object_relationships":[{"name":"categoria","using":{"manual_configuration":{"column_mapping":{"id_categoria":"id"},"insertion_order":null,"remote_table":{"name":"categorias","schema":"acostarep"}}}},{"name":"marca","using":{"manual_configuration":{"column_mapping":{"id_marca":"id"},"insertion_order":null,"remote_table":{"name":"marcas","schema":"acostarep"}}}}],"select_permissions":[{"comment":"","permission":{"allow_aggregations":true,"columns":["is_active_producto","foto","nombre_producto","upc","precio_mayoreo","precio_publico","precio_taller","stock_prod_metapan","stock_prod_sta_ana","id","id_categoria","id_marca","uom_id","created_by","updated_by","created_at","updated_at"],"filter":{}},"role":"gerente_area"},{"comment":"","permission":{"allow_aggregations":true,"columns":["is_active_producto","foto","nombre_producto","upc","precio_mayoreo","precio_publico","precio_taller","stock_prod_metapan","stock_prod_sta_ana","id","id_categoria","id_marca","uom_id","created_by","updated_by","created_at","updated_at"],"filter":{}},"role":"seller"}],"table":{"name":"productos","schema":"acostarep"},"update_permissions":[{"comment":"","permission":{"check":null,"columns":["foto","id","id_categoria","id_marca","is_active_producto","nombre_producto","precio_mayoreo","precio_publico","precio_taller","stock_prod_metapan","stock_prod_sta_ana","uom_id","upc"],"filter":{},"set":{"updated_by":"x-hasura-user-email"}},"role":"gerente_area"}]},{"insert_permissions":[{"comment":"","permission":{"check":{},"columns":["cantidad","descuento","id","id_orden","id_producto","precio","stock","sub_total"]},"role":"gerente_area"},{"comment":"","permission":{"check":{},"columns":["cantidad","descuento","id","id_orden","id_producto","precio","stock","sub_total"]},"role":"seller"}],"object_relationships":[{"name":"orden","using":{"manual_configuration":{"column_mapping":{"id_orden":"id"},"insertion_order":null,"remote_table":{"name":"ordenes","schema":"acostarep"}}}},{"name":"producto","using":{"manual_configuration":{"column_mapping":{"id_producto":"id"},"insertion_order":null,"remote_table":{"name":"productos","schema":"acostarep"}}}}],"select_permissions":[{"comment":"","permission":{"allow_aggregations":true,"columns":["cantidad","descuento","precio","sub_total","id","id_orden","id_producto","stock","created_at"],"filter":{}},"role":"gerente_area"},{"comment":"","permission":{"allow_aggregations":true,"columns":["cantidad","descuento","precio","sub_total","id","id_orden","id_producto","stock","created_at"],"filter":{}},"role":"seller"}],"table":{"name":"productos_orden","schema":"acostarep"}},{"select_permissions":[{"comment":"","permission":{"columns":["is_active","code","combo_objeto","name","id"],"filter":{}},"role":"gerente_area"},{"comment":"","permission":{"columns":["is_active","code","combo_objeto","name","id"],"filter":{}},"role":"seller"}],"table":{"name":"types","schema":"acostarep"}},{"delete_permissions":[{"comment":"","permission":{"filter":{}},"role":"gerente_area"}],"select_permissions":[{"comment":"","permission":{"columns":["roles","sucursal","active","email","name","password","created_on","id"],"filter":{}},"role":"gerente_area"}],"table":{"name":"users","schema":"public"},"update_permissions":[{"comment":"","permission":{"check":null,"columns":["active","email","name","roles","sucursal"],"filter":{}},"role":"gerente_area"}]}]}],"version":3}	6
\.


--
-- TOC entry 4552 (class 0 OID 23863226)
-- Dependencies: 241
-- Data for Name: hdb_scheduled_event_invocation_logs; Type: TABLE DATA; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

COPY "hdb_catalog"."hdb_scheduled_event_invocation_logs" ("id", "event_id", "status", "request", "response", "created_at") FROM stdin;
\.


--
-- TOC entry 4553 (class 0 OID 23863233)
-- Dependencies: 242
-- Data for Name: hdb_scheduled_events; Type: TABLE DATA; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

COPY "hdb_catalog"."hdb_scheduled_events" ("id", "webhook_conf", "scheduled_time", "retry_conf", "payload", "header_conf", "status", "tries", "created_at", "next_retry_at", "comment") FROM stdin;
\.


--
-- TOC entry 4554 (class 0 OID 23863243)
-- Dependencies: 243
-- Data for Name: hdb_schema_notifications; Type: TABLE DATA; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

COPY "hdb_catalog"."hdb_schema_notifications" ("id", "notification", "resource_version", "instance_id", "updated_at") FROM stdin;
1	{"metadata":false,"remote_schemas":[],"sources":[],"data_connectors":[]}	6	6666d954-4e26-4ac7-aabe-9437beb46c58	2024-01-06 18:55:32.451807+00
\.


--
-- TOC entry 4555 (class 0 OID 23863251)
-- Dependencies: 244
-- Data for Name: hdb_version; Type: TABLE DATA; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

COPY "hdb_catalog"."hdb_version" ("hasura_uuid", "version", "upgraded_on", "cli_state", "console_state", "ee_client_id", "ee_client_secret") FROM stdin;
d8eba5e3-d961-49af-9775-0fff52c8bccc	48	2024-01-06 18:28:26.158967+00	{}	{"console_notifications": {"admin": {"date": "2024-01-06T18:58:05.390Z", "read": [], "showBadge": false}}}	\N	\N
\.


--
-- TOC entry 4556 (class 0 OID 23863259)
-- Dependencies: 245
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
-- Data Pos: 0
--

COPY "public"."users" ("id", "name", "email", "password", "active", "created_on", "sucursal", "roles") FROM stdin;
140f5858-b91e-4181-b91a-a182e1b378cf	admin	admin@admin.com	$2b$10$.Imy/JWIFKk66fSfAi8yk.2fomy/Bp7/MqUYGhwiRiH7lDMbdNFVG	t	2024-09-11 15:11:18.704889	{"Santa Ana"}	{admin}
ce022fbe-7d28-46c7-abc7-af41066cf103	Cristian Aarón Ayala	cristianaaron10@gmail.com	$2b$10$bpYCOvu0ohtd/LKsrka6k.G3kDlFEw8kBlVzG33em0e4Xh/RkUPAK	t	2024-09-14 15:21:40.793913	{"Santa Ana"}	{gerente_area}
c59c2042-f22d-4ace-987d-0de356c81464	vendedor 1	vendedor1@app.com	$2b$10$Q6m40lGZqOtMgBzkVruHIu0TwmHb6hFdoi9Y/S4Jp7tu1p1aFgeRy	t	2024-09-14 15:32:16.686637	{Metapan,"Santa Ana"}	{seller}
\.


--
-- TOC entry 4578 (class 0 OID 0)
-- Dependencies: 226
-- Name: cliente_id_seq; Type: SEQUENCE SET; Schema: acostarep; Owner: -
-- Data Pos: 0
--

SELECT pg_catalog.setval('"acostarep"."cliente_id_seq"', 2, true);


--
-- TOC entry 4579 (class 0 OID 0)
-- Dependencies: 234
-- Name: productos_orden_id_seq; Type: SEQUENCE SET; Schema: acostarep; Owner: -
-- Data Pos: 0
--

SELECT pg_catalog.setval('"acostarep"."productos_orden_id_seq"', 1, false);


--
-- TOC entry 4580 (class 0 OID 0)
-- Dependencies: 236
-- Name: types_id_seq; Type: SEQUENCE SET; Schema: acostarep; Owner: -
-- Data Pos: 0
--

SELECT pg_catalog.setval('"acostarep"."types_id_seq"', 27, true);


--
-- TOC entry 4581 (class 0 OID 0)
-- Dependencies: 223
-- Name: categorias_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
-- Data Pos: 0
--

SELECT pg_catalog.setval('"public"."categorias_id_seq"', 1, false);


--
-- TOC entry 4582 (class 0 OID 0)
-- Dependencies: 227
-- Name: marcas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
-- Data Pos: 0
--

SELECT pg_catalog.setval('"public"."marcas_id_seq"', 1, false);


--
-- TOC entry 4583 (class 0 OID 0)
-- Dependencies: 229
-- Name: ordenes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
-- Data Pos: 0
--

SELECT pg_catalog.setval('"public"."ordenes_id_seq"', 1, false);


--
-- TOC entry 4584 (class 0 OID 0)
-- Dependencies: 231
-- Name: productos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
-- Data Pos: 0
--

SELECT pg_catalog.setval('"public"."productos_id_seq"', 1, false);


--
-- TOC entry 4339 (class 2606 OID 23863271)
-- Dependencies: 224
-- Name: categorias categorias_nombre_categoria_key; Type: CONSTRAINT; Schema: acostarep; Owner: -
-- Data Pos: 0
--

ALTER TABLE ONLY "acostarep"."categorias"
    ADD CONSTRAINT "categorias_nombre_categoria_key" UNIQUE ("nombre_categoria");


--
-- TOC entry 4341 (class 2606 OID 23863273)
-- Dependencies: 224
-- Name: categorias categorias_pkey; Type: CONSTRAINT; Schema: acostarep; Owner: -
-- Data Pos: 0
--

ALTER TABLE ONLY "acostarep"."categorias"
    ADD CONSTRAINT "categorias_pkey" PRIMARY KEY ("id");


--
-- TOC entry 4343 (class 2606 OID 23863275)
-- Dependencies: 225
-- Name: cliente cliente_pkey; Type: CONSTRAINT; Schema: acostarep; Owner: -
-- Data Pos: 0
--

ALTER TABLE ONLY "acostarep"."cliente"
    ADD CONSTRAINT "cliente_pkey" PRIMARY KEY ("id");


--
-- TOC entry 4345 (class 2606 OID 23863277)
-- Dependencies: 228
-- Name: marcas marcas_nombre_marca_key; Type: CONSTRAINT; Schema: acostarep; Owner: -
-- Data Pos: 0
--

ALTER TABLE ONLY "acostarep"."marcas"
    ADD CONSTRAINT "marcas_nombre_marca_key" UNIQUE ("nombre_marca");


--
-- TOC entry 4347 (class 2606 OID 23863279)
-- Dependencies: 228
-- Name: marcas marcas_pkey; Type: CONSTRAINT; Schema: acostarep; Owner: -
-- Data Pos: 0
--

ALTER TABLE ONLY "acostarep"."marcas"
    ADD CONSTRAINT "marcas_pkey" PRIMARY KEY ("id");


--
-- TOC entry 4349 (class 2606 OID 23863281)
-- Dependencies: 230
-- Name: ordenes ordenes_pkey; Type: CONSTRAINT; Schema: acostarep; Owner: -
-- Data Pos: 0
--

ALTER TABLE ONLY "acostarep"."ordenes"
    ADD CONSTRAINT "ordenes_pkey" PRIMARY KEY ("id");


--
-- TOC entry 4353 (class 2606 OID 23863283)
-- Dependencies: 233
-- Name: productos_orden productos_orden_pkey; Type: CONSTRAINT; Schema: acostarep; Owner: -
-- Data Pos: 0
--

ALTER TABLE ONLY "acostarep"."productos_orden"
    ADD CONSTRAINT "productos_orden_pkey" PRIMARY KEY ("id");


--
-- TOC entry 4351 (class 2606 OID 23863285)
-- Dependencies: 232
-- Name: productos productos_pkey; Type: CONSTRAINT; Schema: acostarep; Owner: -
-- Data Pos: 0
--

ALTER TABLE ONLY "acostarep"."productos"
    ADD CONSTRAINT "productos_pkey" PRIMARY KEY ("id");


--
-- TOC entry 4355 (class 2606 OID 23863287)
-- Dependencies: 235
-- Name: types types_pkey; Type: CONSTRAINT; Schema: acostarep; Owner: -
-- Data Pos: 0
--

ALTER TABLE ONLY "acostarep"."types"
    ADD CONSTRAINT "types_pkey" PRIMARY KEY ("id");


--
-- TOC entry 4357 (class 2606 OID 23863289)
-- Dependencies: 237
-- Name: hdb_action_log hdb_action_log_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

ALTER TABLE ONLY "hdb_catalog"."hdb_action_log"
    ADD CONSTRAINT "hdb_action_log_pkey" PRIMARY KEY ("id");


--
-- TOC entry 4360 (class 2606 OID 23863291)
-- Dependencies: 238
-- Name: hdb_cron_event_invocation_logs hdb_cron_event_invocation_logs_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

ALTER TABLE ONLY "hdb_catalog"."hdb_cron_event_invocation_logs"
    ADD CONSTRAINT "hdb_cron_event_invocation_logs_pkey" PRIMARY KEY ("id");


--
-- TOC entry 4363 (class 2606 OID 23863293)
-- Dependencies: 239
-- Name: hdb_cron_events hdb_cron_events_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

ALTER TABLE ONLY "hdb_catalog"."hdb_cron_events"
    ADD CONSTRAINT "hdb_cron_events_pkey" PRIMARY KEY ("id");


--
-- TOC entry 4366 (class 2606 OID 23863295)
-- Dependencies: 240
-- Name: hdb_metadata hdb_metadata_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

ALTER TABLE ONLY "hdb_catalog"."hdb_metadata"
    ADD CONSTRAINT "hdb_metadata_pkey" PRIMARY KEY ("id");


--
-- TOC entry 4368 (class 2606 OID 23863297)
-- Dependencies: 240
-- Name: hdb_metadata hdb_metadata_resource_version_key; Type: CONSTRAINT; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

ALTER TABLE ONLY "hdb_catalog"."hdb_metadata"
    ADD CONSTRAINT "hdb_metadata_resource_version_key" UNIQUE ("resource_version");


--
-- TOC entry 4370 (class 2606 OID 23863299)
-- Dependencies: 241
-- Name: hdb_scheduled_event_invocation_logs hdb_scheduled_event_invocation_logs_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

ALTER TABLE ONLY "hdb_catalog"."hdb_scheduled_event_invocation_logs"
    ADD CONSTRAINT "hdb_scheduled_event_invocation_logs_pkey" PRIMARY KEY ("id");


--
-- TOC entry 4373 (class 2606 OID 23863301)
-- Dependencies: 242
-- Name: hdb_scheduled_events hdb_scheduled_events_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

ALTER TABLE ONLY "hdb_catalog"."hdb_scheduled_events"
    ADD CONSTRAINT "hdb_scheduled_events_pkey" PRIMARY KEY ("id");


--
-- TOC entry 4375 (class 2606 OID 23863303)
-- Dependencies: 243
-- Name: hdb_schema_notifications hdb_schema_notifications_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

ALTER TABLE ONLY "hdb_catalog"."hdb_schema_notifications"
    ADD CONSTRAINT "hdb_schema_notifications_pkey" PRIMARY KEY ("id");


--
-- TOC entry 4378 (class 2606 OID 23863305)
-- Dependencies: 244
-- Name: hdb_version hdb_version_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

ALTER TABLE ONLY "hdb_catalog"."hdb_version"
    ADD CONSTRAINT "hdb_version_pkey" PRIMARY KEY ("hasura_uuid");


--
-- TOC entry 4380 (class 2606 OID 23863307)
-- Dependencies: 245
-- Name: users PK_a3ffb1c0c8416b9fc6f907b7433; Type: CONSTRAINT; Schema: public; Owner: -
-- Data Pos: 0
--

ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "PK_a3ffb1c0c8416b9fc6f907b7433" PRIMARY KEY ("id");


--
-- TOC entry 4382 (class 2606 OID 23863309)
-- Dependencies: 245
-- Name: users UQ_97672ac88f789774dd47f7c8be3; Type: CONSTRAINT; Schema: public; Owner: -
-- Data Pos: 0
--

ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "UQ_97672ac88f789774dd47f7c8be3" UNIQUE ("email");


--
-- TOC entry 4358 (class 1259 OID 23863310)
-- Dependencies: 238
-- Name: hdb_cron_event_invocation_event_id; Type: INDEX; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

CREATE INDEX "hdb_cron_event_invocation_event_id" ON "hdb_catalog"."hdb_cron_event_invocation_logs" USING "btree" ("event_id");


--
-- TOC entry 4361 (class 1259 OID 23863311)
-- Dependencies: 239
-- Name: hdb_cron_event_status; Type: INDEX; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

CREATE INDEX "hdb_cron_event_status" ON "hdb_catalog"."hdb_cron_events" USING "btree" ("status");


--
-- TOC entry 4364 (class 1259 OID 23863312)
-- Dependencies: 239 239 239
-- Name: hdb_cron_events_unique_scheduled; Type: INDEX; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

CREATE UNIQUE INDEX "hdb_cron_events_unique_scheduled" ON "hdb_catalog"."hdb_cron_events" USING "btree" ("trigger_name", "scheduled_time") WHERE ("status" = 'scheduled'::"text");


--
-- TOC entry 4371 (class 1259 OID 23863313)
-- Dependencies: 242
-- Name: hdb_scheduled_event_status; Type: INDEX; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

CREATE INDEX "hdb_scheduled_event_status" ON "hdb_catalog"."hdb_scheduled_events" USING "btree" ("status");


--
-- TOC entry 4376 (class 1259 OID 23863314)
-- Dependencies: 244 244
-- Name: hdb_version_one_row; Type: INDEX; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

CREATE UNIQUE INDEX "hdb_version_one_row" ON "hdb_catalog"."hdb_version" USING "btree" ((("version" IS NOT NULL)));


--
-- TOC entry 4385 (class 2620 OID 24040654)
-- Dependencies: 225 308
-- Name: cliente set_acostarep_clientes_updated_at; Type: TRIGGER; Schema: acostarep; Owner: -
-- Data Pos: 0
--

CREATE TRIGGER "set_acostarep_clientes_updated_at" BEFORE UPDATE ON "acostarep"."cliente" FOR EACH ROW EXECUTE FUNCTION "acostarep"."set_current_timestamp_updated_at"();


--
-- TOC entry 4585 (class 0 OID 0)
-- Dependencies: 4385
-- Name: TRIGGER "set_acostarep_clientes_updated_at" ON "cliente"; Type: COMMENT; Schema: acostarep; Owner: -
-- Data Pos: 0
--

COMMENT ON TRIGGER "set_acostarep_clientes_updated_at" ON "acostarep"."cliente" IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- TOC entry 4386 (class 2620 OID 24040653)
-- Dependencies: 230 308
-- Name: ordenes set_acostarep_ordenes_updated_at; Type: TRIGGER; Schema: acostarep; Owner: -
-- Data Pos: 0
--

CREATE TRIGGER "set_acostarep_ordenes_updated_at" BEFORE UPDATE ON "acostarep"."ordenes" FOR EACH ROW EXECUTE FUNCTION "acostarep"."set_current_timestamp_updated_at"();


--
-- TOC entry 4586 (class 0 OID 0)
-- Dependencies: 4386
-- Name: TRIGGER "set_acostarep_ordenes_updated_at" ON "ordenes"; Type: COMMENT; Schema: acostarep; Owner: -
-- Data Pos: 0
--

COMMENT ON TRIGGER "set_acostarep_ordenes_updated_at" ON "acostarep"."ordenes" IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- TOC entry 4388 (class 2620 OID 24170109)
-- Dependencies: 233 309
-- Name: productos_orden trigger_update_stock_before_insert; Type: TRIGGER; Schema: acostarep; Owner: -
-- Data Pos: 0
--

CREATE TRIGGER "trigger_update_stock_before_insert" BEFORE INSERT ON "acostarep"."productos_orden" FOR EACH ROW EXECUTE FUNCTION "public"."update_stock_before_insert"();


--
-- TOC entry 4387 (class 2620 OID 23863315)
-- Dependencies: 308 232
-- Name: productos update_column_updated_at_trigger_productos; Type: TRIGGER; Schema: acostarep; Owner: -
-- Data Pos: 0
--

CREATE TRIGGER "update_column_updated_at_trigger_productos" BEFORE UPDATE ON "acostarep"."productos" FOR EACH ROW EXECUTE FUNCTION "acostarep"."set_current_timestamp_updated_at"();


--
-- TOC entry 4383 (class 2606 OID 23863316)
-- Dependencies: 238 4363 239
-- Name: hdb_cron_event_invocation_logs hdb_cron_event_invocation_logs_event_id_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

ALTER TABLE ONLY "hdb_catalog"."hdb_cron_event_invocation_logs"
    ADD CONSTRAINT "hdb_cron_event_invocation_logs_event_id_fkey" FOREIGN KEY ("event_id") REFERENCES "hdb_catalog"."hdb_cron_events"("id") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4384 (class 2606 OID 23863321)
-- Dependencies: 242 241 4373
-- Name: hdb_scheduled_event_invocation_logs hdb_scheduled_event_invocation_logs_event_id_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: -
-- Data Pos: 0
--

ALTER TABLE ONLY "hdb_catalog"."hdb_scheduled_event_invocation_logs"
    ADD CONSTRAINT "hdb_scheduled_event_invocation_logs_event_id_fkey" FOREIGN KEY ("event_id") REFERENCES "hdb_catalog"."hdb_scheduled_events"("id") ON UPDATE CASCADE ON DELETE CASCADE;


-- Completed on 2024-09-18 15:40:03 CST

--
-- PostgreSQL database dump complete
--

