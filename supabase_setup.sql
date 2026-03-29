-- ════════════════════════════════════════════════════════
-- DRACO E-COMMERCE — Supabase Setup Script
-- Ejecutar completo en: Dashboard > SQL Editor > New Query
-- ════════════════════════════════════════════════════════

-- ── TABLA PRODUCTS ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.products (
  id          uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
  name        text        NOT NULL,
  price       text        NOT NULL,
  category    text        NOT NULL,
  cat         text,
  brand       text,
  badge       text        DEFAULT '',
  description text,
  tags        text[]      DEFAULT '{}',
  sizes       text[]      DEFAULT '{}',
  stock       integer     DEFAULT 0,
  images      text[]      DEFAULT '{}',
  created_at  timestamptz DEFAULT now()
);

-- ── ROW LEVEL SECURITY ──────────────────────────────────
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "products_select_public" ON public.products;
DROP POLICY IF EXISTS "products_insert_anon"   ON public.products;
DROP POLICY IF EXISTS "products_update_anon"   ON public.products;
DROP POLICY IF EXISTS "products_delete_anon"   ON public.products;

CREATE POLICY "products_select_public"
  ON public.products FOR SELECT TO public USING (true);

CREATE POLICY "products_insert_anon"
  ON public.products FOR INSERT TO anon WITH CHECK (true);

CREATE POLICY "products_update_anon"
  ON public.products FOR UPDATE TO anon USING (true) WITH CHECK (true);

CREATE POLICY "products_delete_anon"
  ON public.products FOR DELETE TO anon USING (true);

-- ── STORAGE BUCKET ──────────────────────────────────────
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'product-images', 'product-images', true, 5242880,
  ARRAY['image/jpeg','image/png','image/webp','image/gif']
) ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "product_images_select" ON storage.objects;
DROP POLICY IF EXISTS "product_images_insert" ON storage.objects;
DROP POLICY IF EXISTS "product_images_delete" ON storage.objects;
DROP POLICY IF EXISTS "product_images_update" ON storage.objects;

CREATE POLICY "product_images_select"
  ON storage.objects FOR SELECT TO public
  USING (bucket_id = 'product-images');

CREATE POLICY "product_images_insert"
  ON storage.objects FOR INSERT TO anon
  WITH CHECK (bucket_id = 'product-images');

CREATE POLICY "product_images_delete"
  ON storage.objects FOR DELETE TO anon
  USING (bucket_id = 'product-images');

CREATE POLICY "product_images_update"
  ON storage.objects FOR UPDATE TO anon
  USING (bucket_id = 'product-images');

-- ── VERIFICACIÓN ────────────────────────────────────────
SELECT 'Setup completado exitosamente ✓' AS status;
SELECT COUNT(*) AS total_products FROM public.products;
