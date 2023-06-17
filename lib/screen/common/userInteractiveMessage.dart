import 'package:flutter/material.dart';

class UserInteractiveMessage {
  final String title;
  final String message;
  final String yesButtonText;
  final String noButtonText;
  final Function(bool) onSelection;

  UserInteractiveMessage({
    required this.title,
    required this.message,
    required this.yesButtonText,
    required this.noButtonText,
    required this.onSelection,
  });

/*  void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // No button pressed
              },
              child: Text(noButtonText),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Yes button pressed
              },
              child: Text(yesButtonText),
            ),
          ],
        );
      },
    ).then((value) {
      if (value != null) {
        onSelection(value); // Notify the callback with the user's selection
      }
    });
  }*/

  void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          alignment: Alignment.center,
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  message,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // No button pressed
              },
              child: Text(noButtonText),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Yes button pressed
              },
              child: Text(yesButtonText),
            ),
          ],
        );
      },
    ).then((value) {
      if (value != null) {
        onSelection(value); // Notify the callback with the user's selection
      }
    });
  }

}
