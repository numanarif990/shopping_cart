import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_cart/db_helper.dart';

import 'modules/products_model.dart';

class CartProvider extends ChangeNotifier {

  DbHelper db = DbHelper();
  int _counter = 0;
  double _totalPrice = 0.0;

  int get counter => _counter;
  double get totalPrice => _totalPrice;

  late Future<List<Products>> _cartProducts;
  Future<List<Products>> get cartProducts => _cartProducts;

  Future<List<Products>> getCartProducts () async {
  _cartProducts = db.getCartList();
  return _cartProducts;
  }


  CartProvider() {
    _loadPrefItems();
  }

  void _setPrefItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('cart_item', _counter);
    prefs.setDouble('total_price', _totalPrice);
    notifyListeners();
  }

  void _loadPrefItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt('cart_item') ?? 0;
    _totalPrice = prefs.getDouble('total_price') ?? 0.0;
    notifyListeners();
  }

  void addCounter() {
    _counter++;
    _setPrefItems();
    notifyListeners();
  }

  void reduceCounter() {
    _counter--;
    _setPrefItems();
    notifyListeners();
  }

  void addTotalPrice(double productPrice) {
    _totalPrice += productPrice;
    _setPrefItems();
    notifyListeners();
  }

  void reduceTotalPrice(double productPrice) {
    _totalPrice -= productPrice;
    _setPrefItems();
    notifyListeners();
  }
}

