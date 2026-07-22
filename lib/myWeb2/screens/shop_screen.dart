import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/site_chrome.dart';
import '../../Models/Products/products_model.dart';
import '../../Models/Pagination/pagination_model.dart';
import '../../Backend/Products/get_products.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  List<ProductModel> _products = [];
  bool _loading = true;
  String? _error;
  int _page = 1;
  PaginationModel? _pagination;

  final _scrollKey = GlobalKey();

  static const _perPage = 8;

  static const _trust = [
    [Icons.local_shipping_outlined, 'Fast Delivery', 'Quick delivery across the UAE'],
    [Icons.shield_outlined, '2 Years Warranty', 'Full coverage on all products'],
    [Icons.support_agent, 'Expert Support', 'We are here to help you'],
    [Icons.swap_horiz, 'Easy Returns', '14 days return policy'],
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() { _loading = true; _error = null; });
    final result = await getProducts(page: _page, perPage: _perPage);
    if (!mounted) return;
    if (result.success && result.data != null) {
      setState(() {
        _products = result.data!.items;
        _pagination = result.data!.pagination;
        _loading = false;
      });
    } else {
      setState(() { _error = result.message ?? 'Failed to load products.'; _loading = false; });
    }
  }

  void _goToPage(int page) {
    if (page == _page) return;
    setState(() => _page = page);
    _loadProducts();
    Scrollable.ensureVisible(_scrollKey.currentContext ?? context, duration: const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    final total = _pagination?.total ?? _products.length;
    final from = _pagination?.from ?? ((_page - 1) * _perPage + 1);
    final to = _pagination?.to ?? (_page * _perPage).clamp(0, total);

    return StoreScaffold(active: '/shop', slivers: [
      SliverToBoxAdapter(
        key: _scrollKey,
        child: Band(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              InkWell(
                onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false),
                child: Text('Home', style: AppText.muted.copyWith(color: AppColors.blue700)),
              ),
              Text('  ›  Shop', style: AppText.muted),
            ]),
            const SizedBox(height: 16),
            Text('All Products', style: AppText.headline(34)),
            const SizedBox(height: 6),
            if (!_loading && _error == null)
              Text('Showing $from–$to of $total products', style: AppText.muted),
          ]),
        ),
      ),
      SliverToBoxAdapter(
        child: Band(
          child: _loading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : _error != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text(_error!, style: AppText.muted)),
                    )
                  : LayoutBuilder(builder: (context, c) {
                      final cols = c.maxWidth > 1000 ? 4 : c.maxWidth > 680 ? 3 : 2;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _products.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          mainAxisSpacing: 18,
                          crossAxisSpacing: 18,
                          childAspectRatio: 0.72,
                        ),
                        itemBuilder: (_, i) => _ProductCard(_products[i]),
                      );
                    }),
        ),
      ),
      if (!_loading && _error == null && (_pagination?.lastPage ?? 1) > 1)
        SliverToBoxAdapter(
          child: Band(
            padding: const EdgeInsets.fromLTRB(32, 8, 32, 24),
            child: _PaginationBar(
              current: _page,
              last: _pagination?.lastPage ?? 1,
              onPage: _goToPage,
            ),
          ),
        ),
      SliverToBoxAdapter(
        child: Band(
          color: AppColors.soft,
          child: Wrap(
            spacing: 18,
            runSpacing: 18,
            alignment: WrapAlignment.spaceBetween,
            children: _trust.map((t) => SizedBox(
              width: 250,
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.line)),
                  child: Icon(t[0] as IconData, color: AppColors.blue700, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t[1] as String, style: AppText.label),
                  const SizedBox(height: 2),
                  Text(t[2] as String, style: AppText.muted, maxLines: 1, overflow: TextOverflow.ellipsis),
                ])),
              ]),
            )).toList(),
          ),
        ),
      ),
    ]);
  }
}

// ── Pagination bar ──────────────────────────────────────────────

class _PaginationBar extends StatelessWidget {
  final int current;
  final int last;
  final void Function(int) onPage;
  const _PaginationBar({required this.current, required this.last, required this.onPage});

  List<int?> get _pages {
    if (last <= 7) return List.generate(last, (i) => i + 1);
    final pages = <int?>[1];
    if (current > 3) pages.add(null); // ellipsis
    for (int i = (current - 1).clamp(2, last - 1); i <= (current + 1).clamp(2, last - 1); i++) {
      pages.add(i);
    }
    if (current < last - 2) pages.add(null); // ellipsis
    pages.add(last);
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ArrowBtn(
          icon: Icons.chevron_left,
          enabled: current > 1,
          onTap: () => onPage(current - 1),
        ),
        const SizedBox(width: 6),
        ..._pages.map((p) => p == null
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('…', style: TextStyle(color: AppColors.ink400, fontSize: 14)),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _PageBtn(
                  page: p,
                  active: p == current,
                  onTap: () => onPage(p),
                ),
              )),
        const SizedBox(width: 6),
        _ArrowBtn(
          icon: Icons.chevron_right,
          enabled: current < last,
          onTap: () => onPage(current + 1),
        ),
      ],
    );
  }
}

class _PageBtn extends StatelessWidget {
  final int page;
  final bool active;
  final VoidCallback onTap;
  const _PageBtn({required this.page, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: active ? null : onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.blue700 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? AppColors.blue700 : AppColors.line),
        ),
        child: Text(
          '$page',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppColors.ink700,
          ),
        ),
      ),
    );
  }
}

class _ArrowBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _ArrowBtn({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: enabled ? AppColors.line : AppColors.line.withOpacity(.5)),
        ),
        child: Icon(icon, size: 18, color: enabled ? AppColors.ink700 : AppColors.ink400.withOpacity(.4)),
      ),
    );
  }
}

// ── Product card ────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final ProductModel p;
  const _ProductCard(this.p);

  @override
  Widget build(BuildContext context) {
    final price = double.tryParse(p.startingPrice?.amount ?? '') ?? 0;
    final oldPrice = p.originalPrice != null ? double.tryParse(p.originalPrice!) : null;
    final currency = p.startingPrice?.currency ?? '';
    final isDiscounted = oldPrice != null;

    return InkWell(
      onTap: () => Navigator.of(context).pushNamed('/product', arguments: p),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.line),
          boxShadow: AppShadow.card,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Stack(children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: p.primaryImageUrl != null
                      ? Image.network(p.primaryImageUrl!, fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.water_drop_outlined, size: 52, color: AppColors.blue200))
                      : const Icon(Icons.water_drop_outlined, size: 52, color: AppColors.blue200),
                ),
              ),
              if (p.tagLabel != null)
                Positioned(top: 10, left: 10, child: _ribbon(p.tagLabel!, AppColors.blue700)),
              if (p.discount != null && p.discount! > 0)
                Positioned(top: 10, right: 10, child: _ribbon('${p.discount}% OFF', AppColors.discount)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.code ?? '', style: AppText.h3),
              const SizedBox(height: 2),
              Text(p.shortDescription ?? '', style: AppText.muted, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                Text(
                  '$currency ${price.toStringAsFixed(0)}',
                  style: AppText.price.copyWith(color: isDiscounted ? AppColors.discount : AppColors.ink900),
                ),
                if (isDiscounted) ...[
                  const SizedBox(width: 8),
                  Text('$currency ${oldPrice!.toStringAsFixed(0)}', style: AppText.muted.copyWith(decoration: TextDecoration.lineThrough)),
                ],
              ]),
              const SizedBox(height: 12),
              PwtButton('View details', variant: PwtBtn.ghost, fullWidth: true,
                  onPressed: () => Navigator.of(context).pushNamed('/product', arguments: p)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _ribbon(String t, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(AppRadius.pill)),
        child: Text(t, style: AppText.muted.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10.5)),
      );
}
