package com.example.hse_search

import io.flutter.embedding.android.FlutterActivity
import com.yandex.mapkit.MapKitFactory

class MainActivity: FlutterActivity() {
  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    // TODO(misha): вставь ключик свой
    MapKitFactory.setApiKey("YOUR_API_KEY")
    super.configureFlutterEngine(flutterEngine)
  }
}
