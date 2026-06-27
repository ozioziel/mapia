import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';

class AuthPageFrame extends StatelessWidget {
  const AuthPageFrame({
    super.key,
    required this.children,
    this.compactCard = false,
  });

  final List<Widget> children;
  final bool compactCard;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardVisible = mediaQuery.viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFCF5), Color(0xFFEAF4F8), Color(0xFFF2FBF6)],
            stops: [0, 0.55, 1],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              final compact = height < 760 || width < 370 || keyboardVisible;
              final horizontalPadding = width > 560 ? 24.0 : 14.0;
              final verticalPadding = compact ? 8.0 : 18.0;
              final availableWidth = math.max(
                0.0,
                width - (horizontalPadding * 2),
              );
              final availableHeight = math.max(
                0.0,
                height - (verticalPadding * 2),
              );
              final cardWidth = width > 560
                  ? 510.0
                  : math.max(300.0, availableWidth);
              final widthScale = (cardWidth / 390).clamp(0.82, 1.22);
              final heightScale = (height / 760).clamp(0.76, 1.0);
              final scale =
                  (math.min(widthScale, heightScale) *
                          (keyboardVisible ? 0.88 : 1.0))
                      .toDouble();

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Center(
                  child: SizedBox(
                    width: availableWidth,
                    height: availableHeight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Container(
                        width: cardWidth,
                        padding: EdgeInsets.fromLTRB(
                          compact ? 24 * scale : 32 * scale,
                          compact ? 18 * scale : 34 * scale,
                          compact ? 24 * scale : 32 * scale,
                          compact ? 16 * scale : 28 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30 * scale),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF92A9BF,
                              ).withValues(alpha: 0.24),
                              blurRadius: 34,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: -16 * scale,
                              top: 44 * scale,
                              child: AuthCloudDecoration(width: 118 * scale),
                            ),
                            Positioned(
                              right: -24 * scale,
                              top: compactCard ? 136 * scale : 178 * scale,
                              child: AuthCloudDecoration(width: 86 * scale),
                            ),
                            Positioned(
                              right: 40 * scale,
                              top: 36 * scale,
                              child: AuthMusicNote(size: 30 * scale),
                            ),
                            AuthScale(
                              scale: scale,
                              compact: compact,
                              keyboardVisible: keyboardVisible,
                              availableHeight: availableHeight,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: children,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class AuthScale extends InheritedWidget {
  const AuthScale({
    super.key,
    required this.scale,
    required this.compact,
    required this.keyboardVisible,
    required this.availableHeight,
    required super.child,
  });

  final double scale;
  final bool compact;
  final bool keyboardVisible;
  final double availableHeight;

  static AuthScale of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<AuthScale>();
    assert(result != null, 'AuthScale missing from context');
    return result!;
  }

  @override
  bool updateShouldNotify(AuthScale oldWidget) {
    return scale != oldWidget.scale ||
        compact != oldWidget.compact ||
        keyboardVisible != oldWidget.keyboardVisible ||
        availableHeight != oldWidget.availableHeight;
  }
}

class AuthPenguin extends StatelessWidget {
  const AuthPenguin({
    super.key,
    required this.asset,
    required this.maxHeight,
    this.minHeight = 72,
  });

  static const double aspectRatio = 1448 / 1086;

  final String asset;
  final double maxHeight;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final auth = AuthScale.of(context);
    final reducedHeight = auth.keyboardVisible ? maxHeight * 0.42 : maxHeight;
    final height = reducedHeight.clamp(minHeight, maxHeight).toDouble();

    return SizedBox(
      height: height,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Image.asset(asset, fit: BoxFit.contain),
      ),
    );
  }
}

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleScale = 1,
  });

  final String title;
  final String subtitle;
  final double titleScale;

  @override
  Widget build(BuildContext context) {
    final auth = AuthScale.of(context);
    final scale = auth.scale;

    return Column(
      children: [
        const MapiaLogo(),
        SizedBox(height: auth.compact ? 18 * scale : 30 * scale),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: 38 * scale * titleScale,
            height: 1.02,
          ),
        ),
        SizedBox(height: 14 * scale),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.mutedText,
            fontSize: 16 * scale,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class MapiaLogo extends StatelessWidget {
  const MapiaLogo({super.key});

  static const String asset = 'assets/images/logo.png';

  @override
  Widget build(BuildContext context) {
    final scale = AuthScale.of(context).scale;

    return Image.asset(
      asset,
      height: 44 * scale,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Text(
        'Mapia',
        style: TextStyle(
          color: AppTheme.primaryBlue,
          fontSize: 22 * scale,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.hintText,
    required this.icon,
    required this.iconColor,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
  });

  final String hintText;
  final IconData icon;
  final Color iconColor;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final IconData? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final scale = AuthScale.of(context).scale;

    return SizedBox(
      height: 62 * scale,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: const Color(0xFF8A95A8),
            fontSize: 16 * scale,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: iconColor, size: 26 * scale),
          suffixIcon: suffixIcon == null
              ? null
              : Icon(
                  suffixIcon,
                  color: const Color(0xFF8A95A8),
                  size: 26 * scale,
                ),
          contentPadding: EdgeInsets.symmetric(horizontal: 18 * scale),
          filled: true,
          fillColor: const Color(0xFFFBFDFE),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11 * scale),
            borderSide: const BorderSide(color: AppTheme.softBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11 * scale),
            borderSide: const BorderSide(
              color: AppTheme.boliviaGreen,
              width: 1.2,
            ),
          ),
        ),
        style: TextStyle(
          color: AppTheme.textNavy,
          fontSize: 16 * scale,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({super.key, required this.text, this.onPressed});

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scale = AuthScale.of(context).scale;

    return SizedBox(
      width: double.infinity,
      height: 62 * scale,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.boliviaYellow,
          foregroundColor: AppTheme.textNavy,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12 * scale),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 19 * scale,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, this.text = 'or'});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scale = AuthScale.of(context).scale;

    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppTheme.softBorder, thickness: 1),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * scale),
          child: Text(
            text,
            style: TextStyle(
              color: const Color(0xFF8994A8),
              fontSize: 17 * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: AppTheme.softBorder, thickness: 1),
        ),
      ],
    );
  }
}

class GoogleAuthButton extends StatelessWidget {
  const GoogleAuthButton({super.key, required this.text, this.onPressed});

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scale = AuthScale.of(context).scale;

    return SizedBox(
      width: double.infinity,
      height: 62 * scale,
      child: OutlinedButton(
        onPressed: onPressed ?? () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.textNavy,
          side: const BorderSide(color: AppTheme.softBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12 * scale),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'G',
              style: TextStyle(
                color: const Color(0xFF4285F4),
                fontSize: 27 * scale,
                fontWeight: FontWeight.w800,
                fontFamily: 'Roboto',
              ),
            ),
            SizedBox(width: 18 * scale),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.textNavy,
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthBottomLink extends StatelessWidget {
  const AuthBottomLink({
    super.key,
    required this.text,
    required this.actionText,
    required this.onPressed,
  });

  final String text;
  final String actionText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scale = AuthScale.of(context).scale;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          text,
          style: TextStyle(
            color: AppTheme.textNavy,
            fontSize: 15 * scale,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.only(left: 4 * scale),
          ),
          child: Text(
            actionText,
            style: TextStyle(
              color: AppTheme.boliviaGreen,
              fontSize: 15 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class AuthCloudDecoration extends StatelessWidget {
  const AuthCloudDecoration({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.46,
      child: SizedBox(
        width: width,
        height: width * 0.44,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                width: width,
                height: width * 0.17,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCEFFF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(80)),
                ),
              ),
            ),
            Positioned(
              left: width * 0.18,
              bottom: width * 0.05,
              child: _CloudBubble(size: width * 0.32),
            ),
            Positioned(
              left: width * 0.34,
              bottom: width * 0.09,
              child: _CloudBubble(size: width * 0.42),
            ),
            Positioned(
              right: width * 0.12,
              bottom: 0,
              child: _CloudBubble(size: width * 0.25),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthMusicNote extends StatelessWidget {
  const AuthMusicNote({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.26,
      child: Stack(
        children: [
          Positioned(
            left: size * 0.04,
            bottom: 0,
            child: Container(
              width: size * 0.44,
              height: size * 0.44,
              decoration: const BoxDecoration(
                color: Color(0xFFFBBC05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: size * 0.38,
            top: size * 0.07,
            child: Container(
              width: size * 0.2,
              height: size * 0.88,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(size * 0.1),
              ),
            ),
          ),
          Positioned(
            left: size * 0.4,
            top: 0,
            child: Transform.rotate(
              angle: -0.18,
              child: Container(
                width: size * 0.58,
                height: size * 0.25,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(size * 0.1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CloudBubble extends StatelessWidget {
  const _CloudBubble({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFDCEFFF),
        shape: BoxShape.circle,
      ),
    );
  }
}
