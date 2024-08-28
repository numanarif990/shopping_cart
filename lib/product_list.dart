import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';
import 'package:shopping_cart/cart_provider.dart';
import 'package:shopping_cart/cart_screen.dart';
import 'package:shopping_cart/db_helper.dart';
import 'package:shopping_cart/modules/products_model.dart';
import 'package:http/http.dart' as http;

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  DbHelper dbHelper = DbHelper();

  // Use a ValueNotifier for the badge content
  final ValueNotifier<int> badgeContent = ValueNotifier<int>(0);

  Future<ProductsModel> getProductList() async {
    try {
      final response = await http.get(Uri.parse("https://fakestoreapi.in/api/products"));
      var data = jsonDecode(response.body.toString());
      if (response.statusCode == 200) {
        // print(data);
        return ProductsModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch products. Status code: ${response.statusCode}');
      }
    } catch (error) {
      rethrow; // Rethrow the error for handling in FutureBuilder
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    // Update the badge content when the counter changes
    // badgeContent.value = cart.counter;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Product List",
          style: TextStyle(fontSize: 28),
        ),
        actions: [
          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> const CartScreen()));
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: badges.Badge(
                position: badges.BadgePosition.topEnd(top: -10, end: -8),
                badgeContent: Consumer<CartProvider>(
                  builder: (context, value, child){
                    return Text(
                      value.counter.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 17)
                    );
                  },
                ),
                child: const Icon(
                  Icons.shopping_cart,
                  size: 45,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<ProductsModel>(
              future: getProductList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error1234: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data?.products != null) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.products!.length,
                      itemBuilder: (context, index) {
                        final product = snapshot.data!.products![index];

                        return Card(
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Image(
                                  image: NetworkImage(product.image),
                                  height: 100.0,
                                  width: 100.0,
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.brand,
                                        style: const TextStyle(
                                            fontSize: 20, fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        product.color,
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                      Text(
                                        "Category: " + product.category,
                                        style: const TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(
                                        "Price: " + product.price.toString(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        print("Product ID: ${product.id}");
                                        print("Product Title: ${product.title}");
                                        print("Product Image: ${product.image}");
                                        print("Product Price: ${product.price}");
                                        print("Product Description: ${product.description}");
                                        print("Product Brand: ${product.brand}");
                                        print("Product Model: ${product.model}");
                                        print("Product Color: ${product.color}");
                                        print("Product Category: ${product.category}");
                                        print("Product Discount: ${product.discount}");

                                        dbHelper
                                            .insert(Products(
                                            id: product.id,
                                            title: product.title,
                                            image: product.image,
                                            price: product.price,
                                            description: product.description,
                                            brand: product.brand,
                                            model: product.model,
                                            color: product.color,
                                            category: product.category,
                                            discount: product.discount,
                                            quantity: 1 // Set default quantity to 1
                                        ))
                                            .then((onValue) {
                                          print("Product added to cart");
                                          cart.addTotalPrice(product.price.toDouble());
                                          cart.addCounter();
                                        }).onError((error, stackTrace) {
                                          print(error.toString());
                                        });
                                      },
                                      child: Container(
                                        height: 50,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Center(
                                            child: Text(
                                              "Add to Cart",
                                              style: TextStyle(
                                                  fontSize: 15, color: Colors.white),
                                            )),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return const Center(child: Text('No products found'));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
