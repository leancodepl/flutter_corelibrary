class YourPostWasLiked {
  YourPostWasLiked({
    required this.postLink,
    required this.postName,
    required this.userName,
  });

  factory YourPostWasLiked.fromJson(Map<String, dynamic> json) =>
      YourPostWasLiked(
        postLink: json['PostLink'] as String,
        postName: json['PostName'] as String,
        userName: json['UserName'] as String,
      );

  final String postLink;
  final String postName;
  final String userName;
}
