class ApiEndpoints {
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const refresh = '/auth/refresh';
  static const logout = '/auth/logout';
  static const me = '/auth/me';
  static const profileMe = '/profiles/me';
  static const profilePhoneSend = '/profiles/me/phone/send-code';
  static const profilePhoneVerify = '/profiles/me/phone/verify';

  static String userPosts(String userId) => '/posts/user/$userId';

  static const mapAlerts = '/map/alerts';
  static const mapSummary = '/map/summary';
  static const mapFilters = '/map/filters';
  static const parseReport = '/reports/parse';
  static const publishReport = '/reports';
  static const myReports = '/reports/mine';
}
