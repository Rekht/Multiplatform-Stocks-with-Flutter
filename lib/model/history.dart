class StockHistoryData {
  final String status;
  final String message;
  final List<StockHistory> results;

  StockHistoryData(
      {required this.status, required this.message, required this.results});

  factory StockHistoryData.fromJson(Map<String, dynamic> json) {
    var list = json['data']['results'] as List;
    List<StockHistory> historyList =
        list.map((i) => StockHistory.fromJson(i)).toList();

    return StockHistoryData(
      status: json['status'],
      message: json['message'],
      results: historyList,
    );
  }
}

class StockHistory {
  final String symbol;
  final String date;
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;

  StockHistory({
    required this.symbol,
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory StockHistory.fromJson(Map<String, dynamic> json) {
    return StockHistory(
      symbol: json['symbol'],
      date: json['date'],
      open: json['open'].toDouble(),
      high: json['high'].toDouble(),
      low: json['low'].toDouble(),
      close: json['close'].toDouble(),
      volume: json['volume'],
    );
  }
}
