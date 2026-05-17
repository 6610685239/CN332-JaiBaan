import 'package:flutter/material.dart';

class JaiBaanBackground extends StatelessWidget {
  final Widget child;

  const JaiBaanBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Layer 1: Orange gradient background (50% opacity) ──────────
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ── Layer 2: shape1 — top shape (tilted white panel at top) ────
          Positioned(
          top: -425,
          left: -500,
          child: Image.asset(
            'assets/images/shape1.png',
            width: size.width * 3.5,
              // ตอนนี้จะได้ผลแน่นอน
            // ลบ right: 0 ออก เพราะมันดึง width กลับ
          ),
        ),
          // ── Layer 3: shape2 — side shape (curved white blob, left side) ─
          Positioned(
            top: size.height * 0.22,
            right: 0,
            child: Image.asset(
              'assets/images/shape2.png',
              width: size.width * 0.5,
              fit: BoxFit.fitWidth,
            ),
          ),


          // ── Layer 4: shape3 — bottom shape (wave white strip) ──────────
 //        Positioned(
 //          bottom: 0,
 //          left: 0,
 //          right: -200,
 //          child: Image.asset(
 //            'assets/images/shape3.png',
 //            width: size.width * 1000,
 //            fit: BoxFit.fitWidth,
 //            alignment: Alignment.bottomCenter,
 //          ),
 //        ),

          // ── Layer 5: Page content ───────────────────────────────────────
          Positioned.fill(
            child: child,
          ),
        ],
      ),
    );
  }
}
