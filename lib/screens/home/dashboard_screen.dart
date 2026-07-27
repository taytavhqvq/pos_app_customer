import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
//import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../cart/cart_screen.dart';
import '../orders/order_history_screen.dart';
import '../account/profile_screen.dart';
import '../product/product_detail_screen.dart';
import 'widgets/category_chip.dart';
import 'widgets/product_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _bottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _DashboardHome(),
      const CartScreen(),
      const OrderHistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      // เปลี่ยนจาก pages[_bottomNavIndex] เป็น IndexedStack
      body: IndexedStack(index: _bottomNavIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (i) => setState(() => _bottomNavIndex = i),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ໜ້າຫຼັກ'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'ກະຕ່າ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'ອໍເດີ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'ບັນຊີ',
          ),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    //final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'ສະບາຍດີ ມີສິນຄ້າຫຍັງໃຫ້ຫາບໍ?',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => productProvider.loadAll(),
        child: productProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : productProvider.errorMessage != null
            ? Center(child: Text(productProvider.errorMessage!))
            : CustomScrollView(
                slivers: [
                  // ===== ช่องค้นหา =====
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        onChanged: productProvider.setSearchQuery,
                        decoration: InputDecoration(
                          hintText: '🔍 ຄົ້ນຫາສິນຄ້າ...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ===== แถบหมวดหมู่ =====
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 44,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          CategoryChip(
                            label: 'ທັງໝົດ',
                            isSelected: productProvider.selectedCatId == null,
                            onTap: () => productProvider.setCategory(null),
                          ),
                          ...productProvider.categories.map(
                            (c) => CategoryChip(
                              label: c.catname,
                              isSelected:
                                  productProvider.selectedCatId == c.catid,
                              onTap: () => productProvider.setCategory(c.catid),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  // ===== Grid สินค้า =====
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final product = productProvider.filteredProducts[index];
                        return ProductCard(
                          product: product,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailScreen(proid: product.proid),
                            ),
                          ),
                        );
                      }, childCount: productProvider.filteredProducts.length),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
      ),
    );
  }
}
