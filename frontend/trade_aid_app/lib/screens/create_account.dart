// lib/screens/create_account.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/social_auth_section.dart';

// ✅ Animated card widget (same as login screen)
class AnimatedCard extends StatefulWidget {
  final String message;
  final IconData? icon;
  const AnimatedCard({super.key, required this.message, this.icon});

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _offsetAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color.fromARGB(255, 17, 158, 144),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null)
                  Icon(
                    widget.icon,
                    color: const Color.fromARGB(255, 17, 158, 144),
                  ),
                if (widget.icon != null) const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(color: Colors.black),
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

// ✅ CreateAccountScreen
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  late AnimationController _animController;
  Animation<double>? _fadeAnim;
  Animation<Offset>? _slideAnim;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ✅ Show animated card
  void _showAnimatedCard(String message, {IconData? icon}) {
    final overlay = Overlay.of(context);

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50,
        left: 20,
        right: 20,
        child: AnimatedCard(message: message, icon: icon),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final email = v.trim();
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.trim().isEmpty) return 'Password is required';
    if (v.trim().length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirmPassword(String? v) {
    if (v != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _onNextPressed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null) {
        _showAnimatedCard("Account created successfully 🎉", icon: Icons.check);
        Navigator.pushNamed(context, '/create_profile');
      } else if (response.session == null) {
        _showAnimatedCard(
          "Check your email for verification link before logging in.",
          icon: Icons.info,
        );
      }
    } on AuthException catch (e) {
      _showAnimatedCard(e.message, icon: Icons.error);
    } catch (e) {
      _showAnimatedCard("Unexpected error occurred", icon: Icons.error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            height: 280,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 15, 119, 124),
                  Color.fromARGB(255, 17, 158, 144),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    Image.asset(
                      'assets/whitenamelogo.png',
                      height: 130,
                      width: 130,
                    ),
                    const SizedBox(height: 30),
                    FadeTransition(
                      opacity: _fadeAnim ?? const AlwaysStoppedAnimation(1.0),
                      child: SlideTransition(
                        position:
                            _slideAnim ??
                            Tween<Offset>(
                              begin: Offset.zero,
                              end: Offset.zero,
                            ).animate(_animController),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Create Account ✨",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                "Create your new account",
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 30),
                              _buildField(
                                controller: _emailController,
                                focusNode: _emailFocus,
                                label: "Email",
                                keyboard: TextInputType.emailAddress,
                                validator: _validateEmail,
                                onSubmit: () {
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(_passwordFocus);
                                },
                              ),
                              const SizedBox(height: 20),
                              _buildField(
                                controller: _passwordController,
                                focusNode: _passwordFocus,
                                label: "Password",
                                obscure: _obscurePassword,
                                validator: _validatePassword,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                onSubmit: () {
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(_confirmPasswordFocus);
                                },
                              ),
                              const SizedBox(height: 20),
                              _buildField(
                                controller: _confirmPasswordController,
                                focusNode: _confirmPasswordFocus,
                                label: "Confirm Password",
                                obscure: _obscureConfirmPassword,
                                validator: _validateConfirmPassword,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                                onSubmit: _onNextPressed,
                              ),
                              const SizedBox(height: 30),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _onNextPressed,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      17,
                                      158,
                                      144,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          "Next",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const SocialAuthSection(
                                title: "Or continue with",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
    VoidCallback? onSubmit,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      keyboardType: keyboard,
      validator: validator,
      textInputAction: onSubmit == null
          ? TextInputAction.next
          : TextInputAction.done,
      onFieldSubmitted: (_) => onSubmit?.call(),
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
