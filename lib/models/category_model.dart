class CategoryModel {
  final int catid;
  final String catname;

  CategoryModel({required this.catid, required this.catname});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(catid: json['catid'], catname: json['catname']);
  }
}
