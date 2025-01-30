import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_shoppingapp/containers/additional_confirm.dart';
import 'package:admin_shoppingapp/controllers/db_service.dart';
import 'package:admin_shoppingapp/models/products_model.dart';
import 'package:admin_shoppingapp/providers/admin_provider.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Products"),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, value, child) {
          List<ProductsModel> products =
              ProductsModel.fromJsonList(value.products);

          if (products.isEmpty) {
            return Center(
              child: Text("No Products Found"),
            );
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ListTile(
                onLongPress: () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text("Choose want you want"),
                            content: Text("Delete cannot be undone"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    showDialog(
                                        context: context,
                                        builder: (context) => AdditionalConfirm(
                                            contentText:
                                                "Are you sure you want to delete this product",
                                            onYes: () {
                                              DbService().deleteProduct(
                                                  docId: products[index].id);
                                              Navigator.pop(context);
                                            },
                                            onNo: () {
                                              Navigator.pop(context);
                                            }));
                                  },
                                  child: Text("Delete Product")),
                              TextButton(
                                  onPressed: () {},
                                  child: Text("Edit Product")),
                            ],
                          ));
                },
                onTap: () => Navigator.pushNamed(context, "/view_product",
                    arguments: products[index]),
                leading: SizedBox(
                  height: 50,
                  width: 50,
                  child: Image.network(
                    // Handle both old and new image formats
                    products[index].images.isNotEmpty
                        ? products[index]
                            .images
                            .first 
                        : products[index]
                                .image
                                .isNotEmpty 
                            ? products[index].image
                            : 'https://via.placeholder.com/50', 
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  products[index].name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("₹ ${products[index].new_price.toString()}"),
                    Container(
                        padding: EdgeInsets.all(4),
                        color: Theme.of(context).primaryColor,
                        child: Text(
                          products[index].category.toUpperCase(),
                          style: TextStyle(color: Colors.white),
                        ))
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit_outlined),
                  onPressed: () {
                    Navigator.pushNamed(context, "/add_product",
                        arguments: products[index]);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, "/add_product");
        },
      ),
    );
  }
}
