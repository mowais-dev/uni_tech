import 'package:flutter/material.dart';

enum AnimationAllowedType { fade, slide, scale, rotate }

const List<AnimationAllowedType> fadeSlide = [
  AnimationAllowedType.fade,
  AnimationAllowedType.slide,
];

enum SlideDirection { left, right, up, down }

class AnimatedWrapper extends StatefulWidget {
  final Widget child;
  final List<AnimationAllowedType> animations; // multiple animations
  final SlideDirection slideDirection;
  final Duration duration;
  final Curve curve;
  final bool repeat;

  const AnimatedWrapper({
    super.key,
    required this.child,
    this.animations = const [AnimationAllowedType.fade],
    this.slideDirection = SlideDirection.up,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeInOut,
    this.repeat = false,
  });

  @override
  State<AnimatedWrapper> createState() => _AnimatedWrapperState();
}

class _AnimatedWrapperState extends State<AnimatedWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    final curve = CurvedAnimation(parent: _controller, curve: widget.curve);

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(curve);

    Offset beginOffset;
    switch (widget.slideDirection) {
      case SlideDirection.left:
        beginOffset = const Offset(-1, 0);
        break;
      case SlideDirection.right:
        beginOffset = const Offset(1, 0);
        break;
      case SlideDirection.up:
        beginOffset = const Offset(0, 1);
        break;
      case SlideDirection.down:
        beginOffset = const Offset(0, -1);
        break;
    }

    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(curve);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(curve);
    _rotateAnimation = Tween<double>(begin: -0.2, end: 0.0).animate(curve);

    if (widget.repeat) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _applyAnimations(Widget child) {
    Widget animated = child;

    if (widget.animations.contains(AnimationAllowedType.fade)) {
      animated = FadeTransition(opacity: _fadeAnimation, child: animated);
    }
    if (widget.animations.contains(AnimationAllowedType.slide)) {
      animated = SlideTransition(position: _slideAnimation, child: animated);
    }
    if (widget.animations.contains(AnimationAllowedType.scale)) {
      animated = ScaleTransition(scale: _scaleAnimation, child: animated);
    }
    if (widget.animations.contains(AnimationAllowedType.rotate)) {
      animated = RotationTransition(turns: _rotateAnimation, child: animated);
    }

    return animated;
  }

  @override
  Widget build(BuildContext context) {
    return _applyAnimations(widget.child);
  }
}
