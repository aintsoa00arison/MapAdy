import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/cyber_toast.dart';

class HintSection extends StatefulWidget {
  final List<String> hints;

  const HintSection({super.key, required this.hints});

  @override
  State<HintSection> createState() => _HintSectionState();
}

class _HintSectionState extends State<HintSection> {
  int _hintsRevealed = 0;

  @override
  void didUpdateWidget(HintSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hints != widget.hints) {
      _hintsRevealed = 0;
    }
  }

  void _showHintDialog(String hintText) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lightbulb, color: AppColors.secondary, size: 40),
                  const SizedBox(height: 20),
                  const Text(
                    'INDICE DE RÉSEAU',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Anybody',
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    hintText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _revealHint() {
    if (_hintsRevealed < 2) {
      final hint = widget.hints[_hintsRevealed];
      setState(() {
        _hintsRevealed++;
      });
      _showHintDialog(hint);
    } else {
      CyberToast.show(context, "PLUS D'INDICES DISPONIBLES", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _revealHint,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: AppColors.secondary, size: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'INDICE DISPONIBLE',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                    Text(
                      '-500 CC',
                      style: TextStyle(color: AppColors.secondary, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: List.generate(2, (index) {
                bool isRevealed = index < _hintsRevealed;
                return Container(
                  margin: const EdgeInsets.only(left: 8),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isRevealed ? AppColors.secondary : Colors.white10,
                    boxShadow: isRevealed ? [
                      BoxShadow(color: AppColors.secondary.withValues(alpha: 0.4), blurRadius: 6)
                    ] : null,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
