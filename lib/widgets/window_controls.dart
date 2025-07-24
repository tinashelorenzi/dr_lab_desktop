import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

class WindowControls extends StatelessWidget {
  const WindowControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: Row(
        children: [
          // Minimize button
          _WindowControlButton(
            color: const Color(0xFFFFBD2E),
            onTap: () => windowManager.minimize(),
            icon: Icons.remove,
          ),
          const SizedBox(width: 8),
          
          // Maximize/Restore button
          _WindowControlButton(
            color: const Color(0xFF28CA42),
            onTap: () async {
              if (await windowManager.isMaximized()) {
                windowManager.unmaximize();
              } else {
                windowManager.maximize();
              }
            },
            icon: Icons.crop_square,
          ),
          const SizedBox(width: 8),
          
          // Close button
          _WindowControlButton(
            color: const Color(0xFFFF5F57),
            onTap: () => SystemNavigator.pop(),
            icon: Icons.close,
          ),
        ],
      ),
    );
  }
}

class _WindowControlButton extends StatefulWidget {
  final Color color;
  final VoidCallback onTap;
  final IconData icon;

  const _WindowControlButton({
    required this.color,
    required this.onTap,
    required this.icon,
  });

  @override
  State<_WindowControlButton> createState() => _WindowControlButtonState();
}

class _WindowControlButtonState extends State<_WindowControlButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.4),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: _isHovered
              ? Icon(
                  widget.icon,
                  size: 10,
                  color: Colors.black87,
                )
              : null,
        ),
      ),
    );
  }
}