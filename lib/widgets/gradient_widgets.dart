import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GradientAppBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) => AppBar(
        title: Text(title),
        actions: actions,
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(gradient: AppGradients.primary),
        ),
      );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Extended FAB with the navy gradient instead of the flat theme colour.
class GradientFab extends StatelessWidget {
  const GradientFab({super.key, required this.onPressed, required this.label,
      this.icon = Icons.add});

  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Color(0x552A4C86), blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(color: Colors.white,
                    fontWeight: FontWeight.w600, fontSize: 15)),
              ]),
            ),
          ),
        ),
      );
}

/// Arrow inscribed in a tinted navy circle, used for previous/next period.
class CircleArrowButton extends StatelessWidget {
  const CircleArrowButton({super.key, required this.icon, required this.onPressed,
      this.tooltip});

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) => IconButton.filledTonal(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon),
        style: IconButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: AppColors.navy700.withValues(alpha: 0.1),
          foregroundColor: AppColors.navy700,
        ),
      );
}

/// White pill with a circled arrow on each side and a label in the middle,
/// like the month selector in Cashflow.
class PeriodSelector extends StatelessWidget {
  const PeriodSelector({super.key, required this.label, required this.onPrevious,
      required this.onNext, this.onLabelTap});

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback? onLabelTap;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(children: [
          CircleArrowButton(icon: Icons.chevron_left, onPressed: onPrevious,
              tooltip: 'Previous'),
          Expanded(child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onLabelTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (onLabelTap != null) ...[
                  const Icon(Icons.calendar_today, size: 16, color: AppColors.navy600),
                  const SizedBox(width: 8),
                ],
                Flexible(child: Text(label, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                        color: AppColors.navy900, letterSpacing: 0.2))),
              ]),
            ),
          )),
          CircleArrowButton(icon: Icons.chevron_right, onPressed: onNext,
              tooltip: 'Next'),
        ]),
      );
}

/// Gradient hero card for the headline figure of a screen.
class GradientHeroCard extends StatelessWidget {
  const GradientHeroCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: AppColors.navy700.withValues(alpha: 0.3),
                blurRadius: 14, offset: const Offset(0, 6)),
          ],
        ),
        child: child,
      );
}
