import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

String debugFirebaseError(Object e) {
  if (e is FirebaseException) {
    final code = e.code;
    final msg = e.message ?? '';
    return 'FirebaseException($code) $msg';
  }
  return e.toString();
}

void showDebugSnackBar(BuildContext context, String title, Object e) {
  final text = '$title\n${debugFirebaseError(e)}';

  // also print full error to console
  // ignore: avoid_print
  print(text);
  // ignore: avoid_print
  print(e);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      duration: const Duration(seconds: 6),
    ),
  );
}