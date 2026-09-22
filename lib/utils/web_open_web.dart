// Web implementation to reliably open data URLs or http URLs.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class WebOpen {
  static Future<void> open(String urlOrData, {String? filename}) async {
    try {
      if (urlOrData.startsWith('data:')) {
        final lower = urlOrData.toLowerCase();
        // Try converting data URL to Blob URL to avoid blank tabs
        try {
          final uriData = UriData.parse(urlOrData);
          final bytes = uriData.contentAsBytes();
          final mime = uriData.mimeType;
          final blob = html.Blob([bytes], mime);
          final objectUrl = html.Url.createObjectUrlFromBlob(blob);
          if (lower.startsWith('data:application/pdf')) {
            html.window.open(objectUrl, '_blank');
          } else {
            // Non-PDF: force download
            final anchor = html.AnchorElement(href: objectUrl)
              ..download = filename ?? 'document'
              ..target = '_blank'
              ..rel = 'noopener';
            html.document.body?.append(anchor);
            anchor.click();
            anchor.remove();
          }
          // Revoke URL after microtask to let browser load it
          Future.delayed(const Duration(milliseconds: 100), () {
            html.Url.revokeObjectUrl(objectUrl);
          });
          return;
        } catch (_) {
          // Fallback: open original data URL
          html.window.open(urlOrData, '_blank');
          return;
        }
      }

      // For http(s) urls, open new tab
      html.window.open(urlOrData, '_blank');
    } catch (_) {
      // Swallow errors; caller may show a snackbar.
    }
  }
}
