import 'package:url_launcher/url_launcher.dart';

class UrlService {
  static Future<void> launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  // 회사 정보, 약관 등의 URL을 정의
  static final String companyInfoUrl = 'https://leetoreum.com/';
  static final String privacyPolicyUrl = 'https://leetoreum.com/privacy';
  static final String policyOfServiceUrl = 'https://leetoreum.com/policy';
}
