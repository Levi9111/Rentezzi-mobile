import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/services/api_service.dart';
import '../models/property_model.dart';

class PropertyProvider extends ChangeNotifier {
  List<PropertyModel> _properties = [];
  VacancySummaryModel? _vacancySummary;
  bool _isLoading = false;
  String? _errorMessage;

  List<PropertyModel> get properties => _properties;
  VacancySummaryModel? get vacancySummary => _vacancySummary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalProperties => _properties.length;
  int get totalUnits =>
      _vacancySummary?.totalUnits ??
      _properties.fold(0, (sum, p) => sum + p.totalUnits);
  int get vacantUnits =>
      _vacancySummary?.vacantUnits ??
      _properties.fold(0, (sum, p) => sum + p.vacantUnits);
  int get occupiedUnits =>
      _vacancySummary?.occupiedUnits ??
      _properties.fold(0, (sum, p) => sum + p.occupiedUnits);

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Fetch all properties
  Future<void> fetchProperties() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.get(ApiEndpoints.properties);
      if (response is List) {
        _properties = response
            .whereType<Map<String, dynamic>>()
            .map((p) => PropertyModel.fromJson(p))
            .toList();
      } else if (response is Map<String, dynamic> && response['properties'] is List) {
        _properties = (response['properties'] as List)
            .whereType<Map<String, dynamic>>()
            .map((p) => PropertyModel.fromJson(p))
            .toList();
      }
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

  /// Fetch vacancy summary
  Future<void> fetchVacancySummary() async {
    try {
      final response = await ApiService.get(ApiEndpoints.vacancySummary);
      if (response is Map<String, dynamic>) {
        _vacancySummary = VacancySummaryModel.fromJson(response);
        notifyListeners();
      }
    } catch (_) {
      // Ignore background summary errors
    }
  }

  /// Create new property
  Future<bool> createProperty({required String name, required String address}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.post(
        ApiEndpoints.createProperty,
        body: {'name': name.trim(), 'address': address.trim()},
      );

      if (response is Map<String, dynamic>) {
        final newProp = PropertyModel.fromJson(response);
        _properties.insert(0, newProp);
      } else {
        await fetchProperties();
      }
      await fetchVacancySummary();

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete property
  Future<bool> deleteProperty(String id) async {
    try {
      await ApiService.delete(ApiEndpoints.deleteProperty(id));
      _properties.removeWhere((p) => p.id == id);
      await fetchVacancySummary();
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

  /// Add unit to property
  Future<bool> addUnit({required String propertyId, required String name}) async {
    try {
      final response = await ApiService.post(
        ApiEndpoints.addUnit(propertyId),
        body: {'name': name.trim()},
      );

      final propIndex = _properties.indexWhere((p) => p.id == propertyId);
      if (propIndex != -1 && response is Map<String, dynamic>) {
        if (response.containsKey('units')) {
          _properties[propIndex] = PropertyModel.fromJson(response);
        } else {
          final newUnit = UnitModel.fromJson(response);
          _properties[propIndex].units.add(newUnit);
        }
      } else {
        await fetchProperties();
      }
      await fetchVacancySummary();
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

  /// Delete unit from property
  Future<bool> deleteUnit({required String propertyId, required String unitId}) async {
    try {
      await ApiService.delete(ApiEndpoints.deleteUnit(propertyId, unitId));
      final propIndex = _properties.indexWhere((p) => p.id == propertyId);
      if (propIndex != -1) {
        _properties[propIndex].units.removeWhere((u) => u.id == unitId);
      }
      await fetchVacancySummary();
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

  /// Assign or edit tenant in unit
  Future<bool> assignTenant({
    required String propertyId,
    required String unitId,
    required TenantModel tenant,
  }) async {
    try {
      await ApiService.put(
        ApiEndpoints.assignTenant(propertyId, unitId),
        body: tenant.toJson(),
      );

      final propIndex = _properties.indexWhere((p) => p.id == propertyId);
      if (propIndex != -1) {
        final unitIndex =
            _properties[propIndex].units.indexWhere((u) => u.id == unitId);
        if (unitIndex != -1) {
          final currentUnit = _properties[propIndex].units[unitIndex];
          _properties[propIndex].units[unitIndex] = UnitModel(
            id: currentUnit.id,
            name: currentUnit.name,
            tenant: tenant,
          );
        }
      }
      await fetchVacancySummary();
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

  /// Clear tenant from unit
  Future<bool> clearTenant({required String propertyId, required String unitId}) async {
    try {
      await ApiService.delete(ApiEndpoints.clearTenant(propertyId, unitId));

      final propIndex = _properties.indexWhere((p) => p.id == propertyId);
      if (propIndex != -1) {
        final unitIndex =
            _properties[propIndex].units.indexWhere((u) => u.id == unitId);
        if (unitIndex != -1) {
          final currentUnit = _properties[propIndex].units[unitIndex];
          _properties[propIndex].units[unitIndex] = UnitModel(
            id: currentUnit.id,
            name: currentUnit.name,
            tenant: null,
          );
        }
      }
      await fetchVacancySummary();
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
