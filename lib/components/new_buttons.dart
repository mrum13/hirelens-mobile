// ignore_for_file: must_be_immutable

import "package:flutter/material.dart";

enum MyButtonVariant { primary, secondary, tertiary, neutral, white }

Color _getVariantColor(MyButtonVariant variant, ThemeData theme) {
  switch (variant) {
    case MyButtonVariant.primary:
      return theme.colorScheme.primary;
    case MyButtonVariant.secondary:
      return theme.colorScheme.secondary;
    case MyButtonVariant.tertiary:
      return theme.colorScheme.tertiary;
    case MyButtonVariant.neutral:
      return theme.colorScheme.surfaceBright;
    case MyButtonVariant.white:
      return Colors.white60;
  }
}

Color _getOnVariantColor(MyButtonVariant variant, ThemeData theme) {
  switch (variant) {
    case MyButtonVariant.primary:
      return theme.colorScheme.onPrimary;
    case MyButtonVariant.secondary:
      return theme.colorScheme.onSecondary;
    case MyButtonVariant.tertiary:
      return theme.colorScheme.onTertiary;
    case MyButtonVariant.neutral:
      return theme.colorScheme.onSurface;
    case MyButtonVariant.white:
      return theme.colorScheme.onSurface;
  }
}

class MyFilledButton extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final double? width;
  final double? height;
  final Alignment alignment;
  final MyButtonVariant variant;
  final void Function()? onTap;
  final EdgeInsets padding;
  final double? borderRadius;

  const MyFilledButton({
    super.key,
    this.isLoading = false,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    this.alignment = Alignment.center,
    this.width = double.infinity,
    required this.variant,
    required this.onTap,
    required this.child,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final variantColor = _getVariantColor(variant, theme);
    final onVariantColor = _getOnVariantColor(variant, theme);
    return SizedBox(
      width: width,
      height: height,
      child: FilledButton(
        onPressed: isLoading ? () {} : onTap,
        style: FilledButton.styleFrom(
          backgroundColor: variantColor,
          foregroundColor: onVariantColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 16),
          ),
          padding: padding,
        ),
        child: Align(
          alignment: alignment,
          child:
              isLoading
                  ? CircularProgressIndicator(color: onVariantColor)
                  : child,
        ),
      ),
    );
  }
}

class MyOutlinedButton extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final double? width;
  final double? height;
  final Alignment alignment;
  final MyButtonVariant variant;
  final void Function()? onTap;
  final EdgeInsets padding;
  final double? borderRadius;

  const MyOutlinedButton({
    super.key,
    this.isLoading = false,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    this.alignment = Alignment.center,
    this.width = double.infinity,
    required this.variant,
    required this.onTap,
    required this.child,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final variantColor = _getVariantColor(variant, theme);
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? () {} : onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: variantColor,
          side: BorderSide(color: variantColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 16),
          ),
          padding: padding,
        ),
        child: Align(
          alignment: alignment,
          child:
              isLoading
                  ? CircularProgressIndicator(color: variantColor)
                  : child,
        ),
      ),
    );
  }
}

class MyLinkButton extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final double? width;
  final double? height;
  final Alignment alignment;
  final MyButtonVariant variant;
  final void Function()? onTap;
  final EdgeInsets padding;
  final double? borderRadius;

  const MyLinkButton({
    super.key,
    this.isLoading = false,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    this.alignment = Alignment.center,
    this.width = double.infinity,
    required this.variant,
    required this.onTap,
    required this.child,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final variantColor = _getVariantColor(variant, theme);
    return SizedBox(
      width: width,
      height: height,
      child: TextButton(
        onPressed: isLoading ? () {} : onTap,
        style: TextButton.styleFrom(
          foregroundColor: variantColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 16),
          ),
          padding: padding,
        ),
        child: Align(
          alignment: alignment,
          child:
              isLoading
                  ? CircularProgressIndicator(color: variantColor)
                  : child,
        ),
      ),
    );
  }
}
