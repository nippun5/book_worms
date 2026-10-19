import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../models/book_listing.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../widgets/book_picker.dart';
import '../../widgets/common.dart';

class PostListingScreen extends StatefulWidget {
  const PostListingScreen({super.key});

  @override
  State<PostListingScreen> createState() => _PostListingScreenState();
}

class _PostListingScreenState extends State<PostListingScreen> {
  late final BookPickerController _picker;
  final _priceCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  ListingType _type = ListingType.loan;
  ListingCondition _condition = ListingCondition.good;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _picker = BookPickerController();
  }

  @override
  void dispose() {
    _picker.dispose();
    _priceCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    final bookError = _picker.validate();
    if (bookError != null) {
      setState(() => _error = bookError);
      return;
    }
    double? price;
    if (_type == ListingType.sale) {
      price = double.tryParse(_priceCtrl.text.trim());
      if (price == null || price <= 0) {
        setState(() => _error = 'Enter a valid price.');
        return;
      }
    }

    setState(() => _submitting = true);
    try {
      final me = context.read<AuthProvider>().user!;
      final catalog = context.read<CatalogProvider>();
      final book = await _picker.resolve(catalog, me.id!);
      final result = await context.read<MarketplaceProvider>().postListing(
            me: me,
            book: book,
            type: _type,
            price: price,
            condition: _condition,
            note: _noteCtrl.text,
          );
      if (!mounted) return;
      if (result != null) {
        setState(() => _error = result);
      } else {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List a Book')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookPickerField(controller: _picker),
              const SizedBox(height: 22),
              const Text('List this book to', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.brown900)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _TypeTile(
                      label: 'Loan it out',
                      subtitle: 'Free — lend and get it back',
                      icon: Icons.swap_horiz_rounded,
                      selected: _type == ListingType.loan,
                      onTap: () => setState(() => _type = ListingType.loan),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TypeTile(
                      label: 'Sell it',
                      subtitle: 'Set your own price',
                      icon: Icons.sell_outlined,
                      selected: _type == ListingType.sale,
                      onTap: () => setState(() => _type = ListingType.sale),
                    ),
                  ),
                ],
              ),
              if (_type == ListingType.sale) ...[
                const SizedBox(height: 18),
                TextField(
                  controller: _priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Price (USD)', prefixText: '\$ '),
                ),
              ],
              const SizedBox(height: 20),
              const Text('Condition', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.brown900)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: ListingCondition.values.map((c) {
                  final selected = _condition == c;
                  return ChoiceChip(
                    label: Text(c.label),
                    selected: selected,
                    onSelected: (_) => setState(() => _condition = c),
                    selectedColor: AppColors.brown500,
                    labelStyle: TextStyle(color: selected ? Colors.white : AppColors.brown700, fontWeight: FontWeight.w600),
                    backgroundColor: AppColors.tan100,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: BorderSide.none),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _noteCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Note (optional)', alignLabelWithHint: true),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(_error!, style: const TextStyle(color: AppColors.red, fontSize: 13)),
              ],
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                      : const Text('Post Listing'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.brown500 : AppColors.tan100.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppColors.brown500 : Colors.transparent, width: 1.4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: selected ? Colors.white : AppColors.brown500),
            const SizedBox(height: 10),
            Text(label,
                style: TextStyle(fontWeight: FontWeight.w700, color: selected ? Colors.white : AppColors.brown900)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 11.5, color: selected ? Colors.white.withValues(alpha: 0.85) : AppColors.grayText)),
          ],
        ),
      ),
    );
  }
}
