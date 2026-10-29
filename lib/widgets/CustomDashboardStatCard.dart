
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Color.dart';

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;
  final Color iconColor;
  final Color iconBackground;
  final VoidCallback? onTap;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.iconColor = RequiredColors.Primary_Gold,
    this.iconBackground = RequiredColors.Primary_Gold_transparant,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shadowColor: RequiredColors.Primary_Gold.withOpacity(0.12),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: RequiredColors.Soft_Gold,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon background
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),

              const Spacer(),

              // Statistic value
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: RequiredColors.Charcoal,
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 6),

              // Statistic title
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: RequiredColors.Secondary_Gray,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),

              if (subtitle != null) ...[
                const SizedBox(height: 5),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: iconColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
