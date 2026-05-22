import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../providers/translation_provider.dart';

extension TranslationContext on BuildContext {
  String tr(String key, {String? fallback}) =>
      read<TranslationProvider>().tr(key, fallback: fallback);

  bool get isRtl => read<TranslationProvider>().rtl;
}
