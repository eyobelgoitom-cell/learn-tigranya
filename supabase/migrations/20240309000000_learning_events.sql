-- Learning events for analytics, insights, and smart recommendations.
-- Stores granular events: quiz answers, flashcard reviews, lesson views, etc.

CREATE TABLE public.learning_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL,
    payload JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_learning_events_user ON public.learning_events(user_id);
CREATE INDEX idx_learning_events_type ON public.learning_events(event_type);
CREATE INDEX idx_learning_events_created ON public.learning_events(created_at DESC);
CREATE INDEX idx_learning_events_payload ON public.learning_events USING GIN (payload);

ALTER TABLE public.learning_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert own events"
    ON public.learning_events FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can read own events"
    ON public.learning_events FOR SELECT
    USING (auth.uid() = user_id);
