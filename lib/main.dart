import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/l10n/locale_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar');
  await initializeDateFormatting('en');
  final lang = await LocaleStorage.getLanguage();
  if (lang != 'ar' && lang != 'en') {
    await initializeDateFormatting(lang);
  }
  runApp(const TabkhtnaaApp());
}
