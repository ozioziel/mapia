class OtpService {
  OtpService();

  static const String developmentCode = '123456';
  static DateTime? _expiresAt;
  static String? _phone;
  static int _attempts = 0;

  Future<void> sendCode(String phone) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    _phone = phone.trim();
    _expiresAt = DateTime.now().add(const Duration(minutes: 5));
    _attempts = 0;
  }

  Future<bool> verifyCode({required String phone, required String code}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final expiresAt = _expiresAt;
    if (_phone != phone.trim() || expiresAt == null) return false;
    if (DateTime.now().isAfter(expiresAt)) return false;
    if (_attempts >= 5) return false;

    _attempts++;
    return code.trim() == developmentCode;
  }
}
