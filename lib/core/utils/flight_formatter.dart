/// Converts ISO-8601 duration format (e.g., "PT4H5M") to friendly format (e.g., "4h 05m")
String formatDuration(String duration) {
  if (duration.isEmpty || !duration.startsWith('PT')) {
    return 'N/A';
  }

  try {
    final str = duration.substring(2); // Remove 'PT' prefix
    int hours = 0;
    int minutes = 0;

    // Parse hours
    final hourIndex = str.indexOf('H');
    if (hourIndex != -1) {
      hours = int.parse(str.substring(0, hourIndex));
    }

    // Parse minutes
    final minIndex = str.indexOf('M');
    if (minIndex != -1) {
      final minStr = str.substring(hourIndex + 1, minIndex);
      if (minStr.isNotEmpty) {
        minutes = int.parse(minStr);
      }
    }

    if (hours == 0 && minutes == 0) return 'N/A';
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  } catch (e) {
    return 'N/A';
  }
}

/// Converts ISO-8601 datetime to local time format (e.g., "14:15")
String formatTime(String iso) {
  try {
    final dt = DateTime.parse(iso).toLocal();
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  } catch (e) {
    return '--:--';
  }
}
