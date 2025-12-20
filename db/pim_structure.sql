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

--
-- Name: increase_duplicate_variant_positions(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.increase_duplicate_variant_positions() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        IF
          OLD.position IS DISTINCT FROM NEW.position
        AND
          EXISTS (
            select 1
            FROM variants
            WHERE product_id = NEW.product_id
            AND position = NEW.position
            AND id != NEW.id
            LIMIT 1
          )
        THEN
          UPDATE variants
          SET
            position = position + 1
          WHERE product_id = NEW.product_id
          AND position >= NEW.position
          AND id != NEW.id;
        END IF;
        RETURN NEW;
      END;
      $$;


--
-- Name: maintain_price_active_during(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.maintain_price_active_during() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        UPDATE prices
        SET
          active_during = tsrange(NEW.starts_at, NEW.ends_at, '[]')
        WHERE id = NEW.id;
        RETURN NEW;
      END;
      $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: prices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prices (
    id bigint NOT NULL,
    account_reference character varying NOT NULL,
    variant_id bigint NOT NULL,
    currency_id bigint NOT NULL,
    amount integer NOT NULL,
    was_amount integer,
    starts_at timestamp(0) without time zone NOT NULL,
    ends_at timestamp(0) without time zone NOT NULL,
    active_during tsrange,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: prices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.prices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: prices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.prices_id_seq OWNED BY public.prices.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id bigint NOT NULL,
    account_reference character varying NOT NULL,
    reference character varying NOT NULL,
    title character varying NOT NULL,
    description text,
    visible boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: variants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.variants (
    id bigint NOT NULL,
    account_reference character varying NOT NULL,
    reference character varying NOT NULL,
    product_id bigint NOT NULL,
    "position" integer NOT NULL,
    title character varying NOT NULL,
    visible boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT variants_position_not_negative CHECK (("position" >= 0))
);


--
-- Name: variants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.variants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: variants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.variants_id_seq OWNED BY public.variants.id;


--
-- Name: prices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prices ALTER COLUMN id SET DEFAULT nextval('public.prices_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: variants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.variants ALTER COLUMN id SET DEFAULT nextval('public.variants_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: prices prices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prices
    ADD CONSTRAINT prices_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: variants variants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.variants
    ADD CONSTRAINT variants_pkey PRIMARY KEY (id);


--
-- Name: index_prices_on_currency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_prices_on_currency_id ON public.prices USING btree (currency_id);


--
-- Name: index_prices_on_variant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_prices_on_variant_id ON public.prices USING btree (variant_id);


--
-- Name: index_variants_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_variants_on_product_id ON public.variants USING btree (product_id);


--
-- Name: unique_account_product_references; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_account_product_references ON public.products USING btree (account_reference, reference);


--
-- Name: unique_account_variant_references; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_account_variant_references ON public.variants USING btree (account_reference, reference);


--
-- Name: prices price_create_active_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER price_create_active_trigger AFTER INSERT ON public.prices FOR EACH ROW EXECUTE FUNCTION public.maintain_price_active_during();


--
-- Name: prices price_update_active_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER price_update_active_trigger AFTER UPDATE ON public.prices FOR EACH ROW WHEN (((old.starts_at <> new.starts_at) OR (old.starts_at <> new.starts_at))) EXECUTE FUNCTION public.maintain_price_active_during();


--
-- Name: variants variants_position_clash_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER variants_position_clash_trigger AFTER INSERT OR UPDATE ON public.variants FOR EACH ROW EXECUTE FUNCTION public.increase_duplicate_variant_positions();


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20251219212004'),
('20251213221523'),
('20251206213834'),
('20251128191922');

