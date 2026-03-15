import 'dart:ui_web' as ui;
import 'dart:html' show DivElement, NodeTreeSanitizer;

class AdSenseAd {
  static bool _isRegistered = false;

  static void register() {
    if (_isRegistered) return;
    _isRegistered = true;

    ui.platformViewRegistry.registerViewFactory(
      'adsense-ad',
      (int viewId) {
        final container = DivElement()
          ..style.width = '100%'
          ..style.height = '100%'
          ..setInnerHtml(
            '''
            <ins class="adsbygoogle"
              style="display:inline-block;width:200px;height:600px"
              data-ad-client="ca-pub-3606445852359484"
              data-ad-slot="5460841390"></ins>
            <script>
              (adsbygoogle = window.adsbygoogle || []).push({});
            </script>
            ''',
            treeSanitizer: NodeTreeSanitizer.trusted,
          );

        return container;
      },
    );
  }
}
