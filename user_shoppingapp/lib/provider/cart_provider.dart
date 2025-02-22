import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';
import 'package:user_shoppingapp/models/cart_model.dart';
import 'package:user_shoppingapp/models/product_model.dart';

class CartProvider extends ChangeNotifier {
  StreamSubscription<QuerySnapshot>? _cartSubscription;
  StreamSubscription<QuerySnapshot>? _productSubscription;

  bool isLoading = true;

  List<CartModel> carts = [];
  List<String> cartUids = [];
  List<ProductsModel> products = [];
  int totalCost = 0;
  int totalQuantity = 0;

  CartProvider() {
    readCartData();
  }

  // Add product to the cart along with quantity
  void addToCart(CartModel cartModel) {
    DbService().addToCart(cartData: cartModel);
    readCartData(); // Refresh to get updated data
    notifyListeners();
  }

  // Stream and read cart data
  void readCartData() {
    isLoading = true;
    _cartSubscription?.cancel();
    _cartSubscription = DbService().readUserCart().listen((snapshot) {
      carts = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return CartModel.fromJson(data);
      }).toList();

      cartUids = carts.map((cart) => cart.productId).toList();

      if (carts.isNotEmpty) {
        readCartProducts(cartUids);
      }

      isLoading = false;
      notifyListeners();
    });
  }

  // Read cart products
  void readCartProducts(List<String> uids) {
    _productSubscription?.cancel();
    _productSubscription = DbService().searchProducts(uids).listen((snapshot) {
      Map<String, ProductsModel> productMap = {};

      for (var doc in snapshot.docs) {
        var product = ProductsModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
        productMap[product.id] = product;
      }

      products = carts.map((cartItem) {
        return productMap[cartItem.productId] ?? ProductsModel(
          name: "Unknown",
          description: "",
          image: "",
          images: [],
          old_price: 0,
          new_price: 0,
          category: "",
          id: cartItem.productId,
          maxQuantity: 0,
          sizes: [],
          colors: [],
        );
      }).toList();

      isLoading = false;
      addCost(products, carts);
      calculateTotalQuantity();
      notifyListeners();
    });
  }

  void updateVariants(String productId, {String? size, String? color}) async {
    await DbService().updateVariants(productId, size: size, color: color);
    readCartData();
    notifyListeners();
  }

  // Add cost of all products
  void addCost(List<ProductsModel> products, List<CartModel> carts) {
    totalCost = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < carts.length; i++) {
        totalCost += carts[i].quantity * products[i].new_price;
      }
      notifyListeners();
    });
  }

  // Calculate total quantity for products
  void calculateTotalQuantity() {
    totalQuantity = 0;
    for (int i = 0; i < carts.length; i++) {
      totalQuantity += carts[i].quantity;
    }
    print("totalQuantity: $totalQuantity");
    notifyListeners();
  }

  void updateCartQuantity(String productId, int quantity, {String? size, String? color}) async {
    await DbService().updateCartQuantity(
      productId,
      quantity,
      size: size,
      color: color,
    );

    readCartData();
    notifyListeners();
  }

  // Delete product from the cart
  void deleteItem(String productId, String? size, String? color) async {
    await DbService().deleteItemFromCart(
      productId: productId,
      size: size,
      color: color,
    );

    readCartData();
    notifyListeners();
  }

  // Decrease the count of product
  void decreaseCount(String productId) async {
    await DbService().decreaseCount(productId: productId);
    notifyListeners();
  }

  void cancelProvider() {
    _cartSubscription?.cancel();
    _productSubscription?.cancel();
  }

  @override
  void dispose() {
    cancelProvider();
    super.dispose();
  }
}