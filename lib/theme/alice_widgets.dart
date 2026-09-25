import 'package:flutter/material.dart';
import 'package:flutter_alice/theme/alice_colors.dart';
import 'package:flutter_alice/theme/alice_text_styles.dart';

/// Modern DevTools-style HTTP Status Badge with translucent tinted background.
class AliceStatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final bool loading;

  const AliceStatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (loading) ...[
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 3),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AliceColors.statusBadgeBg(color),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withAlpha(80), width: 1),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// Standardized action button for Alice UI.
class AliceButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isOutlined;
  final bool isDanger;

  const AliceButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isOutlined = false,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isDanger ? AliceColors.error : AliceColors.primary;

    if (isOutlined) {
      if (icon != null) {
        return OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18, color: color),
          label: Text(text),
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text),
      );
    }

    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: AliceColors.textLight),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AliceColors.textLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AliceColors.textLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(text),
    );
  }
}

/// Standardized Key-Value display row for details inspection.
class AliceListRow extends StatelessWidget {
  final String name;
  final String value;
  final VoidCallback? onTap;

  const AliceListRow({
    super.key,
    required this.name,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: name == 'Body:' ? '$name\n' : '$name\t\t\t',
            style: AliceStyles.bodyBold,
          ),
          TextSpan(
            text: value,
            style: AliceStyles.body,
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(onTap: onTap, child: content);
    }
    return content;
  }
}
