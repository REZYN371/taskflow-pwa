// Scheduled reminder worker foundation for Supabase Edge Functions.
// Deploy with: supabase functions deploy send-reminders
// Configure SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY as server-side secrets.
// For actual Web Push delivery, add a reviewed Web Push implementation and VAPID secrets;
// never expose service-role or VAPID private keys to the browser.
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
Deno.serve(async (req) => {
  if (req.method !== 'POST') return new Response('Method not allowed', { status: 405 });
  const secret = Deno.env.get('REMINDER_CRON_SECRET');
  if (!secret || req.headers.get('x-cron-secret') !== secret) return new Response('Unauthorized', { status: 401 });
  const url = Deno.env.get('SUPABASE_URL');
  const key = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!url || !key) return Response.json({ error: 'Server environment is not configured' }, { status: 500 });
  const db = createClient(url, key, { auth: { persistSession: false } });
  const now = new Date().toISOString();
  const { data: reminders, error } = await db.from('reminders').select('id,user_id,message,task_id').eq('status','pending').lte('scheduled_at',now).limit(100);
  if (error) return Response.json({ error: 'Could not load due reminders' }, { status: 500 });
  if (!reminders?.length) return Response.json({ processed: 0, note: 'No due reminders.' });
  let processed = 0;
  for (const reminder of reminders) {
    // A production Web Push adapter should send to the user's valid push_subscriptions here.
    // Record an in-app notification now; do not mark it as push-delivered.
    const { error: insertError } = await db.from('notifications').insert({
      id: crypto.randomUUID(), user_id: reminder.user_id, reminder_id: reminder.id,
      title: 'Pengingat TaskFlow', body: reminder.message,
    });
    if (insertError) {
      await db.from('reminders').update({ status: 'failed', last_error: 'Could not create in-app notification' }).eq('id',reminder.id);
      continue;
    }
    await db.from('reminders').update({ status: 'sent', sent_at: now, last_error: null }).eq('id',reminder.id);
    processed++;
  }
  return Response.json({ processed, channel: 'in-app', note: 'Web Push delivery is not enabled by this starter function.' });
});
