// Definisi kelas Company
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

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'name': name,
        'logo': logo,
      };
}

// Definisi kelas StockPrice
class StockPrice {
  final String symbol;
  final Company company;
  final String date;
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;
  final double change;
  final double changePct;

  StockPrice({
    required this.symbol,
    required this.company,
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.change,
    required this.changePct,
  });

  factory StockPrice.fromJson(Map<String, dynamic> json) {
    return StockPrice(
      symbol: json['symbol'],
      company: Company.fromJson(json['company']),
      date: json['date'],
      open: (json['open'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      close: (json['close'] as num).toDouble(),
      volume: json['volume'],
      change: (json['change'] as num).toDouble(),
      changePct: (json['change_pct'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'company': company.toJson(),
        'date': date,
        'open': open,
        'high': high,
        'low': low,
        'close': close,
        'volume': volume,
        'change': change,
        'change_pct': changePct,
      };
}

// Definisi kelas StockPriceData
class StockPriceData {
  final String status;
  final String message;
  final List<StockPrice> results;

  StockPriceData({
    required this.status,
    required this.message,
    required this.results,
  });

  factory StockPriceData.fromJson(Map<String, dynamic> json) {
    var list = json['data']['results'] as List;
    List<StockPrice> stockPrices =
        list.map((i) => StockPrice.fromJson(i)).toList();

    return StockPriceData(
      status: json['status'],
      message: json['message'],
      results: stockPrices,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'results': results.map((e) => e.toJson()).toList(),
      };
}
