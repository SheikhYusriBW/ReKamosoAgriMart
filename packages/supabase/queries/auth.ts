import { supabase } from '../client';

/** Send OTP to phone number for authentication. */
export async function sendOTP(phone: string) {
  const { data, error } = await supabase.auth.signInWithOtp({ phone });
  return { data, error };
}

/** Verify OTP and get session. */
export async function verifyOTP(phone: string, token: string) {
  const { data, error } = await supabase.auth.verifyOtp({
    phone,
    token,
    type: 'sms',
  });
  return { data, error };
}

/** Get current session. */
export async function getSession() {
  const { data, error } = await supabase.auth.getSession();
  return { data, error };
}

/** Sign out the current user. */
export async function signOut() {
  const { error } = await supabase.auth.signOut();
  return { error };
}

/** Fetch user's roles from user_roles table. */
export async function getUserRoles(profileId: string) {
  const { data, error } = await supabase
    .from('user_roles')
    .select('*')
    .eq('profile_id', profileId)
    .eq('is_active', true);
  return { data, error };
}
