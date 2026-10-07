import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:flutter/material.dart';

/// Compact badge which displays HTTP method of a call.
class AliceMethodBadge extends StatelessWidget {
  const AliceMethodBadge({super.key, required this.method, this.fontSize = 12});

  final String method;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      constraints: BoxConstraints(minWidth: fontSize * 4.3),
      padding: EdgeInsets.symmetric(
        horizontal: fontSize / 2,
        vertical: fontSize / 4,
      ),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        method.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}

/// Colored pill which displays response status of a call, or a progress
/// indicator while the call is still in progress.
class AliceStatusPill extends StatelessWidget {
  const AliceStatusPill({super.key, required this.call, this.fontSize = 13});

  final AliceHttpCall call;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    if (call.loading) {
      return Padding(
        padding: const EdgeInsets.all(2),
        child: SizedBox(
          width: fontSize + 5,
          height: fontSize + 5,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AliceTheme.lightRed),
          ),
        ),
      );
    }
    final int? status = call.response?.status;
    if (call.response == null) {
      return const SizedBox.shrink();
    }
    final Color color = AliceTheme.getStatusColor(context, status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.6,
        vertical: fontSize / 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(fontSize),
      ),
      child: Text(
        getStatusText(status),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  /// Returns text displayed for response [status].
  static String getStatusText(int? status) => switch (status) {
    -1 => 'ERR',
    0 || null => '???',
    _ => '$status',
  };
}
