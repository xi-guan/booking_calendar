import 'package:flutter/material.dart';

class BookingDialog extends StatelessWidget {
  const BookingDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 60,
      width: 60,
      child: CircularProgressIndicator(),
    );
  }
}
