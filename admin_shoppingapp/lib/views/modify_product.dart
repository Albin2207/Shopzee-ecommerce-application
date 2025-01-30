import 'package:admin_shoppingapp/controllers/cloudinary_service.dart';
import 'package:admin_shoppingapp/controllers/db_service.dart';
import 'package:admin_shoppingapp/models/products_model.dart';
import 'package:admin_shoppingapp/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ModifyProduct extends StatefulWidget {
  const ModifyProduct({super.key});

  @override
  State<ModifyProduct> createState() => _ModifyProductState();
}

class _ModifyProductState extends State<ModifyProduct> {
  late String productId = "";
  final formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController oldPriceController = TextEditingController();
  TextEditingController newPriceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController descController = TextEditingController();
  
  final ImagePicker picker = ImagePicker();
  
  // New variables for multiple images and variants
  List<String> imageUrls = [];
  List<String> selectedSizes = [];
  List<String> selectedColors = [];

  // Predefined lists for sizes and colors
  final List<String> availableSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  final List<String> availableColors = ['Red', 'Blue', 'Green', 'Black', 'White', 'Grey'];

  void _pickImageAndCloudinaryUpload() async {
    final List<XFile> selectedImages = await picker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      for (XFile image in selectedImages) {
        String? imageUrl = await uploadToCloudinary(image);
        if (imageUrl != null) {
          setState(() {
            imageUrls.add(imageUrl);
          });
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Images uploaded successfully")));
    }
  }

  void toggleSize(String size) {
    setState(() {
      if (selectedSizes.contains(size)) {
        selectedSizes.remove(size);
      } else {
        selectedSizes.add(size);
      }
    });
  }

  void toggleColor(String color) {
    setState(() {
      if (selectedColors.contains(color)) {
        selectedColors.remove(color);
      } else {
        selectedColors.add(color);
      }
    });
  }

  setData(ProductsModel data) {
    productId = data.id;
    nameController.text = data.name;
    oldPriceController.text = data.old_price.toString();
    newPriceController.text = data.new_price.toString();
    quantityController.text = data.maxQuantity.toString();
    categoryController.text = data.category;
    descController.text = data.description;
    imageUrls = data.images;
    selectedSizes = data.sizes;
    selectedColors = data.colors;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments;
    if (arguments != null && arguments is ProductsModel) {
      setData(arguments);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(productId.isNotEmpty ? "Update Product" : "Add Product"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  validator: (v) => v!.isEmpty ? "This cant be empty." : null,
                  decoration: InputDecoration(
                    hintText: "Product Name",
                    label: Text("Product Name"),
                    fillColor: Colors.deepPurple.shade50,
                    filled: true
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: oldPriceController,
                  validator: (v) => v!.isEmpty ? "This cant be empty." : null,
                  decoration: InputDecoration(
                    hintText: "Original Price",
                    label: Text("Original Price"),
                    fillColor: Colors.deepPurple.shade50,
                    filled: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: newPriceController,
                  validator: (v) => v!.isEmpty ? "This cant be empty." : null,
                  decoration: InputDecoration(
                    hintText: "Sell Price",
                    label: Text("Sell Price"),
                    fillColor: Colors.deepPurple.shade50,
                    filled: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: quantityController,
                  validator: (v) => v!.isEmpty ? "This cant be empty." : null,
                  decoration: InputDecoration(
                    hintText: "Quantity Left",
                    label: Text("Quantity Left"),
                    fillColor: Colors.deepPurple.shade50,
                    filled: true
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: categoryController,
                  validator: (v) => v!.isEmpty ? "This cant be empty." : null,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: "Category",
                    label: Text("Category"),
                    fillColor: Colors.deepPurple.shade50,
                    filled: true
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Select Category :"),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Consumer<AdminProvider>(
                              builder: (context, value, child) =>
                                SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: value.categories
                                      .map((e) => TextButton(
                                        onPressed: () {
                                          categoryController.text = e["name"];
                                          setState(() {});
                                          Navigator.pop(context);
                                        },
                                        child: Text(e["name"])
                                      )).toList(),
                                  ),
                                )
                            )
                          ],
                        ),
                      )
                    );
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: descController,
                  validator: (v) => v!.isEmpty ? "This cant be empty." : null,
                  decoration: InputDecoration(
                    hintText: "Description",
                    label: Text("Description"),
                    fillColor: Colors.deepPurple.shade50,
                    filled: true
                  ),
                  maxLines: 8,
                ),
                
                // Size Selection
                const SizedBox(height: 20),
                const Text("Select Sizes:", 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                ),
                Wrap(
                  spacing: 8,
                  children: availableSizes.map((size) => FilterChip(
                    label: Text(size),
                    selected: selectedSizes.contains(size),
                    onSelected: (selected) => toggleSize(size),
                    backgroundColor: Colors.deepPurple.shade50,
                    selectedColor: Colors.deepPurple.shade200,
                  )).toList(),
                ),

                // Color Selection
                const SizedBox(height: 20),
                const Text("Select Colors:", 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                ),
                Wrap(
                  spacing: 8,
                  children: availableColors.map((color) => FilterChip(
                    label: Text(color),
                    selected: selectedColors.contains(color),
                    onSelected: (selected) => toggleColor(color),
                    backgroundColor: Colors.deepPurple.shade50,
                    selectedColor: Colors.deepPurple.shade200,
                  )).toList(),
                ),

                // Image Section
                const SizedBox(height: 20),
                const Text("Product Images:", 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                ),
                
                // Image preview section
                imageUrls.isEmpty
                    ? const Center(child: Text("No images selected"))
                    : SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: imageUrls.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.all(8),
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Image.network(
                                      imageUrls[index],
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          imageUrls.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                ElevatedButton(
                  onPressed: _pickImageAndCloudinaryUpload,
                  child: Text("Add Images")
                ),
                
                SizedBox(height: 20),
                
                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        if (imageUrls.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please add at least one image"))
                          );
                          return;
                        }
                        
                        Map<String, dynamic> data = {
                          "name": nameController.text,
                          "old_price": int.parse(oldPriceController.text),
                          "new_price": int.parse(newPriceController.text),
                          "quantity": int.parse(quantityController.text),
                          "category": categoryController.text,
                          "desc": descController.text,
                          "images": imageUrls,
                          "sizes": selectedSizes,
                          "colors": selectedColors,
                        };

                        if (productId.isNotEmpty) {
                          DbService().updateProduct(docId: productId, data: data);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Product Updated")));
                        } else {
                          DbService().createProduct(data: data);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Product Added")));
                        }
                      }
                    },
                    child: Text(productId.isNotEmpty ? "Update Product" : "Add Product")
                  )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}