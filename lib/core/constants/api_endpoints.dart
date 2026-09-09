class ApiEndpoints {
  // Production server URL fallback (Render deployment)
  static const String prodBaseUrl = 'https://rentezzi-server-v2.onrender.com/api/v1';
  
  // Local development URL
  static const String localBaseUrl = 'http://localhost:5000/api/v1';

  // Android emulator loopback
  static const String androidEmulatorBaseUrl = 'http://10.0.2.2:5000/api/v1';

  // Current active base URL (can be customized via settings or runtime)
  static String baseUrl = prodBaseUrl;

  // Auth endpoints
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String me = '/auth/me';
  static const String changePassword = '/auth/change-password';

  // User endpoints
  static const String updateUser = '/user/update';

  // Property endpoints
  static const String properties = '/property';
  static const String vacancySummary = '/property/vacancy-summary';
  static const String createProperty = '/property/create-property';
  static String updateProperty(String id) => '/property/update-property/$id';
  static String deleteProperty(String id) => '/property/delete-property/$id';

  // Unit endpoints
  static String addUnit(String propertyId) => '/property/$propertyId/add-unit';
  static String updateUnit(String propertyId, String unitId) =>
      '/property/$propertyId/update-unit/$unitId';
  static String deleteUnit(String propertyId, String unitId) =>
      '/property/$propertyId/delete-unit/$unitId';

  // Tenant endpoints
  static String assignTenant(String propertyId, String unitId) =>
      '/property/$propertyId/units/$unitId/assign-tenant';
  static String clearTenant(String propertyId, String unitId) =>
      '/property/$propertyId/units/$unitId/clear-tenant';

  // Receipt endpoints
  static const String receipts = '/receipt';
  static String receiptById(String id) => '/receipt/$id';
  static String deleteReceipt(String id) => '/receipt/$id';
}
