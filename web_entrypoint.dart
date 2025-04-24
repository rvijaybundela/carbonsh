import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:untitled/main.dart' as app;

void main() {
  setUrlStrategy(PathUrlStrategy()); // Optional: Enables clean URLs for Flutter web
  app.main(); // Calls the main function from your main.dart file
}