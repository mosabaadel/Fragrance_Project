import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
final double size;

const AppLogo({
super.key,
this.size = 120,
});

@override
Widget build(BuildContext context) {
return Container(
width: size,
height: size,
decoration: BoxDecoration(
shape: BoxShape.circle,
gradient: const LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [
Color(0xFF4A3B52),
Color(0xFF8B7185),
],
),
boxShadow: [
BoxShadow(
color: const Color(0xFF4A3B52).withOpacity(0.18),
blurRadius: 20,
offset: const Offset(0, 8),
),
],
),
child: Center(
child: Stack(
alignment: Alignment.center,
children: [
// دائرة داخلية
Container(
width: size * 0.72,
height: size * 0.72,
decoration: BoxDecoration(
shape: BoxShape.circle,
border: Border.all(
color: Colors.white.withOpacity(0.35),
width: 1.5,
),
),
),

// زجاجة العطر
Icon(
Icons.local_florist_rounded,
size: size * 0.34,
color: Colors.white,
),

// لمسة الذكاء الاصطناعي
Positioned(
right: size * 0.12,
top: size * 0.15,
child: Container(
width: size * 0.20,
height: size * 0.20,
decoration: BoxDecoration(
color: const Color(0xFFD8A9B8),
shape: BoxShape.circle,
border: Border.all(
color: Colors.white,
width: 2,
),
),
child: Icon(
Icons.auto_awesome,
size: size * 0.105,
color: const Color(0xFF4A3B52),
),
),
),
],
),
),
);
}
}

