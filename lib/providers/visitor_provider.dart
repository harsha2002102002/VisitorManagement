
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import '../models/visitor.dart';
import '../services/api_service.dart';

enum VisitorLoadError {
  none,
  noInternet,
  poorNetwork,
  serverError,
}
class VisitorProvider extends ChangeNotifier {
  final VisitorService _visitorService;

  VisitorProvider(this._visitorService);
  VisitorLoadError _loadError = VisitorLoadError.none;
  VisitorLoadError get loadError => _loadError;
  bool _isLoading = false;
  String? _errorMessage;
  VisitorModel? _registeredVisitor;
  List<VisitorModel> _visitors = [];
  bool _isFetching = false;
  String? _listError;
  String? _busyVisitorId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  VisitorModel? get registeredVisitor => _registeredVisitor;
  List<VisitorModel> get visitors => List.unmodifiable(_visitors);
  bool get isFetching => _isFetching;
  String? get listError => _listError;
  String? get busyVisitorId => _busyVisitorId;
  bool _isUpdatingVisitStatus = false;
  String? _visitStatusError;

  bool get isUpdatingVisitStatus => _isUpdatingVisitStatus;
  String? get visitStatusError => _visitStatusError;

  bool _isFetchingVisitor = false;
  String? _visitorLookupError;
  bool get isFetchingVisitor => _isFetchingVisitor;
  String? get visitorLookupError => _visitorLookupError;

  int get totalVisitors => _visitors.length;

  int get checkedInVisitors => _visitors.where((visitor) {
    return visitor.status
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\s_-]'), '') ==
        'checkedin';
  }).length;

  int get checkedOutVisitors => _visitors.where((visitor) {
    return visitor.status
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\s_-]'), '') ==
        'checkedout';
  }).length;

  Future<void> fetchVisitors() async {
    _isFetching = true;
    _listError = null;
    _loadError = VisitorLoadError.none;
    notifyListeners();

    try {
      _visitors = await _visitorService.getVisitors();
    } on TimeoutException {
      _loadError = VisitorLoadError.poorNetwork;
      _listError = 'The request timed out. Please try again.';
    } on SocketException {
      _loadError = VisitorLoadError.noInternet;
      _listError = 'Unable to connect to the network.';
    } on HttpException {
      _loadError = VisitorLoadError.serverError;
      _listError = 'Unable to communicate with the server.';
    } catch (e) {
      _loadError = VisitorLoadError.serverError;
      _listError = 'Unable to load visitors. Please try again.';
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  Future<VisitorModel?> fetchVisitorById(String id) async {
    if (_isFetchingVisitor) return null;

    _isFetchingVisitor = true;
    _visitorLookupError = null;
    notifyListeners();

    try {
      return await _visitorService.getVisitorById(id);
    } catch (e) {
      _visitorLookupError = e.toString();
      return null;
    } finally {
      _isFetchingVisitor = false;
      notifyListeners();
    }
  }
  Future<bool> editVisitor(VisitorModel visitor) async {
    if (_busyVisitorId != null) return false;

    _busyVisitorId = visitor.id;
    _listError = null;
    notifyListeners();

    try {
      final updated = await _visitorService.updateVisitor(visitor);

      final index = _visitors.indexWhere((v) => v.id == updated.id);
      if (index != -1) {
        _visitors[index] = updated;
      }
      return true;
    } catch (e) {
      _listError = e.toString();
      return false;
    } finally {
      _busyVisitorId = null;
      notifyListeners();
    }
  }
  Future<VisitorModel?> changeVisitStatus(
      VisitorModel visitor,
      ) async {
    if (_isUpdatingVisitStatus) return null;

    final currentStatus =
    visitor.status.toLowerCase().replaceAll(' ', '');

    final isCheckIn = currentStatus == 'registered';

    if (!isCheckIn && currentStatus != 'checkedin') {
      _visitStatusError = 'This visit has already been completed';
      notifyListeners();
      return null;
    }

    if (visitor.id == null || visitor.id!.isEmpty) {
      _visitStatusError = 'Visitor ID is missing';
      notifyListeners();
      return null;
    }

    _isUpdatingVisitStatus = true;
    _visitStatusError = null;
    notifyListeners();

    try {
      // Fetch latest status to avoid using stale screen data.
      final latest = await _visitorService.getVisitorById(visitor.id!);
      final latestStatus =
      latest.status.toLowerCase().replaceAll(' ', '');

      if (latestStatus != currentStatus) {
        _visitStatusError =
        'Visitor status changed. Please reopen the details.';
        return null;
      }

      final now = DateTime.now().toUtc().toIso8601String();

      final updated = await _visitorService.updateVisitStatus(
        visitorId: visitor.id!,
        status: isCheckIn ? 'Checked In' : 'Checked Out',
        checkInTime: isCheckIn
            ? now
            : latest.checkInTime,
        checkOutTime: isCheckIn
            ? latest.checkOutTime
            : now,
      );

      // Keep the visitors list synchronized.
      final index = _visitors.indexWhere(
            (item) => item.id == updated.id,
      );

      if (index != -1) {
        _visitors[index] = updated;
      }

      return updated;
    } catch (e) {
      _visitStatusError = e.toString();
      return null;
    } finally {
      _isUpdatingVisitStatus = false;
      notifyListeners();
    }
  }
  Future<bool> removeVisitor(String id) async {
    if (_busyVisitorId != null) return false;

    _busyVisitorId = id;
    _listError = null;
    notifyListeners();

    try {
      await _visitorService.deleteVisitor(id);
      _visitors.removeWhere((visitor) => visitor.id == id);
      return true;
    } catch (e) {
      _listError = e.toString();
      return false;
    } finally {
      _busyVisitorId = null;
      notifyListeners();
    }
  }
  Future<bool> registerVisitor(
      VisitorModel visitor,
      ) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    _registeredVisitor = null;
    notifyListeners();

    try {
      _registeredVisitor =
      await _visitorService.registerVisitor(visitor);

      return true;
    } on TimeoutException {
      _errorMessage =
      'Request timed out. Please check whether '
          'the visitor was registered before retrying.';
      return false;
    } catch (e) {
      _errorMessage = 'Unable to register visitor: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearRegistrationState() {
    _errorMessage = null;
    _registeredVisitor = null;
    notifyListeners();
  }
}
