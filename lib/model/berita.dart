class NewsData {
  final String status;
  final String message;
  final List<News> results;

  NewsData(
      {required this.status, required this.message, required this.results});

  factory NewsData.fromJson(Map<String, dynamic> json) {
    var list = json['data']['results'] as List;
    List<News> news = list.map((i) => News.fromJson(i)).toList();

    return NewsData(
      status: json['status'],
      message: json['message'],
      results: news,
    );
  }
}

class News {
  final String title;
  final String publishedAt;
  final String image;
  final String url;
  final String description;

  News({
    required this.title,
    required this.publishedAt,
    required this.image,
    required this.url,
    required this.description,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      title: json['title'],
      publishedAt: json['published_at'],
      image: json['image'],
      url: json['url'],
      description: json['description'],
    );
  }
}
