import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class GlitchEffect extends StatefulWidget {
  final Widget child;
  final bool active;

  const GlitchEffect({super.key, required this.child, this.active = false});

  @override
  State<GlitchEffect> createState() => _GlitchEffectState();
}

class _GlitchEffectState extends State<GlitchEffect> {
  Timer? _timer;
  double _xOffset = 0;
  double _yOffset = 0;
  double _skew = 0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    if (widget.active) _startGlitch();
  }

  @override
  void didUpdateWidget(GlitchEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) _startGlitch();
    else if (!widget.active && oldWidget.active) _stopGlitch();
  }

  void _startGlitch() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (mounted) {
        setState(() {
          if (_random.nextDouble() < 0.5) { // 50% de chance de glitch par frame
            _xOffset = (_random.nextDouble() - 0.5) * 50; // Secousse Violente
            _yOffset = (_random.nextDouble() - 0.5) * 15;
            _skew = (_random.nextDouble() - 0.5) * 0.3; // Distorsion Tordue
          } else {
            _xOffset = 0; _yOffset = 0; _skew = 0;
          }
        });
      }
    });
  }

  void _stopGlitch() {
    _timer?.cancel();
    if (mounted) setState(() { _xOffset = 0; _yOffset = 0; _skew = 0; });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;

    return Stack(
      children: [
        // Contenu Principal Transformé
        Transform(
          transform: Matrix4.identity()
            ..translate(_xOffset, _yOffset)
            ..setEntry(0, 1, _skew),
          alignment: Alignment.center,
          child: widget.child,
        ),
        
        // Calque Chromatique Agressif (Cyan/Rouge)
        if (_xOffset != 0) ...[
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: Transform.translate(
                offset: Offset(_xOffset * 2, _yOffset * 1.5),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(Colors.redAccent, BlendMode.screen),
                  child: widget.child,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: Transform.translate(
                offset: Offset(-_xOffset * 2, -_yOffset * 1.5),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(Colors.cyanAccent, BlendMode.screen),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ],

        // Lignes de Parasites Vidéo
        if (_xOffset.abs() > 10)
          ...List.generate(3, (i) => Positioned(
            top: _random.nextDouble() * MediaQuery.of(context).size.height,
            left: 0, right: 0,
            child: Container(height: 1 + _random.nextDouble() * 3, color: Colors.white.withValues(alpha: 0.15)),
          )),
      ],
    );
  }
}
