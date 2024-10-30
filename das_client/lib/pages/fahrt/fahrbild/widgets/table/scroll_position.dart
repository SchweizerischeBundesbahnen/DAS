import 'package:flutter/material.dart';

// TODO: Dot is visible lagging behind. This effect could be worse with complex stuff like dotted lines.
class TrainRouteScreen extends StatefulWidget {
  @override
  _TrainRouteScreenState createState() => _TrainRouteScreenState();
}

class _TrainRouteScreenState extends State<TrainRouteScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey currentStationKey = GlobalKey();
  bool _isCurrentStationVisible = true;

  final int _currentStationIndex = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_checkCurrentStationVisibility);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_checkCurrentStationVisibility);
    _scrollController.dispose();
    super.dispose();
  }

  void _checkCurrentStationVisibility() {
    final context = currentStationKey.currentContext;
    if (context != null) {
      final renderBox = context.findRenderObject();
      if (renderBox is RenderBox && renderBox.attached) {
        final position = renderBox.localToGlobal(Offset.zero);
        final size = renderBox.size;
        final screenHeight = MediaQuery.of(context).size.height;

        setState(() {
          _isCurrentStationVisible = position.dy >= 0 && position.dy + size.height <= screenHeight;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Train Route'),
      ),
      body: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            itemCount: 20, // For example, 20 train stations
            itemBuilder: (context, index) {
              return ListTile(
                key: index == _currentStationIndex ? currentStationKey : null,
                title: Text('Train Station ${index + 1}'),
              );
            },
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: VerticalLinePainter(),
              ),
            ),
          ),
          if (_isCurrentStationVisible)
            Positioned(
              left: 20.0, // Adjust based on where you want the line
              top: _calculateDotTopPosition(),
              child: Dot(),
            ),
        ],
      ),
    );
  }

  double _calculateDotTopPosition() {
    final context = currentStationKey.currentContext;
    if (context != null) {
      final renderBox = context.findRenderObject();
      if (renderBox is RenderBox && renderBox.attached) {
        final position = renderBox.localToGlobal(Offset.zero);
        return position.dy + renderBox.size.height / 2 - 5; // Adjust for centering the dot
      }
    }
    return 0.0;
  }
}

class VerticalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(25, 0), Offset(25, size.height), paint); // Draw vertical line
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10.0,
      height: 10.0,
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }
}
