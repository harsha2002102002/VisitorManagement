
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Color.dart';

enum EmptyStateType {
  noData,
  noSearchResults,
  noInternet,
  poorNetwork,
  serverError,
}

class CustomEmptyStateWidget extends StatelessWidget {
  final EmptyStateType type;
  final VoidCallback? onRetry;
  final String? title;
  final String? description;

  const CustomEmptyStateWidget({
    super.key,
    required this.type,
    this.onRetry,
    this.title,
    this.description,
  });

  IconData get _icon {
    switch (type) {
      case EmptyStateType.noData:
        return Icons.people_outline_rounded;
      case EmptyStateType.noSearchResults:
        return Icons.search_off_rounded;
      case EmptyStateType.noInternet:
        return Icons.wifi_off_rounded;
      case EmptyStateType.poorNetwork:
        return Icons.signal_wifi_statusbar_connected_no_internet_4_rounded;
      case EmptyStateType.serverError:
        return Icons.cloud_off_rounded;
    }
  }

  String get _title {
    switch (type) {
      case EmptyStateType.noData:
        return 'No Visitors Yet';
      case EmptyStateType.noSearchResults:
        return 'No Visitors Found';
      case EmptyStateType.noInternet:
        return 'No Internet Connection';
      case EmptyStateType.poorNetwork:
        return 'Poor Network Connection';
      case EmptyStateType.serverError:
        return 'Something Went Wrong';
    }
  }

  String get _description {
    switch (type) {
      case EmptyStateType.noData:
        return 'Registered visitors will appear here.';
      case EmptyStateType.noSearchResults:
        return 'Try searching with a different name or mobile number.';
      case EmptyStateType.noInternet:
        return 'Please connect to Wi-Fi or mobile data and try again.';
      case EmptyStateType.poorNetwork:
        return 'The connection is taking too long. Please check your network and retry.';
      case EmptyStateType.serverError:
        return 'Unable to load visitor details right now. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 28,
          vertical: 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                color: RequiredColors.Primary_Gold_transparant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icon,
                size: 52,
                color: RequiredColors.Primary_Gold,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              title ?? _title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: RequiredColors.Charcoal,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              description ?? _description,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                height: 1.6,
                color: RequiredColors.Secondary_Gray,
              ),
            ),

            if (onRetry != null) ...[
              const SizedBox(height: 24),

              SizedBox(
                width: 155,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 19,
                  ),
                  label: Text(
                    'Try Again',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RequiredColors.Primary_Gold,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
