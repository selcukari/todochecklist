import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

void gFToastShowToast({
  required BuildContext context,
  required String message,
  GFToastPosition toastPosition = GFToastPosition.BOTTOM,
  TextStyle textStyle = const TextStyle(color: Colors.white),
  Color backgroundColor = Colors.red,
}) {
  GFToast.showToast(
    message,
    context,
    toastPosition: toastPosition,
    textStyle: textStyle,
    backgroundColor: backgroundColor,
  );
}