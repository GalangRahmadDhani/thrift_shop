import 'package:flutter/material.dart';

class TCheckBoxTheme{
  TCheckBoxTheme._();

  static CheckboxThemeData lightCheckboxThemes = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    checkColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      } else {
        return Colors.black;
      }
    }),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if(states.contains(WidgetState.selected)) {
        return Colors.blue;
      }else{
        return Colors.transparent;
      }
    })
  );

  static CheckboxThemeData darkCheckboxThemes = CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      checkColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        } else {
          return Colors.black;
        }
      }),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if(states.contains(WidgetState.selected)) {
          return Colors.blue;
        }else{
          return Colors.transparent;
        }
      }),
  );
}