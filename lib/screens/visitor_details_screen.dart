
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../Color.dart';
import '../models/visitor.dart';
import '../providers/visitor_provider.dart';
import '../widgets/CustomQR.dart';
import '../widgets/CustomButton.dart';

class VisitorDetailsScreen extends StatefulWidget {
  final VisitorModel visitor;

  const VisitorDetailsScreen({
    super.key,
    required this.visitor,
  });

  @override
  State<VisitorDetailsScreen> createState() =>
      _VisitorDetailsScreenState();
}

class _VisitorDetailsScreenState
    extends State<VisitorDetailsScreen> {
  late VisitorModel _visitor;

  @override
  void initState() {
    super.initState();
    _visitor = widget.visitor;
  }

  String _normalizedStatus(String status) {
    return status.toLowerCase().replaceAll(' ', '');
  }

  String _formatDateTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Not available';
    }

    final parsed = DateTime.tryParse(value);

    if (parsed == null) return value;

    final local = parsed.toLocal();

    final date =
        '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';

    final hour = local.hour % 12 == 0
        ? 12
        : local.hour % 12;

    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';

    return '$date, $hour:$minute $period';
  }

  Color _statusColor(String status) {
    switch (_normalizedStatus(status)) {
      case 'checkedin':
        return const Color(0xFF16834A);
      case 'checkedout':
        return const Color(0xFF64748B);
      default:
        return const Color(0xFFA77B25);
    }
  }

  Color _statusBackground(String status) {
    switch (_normalizedStatus(status)) {
      case 'checkedin':
        return const Color(0xFFE7F6ED);
      case 'checkedout':
        return const Color(0xFFEDF1F5);
      default:
        return RequiredColors.Primary_Gold_transparant;
    }
  }

  Widget _detailRow(
      String label,
      String value,
      IconData icon,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: RequiredColors.Primary_Gold,
            size: 21,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: RequiredColors.Secondary_Gray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'Not provided' : value,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: RequiredColors.Charcoal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleVisitAction() async {
    final provider = context.read<VisitorProvider>();

    final updated = await provider.changeVisitStatus(_visitor);

    if (!mounted) return;

    if (updated != null) {
      setState(() {
        _visitor = updated;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _normalizedStatus(updated.status) == 'checkedin'
                ? 'Visitor checked in successfully'
                : 'Visitor checked out successfully',
          ),
          backgroundColor: const Color(0xFF16834A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.visitStatusError ??
                'Unable to update visitor status',
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _normalizedStatus(_visitor.status);

    final canCheckIn = status == 'registered';
    final canCheckOut = status == 'checkedin';

    return Scaffold(
      backgroundColor: RequiredColors.Background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Visitor Details',
          style: GoogleFonts.poppins(
            color: RequiredColors.Charcoal,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          color: Colors.white,
          elevation: 2,
          shadowColor: RequiredColors.Primary_Gold
              .withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 34,
                  backgroundColor:
                  RequiredColors.Primary_Gold_transparant,
                  child: Icon(
                    Icons.person_rounded,
                    color: RequiredColors.Primary_Gold,
                    size: 35,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  _visitor.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: RequiredColors.Charcoal,
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _statusBackground(_visitor.status),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    _visitor.status,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(_visitor.status),
                    ),
                  ),
                ),

                const Divider(height: 34),

                _detailRow(
                  'Mobile Number',
                  _visitor.mobile,
                  Icons.phone_outlined,
                ),
                _detailRow(
                  'Email',
                  _visitor.email,
                  Icons.email_outlined,
                ),
                _detailRow(
                  'Visitor Type',
                  _visitor.visitorType,
                  Icons.badge_outlined,
                ),
                _detailRow(
                  'Project',
                  _visitor.project,
                  Icons.business_outlined,
                ),
                _detailRow(
                  'Purpose of Visit',
                  _visitor.purpose,
                  Icons.description_outlined,
                ),

                const SizedBox(height: 12),
                const Divider(
                  color: RequiredColors.Soft_Gold,
                ),

                _detailRow(
                  'Check-in Time',
                  _formatDateTime(_visitor.checkInTime),
                  Icons.login_rounded,
                ),
                _detailRow(
                  'Check-out Time',
                  _formatDateTime(_visitor.checkOutTime),
                  Icons.logout_rounded,
                ),

                const SizedBox(height: 24),

                Consumer<VisitorProvider>(
                  builder: (context, provider, child) {
                    if (!canCheckIn && !canCheckOut) {
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7F6ED),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: Color(0xFF16834A),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Visit Completed',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF16834A),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: canCheckIn
                            ? 'Check In Visitor'
                            : 'Check Out Visitor',
                        icon: canCheckIn
                            ? Icons.login_rounded
                            : Icons.logout_rounded,
                        height: 54,
                        borderRadius: 14,
                        backgroundColor:
                        RequiredColors.Primary_Gold,
                        textColor: Colors.white,
                        isLoading: provider.isUpdatingVisitStatus,
                        onPressed: provider.isUpdatingVisitStatus
                            ? null
                            : _handleVisitAction,
                      ),
                    );
                  },
                ),

                if (_visitor.id != null &&
                    _visitor.id!.isNotEmpty) ...[
                  const SizedBox(height: 26),
                  const Divider(
                    color: RequiredColors.Soft_Gold,
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Visitor QR Code',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: RequiredColors.Charcoal,
                    ),
                  ),

                  const SizedBox(height: 18),
                  CustomVisitorQR(
                    visitorId: _visitor.id!,
                    size: 210,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
