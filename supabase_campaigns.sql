-- Create campaigns table
CREATE TABLE public.campaigns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    region TEXT NOT NULL,
    discount_percentage NUMERIC NOT NULL,
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL,
    affected_categories TEXT[] DEFAULT '{}',
    created_by UUID REFERENCES public.corporate_admins(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add Row Level Security (RLS)
ALTER TABLE public.campaigns ENABLE ROW LEVEL SECURITY;

-- Corporate Admins can do everything
CREATE POLICY "Corporate Admins can manage campaigns" ON public.campaigns
    FOR ALL USING (
        auth.uid() IN (SELECT id FROM public.corporate_admins)
    );

-- Sales Associates / Boutiques can view active campaigns
CREATE POLICY "Sales staff can view campaigns" ON public.campaigns
    FOR SELECT USING (
        status = 'Active' OR status = 'Scheduled'
    );
