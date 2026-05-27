-- Add foreign key relationship for ast to catalogs
ALTER TABLE public.ast
ADD CONSTRAINT fk_ast_product
FOREIGN KEY (product_id)
REFERENCES public.catalogs(id)
ON DELETE CASCADE;

-- (Optional) Ensure client relationship exists if not already present
ALTER TABLE public.ast
ADD CONSTRAINT fk_ast_client
FOREIGN KEY (client_id)
REFERENCES public.client(id)
ON DELETE SET NULL;

-- (Optional) Ensure purchased_items has the catalogs relationship too
-- just in case it throws the same PGRST200 error!
ALTER TABLE public.purchased_items
ADD CONSTRAINT fk_purchased_items_product
FOREIGN KEY (product_id)
REFERENCES public.catalogs(id)
ON DELETE CASCADE;
