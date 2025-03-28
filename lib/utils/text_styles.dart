// utils/text_styles.dart

import 'package:flutter/material.dart';

class TextStyles {
  static const TextStyle heading1 = TextStyle(
    fontFamily: 'RethinkSans',
    fontWeight: FontWeight.bold,
    fontSize: 34,
  );

  static const TextStyle heading5 = TextStyle(
    fontFamily: 'RethinkSans',
    fontWeight: FontWeight.bold,
    fontSize: 27,
  );

  static const TextStyle heading6 = TextStyle(
    fontFamily: 'RethinkSans',
    fontWeight: FontWeight.bold,
    fontSize: 21,
  );

  static const TextStyle leadParagraph = TextStyle(
    fontFamily: 'RethinkSans',
    fontWeight: FontWeight.w500, // Medium
    fontSize: 19,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'RethinkSans',
    fontWeight: FontWeight.w600, // Semibold
    fontSize: 18,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'RethinkSans',
    fontWeight: FontWeight.normal, // Regular
    fontSize: 18,
  );

  static const TextStyle bodyNormal = TextStyle(
    fontFamily: 'RethinkSans',
    fontWeight: FontWeight.w400, // Regular
    fontSize: 17,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'RethinkSans',
    fontWeight: FontWeight.w400, // Regular
    fontSize: 15,
  );
}