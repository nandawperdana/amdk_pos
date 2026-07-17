-- ==========================================================================
-- AMDK POS — setup mirror Postgres untuk sinkronisasi (Fase 2)
-- ==========================================================================
--
-- Jalankan di Supabase SQL Editor (project owner). Sinkronisasi bersifat
-- PUSH-ONLY dari kasir; owner hanya MEMBACA.
--
-- ENCODING (penting): tabel ini MENCERMINKAN penyimpanan mentah SQLite lokal
-- supaya upsert JSON tak kena error konversi tipe:
--   * boolean  -> smallint (0/1)
--   * DateTime -> bigint   (unix epoch DETIK)
--   * double   -> double precision
-- Konversi ke boolean/timestamp dilakukan saat query laporan (contoh di bawah).
--
-- PK = (device_id, id): id auto-increment unik per device; device_id
-- memisahkan device bila nanti multi-toko. Upsert idempotent (kirim ulang aman).
-- ==========================================================================

create table if not exists products (
  device_id text not null,
  id bigint not null,
  name text, brand text, category text, base_unit text,
  pack_unit text, pack_size bigint,
  buy_price double precision, sell_price double precision,
  is_gallon smallint, active smallint,
  primary key (device_id, id)
);

create table if not exists suppliers (
  device_id text not null, id bigint not null,
  name text, phone text, note text,
  primary key (device_id, id)
);

create table if not exists customers (
  device_id text not null, id bigint not null,
  name text, type text, phone text,
  primary key (device_id, id)
);

create table if not exists purchases (
  device_id text not null, id bigint not null,
  supplier_id bigint, date bigint, total_amount double precision,
  payment_status text, note text,
  primary key (device_id, id)
);

create table if not exists purchase_items (
  device_id text not null, id bigint not null,
  purchase_id bigint, product_id bigint, qty_base bigint,
  price double precision, subtotal double precision,
  primary key (device_id, id)
);

create table if not exists sales (
  device_id text not null, id bigint not null,
  customer_id bigint, date bigint, total_amount double precision,
  payment_method text, payment_status text, note text,
  primary key (device_id, id)
);

create table if not exists sale_items (
  device_id text not null, id bigint not null,
  sale_id bigint, product_id bigint, qty_base bigint,
  price double precision, subtotal double precision,
  primary key (device_id, id)
);

create table if not exists stock_movements (
  device_id text not null, id bigint not null,
  product_id bigint, date bigint, type text, qty_base bigint,
  ref_type text, ref_id bigint, note text,
  primary key (device_id, id)
);

create table if not exists cash_entries (
  device_id text not null, id bigint not null,
  date bigint, direction text, amount double precision,
  category text, account text, ref_type text, ref_id bigint, note text,
  primary key (device_id, id)
);

create table if not exists gallon_ledger (
  device_id text not null, id bigint not null,
  date bigint, type text, d_full bigint, d_empty bigint, d_deposit bigint,
  customer_id bigint, ref_type text, ref_id bigint, note text,
  primary key (device_id, id)
);

create table if not exists cashier_closings (
  device_id text not null, id bigint not null,
  closed_at bigint, account text,
  system_balance double precision, physical_count double precision,
  difference double precision, note text,
  primary key (device_id, id)
);

-- --------------------------------------------------------------------------
-- RLS: kasir menulis (anon insert/upsert), owner membaca.
-- MVP sederhana pakai anon key. Untuk produksi, ganti ke user auth + policy
-- per-device. Aktifkan RLS lalu izinkan insert+select untuk anon:
-- --------------------------------------------------------------------------
do $$
declare t text;
begin
  foreach t in array array[
    'products','suppliers','customers','purchases','purchase_items',
    'sales','sale_items','stock_movements','cash_entries','gallon_ledger',
    'cashier_closings'
  ] loop
    execute format('alter table %I enable row level security', t);
    execute format($p$create policy anon_insert on %I for insert to anon with check (true)$p$, t);
    execute format($p$create policy anon_update on %I for update to anon using (true) with check (true)$p$, t);
    execute format($p$create policy anon_select on %I for select to anon using (true)$p$, t);
  end loop;
end $$;

-- --------------------------------------------------------------------------
-- Contoh view laporan yang menerjemahkan encoding mentah:
--   date bigint (epoch detik) -> timestamptz, is_galon 0/1 -> boolean.
-- --------------------------------------------------------------------------
create or replace view v_sales as
  select device_id, id, customer_id,
         to_timestamp(date) as date,
         total_amount, payment_method, payment_status, note
  from sales;
