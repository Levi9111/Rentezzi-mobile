import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/services/api_service.dart';
import '../models/receipt_model.dart';

class ReceiptProvider extends ChangeNotifier {
  List<ReceiptModel> _receipts = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<ReceiptModel> get receipts {
    if (_searchQuery.trim().isEmpty) return _receipts;
    final q = _searchQuery.trim().toLowerCase();
    return _receipts.where((r) {
      final tenant = r.tenantName.toLowerCase();
      final prop = (r.propertyName ?? '').toLowerCase();
      final month = r.monthYear.toLowerCase();
      final address = r.propertyAddress.toLowerCase();
      return tenant.contains(q) ||
          prop.contains(q) ||
          month.contains(q) ||
          address.contains(q);
    }).toList();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  int get totalReceiptsCount => _receipts.length;

  int get thisMonthCount {
    final now = DateTime.now();
    return _receipts.where((r) {
      return r.createdAt.month == now.month && r.createdAt.year == now.year;
    }).length;
  }

  num get totalRevenue {
    return _receipts.fold(0, (sum, r) => sum + r.totalAmount);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Fetch all receipts
  Future<void> fetchReceipts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.get(ApiEndpoints.receipts);
      if (response is List) {
        _receipts = response
            .whereType<Map<String, dynamic>>()
            .map((r) => ReceiptModel.fromJson(r))
            .toList();
      } else if (response is Map<String, dynamic> && response['receipts'] is List) {
        _receipts = (response['receipts'] as List)
            .whereType<Map<String, dynamic>>()
            .map((r) => ReceiptModel.fromJson(r))
            .toList();
      }
      // Sort newest first
      _receipts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create new rent receipt
  Future<ReceiptModel?> createReceipt(Map<String, dynamic> payload) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.post(
        ApiEndpoints.receipts,
        body: payload,
      );

      ReceiptModel? newReceipt;
      if (response is Map<String, dynamic>) {
        newReceipt = ReceiptModel.fromJson(response);
        _receipts.insert(0, newReceipt);
      } else {
        await fetchReceipts();
      }

      _isLoading = false;
      notifyListeners();
      return newReceipt;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Delete receipt
  Future<bool> deleteReceipt(String id) async {
    try {
      await ApiService.delete(ApiEndpoints.deleteReceipt(id));
      _receipts.removeWhere((r) => r.id == id);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
