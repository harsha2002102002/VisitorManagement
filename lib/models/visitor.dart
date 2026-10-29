
class VisitorModel {
  final String? id;
  final String name;
  final String mobile;
  final String email;
  final String visitorType;
  final String project;
  final String purpose;
  final String status;
  final String? checkInTime;
  final String? checkOutTime;

  const VisitorModel({
    this.id,
    required this.name,
    required this.mobile,
    required this.email,
    required this.visitorType,
    required this.project,
    required this.purpose,
    this.status = 'Registered',
    this.checkInTime,
    this.checkOutTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mobile': mobile,
      'email': email,
      'visitor_type': visitorType,
      'project': project,
      'purpose': purpose,
      'status': status,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
    };
  }

  factory VisitorModel.fromJson(Map<String, dynamic> json) {
    return VisitorModel(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      visitorType: json['visitor_type']?.toString() ?? '',
      project: json['project']?.toString() ?? '',
      purpose: json['purpose']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Registered',
      checkInTime: json['check_in_time']?.toString(),
      checkOutTime: json['check_out_time']?.toString(),
    );
  }
}
