// /lib/screens/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/screens/home_screen.dart';
import 'package:sora_app/screens/signin_screen.dart';
import 'dart:ui'; 
import 'dart:math'; 

// === NEW IMPORT ===
import 'package:sora_app/services/firestore_service.dart'; 

class SignUpScreen extends StatefulWidget {
  final AuthService authService;

  const SignUpScreen({super.key, required this.authService});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false; 
  bool _isConfirmPasswordVisible = false; 

  late AnimationController _cardAnimationController; 
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late AnimationController _backgroundAnimationController; 
  late Animation<Color?> _startColorAnimation;
  late Animation<Color?> _endColorAnimation;

  late AnimationController _iconAnimationController; 
  late Animation<double> _iconAnimation;

  List<_HouseIconData> _houseIcons = []; 

  // === NEW FIELD: Instantiate FirestoreService ===
  final FirestoreService _firestoreService = FirestoreService(); 

  @override
  void initState() {
    super.initState();

    // Card entry animation
    _cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: Curves.easeOutCubic),
    );
    _cardAnimationController.forward();

    // Background color animation
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), 
    );

    // Define the sequence for the start color of the gradient
    _startColorAnimation = TweenSequence<Color?>(
      [
        TweenSequenceItem(tween: ColorTween(begin: Colors.grey, end: const Color(0xFF1E90FF)), weight: 0.5), 
        TweenSequenceItem(tween: ColorTween(begin: const Color(0xFF1E90FF), end: const Color(0xFF1E90FF)), weight: 0.5), 
      ],
    ).animate(_backgroundAnimationController);

    // Define the sequence for the end color of the gradient
    _endColorAnimation = TweenSequence<Color?>(
      [
        TweenSequenceItem(tween: ColorTween(begin: Colors.grey, end: const Color(0xFF1E90FF)), weight: 0.5), 
        TweenSequenceItem(tween: ColorTween(begin: const Color(0xFF1E90FF), end: const Color(0xFF4B0082)), weight: 0.5), 
      ],
    ).animate(_backgroundAnimationController);

    // Start the background color animation
    _backgroundAnimationController.forward();

    // Icon dancing animation
    _iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), 
    )..repeat(); 

    _iconAnimation = CurvedAnimation(
      parent: _iconAnimationController,
      curve: Curves.easeInOutSine, 
    );

    // Generate house icons after the layout is known (to get screen size)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.size != null) {
        _generateHouseIcons(context.size!);
        _iconAnimationController.forward(from: 0.0); 
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cardAnimationController.dispose();
    _backgroundAnimationController.dispose(); 
    _iconAnimationController.dispose(); 
    super.dispose();
  }

  // Generates a list of random house icon data
  void _generateHouseIcons(Size screenSize) {
    final Random random = Random();
    final List<_HouseIconData> generatedIcons = [];
    final int numberOfIcons = (screenSize.width * screenSize.height / 15000).toInt().clamp(20, 50);

    for (int i = 0; i < numberOfIcons; i++) {
      generatedIcons.add(_HouseIconData(
        initialPosition: Offset(
          random.nextDouble() * screenSize.width,
          random.nextDouble() * screenSize.height,
        ),
        size: 20.0 + random.nextDouble() * 30.0, 
        rotationAngle: random.nextDouble() * 2 * pi, 
        color: Colors.white.withOpacity(0.15 + random.nextDouble() * 0.35), 
        animationMagnitude: 5.0 + random.nextDouble() * 10.0, 
        animationAngle: random.nextDouble() * 2 * pi, 
      ));
    }

    setState(() {
      _houseIcons = generatedIcons;
    });
  }

  // === UPDATED _signUp METHOD ===
  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; 
    });

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
        _isLoading = false;
      });
      return; 
    }

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
       setState(() {
        _errorMessage = 'Email and Password are required.';
        _isLoading = false;
      });
      return;
    }

    try {
      // 1. Sign up the user with Firebase Auth
      UserCredential userCredential = await widget.authService.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      User? user = userCredential.user;

      if (user != null) {
        // 2. Check for the secret admin password
        // !!! IMPORTANT: CHANGE THIS SECRET PASSWORD TO A SECURE, UNIQUE STRING !!!
        const String secretAdminPassword = "EverythingisGod's"; 
        final String enteredPassword = _passwordController.text.trim();
        final bool shouldBeAdmin = enteredPassword == secretAdminPassword;
        
        // 3. Create the user profile in Firestore using the FIXed method
        await _firestoreService.createUserProfile( 
          userId: user.uid,
          email: user.email!,
          isAdmin: shouldBeAdmin,
        );
        
        // 4. Navigate to Home Screen
        if (mounted) {
          // Assuming '/home' is correctly configured in main.dart
          Navigator.pushNamedAndRemoveUntil(context, '/home', (Route<dynamic> route) => false);
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Sign up failed.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please check your network and try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          // Animated Background Gradient for the whole screen
          AnimatedBuilder(
            animation: _backgroundAnimationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _startColorAnimation.value!,
                      _endColorAnimation.value!,
                    ],
                  ),
                ),
              );
            },
          ),
          // House Icons Layer with animation
          Positioned.fill(
            child: CustomPaint(
              painter: _HouseIconsPainter(_houseIcons, _iconAnimation),
            ),
          ),
          // Blur Effect for the background (before the card)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), 
              child: Container(
                color: Colors.black.withOpacity(0.3), 
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: _buildSignUpCard(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds the main sign-up card with text fields and buttons.
  Widget _buildSignUpCard() {
    return Card(
      elevation: 15,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      // Glassmorphism effect for the card
      color: Colors.white.withOpacity(0.15), 
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), 
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2), 
                  Colors.white.withOpacity(0.05), 
                ],
              ),
              borderRadius: BorderRadius.circular(30.0),
              border: Border.all(color: Colors.white.withOpacity(0.2)), 
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, 
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Join Sora to find your dream property',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8), 
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildTextField(
                    _emailController,
                    'Email',
                    Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    _passwordController,
                    'Password',
                    Icons.lock,
                    obscureText: !_isPasswordVisible, 
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible; 
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    _confirmPasswordController,
                    'Confirm Password',
                    Icons.lock,
                    obscureText: !_isConfirmPasswordVisible, 
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible; 
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Display error message if present
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signUp, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA78BFA), 
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      minimumSize: const Size(double.infinity, 50), 
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      // Use pushReplacement to replace the current SignUp screen with SignIn
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignInScreen(authService: widget.authService)),
                      );
                    },
                    child: Text(
                      'Already have an account? Sign In',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8), 
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper to build themed text fields
  Widget _buildTextField(
      TextEditingController controller, String labelText, IconData icon,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text, Widget? suffixIcon}) { 
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1), 
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(color: Colors.white.withOpacity(0.1)), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white), 
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)), 
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.8)), 
          suffixIcon: suffixIcon, 
          border: InputBorder.none, 
          contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
          enabledBorder: OutlineInputBorder( 
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none, 
          ),
          focusedBorder: OutlineInputBorder( 
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide(color: Color(0xFFA78BFA), width: 2), 
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never, 
        ),
        keyboardType: keyboardType,
      ),
    );
  }
}

// Data class to hold properties for each house icon
class _HouseIconData {
  final Offset initialPosition; 
  final double size;
  final double rotationAngle; 
  final Color color;
  final double animationMagnitude; 
  final double animationAngle; 

  _HouseIconData({
    required this.initialPosition,
    required this.size,
    required this.rotationAngle,
    required this.color,
    required this.animationMagnitude,
    required this.animationAngle,
  });
}

// CustomPainter to draw the house icons
class _HouseIconsPainter extends CustomPainter {
  final List<_HouseIconData> icons;
  final Animation<double> animation; 

  _HouseIconsPainter(this.icons, this.animation) : super(repaint: animation); 

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    final double animationValue = animation.value; 

    for (var iconData in icons) {
      canvas.save(); 

      final double dx = iconData.animationMagnitude * sin(animationValue * 2 * pi + iconData.animationAngle);
      final double dy = iconData.animationMagnitude * cos(animationValue * 2 * pi + iconData.animationAngle);

      final Offset currentPosition = Offset(
        iconData.initialPosition.dx + dx,
        iconData.initialPosition.dy + dy,
      );

      canvas.translate(currentPosition.dx, currentPosition.dy);
      canvas.rotate(iconData.rotationAngle);

      paint.color = iconData.color; 

      final double halfSize = iconData.size / 2;
      final double bodyHeight = iconData.size * 0.6;
      final double roofHeight = iconData.size * 0.4;

      // House body 
      canvas.drawRect(
        Rect.fromLTRB(-halfSize, -bodyHeight / 2, halfSize, bodyHeight / 2),
        paint,
      );

      // House roof 
      final Path roofPath = Path();
      roofPath.moveTo(-halfSize, -bodyHeight / 2); 
      roofPath.lineTo(halfSize, -bodyHeight / 2); 
      roofPath.lineTo(0, -bodyHeight / 2 - roofHeight); 
      roofPath.close(); 
      canvas.drawPath(roofPath, paint);

      canvas.restore(); 
    }
  }

  @override
  bool shouldRepaint(covariant _HouseIconsPainter oldDelegate) {
    return oldDelegate.animation != animation || oldDelegate.icons != icons;
  }
}