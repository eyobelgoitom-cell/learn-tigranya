-- Fidel Learn: Demo user for local development and testing
-- Run via: supabase db reset  (or supabase start with fresh DB)
-- Demo credentials: demo@fidellearn.com / demo123456

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

DO $$
DECLARE
  v_user_id UUID := 'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d';  -- Fixed for idempotency
  v_encrypted_pw TEXT := crypt('demo123456', gen_salt('bf'));
BEGIN
  -- Insert into auth.users (skip if exists)
  INSERT INTO auth.users (
    id,
    instance_id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at
  ) VALUES (
    v_user_id,
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'demo@fidellearn.com',
    v_encrypted_pw,
    NOW(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb,
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;

  -- Insert into auth.identities (required for login)
  INSERT INTO auth.identities (
    id,
    user_id,
    identity_data,
    provider,
    provider_id,
    last_sign_in_at,
    created_at,
    updated_at
  ) VALUES (
    v_user_id,
    v_user_id,
    format('{"sub":"%s","email":"demo@fidellearn.com"}', v_user_id)::jsonb,
    'email',
    v_user_id::text,
    NOW(),
    NOW(),
    NOW()
  )
  ON CONFLICT DO NOTHING;

  -- Insert into public.users (app profile)
  INSERT INTO public.users (id, email, created_at, updated_at)
  VALUES (v_user_id, 'demo@fidellearn.com', NOW(), NOW())
  ON CONFLICT (id) DO NOTHING;
END $$;
