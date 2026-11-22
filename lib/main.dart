import 'package:flutter/widgets.dart';

import 'app.dart';
import 'core/di/service_locator.dart';

void main() {
  configureDependencies();
  runApp(const GiftCardApp());
}
