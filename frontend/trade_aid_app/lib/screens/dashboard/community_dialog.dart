import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';

/// PREMIUM COLOR CONSTANTS
const Color primaryTeal = Color(0xFF2E9499);
const Color secondaryTeal = Color(0xFF119E90);
const Color surfaceWhite = Color(0xFFFFFFFF);
const Color textPrimary = Color(0xFF121212);
const Color textSecondary = Color(0xFF5F6368);
const Color dark = Color(0xFF004D40);

/// App-wide gradient used for premium UI elements
const LinearGradient appGradient = LinearGradient(
  colors: [primaryTeal, secondaryTeal],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

/// COMMUNITY MODEL
class Community {
  final String name;
  final String description;
  final bool isCurrent; // trusted member (topmost community)
  final bool isMember;  // nearby community joined or not

  Community({
    required this.name,
    required this.description,
    this.isCurrent = false,
    this.isMember = false,
  });
}

/// COMMUNITY DIALOG
class CommunityDialog {
  static void show(BuildContext context, Community community) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'CommunityDetails',
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = Curves.elasticOut.transform(anim1.value);

        return Transform.scale(
          scale: curve,
          child: Opacity(
            opacity: anim1.value.clamp(0.0, 1.0),
            child: _buildDialog(context, community),
          ),
        );
      },
    );
  }

  static Widget _buildDialog(BuildContext context, Community community) {
    // Wrap with MediaQuery padding to move dialog above keyboard
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
                    decoration: BoxDecoration(
                      color: surfaceWhite.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Community Name
                          Text(
                            community.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: dark,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Body text / description / switch text
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: _getDialogBodyText(community),
                          ),

                          const SizedBox(height: 32),

                          // Footer buttons
                          _getDialogFooter(context, community),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Floating Premium Icon
            Positioned(
              top: -45,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    height: 85,
                    width: 85,
                    decoration: BoxDecoration(
                      gradient: appGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryTeal.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_city,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns the body text depending on scenario
  static Widget _getDialogBodyText(Community community) {
    if (community.isCurrent) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          'You belong to this community and are a trusted member.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: textSecondary,
            fontSize: 16,
            height: 1.5,
          ),
        ),
      );
    } else if (community.isMember) {
      return const Text(
        'Do you really want to switch to this community?',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textSecondary,
          fontSize: 16,
          height: 1.5,
        ),
      );
    } else {
      return Text(
        community.description,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: textSecondary,
          fontSize: 16,
          height: 1.5,
        ),
      );
    }
  }

  /// Returns footer buttons depending on scenario
  static Widget _getDialogFooter(BuildContext context, Community community) {
    if (community.isCurrent) {
      return _buildStatusBadge();
    } else if (community.isMember) {
      return _buildSwitchButtons(context, community);
    } else {
      return _buildJoinButtons(context, community);
    }
  }

  static Widget _buildStatusBadge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: primaryTeal.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryTeal.withOpacity(0.2)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_rounded, color: primaryTeal),
          SizedBox(width: 12),
          Text(
            'TRUSTED MEMBER',
            style: TextStyle(
              color: primaryTeal,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSwitchButtons(BuildContext context, Community community) {
    return Row(
      children: [
        Expanded(
          child: _PremiumButton(
            label: 'Cancel',
            isOutlined: true,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PremiumButton(
            label: 'Switch',
            onPressed: () {
              Navigator.pop(context);
              _showSwitchSuccessDialog(context, community.name);
            },
          ),
        ),
      ],
    );
  }

  static Widget _buildJoinButtons(BuildContext context, Community community) {
    return Row(
      children: [
        Expanded(
          child: _PremiumButton(
            label: 'Dismiss',
            isOutlined: true,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PremiumButton(
            label: 'Join Now',
            onPressed: () {
              Navigator.pop(context);
              _showJoinSuccessDialog(context, community.name);
            },
          ),
        ),
      ],
    );
  }

  static void _showJoinSuccessDialog(BuildContext context, String name) {
    _showSuccessBaseDialog(
      context,
      title: 'Application Sent',
      message:
          'Your request to join "$name" has been sent. You’ll be notified once it’s approved.',
    );
  }

  static void _showSwitchSuccessDialog(BuildContext context, String name) {
    _showSuccessBaseDialog(
      context,
      title: 'Community Switched',
      message: 'You are now active in "$name".',
    );
  }

  static void _showSuccessBaseDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      pageBuilder: (context, _, __) {
        Timer(const Duration(seconds: 4), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });

        return Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: primaryTeal, size: 70),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: dark,
                        fontSize: 20,
                        decoration: TextDecoration.none,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textSecondary,
                        fontSize: 14,
                        decoration: TextDecoration.none,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// PREMIUM BUTTON (UNCHANGED)
class _PremiumButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isOutlined;

  const _PremiumButton({
    required this.label,
    required this.onPressed,
    this.isOutlined = false,
  });

  @override
  State<_PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<_PremiumButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: widget.isOutlined ? null : appGradient,
            borderRadius: BorderRadius.circular(22),
            border: widget.isOutlined
                ? Border.all(color: primaryTeal.withOpacity(0.4))
                : null,
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isOutlined ? primaryTeal : Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
