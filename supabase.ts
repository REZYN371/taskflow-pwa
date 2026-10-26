import { createClient } from '@supabase/supabase-js';
const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
const key = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
export const isSupabaseConfigured = Boolean(url && key && !url.includes('YOUR_PROJECT'));
export const supabase = isSupabaseConfigured ? createClient(url!, key!, { auth: { persistSession:true, autoRefreshToken:true, detectSessionInUrl:true } }) : null;
