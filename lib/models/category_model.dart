class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;
  final String description;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.description = '',
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return CategoryModel(
      id: id ?? map['id'] ?? '',
      name: map['name'] ?? '',
      imageUrl: (map['imageUrl'] as String?) ?? '',
      description: map['description'] ?? '',
    );
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json, {String? id}) =>
      CategoryModel.fromMap(json, id: id);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
    };
  }
}
