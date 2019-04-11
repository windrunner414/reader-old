import 'package:oktoast/oktoast.dart';
import 'package:flutter/material.dart';

class ToastUtil {
  ToastUtil._();

  static void show(String msg, {BuildContext context}) {
    showToast(
      msg,
      context: context,
      duration: const Duration(seconds: 2),
      textPadding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      textStyle: const TextStyle(
        fontSize: 15,
        color: const Color.fromRGBO(235, 235, 235, 1),
      ),
      backgroundColor: Colors.black87,
      position: ToastPosition.bottom,
    );
  }
}

class Toast extends StatelessWidget {
  final Widget child;

  Toast({@required this.child});

  @override
  Widget build(BuildContext context) {
    return OKToast(child: child);
  }
}
