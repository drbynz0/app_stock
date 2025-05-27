class ImagesProduct {
  final String image;
  final String productId;

  ImagesProduct({ required this.image, required this.productId});

  ImagesProduct.fromJson(Map<String, dynamic> json)
      : image = json['image'],
        productId = json['product'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = image;
    data['product'] = productId;
    return data;
  }
}