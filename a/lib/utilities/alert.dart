import 'package:flutter/material.dart';

/// A reusable, animated alert (toast-like) that shows at the bottom
/// and fades out automatically.
void showCustomAlert(
  BuildContext context,
  String message, {
  Color backgroundColor = Colors.green,
  IconData? icon,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  if (overlay == null) return;

  late OverlayEntry overlayEntry; // Declare first

  overlayEntry = OverlayEntry(
    builder: (context) {
      return Positioned(
        bottom: 30,
        right: MediaQuery.of(context).size.width > 600 ? 30 : null,
        left: MediaQuery.of(context).size.width <= 600 ? 20 : null,
        child: _CustomAlertWidget(
          message: message,
          color: backgroundColor,
          icon:
              icon ??
              (backgroundColor == Colors.red
                  ? Icons.error_rounded
                  : Icons.check_circle_rounded),
          duration: duration,
          onDismissed: () {
            overlayEntry.remove(); // Now valid
          },
        ),
      );
    },
  );

  overlay.insert(overlayEntry);
}

class _CustomAlertWidget extends StatefulWidget {
  final String message;
  final Color color;
  final IconData icon;
  final Duration duration;
  final VoidCallback onDismissed;

  const _CustomAlertWidget({
    required this.message,
    required this.color,
    required this.icon,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_CustomAlertWidget> createState() => _CustomAlertWidgetState();
}

class _CustomAlertWidgetState extends State<_CustomAlertWidget>
    with SingleTickerProviderStateMixin {
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Fade in
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => opacity = 1);
    });

    // Fade out before removing
    Future.delayed(widget.duration - const Duration(milliseconds: 500), () {
      if (mounted) setState(() => opacity = 0);
    });

    // Remove from overlay
    Future.delayed(widget.duration, () {
      if (mounted) widget.onDismissed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: opacity,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: Colors.white),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
