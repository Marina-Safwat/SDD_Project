class Category {
  String name;
  String imageUrl;

  Category(this.name, this.imageUrl);

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      json['name'] ?? '',
      json['image_url'] ?? json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "image_url": imageUrl,
    };
  }
}
