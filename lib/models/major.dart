class Major {
  int id;
  String majorName;

  Major({required this.id, required this.majorName});

  factory Major.fromJson(Map<String, dynamic> json) {
    return Major(
      id: int.parse(json['id'].toString()),
      majorName: json['major_name'],
    );
  }
}
