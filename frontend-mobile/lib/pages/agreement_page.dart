import 'dart:ui';
import 'package:flutter/material.dart';

class AgreementPage extends StatefulWidget {
  const AgreementPage({super.key});

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  bool _accepted = false;
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (!_hasScrolledToBottom) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final current = _scrollController.offset;
        if (current >= maxScroll - 80) {
          setState(() => _hasScrolledToBottom = true);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFFDF0E7),
          ),

          Positioned.fill(
            child: Stack(
              children: [
                Positioned(
                  top: size.height * 0.1,
                  left: size.width * 0.03,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFF05053).withOpacity(0.5),
                          const Color(0xFFF05053).withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: size.height * 0.1,
                  right: size.width * 0.05,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFF05053).withOpacity(0.4),
                          const Color(0xFFF05053).withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Container(color: Colors.transparent),
                ),
              ],
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context, false),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 16, color: Color(0xFF555555)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Terms & Agreement',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ),

                // Logo outside box
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Image.asset('assets/images/logo.png', height: 70),
                ),

                // Agreement content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Center(
                                child: Text(
                                  'JaiBaan Terms of Service',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF05053),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Center(
                                child: Text(
                                  'Effective date: January 1, 2025',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              _buildSection(
                                '1. Acceptance of Terms',
                                'By registering and using the JaiBaan application ("App"), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not register or use the App. JaiBaan reserves the right to update these terms at any time, and continued use of the App constitutes your acceptance of any changes.',
                              ),

                              _buildSection(
                                '2. Eligibility',
                                'The App is intended for use by residents, juristic persons, and authorized personnel of residential communities that have adopted the JaiBaan platform. You must be at least 18 years of age and a verified resident or authorized representative to create an account. Accounts are non-transferable.',
                              ),

                              _buildSection(
                                '3. Account Responsibility',
                                'You are responsible for maintaining the confidentiality of your username and password. You agree to notify the juristic office immediately of any unauthorized use of your account. JaiBaan and the building management are not liable for any loss or damage arising from your failure to safeguard your login credentials.',
                              ),

                              _buildSection(
                                '4. Use of the Application',
                                'The App is provided to facilitate community management services including parcel tracking, facility booking, financial statements, and announcements. You agree to use the App only for lawful purposes and in a manner consistent with these terms. You must not misuse, reverse-engineer, or attempt to gain unauthorized access to any part of the App or its infrastructure.',
                              ),

                              _buildSection(
                                '5. Personal Data & Privacy',
                                'JaiBaan collects and processes personal data including your name, phone number, room number, and usage data to operate the App. Your data is handled in accordance with our Privacy Policy and applicable data protection laws. We do not sell your personal data to third parties. By registering, you consent to the collection and use of your data as described in our Privacy Policy.',
                              ),

                              _buildSection(
                                '6. Facility Booking',
                                'Facility bookings made through the App are subject to the rules and regulations set by the building management. Cancellations must be made within the specified timeframe. Repeated no-shows or violations of facility rules may result in suspension of booking privileges.',
                              ),

                              _buildSection(
                                '7. Financial Information',
                                'Financial statements and payment information displayed in the App are provided for informational purposes. The building management is responsible for the accuracy of all financial records. Disputes regarding charges should be directed to the juristic office.',
                              ),

                              _buildSection(
                                '8. Notifications & Announcements',
                                'By using the App, you consent to receiving push notifications and announcements from the building management. You may manage notification preferences within the App settings. Critical safety or maintenance notifications may not be disabled.',
                              ),

                              _buildSection(
                                '9. Limitation of Liability',
                                'JaiBaan and the building management shall not be liable for any indirect, incidental, or consequential damages arising from your use of the App. The App is provided "as is" without warranties of any kind. Service availability may be affected by maintenance or technical issues beyond our control.',
                              ),

                              _buildSection(
                                '10. Termination',
                                'Your account may be suspended or terminated by the building management if you violate these terms or vacate the premises. Upon termination, your access to the App and its services will be revoked. You may also request deletion of your account by contacting the juristic office.',
                              ),

                              _buildSection(
                                '11. Governing Law',
                                'These Terms of Service are governed by the laws of the Kingdom of Thailand. Any disputes arising under or in connection with these terms shall be subject to the exclusive jurisdiction of the courts of Thailand.',
                              ),

                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3F3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFF05053).withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  'By ticking the checkbox below, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service and our Privacy Policy.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                    fontStyle: FontStyle.italic,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              if (!_hasScrolledToBottom)
                                Center(
                                  child: Text(
                                    'Scroll down to read the full agreement',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[400],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom accept area
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    children: [
                      // Checkbox row
                      GestureDetector(
                        onTap: _hasScrolledToBottom
                            ? () => setState(() => _accepted = !_accepted)
                            : null,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: Checkbox(
                                value: _accepted,
                                onChanged: _hasScrolledToBottom
                                    ? (v) => setState(() => _accepted = v ?? false)
                                    : null,
                                activeColor: const Color(0xFFF05053),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                side: BorderSide(
                                  color: _hasScrolledToBottom
                                      ? Colors.grey[400]!
                                      : Colors.grey[300]!,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'I have read and agree to the Terms of Service',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _hasScrolledToBottom
                                      ? const Color(0xFF333333)
                                      : Colors.grey[400],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Accept button
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: _accepted
                              ? const LinearGradient(
                                  colors: [Color(0xFFF9A082), Color(0xFFFF7B7B)],
                                )
                              : LinearGradient(
                                  colors: [Colors.grey[300]!, Colors.grey[300]!],
                                ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: _accepted
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFF9A082).withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ]
                              : [],
                        ),
                        child: ElevatedButton(
                          onPressed: _accepted ? () => Navigator.pop(context, true) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            disabledBackgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Accept & Continue',
                            style: TextStyle(
                              color: _accepted ? Colors.white : Colors.grey[500],
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
