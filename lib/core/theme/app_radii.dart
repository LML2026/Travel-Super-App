import 'package:flutter/material.dart';

class AppRadii {
  AppRadii._();

  static const small = 8.0;
  static const medium = 12.0;
  static const large = 16.0;

  static const smallBorder = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(small)),
  );
  static const mediumBorder = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(medium)),
  );
  static const largeBorder = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(large)),
  );
}
