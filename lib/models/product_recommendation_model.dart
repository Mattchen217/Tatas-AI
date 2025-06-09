```dart
class ProductRecommendationModel {
  final String id;
  final String name;
  final String price; // e.g., "¥1299", "$199.99"
  final List<String> features;
  final String imageUrl;
  final String productUrl; // URL for the "View" or "Details" button

  ProductRecommendationModel({
    required this.id,
    required this.name,
    required this.price,
    required this.features,
    required this.imageUrl,
    required this.productUrl,
  });

  factory ProductRecommendationModel.fromMap(Map<String, dynamic> map) {
    return ProductRecommendationModel(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(), // Fallback ID
      name: map['name'] ?? 'Unnamed Product',
      price: map['price'] ?? 'N/A',
      features: List<String>.from(map['features'] ?? []),
      imageUrl: map['imageUrl'] ?? 'https://via.placeholder.com/150?text=No+Image', // Placeholder if no image
      productUrl: map['productUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'features': features,
      'imageUrl': imageUrl,
      'productUrl': productUrl,
    };
  }
}

// Helper class for the structuredContent of ChatMessageModel
// when type is MessageType.productRecommendationCard
class ProductRecommendationPayload {
  final List<ProductRecommendationModel> products;
  final String? title; // Optional title for the card, e.g., "You might like these:"

  ProductRecommendationPayload({required this.products, this.title});

  factory ProductRecommendationPayload.fromMap(Map<String, dynamic> map) {
    var productList = <ProductRecommendationModel>[];
    if (map['products'] != null && map['products'] is List) {
      for (var productMap in (map['products'] as List)) {
        if (productMap is Map) {
          productList.add(ProductRecommendationModel.fromMap(Map<String, dynamic>.from(productMap)));
        }
      }
    }
    return ProductRecommendationPayload(
      products: productList,
      title: map['title'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cardType': 'productRecommendation', // To identify the type of card in structuredContent
      'title': title,
      'products': products.map((p) => p.toMap()).toList(),
    };
  }
}
```
