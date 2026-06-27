class ApiEndpoints {
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const refresh = '/auth/refresh';
  static const logout = '/auth/logout';
  static const me = '/auth/me';
  static const profileMe = '/profiles/me';
  static const profilePhoneSend = '/profiles/me/phone/send-code';
  static const profilePhoneVerify = '/profiles/me/phone/verify';

  static const myPosts = '/posts/me';
  static String userPosts(String userId) => '/posts/user/$userId';

  static const chatbotAsk = '/chatbot/ask';
  static const chatbotTranscribe = '/chatbot/transcribe';

  static const mapAlerts = '/map/alerts';
  static const mapPublications = '/map/publications';
  static const mapSummary = '/map/summary';
  static const mapFilters = '/map/filters';
  static const newsTodayMap = '/news/today/map';
  static const parseReport = '/reports/parse';
  static const parseReportWithImages = '/reports/parse-with-images';
  static const analyzeReport = '/reports/analyze';
  static const publishReport = '/reports';
  static const myReports = '/reports/mine';
  static const reportCandidates = '/report-candidates';
  static const generateCitizenReport = '/reports/generate';

  static String reportCandidateFromPost(String postId) =>
      '/report-candidates/from-post/$postId';

  static String postById(String postId) => '/posts/$postId';

  static String postComments(String postId) => '/posts/$postId/comments';

  static String reportCandidateStatus(String id) =>
      '/report-candidates/$id/status';
}
