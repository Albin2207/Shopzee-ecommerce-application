import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminProvider extends ChangeNotifier {
  List<QueryDocumentSnapshot> categories = [];
  List<QueryDocumentSnapshot> products = [];
  List<QueryDocumentSnapshot> orders = [];
  
  StreamSubscription<QuerySnapshot>? _categorySubscription;
  StreamSubscription<QuerySnapshot>? _productsSubscription;
  StreamSubscription<QuerySnapshot>? _ordersSubscription;

  // Analytics data
  int totalCategories = 0;
  int totalProducts = 0;
  int totalOrders = 0;
  int ordersDelivered = 0;
  int ordersCancelled = 0;
  int ordersOnTheWay = 0;
  int orderPendingProcess = 0;

  // Revenue metrics
  double totalRevenue = 0;
  double averageOrderValue = 0;

  AdminProvider() {
    initializeData();
  }

  void initializeData() {
    getCategories();
    getProducts();
    readOrders();
  }

  void getCategories() {
    _categorySubscription?.cancel();
    _categorySubscription = FirebaseFirestore.instance
        .collection("shop_categories")
        .orderBy("priority", descending: true)
        .snapshots()
        .listen((snapshot) {
      categories = snapshot.docs;
      totalCategories = snapshot.docs.length;
      notifyListeners();
    });
  }

  void getProducts() {
    _productsSubscription?.cancel();
    _productsSubscription = FirebaseFirestore.instance
        .collection("shop_products")
        .orderBy("category", descending: true)
        .snapshots()
        .listen((snapshot) {
      products = snapshot.docs;
      totalProducts = snapshot.docs.length;
      notifyListeners();
    });
  }

  void readOrders() {
    _ordersSubscription?.cancel();
    _ordersSubscription = FirebaseFirestore.instance
        .collection("shop_orders")
        .orderBy("created_at", descending: true)
        .snapshots()
        .listen((snapshot) {
      orders = snapshot.docs;
      totalOrders = snapshot.docs.length;
      _calculateOrderMetrics();
      notifyListeners();
    });
  }

  void _calculateOrderMetrics() {
    ordersDelivered = 0;
    ordersCancelled = 0;
    ordersOnTheWay = 0;
    orderPendingProcess = 0;
    totalRevenue = 0;

    for (var order in orders) {
      // Safely access the data using try-catch
      try {
        final data = order.data() as Map<String, dynamic>;
        
        // Calculate order status counts
        switch (data['status']) {
          case "DELIVERED":
            ordersDelivered++;
            break;
          case "CANCELLED":
            ordersCancelled++;
            break;
          case "ON_THE_WAY":
            ordersOnTheWay++;
            break;
          default:
            orderPendingProcess++;
        }

        // Calculate revenue metrics
        if (data.containsKey('total') && data['total'] != null) {
          totalRevenue += (data['total'] as num).toDouble();
        }
      } catch (e) {
        print('Error processing order: ${order.id} - $e');
      }
    }

    // Calculate average order value
    averageOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;
  }

  List<Map<String, dynamic>> getProductAnalytics() {
    Map<String, int> productQuantities = {};
    
    for (var order in orders) {
      try {
        final data = order.data() as Map<String, dynamic>;
        final orderProducts = data['products'] as List?;
        
        if (orderProducts != null) {
          for (var product in orderProducts) {
            final name = product['name'] as String?;
            final quantity = product['quantity'] as int?;
            
            if (name != null && quantity != null) {
              productQuantities[name] = (productQuantities[name] ?? 0) + quantity;
            }
          }
        }
      } catch (e) {
        print('Error processing product analytics: ${order.id} - $e');
      }
    }

    return productQuantities.entries
        .map((e) => {'name': e.key, 'quantity': e.value})
        .toList()
      ..sort((a, b) => (b['quantity'] as int).compareTo(a['quantity'] as int));
  }

  void cancelProvider() {
    _ordersSubscription?.cancel();
    _productsSubscription?.cancel();
    _categorySubscription?.cancel();
  }

  @override
  void dispose() {
    cancelProvider();
    super.dispose();
  }
}