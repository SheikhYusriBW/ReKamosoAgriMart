import { supabase } from '../client';

/** Get all platform settings as key-value object. */
export async function getSettings() {
  const { data, error } = await supabase
    .from('platform_settings')
    .select('*');

  if (error) return { data: null, error };

  const settings: Record<string, string> = {};
  data?.forEach((row) => {
    settings[row.key] = row.value;
  });

  return { data: settings, error: null };
}

/** Get a single setting by key. */
export async function getSetting(key: string) {
  const { data, error } = await supabase
    .from('platform_settings')
    .select('value')
    .eq('key', key)
    .single();
  return { data: data?.value ?? null, error };
}

/** Admin: update a setting. */
export async function updateSetting(key: string, value: string, adminId: string) {
  const { data, error } = await supabase
    .from('platform_settings')
    .update({
      value,
      updated_by: adminId,
      updated_at: new Date().toISOString(),
    })
    .eq('key', key)
    .select()
    .single();
  return { data, error };
}
