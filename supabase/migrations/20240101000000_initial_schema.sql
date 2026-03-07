-- Fidel Learn: Initial Database Schema
-- Supports Tigrinya and Amharic language learning

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- USERS (extends Supabase auth.users)
-- ============================================
CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    display_name TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS for users
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
    ON public.users FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON public.users FOR UPDATE
    USING (auth.uid() = id);

-- ============================================
-- LESSON SECTIONS
-- ============================================
CREATE TABLE public.lesson_sections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    "order" INT NOT NULL DEFAULT 0,
    language TEXT NOT NULL DEFAULT 'tigrinya',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- LESSONS
-- ============================================
CREATE TABLE public.lessons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    subtitle TEXT,
    type TEXT NOT NULL CHECK (type IN ('alphabet', 'vocabulary', 'phrase', 'listening')),
    "order" INT NOT NULL DEFAULT 0,
    section_id UUID REFERENCES public.lesson_sections(id) ON DELETE SET NULL,
    language TEXT NOT NULL DEFAULT 'tigrinya',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_lessons_section ON public.lessons(section_id);
CREATE INDEX idx_lessons_language ON public.lessons(language);
CREATE INDEX idx_lessons_order ON public.lessons("order");

-- ============================================
-- FIDEL CHARACTERS (for alphabet lessons)
-- ============================================
CREATE TABLE public.fidel_characters (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    character TEXT NOT NULL,
    transliteration TEXT NOT NULL,
    vowel_order INT NOT NULL,
    consonant_group TEXT NOT NULL,
    audio_url TEXT,
    example_word TEXT,
    example_word_translation TEXT,
    lesson_id UUID REFERENCES public.lessons(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_fidel_lesson ON public.fidel_characters(lesson_id);

-- ============================================
-- WORDS
-- ============================================
CREATE TABLE public.words (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    fidel TEXT NOT NULL,
    transliteration TEXT NOT NULL,
    translation TEXT NOT NULL,
    audio_url TEXT,
    lesson_id UUID REFERENCES public.lessons(id) ON DELETE CASCADE,
    "order" INT NOT NULL DEFAULT 0,
    example_sentence TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_words_lesson ON public.words(lesson_id);
CREATE INDEX idx_words_language ON public.words(lesson_id);

-- ============================================
-- FLASHCARDS (spaced repetition)
-- ============================================
CREATE TABLE public.flashcards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    word_id UUID NOT NULL REFERENCES public.words(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    next_review_at TIMESTAMPTZ,
    repetition_count INT NOT NULL DEFAULT 0,
    ease_factor DOUBLE PRECISION NOT NULL DEFAULT 2.5,
    interval INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(word_id, user_id)
);

CREATE INDEX idx_flashcards_user ON public.flashcards(user_id);
CREATE INDEX idx_flashcards_next_review ON public.flashcards(next_review_at);

ALTER TABLE public.flashcards ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own flashcards"
    ON public.flashcards
    FOR ALL
    USING (auth.uid() = user_id);

-- ============================================
-- USER PROGRESS
-- ============================================
CREATE TABLE public.user_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    score DOUBLE PRECISION,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, lesson_id)
);

CREATE INDEX idx_user_progress_user ON public.user_progress(user_id);
CREATE INDEX idx_user_progress_lesson ON public.user_progress(lesson_id);

ALTER TABLE public.user_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own progress"
    ON public.user_progress
    FOR ALL
    USING (auth.uid() = user_id);

-- ============================================
-- USER STATS (denormalized for performance)
-- ============================================
CREATE TABLE public.user_stats (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    words_learned INT NOT NULL DEFAULT 0,
    lessons_completed INT NOT NULL DEFAULT 0,
    current_streak INT NOT NULL DEFAULT 0,
    longest_streak INT NOT NULL DEFAULT 0,
    last_activity_date DATE,
    total_correct INT NOT NULL DEFAULT 0,
    total_attempts INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.user_stats ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own stats"
    ON public.user_stats
    FOR ALL
    USING (auth.uid() = user_id);

-- ============================================
-- STORAGE BUCKET FOR AUDIO
-- ============================================
-- Run via Supabase Dashboard or: 
-- INSERT INTO storage.buckets (id, name, public) VALUES ('audio', 'audio', true);

-- ============================================
-- TRIGGERS: updated_at
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER lessons_updated_at
    BEFORE UPDATE ON public.lessons
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER words_updated_at
    BEFORE UPDATE ON public.words
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER flashcards_updated_at
    BEFORE UPDATE ON public.flashcards
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER user_progress_updated_at
    BEFORE UPDATE ON public.user_progress
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
