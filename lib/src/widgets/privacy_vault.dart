import 'dart:ui';
import 'package:flutter/material.dart';
import '../controllers/privacy_vault_controller.dart';
import '../models/privacy_config.dart';

/// Top-level privacy protector widget that shields the application view during
/// system app-switching and handles idle inactivity timeout locking.
class PrivacyVault extends StatefulWidget {
  const PrivacyVault({
    super.key,
    required this.child,
    this.config = const PrivacyVaultConfig(),
  });

  final Widget child;
  final PrivacyVaultConfig config;

  @override
  State<PrivacyVault> createState() => _PrivacyVaultState();
}

class _PrivacyVaultState extends State<PrivacyVault>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    PrivacyVaultController.configure(
      inactivityTimeout: widget.config.inactivityTimeout,
      lockOnInactivity: widget.config.lockOnInactivity,
      initialDataMasked: widget.config.maskSensitiveDataByDefault,
      onLocked: widget.config.onLocked,
    );
  }

  @override
  void didUpdateWidget(PrivacyVault oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.inactivityTimeout != widget.config.inactivityTimeout ||
        oldWidget.config.lockOnInactivity != widget.config.lockOnInactivity) {
      PrivacyVaultController.configure(
        inactivityTimeout: widget.config.inactivityTimeout,
        lockOnInactivity: widget.config.lockOnInactivity,
        initialDataMasked: PrivacyVaultController.isDataMasked.value,
        onLocked: widget.config.onLocked,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    PrivacyVaultController.reset();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.config.enableBackgroundShield) return;

    final inBackground = state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden;

    PrivacyVaultController.isAppInBackground.value = inBackground;

    if (inBackground && widget.config.lockOnInactivity) {
      PrivacyVaultController.lock();
    }
  }

  Widget _buildDefaultShield() {
    return Container(
      color: widget.config.shieldColor,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: widget.config.blurSigma,
          sigmaY: widget.config.blurSigma,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 38.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Security Shield Active',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                'Screen contents hidden for privacy',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultLockScreen() {
    return Container(
      color: const Color(0xF209090B),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      width: 2.0,
                    ),
                  ),
                  child: const Icon(
                    Icons.fingerprint_rounded,
                    size: 46.0,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(height: 20.0),
                const Text(
                  'App Vault Locked',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Authentication required to resume session',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 13.0,
                  ),
                ),
                const SizedBox(height: 28.0),
                ElevatedButton.icon(
                  onPressed: () {
                    PrivacyVaultController.unlock();
                    widget.config.onUnlocked?.call();
                  },
                  icon: const Icon(Icons.lock_open_rounded, size: 18),
                  label: const Text('Unlock with Biometrics'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 14.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => PrivacyVaultController.registerUserActivity(),
      onPointerMove: (_) => PrivacyVaultController.registerUserActivity(),
      onPointerHover: (_) => PrivacyVaultController.registerUserActivity(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,

          // 1. App-Switcher Background Shield
          ValueListenableBuilder<bool>(
            valueListenable: PrivacyVaultController.isAppInBackground,
            builder: (context, inBackground, _) {
              if (!inBackground || !widget.config.enableBackgroundShield) {
                return const SizedBox.shrink();
              }

              return widget.config.customShieldBuilder?.call(context) ??
                  _buildDefaultShield();
            },
          ),

          // 2. Lock Screen
          ValueListenableBuilder<bool>(
            valueListenable: PrivacyVaultController.isLocked,
            builder: (context, isLocked, _) {
              if (!isLocked) return const SizedBox.shrink();

              return widget.config.customLockScreenBuilder?.call(
                    context,
                    () {
                      PrivacyVaultController.unlock();
                      widget.config.onUnlocked?.call();
                    },
                  ) ??
                  _buildDefaultLockScreen();
            },
          ),
        ],
      ),
    );
  }
}
