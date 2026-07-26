class WeatherData {
  final String city;
  final String country;
  final double tempC;
  final double tempF;
  final String description;
  final String iconCode;
  final int humidity;
  final double windKph;
  final String condition;

  const WeatherData({
    required this.city,
    required this.country,
    required this.tempC,
    required this.tempF,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windKph,
    required this.condition,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      city: json['city']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      tempC: double.tryParse(json['tempC']?.toString() ?? '') ?? 0,
      tempF: double.tryParse(json['tempF']?.toString() ?? '') ?? 0,
      description: json['description']?.toString() ?? '',
      iconCode: json['iconCode']?.toString() ?? '',
      humidity: int.tryParse(json['humidity']?.toString() ?? '') ?? 0,
      windKph: double.tryParse(json['windKph']?.toString() ?? '') ?? 0,
      condition: json['condition']?.toString() ?? '',
    );
  }

  String get emoji {
    final c = condition.toLowerCase();
    if (c.contains('sun') || c.contains('clear')) return '☀️';
    if (c.contains('cloud')) return '☁️';
    if (c.contains('rain')) return '🌧️';
    if (c.contains('snow')) return '❄️';
    if (c.contains('storm') || c.contains('thunder')) return '⛈️';
    if (c.contains('fog') || c.contains('mist')) return '🌫️';
    return '🌡️';
  }
}
