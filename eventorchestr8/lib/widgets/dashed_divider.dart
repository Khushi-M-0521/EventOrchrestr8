import 'package:flutter/material.dart';

class DashedTicketDivider extends StatelessWidget {
  const DashedTicketDivider({required this.color,super.key});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child:DashedDivider(color: color),
                      ),
                      Positioned(
                        left: -10,
                        child: ClipOval(
                          child: Container(
                            color: Colors.white70,
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                      Positioned(
                        right: -10,
                        child: ClipOval(
                          child: Container(
                            color: Colors.white70,
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                    ],
                  );
  }
}

class DashedDivider extends StatelessWidget {
  const DashedDivider({required this.color,super.key});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: CustomPaint(
        size: Size(double.infinity, 1),
        painter: _DashedLinePainter(color:color),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {

  const _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    double dashWidth = 5;
    double dashSpace = 5;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}