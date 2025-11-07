import 'package:flutter/material.dart';

class IceCreamPreviewWidget extends StatelessWidget {
  final String base; // 'Cone' o 'Cup'
  final List<String> flavors; // Máx 3
  final List<String> toppings; // Máx 4 (UI limit)
  final double size;
  final Map<String, dynamic>? flavorData; // optional: {flavor: {color, abbr}}
  final Map<String, String>? toppingIcons; // optional emoji/icon mapping

  const IceCreamPreviewWidget({
    super.key,
    required this.base,
    required this.flavors,
    required this.toppings,
    this.size = 120,
    this.flavorData,
    this.toppingIcons,
  });

  @override
  Widget build(BuildContext context) {
    // Cálculos mejorados para mejor visualización
    final int scoopCount = flavors.length > 3 ? 3 : flavors.length;
    final double coneHeight = base == 'Cone' ? size * 0.35 : size * 0.25;
    final double radius = size * 0.14; // Radio aumentado para bolas más grandes
    final double overlap = radius * 0.3; // Más superposición para mejor apariencia
    final double scoopStep = 2 * radius - overlap;
    final double bottomOfLowestScoop = coneHeight - (radius * 0.1);
    final double bottomOfTopmostScoop = scoopCount > 0 ? bottomOfLowestScoop + (scoopCount - 1) * scoopStep : bottomOfLowestScoop;
    final double totalHeight = bottomOfTopmostScoop + radius + 50.0; // Más espacio en la parte superior

  // Posiciones mejoradas para toppings
  final int toppingCount = toppings.length > 4 ? 4 : toppings.length;
  // place toppings just above the topmost scoop
  final double toppingBottom = bottomOfTopmostScoop + radius + 6.0;

    return SizedBox(
      width: size,
      height: totalHeight.clamp(size * 0.6, size * 4.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Base
          if (base == 'Cone')
            Positioned(
              bottom: 0,
              child: CustomPaint(
                size: Size(size * 0.8, coneHeight), // Cono más grande
                painter: _ConePainter(),
              ),
            )
          else
            Positioned(
              bottom: 0,
              child: CustomPaint(
                size: Size(size * 0.8, coneHeight), // Copa más grande
                painter: _CupPainter(),
              ),
            ),
          
          // Flavors (bolas) - renderizado mejorado
          ...List.generate(scoopCount, (i) {
            final int bottomIndex = scoopCount - 1 - i;
            final color = _flavorColor(flavors[bottomIndex]);
            final double bottomPos = bottomOfLowestScoop + bottomIndex * scoopStep;
            
            return Positioned(
              bottom: bottomPos,
              child: Container(
                width: radius * 2,
                height: radius * 2,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    (flavorData != null && flavorData![flavors[bottomIndex]] != null && flavorData![flavors[bottomIndex]]['abbr'] != null)
                        ? (flavorData![flavors[bottomIndex]]['abbr'] as String)
                        : flavors[bottomIndex][0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: radius * 0.8,
                    ),
                  ),
                ),
              ),
            );
          }),
          
          // Toppings: centered row positioned above the topmost scoop
          if (toppings.isNotEmpty)
            Positioned(
              bottom: toppingBottom,
              child: SizedBox(
                width: size,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(toppingCount, (i) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: radius * 0.15),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: _toppingIcon(toppings[i]),
                      ),
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _flavorColor(String flavor) {
    if (flavorData != null && flavorData![flavor] != null && flavorData![flavor]['color'] != null) {
      final c = flavorData![flavor]['color'];
      if (c is Color) return c;
    }
    switch (flavor.toLowerCase()) {
      case 'strawberry': return Colors.pinkAccent;
      case 'chocolate': return Colors.brown;
      case 'vanilla': return Colors.yellow[200]!;
      case 'mint': return Colors.tealAccent;
      case 'blueberry': return Colors.blueAccent;
      case 'mango': return Colors.orangeAccent;
      case 'pistachio': return Colors.greenAccent;
      case 'cookies & cream': return Colors.grey[400]!;
      default: return Colors.grey;
    }
  }

  Widget _toppingIcon(String topping) {
    if (toppingIcons != null && toppingIcons![topping] != null) {
      return Text(toppingIcons![topping]!, style: const TextStyle(fontSize: 16));
    }
    switch (topping.toLowerCase()) {
      case 'sprinkles': return const Icon(Icons.emoji_food_beverage, color: Colors.pink, size: 18);
      case 'cherry': return const Icon(Icons.circle, color: Colors.red, size: 18);
      case 'chocolate chips': return const Icon(Icons.scatter_plot, color: Colors.brown, size: 18);
      case 'choc chips': return const Icon(Icons.scatter_plot, color: Colors.brown, size: 18);
      case 'whipped cream': return const Icon(Icons.cloud, color: Colors.white, size: 18);
      case 'caramel': return const Icon(Icons.water_drop, color: Colors.orange, size: 18);
      case 'cookie': return const Icon(Icons.cookie, color: Colors.brown, size: 18);
      default: return const Icon(Icons.star, color: Colors.amber, size: 18);
    }
  }
}

class _ConePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown[400]!
      ..style = PaintingStyle.fill;
    
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(size.width * 0.2, size.height * 0.1)
      ..quadraticBezierTo(size.width / 2, 0, size.width * 0.8, size.height * 0.1)
      ..close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CupPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.fill;
    
    final rect = Rect.fromLTWH(0, size.height * 0.15, size.width, size.height * 0.85);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      paint,
    );
    
    // Añadir línea decorativa en la copa
    final borderPaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      borderPaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}