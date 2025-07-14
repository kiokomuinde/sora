// lib/screens/privacy_policy_screen.dart
import 'package:flutter/material.dart';
import 'package:sora_app/services/auth_service.dart'; // Import AuthService
import 'package:sora_app/widgets/common_widgets.dart'; // Import CommonWidgets

class PrivacyPolicyScreen extends StatefulWidget {
  final AuthService authService;

  const PrivacyPolicyScreen({super.key, required this.authService});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late CommonWidgets commonWidgets;

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonWidgets.buildAppBar(),
      endDrawer: commonWidgets.buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacy Policy',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Last updated: July 14, 2025',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'SORA Properties ("us", "we", or "our") operates the Sora mobile application and website (the "Service").\n\nThis page informs you of our policies regarding the collection, use, and disclosure of personal data when you use our Service and the choices you have associated with that data.\n\nWe use your data to provide and improve the Service. By using the Service, you agree to the collection and use of information in accordance with this policy.',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  _buildPolicySection(
                    context,
                    'Information Collection and Use',
                    'We collect several different types of information for various purposes to provide and improve our Service to you.',
                  ),
                  _buildPolicySubsection(
                    context,
                    'Types of Data Collected',
                    [
                      '**Personal Data:** While using our Service, we may ask you to provide us with certain personally identifiable information that can be used to contact or identify you ("Personal Data"). Personally identifiable information may include, but is not limited to: Email address, First name and last name, Phone number, Address, State, Province, ZIP/Postal code, City, Cookies and Usage Data.',
                      '**Usage Data:** We may also collect information how the Service is accessed and used ("Usage Data"). This Usage Data may include information such as your computer\'s Internet Protocol address (e.g. IP address), browser type, browser version, the pages of our Service that you visit, the time and date of your visit, the time spent on those pages, unique device identifiers and other diagnostic data.',
                    ],
                  ),
                  _buildPolicySection(
                    context,
                    'Use of Data',
                    'SORA Properties uses the collected data for various purposes:',
                  ),
                  _buildPolicyList(
                    context,
                    [
                      'To provide and maintain the Service',
                      'To notify you about changes to our Service',
                      'To allow you to participate in interactive features of our Service when you choose to do so',
                      'To provide customer care and support',
                      'To provide analysis or valuable information so that we can improve the Service',
                      'To monitor the usage of the Service',
                      'To detect, prevent and address technical issues',
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildPolicySection(
                    context,
                    'Disclosure Of Data',
                    'We may disclose your Personal Data in the good faith belief that such action is necessary to:',
                  ),
                  _buildPolicyList(
                    context,
                    [
                      'To comply with a legal obligation',
                      'To protect and defend the rights or property of SORA Properties',
                      'To prevent or investigate possible wrongdoing in connection with the Service',
                      'To protect the personal safety of users of the Service or the public',
                      'To protect against legal liability',
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildPolicySection(
                    context,
                    'Security Of Data',
                    'The security of your data is important to us, but remember that no method of transmission over the Internet, or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your Personal Data, we cannot guarantee its absolute security.',
                  ),
                  const SizedBox(height: 20),
                  _buildPolicySection(
                    context,
                    'Service Providers',
                    'We may employ third party companies and individuals to facilitate our Service ("Service Providers"), to provide the Service on our behalf, to perform Service-related services or to assist us in analyzing how our Service is used.',
                  ),
                  const SizedBox(height: 20),
                  _buildPolicySection(
                    context,
                    'Links To Other Sites',
                    'Our Service may contain links to other sites that are not operated by us. If you click on a third party link, you will be directed to that third party\'s site. We strongly advise you to review the Privacy Policy of every site you visit.',
                  ),
                  const SizedBox(height: 20),
                  _buildPolicySection(
                    context,
                    'Changes To This Privacy Policy',
                    'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.',
                  ),
                  const SizedBox(height: 20),
                  _buildPolicySection(
                    context,
                    'Contact Us',
                    'If you have any questions about this Privacy Policy, please contact us:\n\n* By email: info@soraproperties.com\n* By visiting this page on our website: www.soraproperties.com/contact',
                  ),
                ],
              ),
            ),
            commonWidgets.buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildPolicySubsection(BuildContext context, String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        ...points.map((point) => Padding(
              padding: const EdgeInsets.only(left: 10.0, bottom: 5.0),
              child: Text(
                '• $point',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            )),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildPolicyList(BuildContext context, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) => Padding(
            padding: const EdgeInsets.only(left: 10.0, bottom: 5.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ],
            ),
          )).toList(),
    );
  }
}