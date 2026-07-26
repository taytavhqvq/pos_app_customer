import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/order_model.dart';
import '../models/pagination_model.dart';
import '../services/order_service.dart';
import '../services/payment_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  final PaymentService _paymentService = PaymentService();

  // ===== Order history (list + pagination) =====
  final List<OrderModel> orders = [];
  PaginationModel? pagination;
  bool isLoadingList = false;
  bool isLoadingMore = false;
  String? errorMessage;

  // ===== Order detail =====
  OrderModel? selectedOrder;
  bool isLoadingDetail = false;

  bool isSubmittingOrder = false;
  bool isUploadingSlip = false;

  // ===== สร้างออเดอร์ (checkout) =====
  Future<OrderModel?> createOrder(List<Map<String, dynamic>> items) async {
    isSubmittingOrder = true;
    errorMessage = null;
    notifyListeners();
    try {
      final order = await _orderService.createOrder(items);
      isSubmittingOrder = false;
      notifyListeners();
      return order;
    } catch (e) {
      errorMessage = e.toString();
      isSubmittingOrder = false;
      notifyListeners();
      return null;
    }
  }

  // ===== อัปโหลดสลิป =====
  Future<bool> uploadSlip(int orderid, File imageFile) async {
    isUploadingSlip = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _paymentService.uploadSlip(orderid, imageFile);
      isUploadingSlip = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isUploadingSlip = false;
      notifyListeners();
      return false;
    }
  }

  // ===== โหลดหน้าแรกของประวัติออเดอร์ (เรียกตอนเข้าหน้า หรือ pull-to-refresh) =====
  Future<void> loadFirstPage({String? status}) async {
    isLoadingList = true;
    errorMessage = null;
    orders.clear();
    pagination = null;
    notifyListeners();
    try {
      final result = await _orderService.getMyOrders(
        page: 1,
        limit: 10,
        status: status,
      );
      orders.addAll(result['orders'] as List<OrderModel>);
      pagination = result['pagination'] as PaginationModel;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoadingList = false;
      notifyListeners();
    }
  }

  // ===== โหลดหน้าถัดไป (infinite scroll) =====
  Future<void> loadNextPage({String? status}) async {
    if (pagination == null || !pagination!.hasNextPage || isLoadingMore) return;

    isLoadingMore = true;
    notifyListeners();
    try {
      final nextPage = pagination!.page + 1;
      final result = await _orderService.getMyOrders(
        page: nextPage,
        limit: 10,
        status: status,
      );
      orders.addAll(result['orders'] as List<OrderModel>);
      pagination = result['pagination'] as PaginationModel;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  // ===== รายละเอียดออเดอร์เดี่ยว =====
  Future<void> loadOrderDetail(int orderid) async {
    isLoadingDetail = true;
    selectedOrder = null;
    notifyListeners();
    try {
      selectedOrder = await _orderService.getOrderDetail(orderid);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoadingDetail = false;
      notifyListeners();
    }
  }

  // เรียกหลังได้ event order_status จาก socket -> อัปเดตแถวในลิสต์แบบ real-time โดยไม่ต้อง reload ทั้งหน้า
  void patchOrderStatus(int orderid, String newStatus) {
    final index = orders.indexWhere((o) => o.orderid == orderid);
    if (index >= 0) {
      final old = orders[index];
      orders[index] = OrderModel(
        orderid: old.orderid,
        orderCode: old.orderCode,
        type: old.type,
        paymentMethod: old.paymentMethod,
        total: old.total,
        status: newStatus,
        createdAt: old.createdAt,
        rejectReason: old.rejectReason,
        slipImageUrl: old.slipImageUrl,
        items: old.items,
      );
      notifyListeners();
    }
  }
}
