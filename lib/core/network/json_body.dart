Map<String, dynamic> requireJsonMap(Object? data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  throw const FormatException('Expected a JSON object');
}

List<dynamic> requireJsonList(Object? data) {
  if (data is List) return data;
  throw const FormatException('Expected a JSON list');
}
