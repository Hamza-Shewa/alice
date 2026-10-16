import 'package:netlens/helper/netlens_graphql.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_translation.dart';
import 'package:netlens/ui/common/netlens_context_ext.dart';
import 'package:netlens/ui/common/netlens_theme.dart';
import 'package:flutter/material.dart';

/// Compact badge which displays HTTP method of a call.
class NetLensMethodBadge extends StatelessWidget {
  const NetLensMethodBadge({
    super.key,
    required this.method,
    this.fontSize = 12,
  });

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
class NetLensStatusPill extends StatelessWidget {
  const NetLensStatusPill({super.key, required this.call, this.fontSize = 13});

  final NetLensHttpCall call;
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
            valueColor: AlwaysStoppedAnimation<Color>(NetLensTheme.lightRed),
          ),
        ),
      );
    }
    final int? status = call.response?.status;
    if (call.response == null) {
      return const SizedBox.shrink();
    }
    final Color color = NetLensTheme.getStatusColor(context, status);
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

/// Badge which marks a GraphQL call, and its errors when the response has
/// any.
class NetLensGraphQLBadge extends StatelessWidget {
  const NetLensGraphQLBadge({super.key, required this.operation});

  /// Pink used by GraphQL itself.
  static const Color _graphQLColor = Color(0xffe10098);

  final NetLensGraphQLOperation operation;

  @override
  Widget build(BuildContext context) {
    final Color errorColor = NetLensTheme.getStatusColor(context, 500);
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        _Badge(
          icon: Icons.hub_outlined,
          text: 'GraphQL ${operation.type.name}',
          color: _graphQLColor,
        ),
        if (operation.hasErrors)
          _Badge(
            icon: Icons.error_outline,
            text: context.i18n(NetLensTranslationKey.graphQLErrors),
            color: errorColor,
          ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
