import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Built-in numeric PIN pad with optional randomized keypad shuffling to
/// prevent shoulder-surfing attacks in financial and confidential apps.
class VaultPinPad extends StatefulWidget {
  const VaultPinPad({
    super.key,
    required this.onSuccess,
    this.correctPin = '1234',
    this.pinLength = 4,
    this.shuffleKeypad = false,
    this.title = 'Enter App PIN',
    this.subtitle = 'Authentication required to unlock vault',
    this.onBiometricsPressed,
    this.accentColor = const Color(0xFF10B981),
  });

  final VoidCallback onSuccess;
  final String correctPin;
  final int pinLength;
  final bool shuffleKeypad;
  final String title;
  final String subtitle;
  final VoidCallback? onBiometricsPressed;
  final Color accentColor;

  @override
  State<VaultPinPad> createState() => _VaultPinPadState();
}

class _VaultPinPadState extends State<VaultPinPad> {
  String _enteredPin = '';
  bool _hasError = false;
  late List<int> _keypadDigits;

  @override
  void initState() {
    super.initState();
    _keypadDigits = List.generate(10, (i) => i);
    if (widget.shuffleKeypad) {
      _keypadDigits.shuffle();
    }
  }

  void _onDigitPressed(int digit) {
    if (_enteredPin.length >= widget.pinLength) return;

    HapticFeedback.selectionClick();
    setState(() {
      _hasError = false;
      _enteredPin += digit.toString();
    });

    if (_enteredPin.length == widget.pinLength) {
      _verifyPin();
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _hasError = false;
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  void _verifyPin() {
    if (_enteredPin == widget.correctPin) {
      HapticFeedback.mediumImpact();
      widget.onSuccess();
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _hasError = true;
        _enteredPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: widget.accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.lock_rounded, size: 36, color: widget.accentColor),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _hasError ? 'Incorrect PIN. Please try again.' : widget.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: _hasError ? const Color(0xFFEF4444) : Colors.white60,
              ),
            ),
            const SizedBox(height: 24),

            // PIN Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.pinLength, (index) {
                final isFilled = index < _enteredPin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled
                        ? (_hasError
                            ? const Color(0xFFEF4444)
                            : widget.accentColor)
                        : Colors.white.withValues(alpha: 0.15),
                    border: Border.all(
                      color: isFilled
                          ? Colors.transparent
                          : Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            // Keypad Grid
            Column(
              children: [
                for (int r = 0; r < 3; r++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (int c = 0; c < 3; c++)
                          _buildKeyButton(_keypadDigits[r * 3 + c]),
                      ],
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Left action: Biometrics or empty
                    if (widget.onBiometricsPressed != null)
                      IconButton(
                        onPressed: widget.onBiometricsPressed,
                        icon: const Icon(Icons.fingerprint_rounded, size: 28),
                        color: widget.accentColor,
                      )
                    else
                      const SizedBox(width: 56, height: 56),
                    // Zero digit
                    _buildKeyButton(_keypadDigits[9]),
                    // Delete button
                    IconButton(
                      onPressed: _onDeletePressed,
                      icon: const Icon(Icons.backspace_outlined, size: 24),
                      color: Colors.white70,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyButton(int digit) {
    return InkWell(
      onTap: () => _onDigitPressed(digit),
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: 64,
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Text(
          '$digit',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
