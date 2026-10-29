import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visitor_management_application/screens/visitor_details_screen.dart';
import 'package:visitor_management_application/widgets/CustomTextField.dart';
import '../Color.dart';
import 'package:provider/provider.dart';
import '../models/visitor.dart';
import '../providers/visitor_provider.dart';
import '../widgets/CustomButton.dart';

class VisitorRegistrationScreen extends StatefulWidget {

  final String? visitorId;

  const VisitorRegistrationScreen({
    super.key,
    this.visitorId,
  });

  bool get isEditMode =>
      visitorId != null && visitorId!.isNotEmpty;

  @override
  State<VisitorRegistrationScreen> createState() =>
      _VisitorRegistrationScreenState();
}

class _VisitorRegistrationScreenState
    extends State<VisitorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _purposeController = TextEditingController();

  String? _visitorType;
  String? _project;

  bool _isLoadingVisitor = false;
  bool _isUpdating = false;
  String? _fetchError;
  VisitorModel? _existingVisitor;

  @override
  void initState() {
    super.initState();

    if (widget.isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadVisitorDetails();
      });
    }
  }

  Future<void> _loadVisitorDetails() async {
    setState(() {
      _isLoadingVisitor = true;
      _fetchError = null;
    });

    final provider = context.read<VisitorProvider>();

    final visitor = await provider.fetchVisitorById(
      widget.visitorId!,
    );

    if (!mounted) return;

    if (visitor == null) {
      setState(() {
        _fetchError = provider.visitorLookupError ??
            'Unable to load visitor details';
        _isLoadingVisitor = false;
      });
      return;
    }

    _nameController.text = visitor.name;
    _mobileController.text = visitor.mobile;
    _emailController.text = visitor.email;
    _purposeController.text = visitor.purpose;

    setState(() {
      _existingVisitor = visitor;
      _visitorType = visitor.visitorType;
      _project = visitor.project;
      _isLoadingVisitor = false;
    });
  }

  final List<String> _visitorTypes = [
    'Customer',
    'Vendor',
    'Other',
  ];

  final List<String> _projects = [
    'Project A',
    'Project B',
    'Project C',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _purposeController.dispose();
    super.dispose();
  }



  Future<void> _submitVisitor() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<VisitorProvider>();

    if (widget.isEditMode) {
      if (_isUpdating || _existingVisitor == null) return;

      setState(() => _isUpdating = true);

      final updatedVisitor = VisitorModel(
        id: _existingVisitor!.id,
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
        email: _emailController.text.trim(),
        visitorType: _visitorType!,
        project: _project!,
        purpose: _purposeController.text.trim(),

        // Preserve visit history when editing.
        status: _existingVisitor!.status,
        checkInTime: _existingVisitor!.checkInTime,
        checkOutTime: _existingVisitor!.checkOutTime,
      );

      final success = await provider.editVisitor(updatedVisitor);

      if (!mounted) return;

      setState(() => _isUpdating = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visitor updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.listError ?? 'Failed to update visitor',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else {
      if (provider.isLoading) return;

      final newVisitor = VisitorModel(
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
        email: _emailController.text.trim(),
        visitorType: _visitorType!,
        project: _project!,
        purpose: _purposeController.text.trim(),
      );

      final success = await provider.registerVisitor(newVisitor);

      if (!mounted) return;

      if (success) {
        final registered = provider.registeredVisitor;

        if (registered == null || registered.id == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Visitor saved but ID was not returned'),
            ),
          );
          return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VisitorDetailsScreen(
              visitor: registered,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ?? 'Registration failed',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }



  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: 12,
        color: RequiredColors.Secondary_Gray,
      ),
      prefixIcon: Icon(
        icon,
        color: RequiredColors.Primary_Gold,
        size: 21,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: RequiredColors.Soft_Gold,
        ),
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
          width: 1.6,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.6,
        ),
      ),
    );
  }



  Widget _fieldLabel(String label, {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: RequiredColors.Charcoal,
          ),
          children: [
            TextSpan(text: label),
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.redAccent),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required IconData icon,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          dropdownColor: Colors.white,
          decoration: _inputDecoration(
            hint: hint,
            icon: icon,
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select $label';
            }
            return null;
          },
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RequiredColors.Background,
      appBar:
      AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.isEditMode
              ? 'Edit Visitor'
              : 'New Visitor Registration',
          style: GoogleFonts.poppins(
            color: RequiredColors.Charcoal,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: RequiredColors.Charcoal,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
      _isLoadingVisitor
          ? const Center(
        child: CircularProgressIndicator(
          color: RequiredColors.Primary_Gold,
        ),
      )
          : _fetchError != null
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: RequiredColors.Primary_Gold,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              _fetchError!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _loadVisitorDetails,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      )
          :
      Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Visitor Information',
                style: GoogleFonts.poppins(
                  color: RequiredColors.Charcoal,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Please fill in the details below.',
                style: GoogleFonts.poppins(
                  color: RequiredColors.Secondary_Gray,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 26),

              CustomTextField(
                label: 'Visitor Name',
                hint: 'Enter full name',
                icon: Icons.person_outline_rounded,
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Visitor name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Mobile Number',
                hint: 'Enter 10-digit mobile number',
                icon: Icons.phone_outlined,
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mobile number is required';
                  }
                  if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                    return 'Enter exactly 10 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Email',
                hint: 'example@email.com',
                icon: Icons.email_outlined,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                isRequired: false,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return null;
                  }
                  final emailRegex = RegExp(
                    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                  );
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _buildDropdown(
                label: 'Visitor Type',
                hint: 'Select visitor type',
                icon: Icons.badge_outlined,
                items: _visitorTypes,
                value: _visitorType,
                onChanged: (value) {
                  setState(() => _visitorType = value);
                },
              ),
              const SizedBox(height: 20),

              _buildDropdown(
                label: 'Project',
                hint: 'Select project',
                icon: Icons.business_outlined,
                items: _projects,
                value: _project,
                onChanged: (value) {
                  setState(() => _project = value);
                },
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Purpose of Visit',
                hint: 'Describe the purpose of your visit',
                icon: Icons.edit_note_rounded,
                controller: _purposeController,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Purpose of visit is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),



              Consumer<VisitorProvider>(
                builder: (context, provider, child) {
                  final loading = widget.isEditMode
                      ? _isUpdating
                      : provider.isLoading;

                  return SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: widget.isEditMode
                          ? 'Update Visitor'
                          : 'Register Visitor',
                      icon: widget.isEditMode
                          ? Icons.save_outlined
                          : Icons.check_circle_outline_rounded,
                      height: 56,
                      borderRadius: 16,
                      backgroundColor: RequiredColors.Primary_Gold,
                      textColor: Colors.white,
                      isLoading: loading,
                      onPressed: loading ? null : _submitVisitor,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
