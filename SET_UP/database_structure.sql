--
-- PostgreSQL database dump
--

-- Dumped from database version 15.4
-- Dumped by pg_dump version 15.4

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
-- Name: acostarep; Type: SCHEMA; Schema: -; Owner: cristian
--

CREATE SCHEMA acostarep;


ALTER SCHEMA acostarep OWNER TO cristian;

--
-- Name: hdb_catalog; Type: SCHEMA; Schema: -; Owner: cristian
--

CREATE SCHEMA hdb_catalog;


ALTER SCHEMA hdb_catalog OWNER TO cristian;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: set_current_timestamp_updated_at(); Type: FUNCTION; Schema: acostarep; Owner: cristian
--

CREATE FUNCTION acostarep.set_current_timestamp_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."updated_at" = NOW();
  RETURN _new;
END;
$$;


ALTER FUNCTION acostarep.set_current_timestamp_updated_at() OWNER TO cristian;

--
-- Name: gen_hasura_uuid(); Type: FUNCTION; Schema: hdb_catalog; Owner: cristian
--

CREATE FUNCTION hdb_catalog.gen_hasura_uuid() RETURNS uuid
    LANGUAGE sql
    AS $$select gen_random_uuid()$$;


ALTER FUNCTION hdb_catalog.gen_hasura_uuid() OWNER TO cristian;

--
-- Name: categorias_id_seq; Type: SEQUENCE; Schema: public; Owner: cristian
--

CREATE SEQUENCE public.categorias_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.categorias_id_seq OWNER TO cristian;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: categorias; Type: TABLE; Schema: acostarep; Owner: cristian
--

CREATE TABLE acostarep.categorias (
    id integer DEFAULT nextval('public.categorias_id_seq'::regclass) NOT NULL,
    nombre_categoria character varying NOT NULL,
    descripcion_categoria character varying,
    is_active_categoria boolean DEFAULT true
);


ALTER TABLE acostarep.categorias OWNER TO cristian;

--
-- Name: TABLE categorias; Type: COMMENT; Schema: acostarep; Owner: cristian
--

COMMENT ON TABLE acostarep.categorias IS 'categorias';


--
-- Name: cliente; Type: TABLE; Schema: acostarep; Owner: cristian
--

CREATE TABLE acostarep.cliente (
    id integer NOT NULL,
    name character varying NOT NULL,
    last_name character varying,
    email character varying,
    direccion character varying,
    telefono character varying,
    empresa character varying,
    activo_cliente boolean DEFAULT true,
    dui character varying,
    created_by character varying,
    updated_by character varying,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE acostarep.cliente OWNER TO cristian;

--
-- Name: TABLE cliente; Type: COMMENT; Schema: acostarep; Owner: cristian
--

COMMENT ON TABLE acostarep.cliente IS 'cliente';


--
-- Name: cliente_id_seq; Type: SEQUENCE; Schema: acostarep; Owner: cristian
--

CREATE SEQUENCE acostarep.cliente_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE acostarep.cliente_id_seq OWNER TO cristian;

--
-- Name: cliente_id_seq; Type: SEQUENCE OWNED BY; Schema: acostarep; Owner: cristian
--

ALTER SEQUENCE acostarep.cliente_id_seq OWNED BY acostarep.cliente.id;


--
-- Name: marcas_id_seq; Type: SEQUENCE; Schema: public; Owner: cristian
--

CREATE SEQUENCE public.marcas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.marcas_id_seq OWNER TO cristian;

--
-- Name: marcas; Type: TABLE; Schema: acostarep; Owner: cristian
--

CREATE TABLE acostarep.marcas (
    id integer DEFAULT nextval('public.marcas_id_seq'::regclass) NOT NULL,
    nombre_marca character varying NOT NULL,
    descripcion_marca character varying,
    is_active_marca boolean DEFAULT true
);


ALTER TABLE acostarep.marcas OWNER TO cristian;

--
-- Name: TABLE marcas; Type: COMMENT; Schema: acostarep; Owner: cristian
--

COMMENT ON TABLE acostarep.marcas IS 'marcas';


--
-- Name: ordenes_id_seq; Type: SEQUENCE; Schema: public; Owner: cristian
--

CREATE SEQUENCE public.ordenes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.ordenes_id_seq OWNER TO cristian;

--
-- Name: ordenes; Type: TABLE; Schema: acostarep; Owner: cristian
--

CREATE TABLE acostarep.ordenes (
    id integer DEFAULT nextval('public.ordenes_id_seq'::regclass) NOT NULL,
    is_active_orden boolean DEFAULT true NOT NULL,
    metodo_pago_id integer NOT NULL,
    tipo_distribucion_id integer NOT NULL,
    total_orden double precision NOT NULL,
    status_id integer NOT NULL,
    tipo_orden_id integer NOT NULL,
    cliente_id integer NOT NULL,
    observaciones_orden character varying,
    cede text,
    created_by character varying,
    updated_by character varying,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE acostarep.ordenes OWNER TO cristian;

--
-- Name: TABLE ordenes; Type: COMMENT; Schema: acostarep; Owner: cristian
--

COMMENT ON TABLE acostarep.ordenes IS 'ordenes';


--
-- Name: productos_id_seq; Type: SEQUENCE; Schema: public; Owner: cristian
--

CREATE SEQUENCE public.productos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.productos_id_seq OWNER TO cristian;

--
-- Name: productos; Type: TABLE; Schema: acostarep; Owner: cristian
--

CREATE TABLE acostarep.productos (
    nombre_producto character varying NOT NULL,
    id integer DEFAULT nextval('public.productos_id_seq'::regclass) NOT NULL,
    upc character varying NOT NULL,
    id_marca integer NOT NULL,
    id_categoria integer NOT NULL,
    foto character varying NOT NULL,
    precio_taller double precision NOT NULL,
    precio_mayoreo double precision NOT NULL,
    precio_publico double precision NOT NULL,
    stock_prod_sta_ana double precision DEFAULT '0'::double precision,
    stock_prod_metapan double precision DEFAULT '0'::double precision,
    uom_id integer,
    is_active_producto boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text DEFAULT 'Jhon Doe'::text NOT NULL,
    updated_by text DEFAULT 'Jhon Doe'::text NOT NULL
);


ALTER TABLE acostarep.productos OWNER TO cristian;

--
-- Name: TABLE productos; Type: COMMENT; Schema: acostarep; Owner: cristian
--

COMMENT ON TABLE acostarep.productos IS 'productos';


--
-- Name: productos_orden; Type: TABLE; Schema: acostarep; Owner: cristian
--

CREATE TABLE acostarep.productos_orden (
    id integer NOT NULL,
    id_orden integer NOT NULL,
    id_producto integer NOT NULL,
    cantidad double precision NOT NULL,
    precio double precision NOT NULL,
    descuento double precision,
    sub_total double precision NOT NULL,
    stock integer,
    created_at timestamp with time zone
);


ALTER TABLE acostarep.productos_orden OWNER TO cristian;

--
-- Name: TABLE productos_orden; Type: COMMENT; Schema: acostarep; Owner: cristian
--

COMMENT ON TABLE acostarep.productos_orden IS 'productos_orden';


--
-- Name: productos_orden_id_seq; Type: SEQUENCE; Schema: acostarep; Owner: cristian
--

CREATE SEQUENCE acostarep.productos_orden_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE acostarep.productos_orden_id_seq OWNER TO cristian;

--
-- Name: productos_orden_id_seq; Type: SEQUENCE OWNED BY; Schema: acostarep; Owner: cristian
--

ALTER SEQUENCE acostarep.productos_orden_id_seq OWNED BY acostarep.productos_orden.id;


--
-- Name: types; Type: TABLE; Schema: acostarep; Owner: cristian
--

CREATE TABLE acostarep.types (
    code character varying,
    id integer NOT NULL,
    name character varying,
    combo_objeto character varying NOT NULL,
    is_active boolean DEFAULT true NOT NULL
);


ALTER TABLE acostarep.types OWNER TO cristian;

--
-- Name: TABLE types; Type: COMMENT; Schema: acostarep; Owner: cristian
--

COMMENT ON TABLE acostarep.types IS 'types';


--
-- Name: types_id_seq; Type: SEQUENCE; Schema: acostarep; Owner: cristian
--

CREATE SEQUENCE acostarep.types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE acostarep.types_id_seq OWNER TO cristian;

--
-- Name: types_id_seq; Type: SEQUENCE OWNED BY; Schema: acostarep; Owner: cristian
--

ALTER SEQUENCE acostarep.types_id_seq OWNED BY acostarep.types.id;


--
-- Name: hdb_action_log; Type: TABLE; Schema: hdb_catalog; Owner: cristian
--

CREATE TABLE hdb_catalog.hdb_action_log (
    id uuid DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    action_name text,
    input_payload jsonb NOT NULL,
    request_headers jsonb NOT NULL,
    session_variables jsonb NOT NULL,
    response_payload jsonb,
    errors jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    response_received_at timestamp with time zone,
    status text NOT NULL,
    CONSTRAINT hdb_action_log_status_check CHECK ((status = ANY (ARRAY['created'::text, 'processing'::text, 'completed'::text, 'error'::text])))
);


ALTER TABLE hdb_catalog.hdb_action_log OWNER TO cristian;

--
-- Name: hdb_cron_event_invocation_logs; Type: TABLE; Schema: hdb_catalog; Owner: cristian
--

CREATE TABLE hdb_catalog.hdb_cron_event_invocation_logs (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    event_id text,
    status integer,
    request json,
    response json,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE hdb_catalog.hdb_cron_event_invocation_logs OWNER TO cristian;

--
-- Name: hdb_cron_events; Type: TABLE; Schema: hdb_catalog; Owner: cristian
--

CREATE TABLE hdb_catalog.hdb_cron_events (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    trigger_name text NOT NULL,
    scheduled_time timestamp with time zone NOT NULL,
    status text DEFAULT 'scheduled'::text NOT NULL,
    tries integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    next_retry_at timestamp with time zone,
    CONSTRAINT valid_status CHECK ((status = ANY (ARRAY['scheduled'::text, 'locked'::text, 'delivered'::text, 'error'::text, 'dead'::text])))
);


ALTER TABLE hdb_catalog.hdb_cron_events OWNER TO cristian;

--
-- Name: hdb_metadata; Type: TABLE; Schema: hdb_catalog; Owner: cristian
--

CREATE TABLE hdb_catalog.hdb_metadata (
    id integer NOT NULL,
    metadata json NOT NULL,
    resource_version integer DEFAULT 1 NOT NULL
);


ALTER TABLE hdb_catalog.hdb_metadata OWNER TO cristian;

--
-- Name: hdb_scheduled_event_invocation_logs; Type: TABLE; Schema: hdb_catalog; Owner: cristian
--

CREATE TABLE hdb_catalog.hdb_scheduled_event_invocation_logs (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    event_id text,
    status integer,
    request json,
    response json,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE hdb_catalog.hdb_scheduled_event_invocation_logs OWNER TO cristian;

--
-- Name: hdb_scheduled_events; Type: TABLE; Schema: hdb_catalog; Owner: cristian
--

CREATE TABLE hdb_catalog.hdb_scheduled_events (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    webhook_conf json NOT NULL,
    scheduled_time timestamp with time zone NOT NULL,
    retry_conf json,
    payload json,
    header_conf json,
    status text DEFAULT 'scheduled'::text NOT NULL,
    tries integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    next_retry_at timestamp with time zone,
    comment text,
    CONSTRAINT valid_status CHECK ((status = ANY (ARRAY['scheduled'::text, 'locked'::text, 'delivered'::text, 'error'::text, 'dead'::text])))
);


ALTER TABLE hdb_catalog.hdb_scheduled_events OWNER TO cristian;

--
-- Name: hdb_schema_notifications; Type: TABLE; Schema: hdb_catalog; Owner: cristian
--

CREATE TABLE hdb_catalog.hdb_schema_notifications (
    id integer NOT NULL,
    notification json NOT NULL,
    resource_version integer DEFAULT 1 NOT NULL,
    instance_id uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT hdb_schema_notifications_id_check CHECK ((id = 1))
);


ALTER TABLE hdb_catalog.hdb_schema_notifications OWNER TO cristian;

--
-- Name: hdb_version; Type: TABLE; Schema: hdb_catalog; Owner: cristian
--

CREATE TABLE hdb_catalog.hdb_version (
    hasura_uuid uuid DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    version text NOT NULL,
    upgraded_on timestamp with time zone NOT NULL,
    cli_state jsonb DEFAULT '{}'::jsonb NOT NULL,
    console_state jsonb DEFAULT '{}'::jsonb NOT NULL,
    ee_client_id text,
    ee_client_secret text
);


ALTER TABLE hdb_catalog.hdb_version OWNER TO cristian;

--
-- Name: cliente id; Type: DEFAULT; Schema: acostarep; Owner: cristian
--

ALTER TABLE ONLY acostarep.cliente ALTER COLUMN id SET DEFAULT nextval('acostarep.cliente_id_seq'::regclass);


--
-- Name: productos_orden id; Type: DEFAULT; Schema: acostarep; Owner: cristian
--

ALTER TABLE ONLY acostarep.productos_orden ALTER COLUMN id SET DEFAULT nextval('acostarep.productos_orden_id_seq'::regclass);


--
-- Name: types id; Type: DEFAULT; Schema: acostarep; Owner: cristian
--

ALTER TABLE ONLY acostarep.types ALTER COLUMN id SET DEFAULT nextval('acostarep.types_id_seq'::regclass);


--
-- Name: categorias categorias_nombre_categoria_key; Type: CONSTRAINT; Schema: acostarep; Owner: cristian
--

ALTER TABLE ONLY acostarep.categorias
    ADD CONSTRAINT categorias_nombre_categoria_key UNIQUE (nombre_categoria);


--
-- Name: categorias categorias_pkey; Type: CONSTRAINT; Schema: acostarep; Owner: cristian
--

ALTER TABLE ONLY acostarep.categorias
    ADD CONSTRAINT categorias_pkey PRIMARY KEY (id);


--
-- Name: cliente cliente_pkey; Type: CONSTRAINT; Schema: acostarep; Owner: cristian
--

ALTER TABLE ONLY acostarep.cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (id);


--
-- Name: marcas marcas_nombre_marca_key; Type: CONSTRAINT; Schema: acostarep; Owner: cristian
--

ALTER TABLE ONLY acostarep.marcas
    ADD CONSTRAINT marcas_nombre_marca_key UNIQUE (nombre_marca);


--
-- Name: marcas marcas_pkey; Type: CONSTRAINT; Schema: acostarep; Owner: cristian
--

ALTER TABLE ONLY acostarep.marcas
    ADD CONSTRAINT marcas_pkey PRIMARY KEY (id);


--
-- Name: ordenes ordenes_pkey; Type: CONSTRAINT; Schema: acostarep; Owner: cristian
--

ALTER TABLE ONLY acostarep.ordenes
    ADD CONSTRAINT ordenes_pkey PRIMARY KEY (id);


--
-- Name: productos_orden productos_orden_pkey; Type: CONSTRAINT; Schema: acostarep; Owner: cristian
--

ALTER TABLE ONLY acostarep.productos_orden
    ADD CONSTRAINT productos_orden_pkey PRIMARY KEY (id);


--
-- Name: productos productos_pkey; Type: CONSTRAINT; Schema: acostarep; Owner: cristian
--

ALTER TABLE ONLY acostarep.productos
    ADD CONSTRAINT productos_pkey PRIMARY KEY (id);


--
-- Name: types types_pkey; Type: CONSTRAINT; Schema: acostarep; Owner: cristian
--

ALTER TABLE ONLY acostarep.types
    ADD CONSTRAINT types_pkey PRIMARY KEY (id);


--
-- Name: hdb_action_log hdb_action_log_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: cristian
--

ALTER TABLE ONLY hdb_catalog.hdb_action_log
    ADD CONSTRAINT hdb_action_log_pkey PRIMARY KEY (id);


--
-- Name: hdb_cron_event_invocation_logs hdb_cron_event_invocation_logs_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: cristian
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_event_invocation_logs
    ADD CONSTRAINT hdb_cron_event_invocation_logs_pkey PRIMARY KEY (id);


--
-- Name: hdb_cron_events hdb_cron_events_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: cristian
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_events
    ADD CONSTRAINT hdb_cron_events_pkey PRIMARY KEY (id);


--
-- Name: hdb_metadata hdb_metadata_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: cristian
--

ALTER TABLE ONLY hdb_catalog.hdb_metadata
    ADD CONSTRAINT hdb_metadata_pkey PRIMARY KEY (id);


--
-- Name: hdb_metadata hdb_metadata_resource_version_key; Type: CONSTRAINT; Schema: hdb_catalog; Owner: cristian
--

ALTER TABLE ONLY hdb_catalog.hdb_metadata
    ADD CONSTRAINT hdb_metadata_resource_version_key UNIQUE (resource_version);


--
-- Name: hdb_scheduled_event_invocation_logs hdb_scheduled_event_invocation_logs_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: cristian
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_event_invocation_logs
    ADD CONSTRAINT hdb_scheduled_event_invocation_logs_pkey PRIMARY KEY (id);


--
-- Name: hdb_scheduled_events hdb_scheduled_events_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: cristian
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_events
    ADD CONSTRAINT hdb_scheduled_events_pkey PRIMARY KEY (id);


--
-- Name: hdb_schema_notifications hdb_schema_notifications_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: cristian
--

ALTER TABLE ONLY hdb_catalog.hdb_schema_notifications
    ADD CONSTRAINT hdb_schema_notifications_pkey PRIMARY KEY (id);


--
-- Name: hdb_version hdb_version_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: cristian
--

ALTER TABLE ONLY hdb_catalog.hdb_version
    ADD CONSTRAINT hdb_version_pkey PRIMARY KEY (hasura_uuid);


--
-- Name: hdb_cron_event_invocation_event_id; Type: INDEX; Schema: hdb_catalog; Owner: cristian
--

CREATE INDEX hdb_cron_event_invocation_event_id ON hdb_catalog.hdb_cron_event_invocation_logs USING btree (event_id);


--
-- Name: hdb_cron_event_status; Type: INDEX; Schema: hdb_catalog; Owner: cristian
--

CREATE INDEX hdb_cron_event_status ON hdb_catalog.hdb_cron_events USING btree (status);


--
-- Name: hdb_cron_events_unique_scheduled; Type: INDEX; Schema: hdb_catalog; Owner: cristian
--

CREATE UNIQUE INDEX hdb_cron_events_unique_scheduled ON hdb_catalog.hdb_cron_events USING btree (trigger_name, scheduled_time) WHERE (status = 'scheduled'::text);


--
-- Name: hdb_scheduled_event_status; Type: INDEX; Schema: hdb_catalog; Owner: cristian
--

CREATE INDEX hdb_scheduled_event_status ON hdb_catalog.hdb_scheduled_events USING btree (status);


--
-- Name: hdb_version_one_row; Type: INDEX; Schema: hdb_catalog; Owner: cristian
--

CREATE UNIQUE INDEX hdb_version_one_row ON hdb_catalog.hdb_version USING btree (((version IS NOT NULL)));


--
-- Name: productos update_column_updated_at_trigger_productos; Type: TRIGGER; Schema: acostarep; Owner: cristian
--

CREATE TRIGGER update_column_updated_at_trigger_productos BEFORE UPDATE ON acostarep.productos FOR EACH ROW EXECUTE FUNCTION acostarep.set_current_timestamp_updated_at();


--
-- Name: hdb_cron_event_invocation_logs hdb_cron_event_invocation_logs_event_id_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: cristian
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_event_invocation_logs
    ADD CONSTRAINT hdb_cron_event_invocation_logs_event_id_fkey FOREIGN KEY (event_id) REFERENCES hdb_catalog.hdb_cron_events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: hdb_scheduled_event_invocation_logs hdb_scheduled_event_invocation_logs_event_id_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: cristian
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_event_invocation_logs
    ADD CONSTRAINT hdb_scheduled_event_invocation_logs_event_id_fkey FOREIGN KEY (event_id) REFERENCES hdb_catalog.hdb_scheduled_events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

