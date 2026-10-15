# KoZ Lead Rescue — production app setup

This adds a database-backed Lead Desk to the existing static site. It does not replace the current homepage or prospect demo builder.

## Current architecture
- Existing marketing/demo pages remain at the repository root.
- `/app/` is the authenticated Lead Desk.
- `/api/config` exposes only the Supabase project URL and publishable/anon key; never put a service-role key in a browser or public environment variable.
- `supabase/schema.sql` creates business workspaces and leads, with row-level security policies restricting each account to its own records.

## Required setup
1. Create a dedicated Supabase project for KoZ Lead Rescue. Do not reuse a database for an unrelated product.
2. Run the SQL in `supabase/schema.sql` in the Supabase SQL editor.
3. Add these **Production, Preview, and Development** environment variables in the existing Vercel project:
   - `SUPABASE_URL` — project API URL.
   - `SUPABASE_PUBLISHABLE_KEY` — publishable key (or use `SUPABASE_ANON_KEY` for a legacy anon key).
4. Redeploy the existing Vercel project.
5. In Supabase Auth, configure the site URL as `https://koz-lead-rescue.vercel.app` and allow the same URL plus preview URLs if preview testing is needed.
6. Test account creation, email confirmation (if enabled), sign-in, lead create/edit/delete, CSV export, and cross-account isolation before adding real customer information.

## Important scope note
The Lead Desk persists manually entered leads and business settings once configured. Automatic public lead intake, transactional email/SMS, appointment booking, billing, production rate-limiting, and compliance controls are separate integration work and must not be represented as active until implemented and tested.
