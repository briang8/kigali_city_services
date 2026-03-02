import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../constants/app_theme.dart';

// Shown after registration while waiting for the user to verify their email
class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  Timer? _pollTimer;
  bool _canResend = true;
  int _cooldown = 0;

  @override
  void initState() {
    super.initState();
    // Poll Firebase every 3 seconds to detect when email is verified
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await ref.read(authServiceProvider).reloadUser();
      ref.invalidate(authStateProvider);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  // Resend the verification email with a 60-second cooldown
  Future<void> _resend() async {
    if (!_canResend) return;
    setState(() {
      _canResend = false;
      _cooldown = 60;
    });
    await ref.read(authServiceProvider).resendVerificationEmail();
    // Decrement the cooldown counter every second
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (_cooldown <= 1) {
        t.cancel();
        if (mounted) setState(() => _canResend = true);
      } else {
        if (mounted) setState(() => _cooldown--);
      }
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Verification email sent.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final email =
        ref.watch(authStateProvider).asData?.value?.email ?? '';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email icon container
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.mark_email_read_outlined,
                  color: AppColors.accent,
                  size: 40,
                ),
              ),
              const SizedBox(height: 28),

              const Text(
                'Verify Your Email',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'A verification link was sent to\n$email',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Click the link in your inbox to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    height: 1.5),
              ),
              const SizedBox(height: 40),

              // Resend button with cooldown state
              ElevatedButton(
                onPressed: _canResend ? _resend : null,
                child: Text(_canResend
                    ? 'Resend Verification Email'
                    : 'Resend in ${_cooldown}s'),
              ),
              const SizedBox(height: 14),

              // Sign out option
              OutlinedButton(
                onPressed: () => ref
                    .read(authNotifierProvider.notifier)
                    .signOut(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  minimumSize: const Size(double.infinity, 52),
                  side: const BorderSide(color: AppColors.divider),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Sign Out'),
              ),
              const SizedBox(height: 32),

              // Polling indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textMuted),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Waiting for verification...',
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}