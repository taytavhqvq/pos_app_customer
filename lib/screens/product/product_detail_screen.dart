import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../cart/cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int proid;
  const ProductDetailScreen({super.key, required this.proid});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductUnitModel? _selectedUnit;
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final product = context.watch<ProductProvider>().findById(widget.proid);

    if (product == null) {
      return const Scaffold(body: Center(child: Text('ບໍ່ພົບຂໍ້ມູນສິນຄ້າ')));
    }

    _selectedUnit ??= product.baseUnit;
    final serverRoot = ApiConstants.baseUrl.replaceAll('/api', '');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          product.proname,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.2,
              child: product.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: '$serverRoot${product.imageUrl}',
                      fit: BoxFit.contain,
                    )
                  : Container(
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.inventory_2_outlined, size: 60),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.proname,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'ເລືອກຫົວໜ່ວຍ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ...product.units.map(
                    (unit) => RadioListTile<ProductUnitModel>(
                      contentPadding: EdgeInsets.zero,
                      value: unit,
                      groupValue: _selectedUnit,
                      onChanged: (v) => setState(() => _selectedUnit = v),
                      title: Text(unit.uname),
                      subtitle: Text(
                        '${CurrencyFormatter.format(unit.saleprice)} ກີບ',
                      ),
                      activeColor: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Text(
                        'ຈຳນວນ',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => setState(() {
                          if (_qty > 1) _qty--;
                        }),
                      ),
                      Text(
                        '$_qty',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: AppColors.secondary,
                        ),
                        onPressed: () => setState(() => _qty++),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _selectedUnit == null
                  ? null
                  : () {
                      context.read<CartProvider>().addItem(
                        product,
                        _selectedUnit!,
                        _qty,
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
              child: const Text(
                'ຈ່າຍເງິນເລີຍ',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
