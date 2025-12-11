// lib/data/product_data.dart
import '../models/product.dart';

final Map<String, List<Product>> productCatalog = {
  // NOTE: keys are lowercase and should match the category string you pass
  "chairs": [
    Product(
      id: "chair01",
      name: "Royal Wooden Chair",
      price: 1200,
      imageUrl: "https://picsum.photos/id/1062/600/400",
      category: "chairs",
    ),
    Product(
      id: "chair02",
      name: "Premium Leather Chair",
      price: 1650,
      imageUrl: "https://picsum.photos/id/237/600/400",
      category: "chairs",
    ),
    Product(
      id: "chair03",
      name: "Modern Plastic Chair",
      price: 900,
      imageUrl: "https://picsum.photos/id/1080/600/400",
      category: "chairs",
    ),
    Product(
      id: "chair04",
      name: "Comfort Armchair",
      price: 1450,
      imageUrl: "https://picsum.photos/id/1025/600/400",
      category: "chairs",
    ),
  ],

  "sofas": [
    Product(
      id: "sofa01",
      name: "Luxury 3-Seater Sofa",
      price: 8500,
      imageUrl: "https://picsum.photos/seed/sofa1/600/400",
      category: "sofas",
    ),
    Product(
      id: "sofa02",
      name: "Comfort Soft Sofa",
      price: 7800,
      imageUrl: "https://picsum.photos/seed/sofa2/600/400",
      category: "sofas",
    ),
    Product(
      id: "sofa03",
      name: "Corner Sofa",
      price: 9200,
      imageUrl: "https://picsum.photos/seed/sofa3/600/400",
      category: "sofas",
    ),
  ],

  "tables": [
    Product(
      id: "table01",
      name: "Classic Dining Table",
      price: 4500,
      imageUrl: "https://picsum.photos/id/1048/600/400",
      category: "tables",
    ),
    Product(
      id: "table02",
      name: "Study Table",
      price: 2200,
      imageUrl: "https://picsum.photos/id/1041/600/400",
      category: "tables",
    ),
    Product(
      id: "table03",
      name: "Coffee Table",
      price: 1500,
      imageUrl: "https://picsum.photos/id/1052/600/400",
      category: "tables",
    ),
  ],

  "beds": [
    Product(
      id: "bed01",
      name: "King Size Bed",
      price: 12000,
      imageUrl: "https://picsum.photos/id/1021/600/400",
      category: "beds",
    ),
    Product(
      id: "bed02",
      name: "Modern Single Bed",
      price: 6500,
      imageUrl: "https://picsum.photos/id/1031/600/400",
      category: "beds",
    ),
  ],

  "decor": [
    Product(
      id: "decor01",
      name: "Wall Frame",
      price: 650,
      imageUrl: "https://picsum.photos/id/1015/600/400",
      category: "decor",
    ),
    Product(
      id: "decor02",
      name: "Showpiece Sculpture",
      price: 950,
      imageUrl: "https://picsum.photos/id/1027/600/400",
      category: "decor",
    ),
  ],
};
