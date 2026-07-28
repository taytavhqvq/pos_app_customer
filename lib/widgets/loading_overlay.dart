import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        // ===== AnimatedSwitcher ทำให้ overlay ค่อยๆ fade+scale เข้า/ออก แทนที่จะโผล่/หายทันที =====
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (widget, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween(begin: 0.94, end: 1.0).animate(animation),
              child: widget,
            ),
          ),
          child: isLoading
              ? _buildOverlayContent(context)
              : const SizedBox.shrink(key: ValueKey('hidden')),
        ),
      ],
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return Positioned.fill(
      key: const ValueKey('loading'),
      child: AbsorbPointer(
        absorbing: true,
        child: BackdropFilter(
          // ===== เบลอพื้นหลังแทนสีทึบดำ ดูนุ่มนวล/พรีเมียมกว่า =====
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            color: Colors.black.withOpacity(0.25),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 26,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    // ===== เงานุ่มๆ ให้กล่องมีมิติ ไม่ลอยแบนราบ =====
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 34,
                        height: 34,
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 3,
                          // ===== ให้พื้นหลังวงแหวนจางๆ กันดูโดดเดี่ยวเกินไป =====
                          backgroundColor: AppColors.primary.withOpacity(0.12),
                        ),
                      ),
                      if (message != null) ...[
                        const SizedBox(height: 18),
                        Text(
                          message!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
