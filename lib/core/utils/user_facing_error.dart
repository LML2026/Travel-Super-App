/// Converts provider and persistence failures into safe, actionable UI text.
class UserFacingError {
  const UserFacingError._();

  static String message(Object error, {String fallback = 'Please try again.'}) {
    final raw = error.toString().toLowerCase();
    if (raw.contains('permission-denied') ||
        raw.contains('permission denied')) {
      return 'You do not have permission to access this information.';
    }
    if (raw.contains('network') ||
        raw.contains('socket') ||
        raw.contains('offline') ||
        raw.contains('dioexception') ||
        raw.contains('http') ||
        raw.contains('https') ||
        raw.contains('timeout') ||
        raw.contains('timed out')) {
      return 'You appear to be offline. Check your connection and try again.';
    }
    if (raw.contains('requires-recent-login') || raw.contains('recent login')) {
      return 'Please sign in again before retrying this action.';
    }
    if (raw.contains('unauthenticated') ||
        raw.contains('authentication required') ||
        raw.contains('not signed in')) {
      return 'Please sign in to continue.';
    }
    if (raw.contains('not found')) {
      return 'This information is no longer available.';
    }
    return fallback;
  }
}
