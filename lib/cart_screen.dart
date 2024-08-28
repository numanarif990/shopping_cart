import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_cart/modules/products_model.dart';
import 'package:badges/badges.dart' as badges;

import 'cart_provider.dart';
import 'db_helper.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  DbHelper dbHelper = DbHelper();

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context,);

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Cart",
            style: TextStyle(fontSize: 28),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: badges.Badge(
                position: badges.BadgePosition.topEnd(top: -10, end: -8),
                badgeContent: Consumer<CartProvider>(
                  builder: (context, value, child) {
                    return Text(value.counter.toString(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 17));
                  },
                ),
                child: const Icon(
                  Icons.shopping_cart,
                  size: 45,
                ),
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FutureBuilder<List<Products>>(
                future: cart.getCartProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error1234: ${snapshot.error}'));
                  } else if (snapshot.data!.isEmpty) {
                    return const Column(
                      children: [
                        Image(
                            image: AssetImage("images/empty_cart.png")
                        ),
                        SizedBox(height: 15,),
                        Center(
                                child: Text("Explore products",style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
                        ),
                      ],
                    );
                  } else if (snapshot.hasData){
                    return Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final product = snapshot.data![index];
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
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.brand,
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500),
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
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: [
                                        InkWell(
                                            onTap: () {
                                              dbHelper.delete(
                                                  product.image.toString());
                                              print("product is deleted");
                                              cart.reduceCounter();
                                              cart.reduceTotalPrice(
                                                  product.price.toDouble());
                                            },
                                            child: const Icon(
                                              Icons.delete,
                                              size: 40,
                                              color: Colors.grey,
                                            )),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Container(
                                          height: 50,
                                          width: 120,
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius:
                                            BorderRadius.circular(10),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    int quantity = product.quantity.toInt();
                                                    int unitPrice = product.price ~/ product.quantity; // Assuming price is total price for current quantity
                                                    quantity++;
                                                    int newPrice = quantity * unitPrice;

                                                    dbHelper.updateQuantity(
                                                      Products(
                                                        id: product.id.toInt(),
                                                        title: product.title.toString(),
                                                        image: product.image.toString(),
                                                        price: newPrice,
                                                        description: product.description.toString(),
                                                        brand: product.brand.toString(),
                                                        model: product.model.toString(),
                                                        color: product.color.toString(),
                                                        category: product.category.toString(),
                                                        discount: product.discount.toInt(),
                                                        quantity: quantity,
                                                      ),
                                                    ).then((onValue) {
                                                      cart.addTotalPrice(unitPrice.toDouble());
                                                    }).onError((error, stackTrace) {
                                                      print(error);
                                                    });
                                                  },
                                                  child: const Icon(
                                                    Icons.add,
                                                    size: 30,
                                                    color: Colors.white,
                                                  ),
                                                ),

                                                Text(
                                                  product.quantity.toString(),
                                                  style: const TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white),
                                                ),

                                                InkWell(
                                                  onTap: () {
                                                    int quantity = product.quantity.toInt();
                                                    int unitPrice = product.price ~/ product.quantity; // Assuming price is total price for current quantity
                                                    if (quantity > 1) { // Ensure quantity does not go below 1
                                                      quantity--;
                                                      int newPrice = quantity * unitPrice;

                                                      dbHelper.updateQuantity(
                                                        Products(
                                                          id: product.id.toInt(),
                                                          title: product.title.toString(),
                                                          image: product.image.toString(),
                                                          price: newPrice,
                                                          description: product.description.toString(),
                                                          brand: product.brand.toString(),
                                                          model: product.model.toString(),
                                                          color: product.color.toString(),
                                                          category: product.category.toString(),
                                                          discount: product.discount.toInt(),
                                                          quantity: quantity,
                                                        ),
                                                      ).then((onValue) {
                                                        cart.reduceTotalPrice(unitPrice.toDouble());
                                                      }).onError((error, stackTrace) {
                                                        print(error);
                                                      });
                                                    }
                                                  },
                                                  child: const Icon(
                                                    Icons.remove,
                                                    size: 30,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ])
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  else {
                    return const Center(child: Text('No products found'));
                  }
                },
              ),
              Consumer<CartProvider>(builder: (context, value, child) {
                return Visibility(
                  visible: value.totalPrice.toStringAsFixed(2) == "0.00"
                      ? false
                      : true,
                  child: Column(
                    children: [
                      ReuseAble(
                          title: "Sub total",
                          value: r'$' + value.totalPrice.toStringAsFixed(2)),
                     const ReuseAble (
                          title: "Discount 5%",
                          value: r'$'),
                      ReuseAble(
                          title: "Sub total",
                          value: r'$' + value.totalPrice.toStringAsFixed(2)),
                    ],
                  ),
                );
              })
            ],
          ),
        ));
  }
}

class ReuseAble extends StatelessWidget {
  final String title, value;

  const ReuseAble({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18),
          )
        ],
      ),
    );
  }
}
