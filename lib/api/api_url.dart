String apiURL(
  String endpoint, {
  String emiten = '',
  String tanggal_awal = '',
  String tanggal_akhir = '',
  String halaman = '',
  required String apiKey,
}) {
  String baseUrl = "https://api.goapi.io/stock/idx";

  String url;

  switch (endpoint) {
    case 'data_perusahaan':
      url = "$baseUrl/companies?api_key=$apiKey";
      break;
    case 'harga_saham':
      url = "$baseUrl/prices?symbols=$emiten&api_key=$apiKey";
      break;
    case 'histori':
      url =
          "$baseUrl/$emiten/historical?from=$tanggal_awal&to=$tanggal_akhir&api_key=$apiKey";
      break;
    case 'kenaikan_tertinggi':
      url = "$baseUrl/top_gainer?api_key=$apiKey";
      break;
    case 'berita':
      url = "$baseUrl/news?page=$halaman&api_key=$apiKey";
      break;
    default:
      url = "$baseUrl/companies?api_key=$apiKey";
      break;
  }
  return url;
}



// String apiURL(String endpoint,
//     {String? emiten,
//     String? tanggal_awal,
//     String? tanggal_akhir,
//     String? halaman}) {
//   final baseUrl = 'https://api.goapi.id/v1/stock/';
//   final apiKey = ApiKeyManager.currentApiKey; // Ini adalah bagian yang diubah

//   switch (endpoint) {
//     case 'data_perusahaan':
//       return "$baseUrl/companies?api_key=$apiKey";
//     case 'harga_saham':
//       return "$baseUrl/prices?symbols=$emiten&api_key=$apiKey";
//     case 'kenaikan_tertinggi':
//       return "$baseUrl/top_gainer?api_key=$apiKey";
//     case 'berita':
//       return "$baseUrl/news?page=$halaman&api_key=$apiKey";
//     case 'histori':
//       return "$baseUrl/$emiten/historical?from=$tanggal_awal&to=$tanggal_akhir&api_key=$apiKey";
//     default:
//       throw ArgumentError('Invalid endpoint: $endpoint');
//   }
// }





// String apiURL(var emiten, var tanggal_awal, var tanggal_akhir) {
//   String url_data_perusahaan;
//   String url_harga_saham;
//   String url_histori;
//   String baseUrl = "https://api.goapi.io/stock/idx";

//   url_data_perusahaan = "$baseUrl/companies?api_key=$apiKey";

//   url_harga_saham = "$baseUrl/prices?symbols=$emiten&api_key=$apiKey";

//   url_histori =
//       "$baseUrl/$emiten/historical?from=$tanggal_awal&to=$tanggal_akhir&api_key=$apiKey";
//   // format tanggal YYYY-MM-DD
//   return url_data_perusahaan;
// }

// kode saham yang terdapat pada index saham
// https://api.goapi.io/stock/idx/index/KOMPAS100/items?api_key=bec21e12-d295-54b9-08b5-a969a096

// data index saham
// https://api.goapi.io/stock/idx/indices?api_key=bec21e12-d295-54b9-08b5-a969a096

// data nama company
// https://api.goapi.io/stock/idx/BBCA/profile?api_key=bec21e12-d295-54b9-08b5-a969a096

// data saham berdasarkan tren volume atau value
// https://api.goapi.io/stock/idx/trending?api_key=bec21e12-d295-54b9-08b5-a969a096

// data perubahan harga tinggi
// https://api.goapi.io/stock/idx/top_gainer?api_key=bec21e12-d295-54b9-08b5-a969a096

// data perubahan harga rendah
// https://api.goapi.io/stock/idx/top_loser?api_key=bec21e12-d295-54b9-08b5-a969a096
