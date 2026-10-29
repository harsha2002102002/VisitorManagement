
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Color.dart';
import 'custom_bottom_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CustomBottomNavigation(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const gold = RequiredColors.Primary_Gold;
    const charcoal = RequiredColors.Charcoal;
    const gray = RequiredColors.Secondary_Gray;

    return Scaffold(
      backgroundColor: RequiredColors.Background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
          child: Center(
            child: Column(
              children: [
                const Spacer(flex: 3),
                FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Column(
                      children: [
                        // Premium visitor logo
                        Container(
                          width: 125,
                          height: 125,
                          decoration: BoxDecoration(
                            color: RequiredColors
                                .Primary_Gold_transparant,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: gold.withOpacity(0.65),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: gold.withOpacity(0.16),
                                blurRadius: 35,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.badge_outlined,
                                size: 72,
                                color: gold,
                              ),
                              Positioned(
                                right: 23,
                                bottom: 24,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: RequiredColors
                                        .Primary_Gold_transparant,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.verified,
                                    size: 22,
                                    color: gold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 35),

                        Text(
                          'VISITOR',
                          style: GoogleFonts.poppins(
                            color: charcoal,
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 5,
                          ),
                        ),

                        Text(
                          'MANAGEMENT',
                          style: GoogleFonts.poppins(
                            color: gold,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 4,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Container(
                          height: 2,
                          width: 55,
                          decoration: BoxDecoration(
                            color: gold,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),

                        const SizedBox(height: 22),

                        Text(
                          'Seamless arrivals. Secure spaces.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: gray,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                FadeTransition(
                  opacity: _fade,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator(
                          color: gold,
                          strokeWidth: 2.5,
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        'Preparing your workspace...',
                        style: GoogleFonts.poppins(
                          color: gray,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 65),

                Text(
                  'SMART  •  SECURE  •  SEAMLESS',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
