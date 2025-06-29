// /lib/screens/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/screens/home_screen.dart';
import 'package:sora_app/screens/signin_screen.dart';
import 'dart:ui'; // Import for ImageFilter
import 'dart:math'; // Import for random

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
  bool _isPasswordVisible = false; // New state for password visibility
  bool _isConfirmPasswordVisible = false; // New state for confirm password visibility

  late AnimationController _cardAnimationController; // For card fade/slide
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late AnimationController _backgroundAnimationController; // For background color animation
  late Animation<Color?> _startColorAnimation;
  late Animation<Color?> _endColorAnimation;

  late AnimationController _iconAnimationController; // For icon dancing animation
  late Animation<double> _iconAnimation;

  List<_HouseIconData> _houseIcons = []; // List to hold data for house icons

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
      duration: const Duration(seconds: 4), // Total duration for background animation
    );

    // Define the sequence for the start color of the gradient
    // Starts with grey, transitions to blue, and then holds blue
    _startColorAnimation = TweenSequence<Color?>(
      [
        TweenSequenceItem(tween: ColorTween(begin: Colors.grey, end: const Color(0xFF1E90FF)), weight: 0.5), // Grey to Blue
        TweenSequenceItem(tween: ColorTween(begin: const Color(0xFF1E90FF), end: const Color(0xFF1E90FF)), weight: 0.5), // Hold Blue
      ],
    ).animate(_backgroundAnimationController);

    // Define the sequence for the end color of the gradient
    // Starts with grey, transitions to blue, and then to purple
    _endColorAnimation = TweenSequence<Color?>(
      [
        TweenSequenceItem(tween: ColorTween(begin: Colors.grey, end: const Color(0xFF1E90FF)), weight: 0.5), // Grey to Blue (synchronized with start)
        TweenSequenceItem(tween: ColorTween(begin: const Color(0xFF1E90FF), end: const Color(0xFF4B0082)), weight: 0.5), // Blue to Purple
      ],
    ).animate(_backgroundAnimationController);

    // Start the background color animation
    _backgroundAnimationController.forward();

    // Icon dancing animation
    _iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Adjust speed as needed for dancing
    )..repeat(); // Make it repeat continuously

    _iconAnimation = CurvedAnimation(
      parent: _iconAnimationController,
      curve: Curves.easeInOutSine, // Smooth back-and-forth movement
    );

    // Generate house icons after the layout is known (to get screen size)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _generateHouseIcons(context.size!);
        _iconAnimationController.forward(from: 0.0); // Start the icon animation
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cardAnimationController.dispose();
    _backgroundAnimationController.dispose(); // Dispose background color controller
    _iconAnimationController.dispose(); // Dispose icon animation controller
    super.dispose();
  }

  // Generates a list of random house icon data
  void _generateHouseIcons(Size screenSize) {
    final Random random = Random();
    final List<_HouseIconData> generatedIcons = [];
    // Adjust the number of icons based on screen area to maintain density
    final int numberOfIcons = (screenSize.width * screenSize.height / 15000).toInt().clamp(20, 50);

    for (int i = 0; i < numberOfIcons; i++) {
      generatedIcons.add(_HouseIconData(
        initialPosition: Offset(
          random.nextDouble() * screenSize.width,
          random.nextDouble() * screenSize.height,
        ),
        size: 20.0 + random.nextDouble() * 30.0, // Size between 20 and 50
        rotationAngle: random.nextDouble() * 2 * pi, // 0 to 360 degrees in radians
        color: Colors.white.withOpacity(0.15 + random.nextDouble() * 0.35), // Opacity between 0.15 and 0.50
        animationMagnitude: 5.0 + random.nextDouble() * 10.0, // Moves 5 to 15 pixels
        animationAngle: random.nextDouble() * 2 * pi, // Random direction for each icon
      ));
    }

    setState(() {
      _houseIcons = generatedIcons;
    });
  }

  // Handles the sign-up process, showing loading state and error messages.
  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous error messages
    });

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
        _isLoading = false;
      });
      return; // Stop the sign-up process
    }

    try {
      await widget.authService.signUpWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );
      // On successful sign-up, navigate to HomeScreen and remove all previous routes
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (Route<dynamic> route) => false);
      }
    } on FirebaseAuthException catch (e) {
      // Set specific error messages for FirebaseAuthException
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      // Set a generic error message for other exceptions
      setState(() {
        _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      });
    } finally {
      // Ensure loading state is reset even if an error occurs
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent resize when keyboard appears
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
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Adjust blur strength
              child: Container(
                color: Colors.black.withOpacity(0.3), // Darken the blurred background
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
      color: Colors.white.withOpacity(0.15), // Very light transparent background
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Stronger blur for the card
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2), // Top-left light
                  Colors.white.withOpacity(0.05), // Bottom-right darker
                ],
              ),
              borderRadius: BorderRadius.circular(30.0),
              border: Border.all(color: Colors.white.withOpacity(0.2)), // Light transparent border
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
                      color: Colors.white, // White text for contrast
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Join Sora to find your dream property',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8), // Slightly transparent white
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
                    obscureText: !_isPasswordVisible, // Use the state variable here
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible; // Toggle visibility
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    _confirmPasswordController,
                    'Confirm Password',
                    Icons.lock,
                    obscureText: !_isConfirmPasswordVisible, // Use the state variable here
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible; // Toggle visibility
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
                    onPressed: _isLoading ? null : _signUp, // Disable button during loading
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA78BFA), // Purple shade
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      minimumSize: const Size(double.infinity, 50), // Full width button
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
                        color: Colors.white.withOpacity(0.8), // Slightly transparent white
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
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text, Widget? suffixIcon}) { // Added suffixIcon parameter
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1), // Very light transparent background for input
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(color: Colors.white.withOpacity(0.1)), // Light transparent border
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
        style: const TextStyle(color: Colors.white), // Text color inside the field
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)), // Label text color
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.8)), // Icon color
          suffixIcon: suffixIcon, // Assign the suffixIcon here
          border: InputBorder.none, // Remove default border
          contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
          enabledBorder: OutlineInputBorder( // Border when enabled (but not focused)
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none, // No visible border here, relies on container's border
          ),
          focusedBorder: OutlineInputBorder( // Border when focused
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide(color: Color(0xFFA78BFA), width: 2), // Purple shade for focus
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never, // Label always acts as hint
        ),
        keyboardType: keyboardType,
      ),
    );
  }
}

// Data class to hold properties for each house icon
class _HouseIconData {
  final Offset initialPosition; // Store the original fixed position
  final double size;
  final double rotationAngle; // In radians
  final Color color;
  final double animationMagnitude; // How far it moves
  final double animationAngle; // Direction of movement for this specific icon

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
  final Animation<double> animation; // The animation object

  _HouseIconsPainter(this.icons, this.animation) : super(repaint: animation); // Repaint when animation changes

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    final double animationValue = animation.value; // Get current animation value (0.0 to 1.0)

    for (var iconData in icons) {
      canvas.save(); // Save the current canvas state

      // Calculate the displacement based on animation value, magnitude, and angle
      // Using sin/cos for smooth back-and-forth motion,
      // and adding a unique phase to each icon's animation (animationAngle)
      final double dx = iconData.animationMagnitude * sin(animationValue * 2 * pi + iconData.animationAngle);
      final double dy = iconData.animationMagnitude * cos(animationValue * 2 * pi + iconData.animationAngle);

      // Calculate the current position
      final Offset currentPosition = Offset(
        iconData.initialPosition.dx + dx,
        iconData.initialPosition.dy + dy,
      );

      // Move the canvas origin to the icon's current position
      canvas.translate(currentPosition.dx, currentPosition.dy);
      // Rotate the canvas around the new origin
      canvas.rotate(iconData.rotationAngle);

      paint.color = iconData.color; // Set icon color and opacity

      // Draw a simple house shape (rectangle for body, triangle for roof)
      final double halfSize = iconData.size / 2;
      final double bodyHeight = iconData.size * 0.6;
      final double roofHeight = iconData.size * 0.4;

      // House body (centered at the new origin)
      canvas.drawRect(
        Rect.fromLTRB(-halfSize, -bodyHeight / 2, halfSize, bodyHeight / 2),
        paint,
      );

      // House roof (triangle on top of the body)
      final Path roofPath = Path();
      roofPath.moveTo(-halfSize, -bodyHeight / 2); // Top-left corner of body
      roofPath.lineTo(halfSize, -bodyHeight / 2); // Top-right corner of body
      roofPath.lineTo(0, -bodyHeight / 2 - roofHeight); // Apex of the roof
      roofPath.close(); // Close the path to form a triangle
      canvas.drawPath(roofPath, paint);

      canvas.restore(); // Restore the canvas to its previous state
    }
  }

  @override
  bool shouldRepaint(covariant _HouseIconsPainter oldDelegate) {
    // Only repaint if the animation object or the list of icons changes.
    // The `repaint: animation` in the constructor already handles animation value changes.
    return oldDelegate.animation != animation || oldDelegate.icons != icons;
  }
}
