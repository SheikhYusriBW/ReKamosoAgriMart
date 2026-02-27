import { supabase } from '../client';

/** Generic file upload to a Supabase storage bucket. */
export async function uploadFile(bucket: string, path: string, file: Blob) {
  const { data, error } = await supabase.storage
    .from(bucket)
    .upload(path, file, { upsert: true });
  return { data, error };
}

/** Get public URL for a file in a bucket. */
export function getPublicUrl(bucket: string, path: string): string {
  const { data } = supabase.storage.from(bucket).getPublicUrl(path);
  return data.publicUrl;
}

/** Delete a file from a bucket. */
export async function deleteFile(bucket: string, path: string) {
  const { data, error } = await supabase.storage.from(bucket).remove([path]);
  return { data, error };
}

/** Upload user avatar. Returns public URL. */
export async function uploadAvatar(userId: string, file: Blob) {
  const path = `${userId}/avatar.jpg`;
  const { error } = await supabase.storage
    .from('avatars')
    .upload(path, file, { upsert: true });

  if (error) return { data: null, error };
  return { data: getPublicUrl('avatars', path), error: null };
}

/** Upload farm image. Returns public URL. */
export async function uploadFarmImage(farmerId: string, file: Blob) {
  const path = `${farmerId}/${Date.now()}.jpg`;
  const { error } = await supabase.storage
    .from('farm-images')
    .upload(path, file);

  if (error) return { data: null, error };
  return { data: getPublicUrl('farm-images', path), error: null };
}

/** Upload listing image. Returns public URL. */
export async function uploadListingImage(listingId: string, file: Blob) {
  const path = `${listingId}/${Date.now()}.jpg`;
  const { error } = await supabase.storage
    .from('listing-images')
    .upload(path, file);

  if (error) return { data: null, error };
  return { data: getPublicUrl('listing-images', path), error: null };
}

/** Upload store logo. Returns public URL. */
export async function uploadStoreLogo(storeId: string, file: Blob) {
  const path = `${storeId}/logo.jpg`;
  const { error } = await supabase.storage
    .from('store-logos')
    .upload(path, file, { upsert: true });

  if (error) return { data: null, error };
  return { data: getPublicUrl('store-logos', path), error: null };
}
