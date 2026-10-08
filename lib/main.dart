import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'widgets/app_logo.dart';
import 'screens/nlp_connection_screen.dart';
// ============================================================
// 🎨 Fragrance Identity — Pink & Dark Purple Theme
// ============================================================

const Color backgroundColor = Color(0xFFFCF8FA);
const Color ivory = Color(0xFFFFFFFF);

// البنفسجي الغامق الأساسي
const Color espresso = Color(0xFF3F2945);

// البنفسجي الغامق المساعد
const Color warmBrown = Color(0xFF4B304F);

// البمبي الفاتح الأساسي
const Color champagne = Color(0xFFE6B6C8);

// بمبي أفتح للحدود والخلفيات
const Color softChampagne = Color(0xFFF1D5E0);

// بنفسجي رمادي للنصوص الثانوية
const Color taupe = Color(0xFF9A8297);

const Color secondaryText = Color(0xFF756574);

// خلفية بمبي خفيفة جدًا
const Color softBrown = Color(0xFFF5EAF0);

// خلفية بمبي ناعمة
const Color softRose = Color(0xFFF9EDF2);
// ============================================================
// Main
// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const FragranceIdentityApp());
}

// ============================================================
// التطبيق
// ============================================================

class FragranceIdentityApp extends StatelessWidget {
  const FragranceIdentityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fragrance Identity',

      theme: ThemeData(
        useMaterial3: true,

        scaffoldBackgroundColor: backgroundColor,

        colorScheme: ColorScheme.fromSeed(
          seedColor: warmBrown,
          primary: warmBrown,
          secondary: champagne,
          surface: backgroundColor,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundColor,
          foregroundColor: espresso,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: ivory,

          labelStyle: const TextStyle(
            color: secondaryText,
            fontSize: 13,
          ),

          hintStyle: const TextStyle(
            color: taupe,
            fontSize: 13,
          ),

          prefixIconColor: warmBrown,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 17,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: softChampagne.withOpacity(0.55),
              width: 1,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: warmBrown,
              width: 1.3,
            ),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: espresso,
            foregroundColor: Colors.white,
            disabledBackgroundColor: champagne,
            disabledForegroundColor: Colors.white,
            elevation: 0,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),

            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: warmBrown,
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),

      home: const AuthGate(),
    );
  }
}

// ============================================================
// AuthGate
// ============================================================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: backgroundColor,

            body: Center(
              child: CircularProgressIndicator(
                color: warmBrown,
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          return const HomePage();
        }

        return const LoginPage();
      },
    );
  }
}

// ============================================================
// صفحة تسجيل الدخول
// ============================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  // ==========================================================
  // تسجيل الدخول
  // ==========================================================

  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      showMessage(
        'يرجى إدخال البريد الإلكتروني وكلمة المرور',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'user-not-found':
          message = 'لا يوجد حساب بهذا البريد الإلكتروني';
          break;

        case 'wrong-password':
        case 'invalid-credential':
          message = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
          break;

        case 'invalid-email':
          message = 'البريد الإلكتروني غير صحيح';
          break;

        case 'too-many-requests':
          message = 'عدد المحاولات كبير، يرجى المحاولة لاحقًا';
          break;

        default:
          message = 'تعذر تسجيل الدخول، يرجى المحاولة مرة أخرى';
      }

      showMessage(message);
    } catch (e) {
      showMessage('حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ==========================================================
  // رسالة
  // ==========================================================

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: espresso,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ==========================================================
  // واجهة تسجيل الدخول
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              24,
              32,
              24,
              28,
            ),

            child: Column(
              children: [
                // ==================================================
                // الشعار
                // ==================================================

                Container(
                  width: 112,
                  height: 112,

                  padding: const EdgeInsets.all(10),

                  decoration: BoxDecoration(
                    color: ivory,
                    shape: BoxShape.circle,

                    border: Border.all(
                      color: softChampagne,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: champagne.withOpacity(0.22),
                        blurRadius: 24,
                        offset: const Offset(0, 9),
                      ),
                    ],
                  ),

                  child: const AppLogo(
                    size: 88,
                  ),
                ),

                const SizedBox(height: 24),

                // ==================================================
                // اسم التطبيق
                // ==================================================

                const Text(
                  'Fragrance Identity',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: espresso,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'هويتك العطرية تبدأ من ذوقك',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: warmBrown,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'اكتشف التفضيلات العطرية التي تعبّر عنك',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 34),

                // ==================================================
                // بطاقة تسجيل الدخول
                // ==================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: ivory,
                    borderRadius: BorderRadius.circular(25),

                    border: Border.all(
                      color: softChampagne,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: espresso.withOpacity(0.045),
                        blurRadius: 22,
                        offset: const Offset(0, 9),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'مرحبًا بعودتك',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: espresso,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),

                      const SizedBox(height: 5),

                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'سجّل الدخول للمتابعة إلى ملفك العطري',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 11.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // البريد
                      TextField(
                        controller: emailController,
                        keyboardType:
                        TextInputType.emailAddress,

                        textDirection: TextDirection.ltr,

                        decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // كلمة المرور
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,

                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',

                          prefixIcon: const Icon(
                            Icons.lock_outline,
                          ),

                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: warmBrown,
                            ),

                            onPressed: () {
                              setState(() {
                                obscurePassword =
                                !obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 5),

                      // نسيت كلمة المرور
                      Align(
                        alignment: Alignment.centerRight,

                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                const ForgotPasswordPage(),
                              ),
                            );
                          },

                          child: const Text(
                            'نسيت كلمة المرور؟',
                          ),
                        ),
                      ),

                      const SizedBox(height: 7),

                      // زر تسجيل الدخول
                      SizedBox(
                        width: double.infinity,
                        height: 54,

                        child: ElevatedButton(
                          onPressed:
                          isLoading ? null : login,

                          child: isLoading
                              ? const SizedBox(
                            width: 23,
                            height: 23,
                            child:
                            CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                              : const Text(
                            'تسجيل الدخول',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // إنشاء حساب
                // ==================================================

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [
                    const Text(
                      'لا يوجد حساب؟',
                      textDirection:
                      TextDirection.rtl,
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 12,
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const RegisterPage(),
                          ),
                        );
                      },

                      child: const Text(
                        'إنشاء حساب',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                const Text(
                  'Fragrance Identity  •  Personalized Profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: taupe,
                    fontSize: 8.5,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// إنشاء حساب
// ============================================================

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController =
  TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  // ==========================================================
  // إنشاء الحساب
  // ==========================================================

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword =
        confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      showMessage(
        'يرجى تعبئة جميع البيانات',
      );
      return;
    }

    if (password != confirmPassword) {
      showMessage(
        'كلمتا المرور غير متطابقتين',
      );
      return;
    }

    if (password.length < 6) {
      showMessage(
        'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);

      if (!mounted) return;

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message =
          'هذا البريد الإلكتروني مستخدم بالفعل';
          break;

        case 'invalid-email':
          message = 'البريد الإلكتروني غير صحيح';
          break;

        case 'weak-password':
          message = 'كلمة المرور ضعيفة';
          break;

        default:
          message =
          'تعذر إنشاء الحساب، يرجى المحاولة مرة أخرى';
      }

      showMessage(message);
    } catch (e) {
      showMessage(
        'حدث خطأ غير متوقع',
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: espresso,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  // ==========================================================
  // واجهة إنشاء الحساب
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: const Text(
          'إنشاء حساب',
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            24,
            12,
            24,
            30,
          ),

          child: Column(
            children: [
              // ==================================================
              // الشعار
              // ==================================================

              Container(
                width: 96,
                height: 96,
                padding: const EdgeInsets.all(8),

                decoration: BoxDecoration(
                  color: ivory,
                  shape: BoxShape.circle,

                  border: Border.all(
                    color: softChampagne,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: champagne.withOpacity(0.20),
                      blurRadius: 20,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),

                child: const AppLogo(
                  size: 76,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'أنشئ ملفك الشخصي',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: espresso,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'ابدأ رحلتك لاكتشاف هويتك العطرية',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // بطاقة البيانات
              // ==================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: ivory,
                  borderRadius: BorderRadius.circular(25),

                  border: Border.all(
                    color: softChampagne,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: espresso.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    // الاسم
                    TextField(
                      controller: nameController,

                      textDirection: TextDirection.rtl,

                      decoration: const InputDecoration(
                        labelText: 'الاسم',
                        prefixIcon: Icon(
                          Icons.person_outline,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // البريد
                    TextField(
                      controller: emailController,

                      keyboardType:
                      TextInputType.emailAddress,

                      textDirection: TextDirection.ltr,

                      decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // كلمة المرور
                    TextField(
                      controller: passwordController,

                      obscureText: obscurePassword,

                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',

                        prefixIcon: const Icon(
                          Icons.lock_outline,
                        ),

                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: warmBrown,
                          ),

                          onPressed: () {
                            setState(() {
                              obscurePassword =
                              !obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // تأكيد كلمة المرور
                    TextField(
                      controller:
                      confirmPasswordController,

                      obscureText:
                      obscureConfirmPassword,

                      decoration: InputDecoration(
                        labelText:
                        'تأكيد كلمة المرور',

                        prefixIcon: const Icon(
                          Icons.lock_reset_outlined,
                        ),

                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: warmBrown,
                          ),

                          onPressed: () {
                            setState(() {
                              obscureConfirmPassword =
                              !obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // زر إنشاء الحساب
                    SizedBox(
                      width: double.infinity,
                      height: 54,

                      child: ElevatedButton(
                        onPressed:
                        isLoading ? null : register,

                        child: isLoading
                            ? const SizedBox(
                          width: 23,
                          height: 23,
                          child:
                          CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                            : const Text(
                          'إنشاء الحساب',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'يمكن تعديل بياناتك وتفضيلاتك العطرية لاحقًا',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: taupe,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// نسيت كلمة المرور
// ============================================================

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();

  bool isLoading = false;

  // ==========================================================
  // إعادة تعيين كلمة المرور
  // ==========================================================

  Future<void> resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showMessage(
        'يرجى إدخال البريد الإلكتروني',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      showMessage(
        'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
      );
    } on FirebaseAuthException catch (e) {
      showMessage(
        e.message ??
            'تعذر إرسال رابط إعادة التعيين',
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: espresso,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  // ==========================================================
  // واجهة استعادة كلمة المرور
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: const Text(
          'استعادة كلمة المرور',
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Column(
              children: [
                // ==================================================
                // الشعار
                // ==================================================

                Container(
                  width: 108,
                  height: 108,
                  padding: const EdgeInsets.all(9),

                  decoration: BoxDecoration(
                    color: ivory,
                    shape: BoxShape.circle,

                    border: Border.all(
                      color: softChampagne,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: champagne.withOpacity(0.22),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),

                  child: const AppLogo(
                    size: 86,
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  'استعادة كلمة المرور',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: espresso,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'أدخل البريد الإلكتروني المرتبط بحسابك، '
                      'وسيتم إرسال رابط لإعادة تعيين كلمة المرور.',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 12,
                    height: 1.7,
                  ),
                ),

                const SizedBox(height: 25),

                // ==================================================
                // البطاقة
                // ==================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: ivory,
                    borderRadius:
                    BorderRadius.circular(25),

                    border: Border.all(
                      color: softChampagne,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: espresso.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      TextField(
                        controller: emailController,

                        keyboardType:
                        TextInputType.emailAddress,

                        textDirection:
                        TextDirection.ltr,

                        decoration:
                        const InputDecoration(
                          labelText:
                          'البريد الإلكتروني',

                          prefixIcon: Icon(
                            Icons.email_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 54,

                        child: ElevatedButton(
                          onPressed:
                          isLoading
                              ? null
                              : resetPassword,

                          child: isLoading
                              ? const SizedBox(
                            width: 23,
                            height: 23,
                            child:
                            CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                              : const Text(
                            'إرسال رابط الاستعادة',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                  ),

                  label: const Text(
                    'العودة إلى تسجيل الدخول',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}