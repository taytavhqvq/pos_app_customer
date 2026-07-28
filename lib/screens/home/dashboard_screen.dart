import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/product_provider.dart';
import '../../providers/notification_provider.dart';
import '../cart/cart_screen.dart';
import '../orders/order_history_screen.dart';
import '../account/profile_screen.dart';
import '../product/product_detail_screen.dart';
import 'widgets/category_chip.dart';
import 'widgets/product_card.dart';
import 'widgets/promo_banner.dart';

class DashboardScreen extends StatefulWidget {
  final int initialIndex;
  const DashboardScreen({super.key, this.initialIndex = 0});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _bottomNavIndex;

  @override
  void initState() {
    super.initState();
    _bottomNavIndex = widget.initialIndex;
  }

  void _goToCartTab() {
    setState(() => _bottomNavIndex = 1);
  }

  void _goToHomeTab() {
    setState(() => _bottomNavIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _DashboardHome(onGoToCart: _goToCartTab), // ส่ง callback ลงไป
      CartScreen(onGoToHome: _goToHomeTab),
      const OrderHistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
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
  final VoidCallback onGoToCart; // รับ callback มาจาก parent

  const _DashboardHome({required this.onGoToCart});

  void _showNotification(BuildContext context, Map<String, dynamic> event) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.notifications, color: AppColors.primary, size: 32),
            const SizedBox(height: 12),
            Text(
              event['message']?.toString() ?? 'ມີການອັບເດດອໍເດີຂອງທ່ານ',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ).then((_) {
      if (context.mounted) {
        context.read<NotificationProvider>().clearLatestEvent();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    final hasUnread = notificationProvider.latestEvent != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'ສະບາຍດີ ມີຫຍັງໃຫ້ຫາບໍ່?',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () {
                  final event = notificationProvider.latestEvent;
                  if (event != null) {
                    _showNotification(context, event);
                  }
                },
              ),
              if (hasUnread)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => productProvider.loadAll(),
        child: productProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : productProvider.errorMessage != null
            ? Center(child: Text(productProvider.errorMessage!))
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
                  const SliverToBoxAdapter(child: PromoBanner()),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
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
                          onTap: () async {
                            // await ผลลัพธ์ที่ pop กลับมา
                            final goToCart = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailScreen(proid: product.proid),
                              ),
                            );
                            // ถ้ากดไอคอนตะกร้าตอนอยู่หน้ารายละเอียดสินค้า -> สลับ tab
                            if (goToCart == true) {
                              onGoToCart();
                            }
                          },
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
