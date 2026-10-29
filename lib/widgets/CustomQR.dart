import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../Color.dart';

class CustomVisitorQR extends StatelessWidget {
  final String visitorId;
  final double size;

  const CustomVisitorQR({
    super.key,
    required this.visitorId,
    this.size = 220,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: RequiredColors.Soft_Gold,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: RequiredColors.Primary_Gold
                    .withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: QrImageView(
            data: 'VISITOR:$visitorId',
            version: QrVersions.auto,
            size: size,
            backgroundColor: Colors.white,
            foregroundColor: RequiredColors.Charcoal,
            errorCorrectionLevel: QrErrorCorrectLevel.M,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Visitor ID: $visitorId',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: RequiredColors.Charcoal,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Scan this QR code to view visitor details',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: RequiredColors.Secondary_Gray,
          ),
        ),
      ],
    );
  }
}
