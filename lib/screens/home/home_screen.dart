import 'package:flutter/material.dart';
import '../product/product_list_screen.dart';

// Product class
class Product {
  final String id;
  final String name;
  final int price;
  final String imageUrl;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
  });
}

// Minimal product data - 2 products from each category
final Map<String, List<Product>> productCatalog = {
  "chairs": [
    Product(
      id: "chair01",
      name: "Modern Accent Chairs",
      price: 15700,
      imageUrl:
          "https://m.media-amazon.com/images/I/81t+ZaPswoL._AC_SL1000__.jpg",
      category: "chairs",
    ),
    Product(
      id: "chair02",
      name: "KCC Modern Velvet",
      price: 30500,
      imageUrl:
          "https://m.media-amazon.com/images/I/61-e75xsXEL._AC_SL400_.jpg",
      category: "chairs",
    ),
  ],
  "sofas": [
    Product(
      id: "sofa01",
      name: "Recliner Sofa",
      price: 15000,
      imageUrl:
          "https://www.nilkamalfurniture.com/cdn/shop/files/SIERRANeo_Brown_01_b99023f0-b1d4-4550-92cc-fd9b2adbe88f.webp?v=1753182800&width=900",
      category: "sofas",
    ),
    Product(
      id: "sofa02",
      name: "Electric Recliner Sofa",
      price: 16590,
      imageUrl:
          "https://www.nilkamalfurniture.com/cdn/shop/files/Electro1STRRECLS07.jpg?v=1731908182&width=900",
      category: "sofas",
    ),
  ],
  "tables": [
    Product(
      id: "table01",
      name: "Endura Office Table",
      price: 15000,
      imageUrl:
          "https://www.nilkamalfurniture.com/cdn/shop/products/NilkamalEnduraOfficeTable_Brown.jpg?v=1681293846&width=900",
      category: "tables",
    ),
    Product(
      id: "table02",
      name: "Orange Poppy Desk",
      price: 3299,
      imageUrl:
          "https://www.nilkamalfurniture.com/cdn/shop/files/ORANGEPOPPYREDACTIVITYDESKNEW.jpg?v=1690966157&width=900",
      category: "tables",
    ),
  ],
  "beds": [
    Product(
      id: "bed01",
      name: "Arthur Plus Double Bed",
      price: 9999,
      imageUrl:
          "https://www.nilkamalfurniture.com/cdn/shop/files/ArthurDouble_WOS_LS01_3927bfe6-6b13-4966-9047-f451dc808987.jpg?v=1761555389&width=900",
      category: "beds",
    ),
    Product(
      id: "bed02",
      name: "Striker Metal Bed",
      price: 7500,
      imageUrl:
          "https://www.nilkamalfurniture.com/cdn/shop/files/6_5d447f26-b2a5-4e7c-ab15-3302ebd3253b.jpg?v=1691398937&width=900",
      category: "beds",
    ),
  ],
  "decor": [
    Product(
      id: "decor01",
      name: "Comfy Premium",
      price: 2050,
      imageUrl:
          "https://cdn.othoba.com/images/thumbs/1400756_comfy-premium-comforter-double-233cm-x-208cm-q-301.jpeg",
      category: "decor",
    ),
    Product(
      id: "decor02",
      name: "Comfy Comforter Single",
      price: 1500,
      imageUrl:
          "https://cdn.othoba.com/images/thumbs/0704698_comfy-comforter-single-228cm-x-152cm-q-204-stock-clearance-sale-offer.jpeg",
      category: "decor",
    ),
  ],
};

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  // Helper function to get first 2 products from each category
  List<Product> getRecommendedProducts() {
    List<Product> recommended = [];
    final categories = ["chairs", "sofas", "tables", "beds", "decor"];

    for (var category in categories) {
      final products = productCatalog[category];
      if (products != null && products.length >= 2) {
        recommended.addAll(products.take(2));
      }
    }

    return recommended;
  }

  @override
  Widget build(BuildContext context) {
    final recommendedProducts = getRecommendedProducts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Furniture'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categories Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Browse Categories",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Categories in a row (non-scrollable)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryButton(context, "Chairs", "chairs"),
                        const SizedBox(width: 5),
                        _buildCategoryButton(context, "Sofas", "sofas"),
                        const SizedBox(width: 5),
                        _buildCategoryButton(context, "Tables", "tables"),
                        const SizedBox(width: 5),
                        _buildCategoryButton(context, "Beds", "beds"),
                        const SizedBox(width: 5),
                        _buildCategoryButton(context, "Decor", "decor"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Recommended Products Section - FIXED: Only takes needed space
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16, right: 16, top: 8),
                  child: Text(
                    "Recommended Products",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 270,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: recommendedProducts.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final product = recommendedProducts[index];
                      return SizedBox(
                        width: 220, // Slightly smaller width
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: SizedBox(
                                  height: 130, // Smaller image height
                                  width: double.infinity,
                                  child: Image.network(
                                    product.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey.shade100,
                                        child: const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey,
                                            size: 40,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              // Product Details
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '৳${product.price}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.brown.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.brown.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        product.category.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.brown.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Add some bottom padding so it doesn't touch the navigation bar
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(
    BuildContext context,
    String label,
    String categoryId,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductListScreen(category: categoryId),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.brown.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.brown.shade800,
          ),
        ),
      ),
    );
  }
}
