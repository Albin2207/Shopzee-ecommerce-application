import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';
import 'package:user_shoppingapp/models/category_model.dart';

class CategoryContainer extends StatefulWidget {
  const CategoryContainer({super.key});

  @override
  State<CategoryContainer> createState() => _CategoryContainerState();
}

class _CategoryContainerState extends State<CategoryContainer> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DbService().readCategories(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<CategoriesModel> categories =
              CategoriesModel.fromJsonList(snapshot.data!.docs);
          if (categories.isEmpty) {
            return SizedBox();
          } else {
            return Container(
              height: 110,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 12),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return CategoryButton(
                    imagepath: categories[index].image,
                    name: categories[index].name,
                  );
                },
              ),
            );
          }
        } else {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 110,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        }
      },
    );
  }
}

class CategoryButton extends StatefulWidget {
  final String imagepath, name;
  const CategoryButton({super.key, required this.imagepath, required this.name});

  @override
  State<CategoryButton> createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<CategoryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () => Navigator.pushNamed(
        context,
        "/specific",
        arguments: {"name": widget.name},
      ),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(4),
        height: 95,
        width: 95,
        transform: Matrix4.identity()
          ..scale(_isPressed ? 0.95 : 1.0),
        decoration: BoxDecoration(
          color: Colors.green[50],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: _isPressed ? 2 : 4,
              offset: Offset(0, _isPressed ? 1 : 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              widget.imagepath,
              height: 45,
            ),
            SizedBox(height: 5),
            Text(
              "${widget.name.substring(0, 1).toUpperCase()}${widget.name.substring(1)}",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}