class TopGainerData {
  final String status;
  final String message;
  final List<TopGainer> results;

  TopGainerData(
      {required this.status, required this.message, required this.results});

  factory TopGainerData.fromJson(Map<String, dynamic> json) {
    var list = json['data']['results'] as List;
    List<TopGainer> topGainers =
        list.map((i) => TopGainer.fromJson(i)).toList();

    return TopGainerData(
      status: json['status'],
      message: json['message'],
      results: topGainers,
    );
  }
}

class TopGainer {
  final String symbol;
  final Company company;
  final double close;
  final double change;
  final double percent;

  TopGainer({
    required this.symbol,
    required this.company,
    required this.close,
    required this.change,
    required this.percent,
  });

  factory TopGainer.fromJson(Map<String, dynamic> json) {
    return TopGainer(
      symbol: json['symbol'],
      company: Company.fromJson(json['company']),
      close: json['close'].toDouble(),
      change: json['change'].toDouble(),
      percent: json['percent'].toDouble(),
    );
  }
}

class Company {
  final String symbol;
  final String name;
  final String logo;

  Company({required this.symbol, required this.name, required this.logo});

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      symbol: json['symbol'],
      name: json['name'],
      logo: json['logo'],
    );
  }
}
