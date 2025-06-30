import 'package:flutter/material.dart';

class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key, required this.isloading, 
  this.onPressed, required this.text,
  required this.photo,
  });
  final bool isloading;
  final void Function()? onPressed;
  final String text;
  final String photo;
  @override
  Widget build(BuildContext context) {
    return  OutlinedButton.icon(
      icon: Image.asset(
      photo,
        height: 24,
        width: 24,
      ),
      label:   Text(
       text,
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
      ),
      onPressed:  isloading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        side: const BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}