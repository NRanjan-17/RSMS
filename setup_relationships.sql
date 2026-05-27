-- 1. Create the relationship between ast and catalogs
ALTER TABLE public.ast
ADD CONSTRAINT fk_ast_product
FOREIGN KEY (product_id)
REFERENCES public.catalogs(id)
ON DELETE CASCADE;

-- 2. Create the relationship for client_id if missing on ast
ALTER TABLE public.ast
ADD CONSTRAINT fk_ast_client
FOREIGN KEY (client_id)
REFERENCES public.client(id)
ON DELETE SET NULL;

-- 3. Create the relationship between transaction and client
ALTER TABLE public.transaction
ADD CONSTRAINT fk_transaction_client
FOREIGN KEY (client_id)
REFERENCES public.client(id)
ON DELETE SET NULL;

-- 4. (Optional) Create the relationship between transaction and staff
ALTER TABLE public.transaction
ADD CONSTRAINT fk_transaction_staff
FOREIGN KEY (staff_id)
REFERENCES public.staff(id)
ON DELETE SET NULL;

