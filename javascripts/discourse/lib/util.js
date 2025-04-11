export function tryCatch(callback) {
  try {
    const data = callback();
    return { data, error: null };
  } catch (error) {
    return { data: null, error };
  }
}
