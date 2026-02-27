import { supabase } from '../client';

const DEFAULT_PAGE_SIZE = 20;

/** Get user's notifications, newest first. */
export async function getMyNotifications(userId: string, page = 1, pageSize = DEFAULT_PAGE_SIZE) {
  const from = (page - 1) * pageSize;
  const to = from + pageSize - 1;

  const { data, error, count } = await supabase
    .from('notifications')
    .select('*', { count: 'exact' })
    .eq('recipient_id', userId)
    .order('created_at', { ascending: false })
    .range(from, to);
  return { data, error, count };
}

/** Count unread notifications. */
export async function getUnreadCount(userId: string) {
  const { count, error } = await supabase
    .from('notifications')
    .select('id', { count: 'exact', head: true })
    .eq('recipient_id', userId)
    .eq('is_read', false);
  return { data: count ?? 0, error };
}

/** Mark a single notification as read. */
export async function markAsRead(notificationId: string) {
  const { data, error } = await supabase
    .from('notifications')
    .update({ is_read: true })
    .eq('id', notificationId)
    .select()
    .single();
  return { data, error };
}

/** Mark all notifications as read for a user. */
export async function markAllAsRead(userId: string) {
  const { error } = await supabase
    .from('notifications')
    .update({ is_read: true })
    .eq('recipient_id', userId)
    .eq('is_read', false);
  return { error };
}

/** System: create a notification. */
export async function createNotification(data: {
  recipient_id: string;
  type: string;
  title: string;
  body: string;
  data?: Record<string, string | number | boolean | null> | null;
  channel: string;
}) {
  const { data: notification, error } = await supabase
    .from('notifications')
    .insert(data)
    .select()
    .single();
  return { data: notification, error };
}
