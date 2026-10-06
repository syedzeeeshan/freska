import 'package:flutter/material.dart';

class FreskaL10n {
  final Locale locale;

  FreskaL10n(this.locale);

  static FreskaL10n of(BuildContext context) {
    return Localizations.of<FreskaL10n>(context, FreskaL10n) ??
        FreskaL10n(const Locale('en'));
  }

  static const LocalizationsDelegate<FreskaL10n> delegate =
      _FreskaL10nDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Freska Rider',
      'login_title': 'Partner Login',
      'login_subtitle': 'Enter your registered mobile number to continue',
      'phone_hint': 'Mobile number',
      'send_otp': 'Send OTP',
      'otp_verification': 'OTP Verification',
      'otp_subtitle': 'We have sent a 6-digit verification code to',
      'resend_in': 'Resend code in',
      'resend_now': 'Resend OTP',
      'verify_and_proceed': 'Verify & Proceed',
      'invalid_phone': 'Please enter a valid 10-digit mobile number',
      'invalid_otp': 'Please enter a valid 6-digit OTP code',
      'offline_banner': 'You are currently offline. Check network connection.',
      'loading': 'Please wait...',
      'error_title': 'Something went wrong',
      'retry': 'Retry',
    },
    'hi': {
      'app_name': 'फ़्रेस्का राइडर',
      'login_title': 'पार्टनर लॉगिन',
      'login_subtitle': 'आगे बढ़ने के लिए अपना मोबाइल नंबर दर्ज करें',
      'phone_hint': 'मोबाइल नंबर',
      'send_otp': 'ओटीपी भेजें',
      'otp_verification': 'ओटीपी सत्यापन',
      'otp_subtitle': 'हमने इस नंबर पर 6-अंकों का कोड भेजा है',
      'resend_in': 'पुनः भेजें',
      'resend_now': 'ओटीपी पुनः भेजें',
      'verify_and_proceed': 'सत्यापित करें और आगे बढ़ें',
      'invalid_phone': 'कृपया मान्य 10-अंकों का मोबाइल नंबर दर्ज करें',
      'invalid_otp': 'कृपया मान्य 6-अंकों का ओटीपी दर्ज करें',
      'offline_banner': 'आप ऑफ़लाइन हैं। नेटवर्क कनेक्शन की जाँच करें।',
      'loading': 'कृपया प्रतीक्षा करें...',
      'error_title': 'कुछ गलत हो गया',
      'retry': 'पुनः प्रयास करें',
    },
    'kn': {
      'app_name': 'ಫ್ರೆಸ್ಕಾ ರೈಡರ್',
      'login_title': 'ಪಾಲುದಾರ ಲಾಗಿನ್',
      'login_subtitle': 'ಮುಂದುವರಿಯಲು ನಿಮ್ಮ ಮೊಬೈಲ್ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ',
      'phone_hint': 'ಮೊಬೈಲ್ ಸಂಖ್ಯೆ',
      'send_otp': 'ಒಟಿಪಿ ಕಳುಹಿಸಿ',
      'otp_verification': 'ಒಟಿಪಿ ಪರಿಶೀಲನೆ',
      'otp_subtitle': 'ನಾವು 6-ಅಂಕಿಯ ಪರಿಶೀಲನಾ ಕೋಡ್ ಅನ್ನು ಕಳುಹಿಸಿದ್ದೇವೆ',
      'resend_in': 'ಮತ್ತೆ ಕಳುಹಿಸಿ',
      'resend_now': 'ಒಟಿಪಿ ಮತ್ತೆ ಕಳುಹಿಸಿ',
      'verify_and_proceed': 'ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಮುಂದುವರಿಯಿರಿ',
      'invalid_phone': 'ದಯವಿಟ್ಟು ಮಾನ್ಯ ಮೊಬೈಲ್ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ',
      'invalid_otp': 'ದಯವಿಟ್ಟು ಮಾನ್ಯ 6-ಅಂಕಿಯ ಒಟಿಪಿ ನಮೂದಿಸಿ',
      'offline_banner': 'ನೀವು ಆಫ್‌ಲೈನ್‌ನಲ್ಲಿದ್ದೀರಿ. ನೆಟ್‌ವರ್ಕ್ ಪರಿಶೀಲಿಸಿ.',
      'loading': 'ದಯವಿಟ್ಟು ನಿರೀಕ್ಷಿಸಿ...',
      'error_title': 'ಏನೋ ತಪ್ಪಾಗಿದೆ',
      'retry': 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  String get appName => get('app_name');
  String get loginTitle => get('login_title');
  String get loginSubtitle => get('login_subtitle');
  String get phoneHint => get('phone_hint');
  String get sendOtp => get('send_otp');
  String get otpVerification => get('otp_verification');
  String get otpSubtitle => get('otp_subtitle');
  String get resendIn => get('resend_in');
  String get resendNow => get('resend_now');
  String get verifyAndProceed => get('verify_and_proceed');
  String get invalidPhone => get('invalid_phone');
  String get invalidOtp => get('invalid_otp');
  String get offlineBanner => get('offline_banner');
  String get loading => get('loading');
  String get errorTitle => get('error_title');
  String get retry => get('retry');
}

class _FreskaL10nDelegate extends LocalizationsDelegate<FreskaL10n> {
  const _FreskaL10nDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'hi', 'kn'].contains(locale.languageCode);

  @override
  Future<FreskaL10n> load(Locale locale) async => FreskaL10n(locale);

  @override
  bool shouldReload(_FreskaL10nDelegate old) => false;
}
