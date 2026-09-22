// Generic (non-web) stub to keep conditional imports happy.
// On non-web platforms, the caller should not rely on this for opening files.
class WebOpen {
  static Future<void> open(String urlOrData, {String? filename}) async {
    // No-op on non-web. Caller should handle native open paths.
  }
}
