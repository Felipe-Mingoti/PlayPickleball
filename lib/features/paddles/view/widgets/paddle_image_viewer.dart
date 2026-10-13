import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';

Future<void> showPaddleImageViewer(BuildContext context, String imagePath) {
  return showDialog<void>(
    context: context,
    useSafeArea: false,
    barrierDismissible: false,
    barrierColor: Colors.black,
    builder: (context) => PaddleImageViewer(imagePath: imagePath),
  );
}

class PaddleImageViewer extends StatefulWidget {
  const PaddleImageViewer({super.key, required this.imagePath});

  final String imagePath;

  @override
  State<PaddleImageViewer> createState() => _PaddleImageViewerState();
}

class _PaddleImageViewerState extends State<PaddleImageViewer> {
  final _transform = TransformationController();
  Offset? _pointerDown;
  DateTime? _lastTapAt;
  Offset? _lastTapPosition;

  static const _doubleTapScale = 2.5;
  static const _doubleTapWindow = Duration(milliseconds: 300);

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointerDown = event.localPosition;
  }

  void _onPointerUp(PointerUpEvent event) {
    final down = _pointerDown;
    _pointerDown = null;
    if (down == null) return;
    if ((event.localPosition - down).distance > 18) return;

    final now = DateTime.now();
    final lastAt = _lastTapAt;
    final lastPosition = _lastTapPosition;
    if (lastAt != null &&
        lastPosition != null &&
        now.difference(lastAt) < _doubleTapWindow &&
        (event.localPosition - lastPosition).distance < 48) {
      _lastTapAt = null;
      _zoomAt(event.localPosition);
      return;
    }

    _lastTapAt = now;
    _lastTapPosition = event.localPosition;
  }

  void _zoomAt(Offset focal) {
    if (_transform.value.getMaxScaleOnAxis() > 1) {
      _transform.value = Matrix4.identity();
      return;
    }

    _transform.value = Matrix4.identity()
      ..translateByDouble(focal.dx, focal.dy, 0, 1)
      ..scaleByDouble(_doubleTapScale, _doubleTapScale, 1, 1)
      ..translateByDouble(-focal.dx, -focal.dy, 0, 1);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(
            child: Listener(
              onPointerDown: _onPointerDown,
              onPointerUp: _onPointerUp,
              child: InteractiveViewer(
                transformationController: _transform,
                minScale: 1,
                maxScale: 4,
                child: ExcludeSemantics(
                  child: Image.asset(
                    widget.imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black.withValues(alpha: 0.45),
                    minimumSize: const Size(
                      AppSpacing.minTouchTarget,
                      AppSpacing.minTouchTarget,
                    ),
                  ),
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
