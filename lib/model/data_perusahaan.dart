class CompanyData {
  final String status;
  final String message;
  final List<Company> results;

  CompanyData(
      {required this.status, required this.message, required this.results});

  factory CompanyData.fromJson(Map<String, dynamic> json) {
    var list = json['data']['results'] as List;
    List<Company> companies = list.map((i) => Company.fromJson(i)).toList();

    return CompanyData(
      status: json['status'],
      message: json['message'],
      results: companies,
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
