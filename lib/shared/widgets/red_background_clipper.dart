
import 'package:flutter/material.dart';

class RedBackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.7); 
    path.quadraticBezierTo(
      size.width * 0.4, size.height * 0.6, 
      size.width, size.height * 0.9,       
    );
    path.lineTo(size.width, 0); 
    path.close(); 
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false; 
  }
}
