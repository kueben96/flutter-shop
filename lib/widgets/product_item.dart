import 'package:flutter/material.dart';
import 'package:shop_app/screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  ProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: GridTile(
        child: GestureDetector(
          onTap: () => Navigator.of(context)
              .pushNamed(ProducDetailScreen.routeName, arguments: id),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: GridTileBar(
            backgroundColor: Colors.black87,
            leading: IconButton(
              icon: Icon(Icons.favorite),
              onPressed: () {},
              color: Theme.of(context).accentColor,
            ),
            trailing: IconButton(
              icon: Icon(Icons.shopping_bag),
              onPressed: () {},
              color: Theme.of(context).accentColor,
            ),
            title: Text(
              title,
              textAlign: TextAlign.center,
            )),
      ),
    );
  }
}
