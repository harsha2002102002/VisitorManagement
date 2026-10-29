import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:visitor_management_application/screens/visitor_details_screen.dart';
import 'package:visitor_management_application/screens/visitor_form_screen.dart';
import '../Color.dart';
import '../models/visitor.dart';
import '../providers/visitor_provider.dart';
import '../widgets/CustomEmptyState.dart';

class VisitorsListScreen extends StatefulWidget {
  const VisitorsListScreen({super.key});

  @override
  State<VisitorsListScreen> createState() => _VisitorsListScreenState();
}

class _VisitorsListScreenState extends State<VisitorsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<VisitorProvider>().fetchVisitors();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<VisitorModel> _filterVisitors(List<VisitorModel> visitors) {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) return visitors;

    return visitors.where((visitor) {
      return visitor.name.toLowerCase().contains(query) ||
          visitor.mobile.contains(query);
    }).toList();
  }

  Color _statusColor(String status) {
    switch (status.trim().toLowerCase().replaceAll(' ', '')) {
      case 'checkedin':
      case 'checkin':
        return const Color(0xFF16834A);
      case 'checkedout':
      case 'checkout':
        return const Color(0xFF64748B);
      default:
        return const Color(0xFFA77B25);
    }
  }

  Color _statusBackground(String status) {
    switch (status.trim().toLowerCase().replaceAll(' ', '')) {
      case 'checkedin':
      case 'checkin':
        return const Color(0xFFE7F6ED);
      case 'checkedout':
      case 'checkout':
        return const Color(0xFFEDF1F5);
      default:
        return RequiredColors.Primary_Gold_transparant;
    }
  }

  Widget _statusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: _statusBackground(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.isEmpty ? 'Registered' : status,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _statusColor(status),
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required Color background,
    required VoidCallback? onPressed,
    required String tooltip,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, size: 19, color: color),
        constraints: const BoxConstraints(
          minWidth: 42,
          minHeight: 42,
        ),
      ),
    );
  }

  Future<void> _deleteVisitor(VisitorModel visitor) async {
    if (visitor.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          'Delete Visitor?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete ${visitor.name}? '
              'This action cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<VisitorProvider>();
    final success = await provider.removeVisitor(visitor.id!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Visitor deleted successfully'
              : provider.listError ?? 'Unable to delete visitor',
        ),
        backgroundColor: success ? Colors.green : Colors.redAccent,
      ),
    );
  }


  Future<void> _editVisitor(VisitorModel visitor) async {
    if (visitor.id == null || visitor.id!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Visitor ID is missing'),
        ),
      );
      return;
    }

    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => VisitorRegistrationScreen(
          visitorId: visitor.id!,
        ),
      ),
    );

    if (!mounted) return;

    if (updated == true) {
      await context.read<VisitorProvider>().fetchVisitors();
    }
  }


  Widget _visitorCard(
      VisitorModel visitor,
      VisitorProvider provider,
      ) {
    final isBusy = provider.busyVisitorId == visitor.id;

    return Card(
      color: Colors.white,
      elevation: 1.5,
      shadowColor: RequiredColors.Primary_Gold.withOpacity(0.12),
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: RequiredColors.Soft_Gold,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VisitorDetailsScreen(
                visitor: visitor,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 23,
                    backgroundColor:
                    RequiredColors.Primary_Gold_transparant,
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: RequiredColors.Primary_Gold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visitor.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: RequiredColors.Charcoal,
                          ),
                        ),
                        Text(
                          visitor.mobile,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: RequiredColors.Secondary_Gray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusChip(visitor.status),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: RequiredColors.Soft_Gold),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _infoColumn('Project', visitor.project),
                  ),
                  Expanded(
                    child: _infoColumn('Visitor Type', visitor.visitorType),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (isBusy)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(
                      color: RequiredColors.Primary_Gold,
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _actionButton(
                      icon: Icons.edit_outlined,
                      tooltip: 'Edit visitor',
                      color: const Color(0xFFA77B25),
                      background:
                      RequiredColors.Primary_Gold_transparant,
                      onPressed: () => _editVisitor(visitor),
                    ),
                    _actionButton(
                      icon: Icons.delete_outline_rounded,
                      tooltip: 'Delete visitor',
                      color: Colors.redAccent,
                      background: const Color(0xFFFDECEC),
                      onPressed: () => _deleteVisitor(visitor),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: RequiredColors.Secondary_Gray,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: RequiredColors.Charcoal,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RequiredColors.Background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          'Visitors',
          style: GoogleFonts.poppins(
            color: RequiredColors.Charcoal,
            fontWeight: FontWeight.w600,
            fontSize: 19,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 14),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search by name or mobile number',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  color: RequiredColors.Secondary_Gray,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: RequiredColors.Primary_Gold,
                ),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: RequiredColors.Soft_Gold,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: RequiredColors.Primary_Gold,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<VisitorProvider>(
              builder: (context, provider, child) {
                if (provider.isFetching && provider.visitors.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: RequiredColors.Primary_Gold,
                    ),
                  );
                }


                if (provider.listError != null) {
                  EmptyStateType errorType;

                  switch (provider.loadError) {
                    case VisitorLoadError.noInternet:
                      errorType = EmptyStateType.noInternet;
                      break;

                    case VisitorLoadError.poorNetwork:
                      errorType = EmptyStateType.poorNetwork;
                      break;

                    case VisitorLoadError.serverError:
                    case VisitorLoadError.none:
                      errorType = EmptyStateType.serverError;
                      break;
                  }

                  return CustomEmptyStateWidget(
                    type: errorType,
                    onRetry: provider.isFetching
                        ? null
                        : () => provider.fetchVisitors(),
                  );
                }


                final filtered = _filterVisitors(provider.visitors);

                return RefreshIndicator(
                  color: RequiredColors.Primary_Gold,
                  onRefresh: provider.fetchVisitors,
                  child: filtered.isEmpty
                      ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.55,
                        child: CustomEmptyStateWidget(
                          type: _searchQuery.trim().isNotEmpty
                              ? EmptyStateType.noSearchResults
                              : EmptyStateType.noData,
                        ),
                      ),
                    ],
                  )
                      : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 110),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _visitorCard(
                        filtered[index],
                        provider,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
