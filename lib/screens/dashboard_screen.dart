
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../Color.dart';
import '../providers/visitor_provider.dart';
import '../widgets/CustomButton.dart';
import '../widgets/CustomDashboardStatCard.dart';

import '../widgets/CustomEmptyState.dart';
import 'visitor_form_screen.dart';
import 'QrScannerScreen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onNewVisitor;
  final VoidCallback? onScanQR;

  const DashboardScreen({
    super.key,
    this.onNewVisitor,
    this.onScanQR,
  });

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _refreshDashboard();
    });
  }

  // Fetch latest visitor details from API
  Future<void> _refreshDashboard() async {
    await context.read<VisitorProvider>().fetchVisitors();
  }

  // Navigate to visitor registration
  Future<void> _openRegistration() async {
    if (widget.onNewVisitor != null) {
      widget.onNewVisitor!();
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const VisitorRegistrationScreen(),
      ),
    );

    if (!mounted) return;

    await _refreshDashboard();
  }

  // Navigate to QR scanner
  Future<void> _openQRCode() async {
    // Prefer switching to the existing scanner tab.


    // Fallback for a standalone dashboard.
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const QRScannerScreen(),
      ),
    );

    if (!mounted) return;

    await _refreshDashboard();
  }

  // Map Provider network errors to empty-state UI
  EmptyStateType _getErrorType(VisitorLoadError error) {
    switch (error) {
      case VisitorLoadError.noInternet:
        return EmptyStateType.noInternet;

      case VisitorLoadError.poorNetwork:
        return EmptyStateType.poorNetwork;

      case VisitorLoadError.serverError:
      case VisitorLoadError.none:
        return EmptyStateType.serverError;
    }
  }

  // Dashboard statistics
  Widget _buildStats(VisitorProvider provider) {
    return Column(
      children: [
        SizedBox(
          height: 165,
          width: double.infinity,
          child: DashboardStatCard(
            title: 'Total Visitors',
            value: provider.totalVisitors.toString(),
            icon: Icons.people_alt_rounded,
          ),
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 165,
                child: DashboardStatCard(
                  title: 'Checked In',
                  value: provider.checkedInVisitors.toString(),
                  icon: Icons.login_rounded,
                  iconColor: Colors.green.shade600,
                  iconBackground: const Color(0xFFE8F6EE),
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: SizedBox(
                height: 165,
                child: DashboardStatCard(
                  title: 'Checked Out',
                  value: provider.checkedOutVisitors.toString(),
                  icon: Icons.logout_rounded,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Quick actions section
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            color: RequiredColors.Charcoal,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: 'New Visitor Registration',
            icon: Icons.person_add_alt_1_rounded,
            height: 55,
            onPressed: _openRegistration,
          ),
        ),

        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: 'Scan Visitor QR Code',
            icon: Icons.qr_code_scanner_rounded,
            height: 55,
            onPressed: _openQRCode,
          ),
        ),
      ],
    );
  }

  // Network error screen
  Widget _buildNetworkError(VisitorProvider provider) {
    return RefreshIndicator(
      color: RequiredColors.Primary_Gold,
      onRefresh: _refreshDashboard,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: constraints.maxHeight,
                child: CustomEmptyStateWidget(
                  type: _getErrorType(provider.loadError),
                  onRetry: _refreshDashboard,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Dashboard content
  Widget _buildDashboardContent(VisitorProvider provider) {
    return RefreshIndicator(
      color: RequiredColors.Primary_Gold,
      onRefresh: _refreshDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 24, 18, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStats(provider),

            const SizedBox(height: 32),

            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RequiredColors.Background,

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 75,
        automaticallyImplyLeading: false,

        title: Row(
          children: [
            Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: RequiredColors.Primary_Gold_transparant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.badge_outlined,
                color: RequiredColors.Primary_Gold,
                size: 27,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Visitor Management',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: RequiredColors.Charcoal,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  Text(
                    'Secure • Smart • Seamless',
                    style: GoogleFonts.poppins(
                      color: RequiredColors.Secondary_Gray,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // actions: [
        //   Consumer<VisitorProvider>(
        //     builder: (context, provider, child) {
        //       return IconButton(
        //         tooltip: 'Refresh Dashboard',
        //         onPressed: provider.isFetching
        //             ? null
        //             : _refreshDashboard,
        //         icon: const Icon(
        //           Icons.refresh_rounded,
        //           color: RequiredColors.Charcoal,
        //           size: 25,
        //         ),
        //       );
        //     },
        //   ),
        //
        //   const SizedBox(width: 8),
        // ],
      ),

      body: SafeArea(
        child: Consumer<VisitorProvider>(
          builder: (context, provider, child) {

            // 1. Loading
            if (provider.isFetching) {
              return const Center(
                child: CircularProgressIndicator(
                  color: RequiredColors.Primary_Gold,
                ),
              );
            }

            // 2. Network / server error
            if (provider.listError != null) {
              return _buildNetworkError(provider);
            }

            // 3. Successful API response
            return _buildDashboardContent(provider);
          },
        ),
      ),
    );
  }
}
