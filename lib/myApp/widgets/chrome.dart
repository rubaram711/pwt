// App chrome ported from proto/shared.jsx: AppHeader, PwtTopBar, PwtBottomNav,
// ProfileDrawer, ProductImage, FloatingCart. The prototype's fake phone status
// bar / dynamic island / home indicator are intentionally dropped — a real
// Flutter app gets those from the OS (use SafeArea where needed).

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/asset_resolver.dart';
import '../core/theme.dart';
import '../core/tokens.dart';
import '../i18n/strings.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../state/cart_state.dart';
import 'primitives.dart';
import 'pwt_icons.dart';

/// Home header: logo + wordmark on the left, optional [extra], a notification
/// bell, and the avatar that opens the profile drawer.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.user,
    this.onBell,
    this.onProfile,
    this.extra,
  });

  final AppUser user;
  final VoidCallback? onBell;
  final VoidCallback? onProfile;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Image.asset('assets/images/full_logo.png', height: 60,fit: BoxFit.contain),
              ],
            ),
          ),
          if (extra != null) extra!,
          const SizedBox(width: 10),
          // Hidden for now — will return later.
          // _CircleButton(
          //   icon: PwtIcons.bell,
          //   onTap: onBell,
          //   badge: true,
          // ),
          // const SizedBox(width: 10),
          GestureDetector(
            onTap: onProfile,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [PwtColors.brand, PwtColors.brandDeep],
                ),
              ),
              alignment: Alignment.center,
              child: Text(user.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, this.onTap, this.badge = false});
  final IconData icon;
  final VoidCallback? onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: PwtColors.surface,
              border: Border.all(color: PwtColors.hairline),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: PwtColors.textPri),
          ),
          if (badge)
            Positioned(
              right: 7,
              top: 6,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PwtColors.brand,
                  border: Border.all(color: PwtColors.surface, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Back + centered title + optional trailing actions.
class PwtTopBar extends StatelessWidget {
  const PwtTopBar({super.key, this.title, this.onBack, this.actions});

  final String? title;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: onBack != null
                  ? IconButton(
                      onPressed: onBack,
                      icon: const Icon(PwtIcons.back, size: 24),
                      color: PwtColors.textPri,
                      padding: EdgeInsets.zero,
                    )
                  : null,
            ),
            Expanded(
              child: Text(
                title ?? '',
                textAlign: TextAlign.center,
                style: PwtType.subtitle().copyWith(fontSize: 16),
              ),
            ),
            SizedBox(
              width: 40,
              child: actions == null
                  ? null
                  : Row(mainAxisAlignment: MainAxisAlignment.end, children: actions!),
            ),
          ],
        ),
      ),
    );
  }
}

class PwtNavItem {
  const PwtNavItem({required this.key, required this.label, required this.icon});
  final String key;
  final String label;
  final IconData icon;
}

/// Bottom navigation with the active indicator bar on top of the active item.
class PwtBottomNav extends StatelessWidget {
  const PwtBottomNav({
    super.key,
    required this.items,
    required this.active,
    required this.onChanged,
  });

  final List<PwtNavItem> items;
  final String active;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: PwtColors.bg,
        border: Border(top: BorderSide(color: PwtColors.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final item in items)
                _NavButton(
                  item: item,
                  active: item.key == active,
                  onTap: () => onChanged(item.key),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.active, required this.onTap});
  final PwtNavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? PwtColors.brand : PwtColors.textTer;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 76,
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (active)
              Positioned(
                top: 2,
                child: Container(
                  width: 24,
                  height: 3,
                  decoration: BoxDecoration(
                    color: PwtColors.brand,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, size: 22, color: color),
                const SizedBox(height: 3),
                Text(
                  item.label,
                  style: TextStyle(fontSize: 10.5, fontWeight: active ? FontWeight.w600 : FontWeight.w500, color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Product image with the soft radial brand glow behind it.
class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.img, this.imageUrl, this.size = 180, this.accent});
  final String img;
  final String? imageUrl;
  final double size;
  final Color? accent;

  Widget _fallback() => Icon(Icons.water_drop_outlined, size: size * 0.4, color: PwtColors.brand.withValues(alpha: 0.4));

  Widget _imageWidget() {
    if (hasLocalAsset(img)) {
      return Image(image: pwtImage(img), height: size, fit: BoxFit.contain);
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(imageUrl!, height: size, fit: BoxFit.contain, errorBuilder: (_, __, ___) => _fallback());
    }
    return _fallback();
  }

  @override
  Widget build(BuildContext context) {
    final a = accent ?? PwtColors.brand;
    return SizedBox(
      height: size + 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 1.5,
            height: size * 1.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [a.withValues(alpha: 0.19), a.withValues(alpha: 0)],
                stops: const [0, 0.65],
              ),
            ),
          ),
          _imageWidget(),
        ],
      ),
    );
  }
}

/// The profile side-sheet (used as Scaffold.endDrawer so it opens from the
/// trailing edge in both LTR and RTL).
class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({
    super.key,
    required this.user,
    required this.onSelect,
  });

  final AppUser user;
  final ValueChanged<String> onSelect; // profile | settings | invoices | logout

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = Strings.of(app.lang);
    return Drawer(
      width: 304,
      backgroundColor: PwtColors.bgElev,
      shape: const RoundedRectangleBorder(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // user header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 64, 20, 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: PwtColors.hairline)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [PwtColors.brand, PwtColors.brandDeep]),
                      ),
                      alignment: Alignment.center,
                      child: Text(user.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: PwtType.subtitle().copyWith(fontSize: 15)),
                          const SizedBox(height: 2),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(user.phone, style: PwtType.mono(size: 12, color: PwtColors.textTer)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Pill(label: user.kind == AccountKind.business ? s['business']! : s['individual']!),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _DrawerItem(icon: PwtIcons.user, label: s['profile']!, onTap: () => onSelect('profile')),
          _DrawerItem(icon: PwtIcons.bell, label: s['settings']!, onTap: () => onSelect('settings')),
          // Hidden for now — will return later.
          // _DrawerItem(icon: PwtIcons.file, label: s['invoices']!, onTap: () => onSelect('invoices')),
          // Hidden for now — will return later.
          // const Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          //   child: Divider(height: 1, color: PwtColors.hairline),
          // ),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Padding(
          //         padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
          //         child: Text(s['preferences']!.toUpperCase(), style: PwtType.eyebrow().copyWith(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 1.3)),
          //       ),
          //       SegmentRow<String>(
          //         label: s['language'],
          //         value: app.lang,
          //         options: const [
          //           SegmentOption(value: 'en', label: 'EN'),
          //           SegmentOption(value: 'ar', label: 'AR'),
          //         ],
          //         onChanged: app.setLang,
          //       ),
          //     ],
          //   ),
          // ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 28),
            child: _DrawerItem(icon: PwtIcons.logout, label: s['logout']!, danger: true, onTap: () => onSelect('logout')),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({required this.icon, required this.label, this.onTap, this.danger = false});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final fg = danger ? PwtColors.error : PwtColors.textPri;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: danger ? PwtColors.error : PwtColors.textSec),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: PwtType.label(color: fg, weight: FontWeight.w500).copyWith(fontSize: 14.5))),
            ],
          ),
        ),
      ),
    );
  }
}

/// Floating cart button (badge = total qty). Returns an empty widget when the
/// cart is empty, like the prototype.
class FloatingCart extends StatelessWidget {
  const FloatingCart({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final qty = context.watch<CartState>().totalQty;
    if (qty == 0) return const SizedBox.shrink();
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: PwtColors.brand,
              boxShadow: PwtShadows.brandGlow(PwtColors.brand),
            ),
            alignment: Alignment.center,
            child: const Icon(PwtIcons.cart, color: Colors.white, size: 24),
          ),
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              constraints: const BoxConstraints(minWidth: 22),
              height: 22,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: PwtColors.brand, width: 2),
              ),
              alignment: Alignment.center,
              child: Text('$qty', style: const TextStyle(color: PwtColors.brand, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

/// WhatsApp circular FAB — opens the WhatsApp app directly (not WhatsApp Web),
/// via the wa.me deep link launched in an external application. Number is
/// fixed, matching how myWeb2's WhatsAppFab hardcodes its number.
class WhatsAppFab extends StatelessWidget {
  const WhatsAppFab({super.key});

  static const _number = '971556539575';

  Future<void> _open() async {
    final uri = Uri.parse('https://wa.me/$_number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _open,
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF25D366),
          boxShadow: [BoxShadow(color: Color(0x4025D366), blurRadius: 14, offset: Offset(0, 6))],
        ),
        alignment: Alignment.center,
        child: SvgPicture.string(_kWaSvg, width: 26, height: 26),
      ),
    );
  }
}

const _kWaSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="white">
  <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
</svg>
''';
