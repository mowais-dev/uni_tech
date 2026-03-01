import 'package:uni_tech/styles/texts.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    required this.child,
    this.padding,
    this.border,
    this.height,
    this.width,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? border;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: border ?? BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width ?? double.infinity,
          height: height,
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          color: kwhite.withOpacity(0.1),
          child: child,
        ),
      ),
    );
  }
}
