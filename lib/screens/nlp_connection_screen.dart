import 'package:flutter/material.dart';

import '../services/nlp_connection_service.dart';
import '../widgets/app_logo.dart';

class NlpConnectionScreen extends StatefulWidget {
  final Widget nextScreen;

  const NlpConnectionScreen({
    super.key,
    required this.nextScreen,
  });

  @override
  State<NlpConnectionScreen> createState() => _NlpConnectionScreenState();
}

class _NlpConnectionScreenState extends State<NlpConnectionScreen> {
  final ipController = TextEditingController();

  bool isChecking = false;
  String? errorMessage;

  Future<void> connect() async {
    FocusScope.of(context).unfocus();

    final ip = ipController.text.trim();

    if (!NlpConnectionService.isValidIpv4(ip)) {
      setState(() {
        errorMessage = 'أدخل عنوان IPv4 صحيح، مثال: 192.168.1.25';
      });
      return;
    }

    setState(() {
      isChecking = true;
      errorMessage = null;
    });

    final success = await NlpConnectionService.connect(ip);

    if (!mounted) return;

    if (!success) {
      setState(() {
        isChecking = false;
        errorMessage =
            'تعذر الاتصال. تأكد أن الهاتف والكمبيوتر على نفس الشبكة وأن خدمة NLP تعمل على المنفذ 8000.';
      });
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => widget.nextScreen,
      ),
    );
  }

  @override
  void dispose() {
    ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 32,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppLogo(size: 105),
                    const SizedBox(height: 28),
                    Text(
                      'الاتصال بخدمة التحليل',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'أدخل IPv4 الظاهر في الكمبيوتر بعد تشغيل ipconfig',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 26),
                    TextField(
                      controller: ipController,
                      enabled: !isChecking,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'IPv4',
                        hintText: '192.168.1.25',
                        prefixIcon: Icon(Icons.computer_rounded),
                      ),
                      onSubmitted: (_) {
                        if (!isChecking) connect();
                      },
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.18),
                          ),
                        ),
                        child: Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: isChecking ? null : connect,
                        icon: isChecking
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.link_rounded),
                        label: Text(
                          isChecking ? 'جاري اختبار الاتصال...' : 'اتصال',
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'المنفذ المستخدم: 8000',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
