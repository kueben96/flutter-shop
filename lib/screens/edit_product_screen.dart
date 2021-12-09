import 'package:flutter/material.dart';
import 'package:shop_app/providers/product.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({Key? key}) : super(key: key);

  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  // for the price to be focused and get the next option
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  // text editing controller to preview the image before the form is submitted
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();

  // key to access form
  final _form = GlobalKey<FormState>();

  // Product
  var _editedProduct =
      Product(id: '', title: '', description: '', price: 0, imageUrl: '');

  void initState() {
    // point to function to tell flutter to execute the function when focus changes
    _imageUrlFocusNode.addListener(_uppdateImageUrl);
    super.initState();
  }

  // dispose focus nodes after usage to free up the memory
  void dispose() {
    _imageUrlFocusNode.removeListener(_uppdateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();

    super.dispose();
  }

  void _uppdateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  void _saveForm() {
    _form.currentState!.save();
    print(_editedProduct.title);
    print(_editedProduct.price);
    print(_editedProduct.description);
    print(_editedProduct.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(onPressed: _saveForm, icon: Icon(Icons.save))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          // can also insted use column and single child scroll view
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                // move focus from title input to price input
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
                onSaved: (value) {
                  if (value == null) return;
                  _editedProduct = Product(
                      title: value,
                      description: _editedProduct.description,
                      price: _editedProduct.price,
                      imageUrl: _editedProduct.imageUrl,
                      id: _editedProduct.id);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                textInputAction: TextInputAction.next,
                focusNode: _priceFocusNode,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_descriptionFocusNode);
                },
                onSaved: (value) {
                  if (value == null) return;
                  _editedProduct = Product(
                      title: _editedProduct.title,
                      description: _editedProduct.description,
                      price: double.parse(value),
                      imageUrl: _editedProduct.imageUrl,
                      id: _editedProduct.id);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                focusNode: _descriptionFocusNode,
                onSaved: (value) {
                  if (value == null) return;
                  _editedProduct = Product(
                      title: _editedProduct.title,
                      description: value,
                      price: _editedProduct.price,
                      imageUrl: _editedProduct.imageUrl,
                      id: _editedProduct.id);
                },
              ),
              // Image Preview
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.only(
                        top: 8,
                        right: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.grey,
                        ),
                      ),
                      child: _imageUrlController.text.isEmpty
                          ? Text('Enter a URL')
                          : FittedBox(
                              child: Image.network(_imageUrlController.text),
                              fit: BoxFit.fill,
                            )),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Image URL'),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      // controller is updated when we type into that field
                      controller: _imageUrlController,
                      focusNode: _imageUrlFocusNode,
                      onFieldSubmitted: (_) {
                        _saveForm();
                      },
                      onSaved: (value) {
                        if (value == null) return;
                        _editedProduct = Product(
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            price: _editedProduct.price,
                            imageUrl: value,
                            id: _editedProduct.id);
                      },
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
