ALTER TABLE transactions ADD COLUMN IF NOT EXISTS payment_gateway_id TEXT;
ALTER TABLE transaction ADD COLUMN IF NOT EXISTS payment_gateway_id TEXT;
