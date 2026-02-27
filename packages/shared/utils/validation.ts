/** Validate Botswana phone number (+267 followed by 7 or 8 digits). Also accepts South African numbers (+27 followed by 9 digits). */
export function isValidPhone(phone: string): boolean {
  const cleaned = phone.replace(/[\s\-\(\)]/g, '');
  return /^\+267\d{7,8}$/.test(cleaned) || /^\+27\d{9}$/.test(cleaned);
}

/** Validate email format. */
export function isValidEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

/** Validate that a value is a positive number. */
export function isPositiveNumber(value: unknown): boolean {
  const num = Number(value);
  return !isNaN(num) && num > 0;
}

/** Validate that end date is after start date. */
export function isDateAfter(startDate: string, endDate: string): boolean {
  return new Date(endDate) > new Date(startDate);
}

/** Validate that a date is in the future. */
export function isFutureDate(dateString: string): boolean {
  return new Date(dateString) > new Date();
}

/** Validate rating is between 1 and 5. */
export function isValidRating(rating: number): boolean {
  return Number.isInteger(rating) && rating >= 1 && rating <= 5;
}

/** Validate OTP is 6 digits. */
export function isValidOTP(otp: string): boolean {
  return /^\d{6}$/.test(otp);
}
