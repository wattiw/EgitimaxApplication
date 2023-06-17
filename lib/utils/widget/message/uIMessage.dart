
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum ToastLength {
  LENGTH_SHORT,
  LENGTH_LONG,
}

enum SnackPosition {
  top,
  bottom,
  center,
}

Color typeToColor(MessageType type) {
  switch (type) {
    case MessageType.info:
      return Colors.blue;
    case MessageType.warning:
      return Colors.amber;
    case MessageType.success:
      return Colors.green;
    case MessageType.error:
      return Colors.red;
  }
}

enum MessageType { info, warning, success, error }

abstract class UIMessageBase {

  static void showShort(String message, {ToastGravity? gravity}) async {
  }
  static void showLong(String message, {ToastGravity? gravity}) async{
  }
  static void showError(String message, {ToastGravity? gravity}) async {
  }
  static void showSuccess(String message, {ToastGravity? gravity}) async {
  }

  static void show({
    required String message,
    required ToastLength length,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
    ToastGravity? gravity,
  }) async {
  }

  static void cancel() {}

  static void showMessage(
      BuildContext context,
      String message, {
        MessageType type = MessageType.info,
        SnackPosition position = SnackPosition.bottom,
      }) {
  }


}




class UIMessage implements UIMessageBase {


  static Future<void> showShort(String message, {ToastGravity? gravity}) async {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity ?? ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey[600],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static Future<void> showLong(String message, {ToastGravity? gravity}) async {

    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: gravity ?? ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.grey[600],
      textColor: Colors.white,
      fontSize: 12.0,
    );
  }


  static Future<void> showError(String message, {ToastGravity? gravity}) async {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: gravity ?? ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 12.0,
    );
  }


  static Future<void> showSuccess(String message, {ToastGravity? gravity}) async {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: gravity ?? ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 12.0,
    );
  }


  static Future<void> show({
    required String message,
    required ToastLength length,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
    ToastGravity? gravity,
  }) async {
    Fluttertoast.showToast(
      msg: message,
      toastLength: length == ToastLength.LENGTH_SHORT
          ? Toast.LENGTH_SHORT
          : Toast.LENGTH_LONG,
      gravity: gravity ?? ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: backgroundColor ?? Colors.grey[600],
      textColor: textColor ?? Colors.white,
      fontSize: fontSize ?? 12.0,
    );
  }


  static Future<void> cancel() async {
    Fluttertoast.cancel();
  }


  static Future<void> showMessage(
      BuildContext context,
      String message, {
        MessageType type = MessageType.info,
        SnackPosition position = SnackPosition.bottom,
      }) async {
    if (context == null) {
      debugPrint('Error: Invalid context provided!');
      return;
    }
    try {

    IconData icon;
    Color backgroundColor;
    switch (type) {
      case MessageType.success:
        icon = Icons.check_circle;
        backgroundColor = Colors.green;
        break;
      case MessageType.error:
        icon = Icons.error;
        backgroundColor = Colors.red;
        break;
      case MessageType.warning:
        icon = Icons.warning;
        backgroundColor = Colors.amber;
        break;
      default:
        icon = Icons.info;
        backgroundColor = Colors.blue;
        break;
    }

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      position == SnackPosition.bottom
          ? snackBar
          : position == SnackPosition.center
          ? SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            snackBar,
            const SizedBox(height: 10),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      )
          : SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            snackBar,
            const SizedBox(height: 10),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
      ),
    );

    }
    catch(e)
    {}
  }

}

