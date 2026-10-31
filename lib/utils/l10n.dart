import 'package:flutter/material.dart';

import 'package:kubenav/l10n/help_zh.dart';
import 'package:kubenav/l10n/zh_cn.dart';

/// Locales shipped with the app. Resolution follows the device language:
/// Chinese maps to zh-CN, every other language maps to en-US.
const Locale localeEnUs = Locale('en', 'US');
const Locale localeZhCn = Locale('zh', 'CN');

const List<Locale> appSupportedLocales = <Locale>[localeEnUs, localeZhCn];

Locale resolveAppLocale(Locale? locale, Iterable<Locale> supported) {
  if (locale != null && locale.languageCode.toLowerCase() == 'zh') {
    return localeZhCn;
  }
  return localeEnUs;
}

bool isChinese(BuildContext context) {
  return Localizations.maybeLocaleOf(context)?.languageCode == 'zh';
}

/// Translates an English source string. Unknown strings stay in English so
/// cluster data, brands, and not-yet-covered copy are left untouched.
String t(BuildContext context, String message) {
  if (!isChinese(context)) {
    return message;
  }
  return zhCn[message] ?? message;
}

/// Translates using a locale that is not yet available through [BuildContext].
String tLocale(Locale? locale, String message) {
  if (locale == null || locale.languageCode.toLowerCase() != 'zh') {
    return message;
  }
  return zhCn[message] ?? message;
}

/// Translates a `Label: value` row. The value is never translated.
String tField(BuildContext context, String label, Object? value) {
  final shown = value == null || '$value'.isEmpty ? '-' : '$value';
  return '${t(context, label)}: $shown';
}

/// Translates an English template that uses `{0}`, `{1}`, ... placeholders.
String tFmt(BuildContext context, String template, List<Object?> args) {
  var pattern = template;
  if (isChinese(context)) {
    pattern = zhCn[template] ?? template;
  }
  for (var i = 0; i < args.length; i++) {
    pattern = pattern.replaceAll('{$i}', '${args[i]}');
  }
  return pattern;
}

String helpBody(BuildContext context, String title, String english) {
  if (!isChinese(context)) {
    return english;
  }
  return helpZh[title] ?? english;
}
