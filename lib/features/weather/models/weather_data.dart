enum WeatherDataSource { demo, backend, openMeteo }

class WeatherForecastDay {
  const WeatherForecastDay({
    required this.date,
    required this.minTempC,
    required this.maxTempC,
    required this.description,
    required this.condition,
  });

  final DateTime date;
  final double minTempC;
  final double maxTempC;
  final String description;
  final String condition;

  String get emoji => WeatherData.emojiFor(condition);
}

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
  final List<WeatherForecastDay> forecast;
  final WeatherDataSource dataSource;

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
    this.forecast = const [],
    this.dataSource = WeatherDataSource.demo,
  });

  factory WeatherData.fromJson(
    Map<String, dynamic> json, {
    WeatherDataSource dataSource = WeatherDataSource.backend,
  }) {
    final rawForecast = json['forecast'];
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
      forecast: rawForecast is List
          ? rawForecast.whereType<Map>().map((item) {
              final map = Map<String, dynamic>.from(item);
              return WeatherForecastDay(
                date: DateTime.tryParse(map['date']?.toString() ?? '') ??
                    DateTime.now(),
                minTempC:
                    double.tryParse(map['minTempC']?.toString() ?? '') ?? 0,
                maxTempC:
                    double.tryParse(map['maxTempC']?.toString() ?? '') ?? 0,
                description: map['description']?.toString() ?? '',
                condition: map['condition']?.toString() ?? '',
              );
            }).toList(growable: false)
          : const [],
      dataSource: dataSource,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'country': country,
      'tempC': tempC,
      'tempF': tempF,
      'description': description,
      'iconCode': iconCode,
      'humidity': humidity,
      'windKph': windKph,
      'condition': condition,
      'forecast': forecast
          .map((day) => {
                'date': day.date.toIso8601String(),
                'minTempC': day.minTempC,
                'maxTempC': day.maxTempC,
                'description': day.description,
                'condition': day.condition,
              })
          .toList(growable: false),
      'dataSource': dataSource.name,
    };
  }

  String get emoji {
    return emojiFor(condition);
  }

  static String emojiFor(String value) {
    final c = value.toLowerCase();
    if (c.contains('sun') || c.contains('clear')) return '☀️';
    if (c.contains('cloud')) return '☁️';
    if (c.contains('rain')) return '🌧️';
    if (c.contains('snow')) return '❄️';
    if (c.contains('storm') || c.contains('thunder')) return '⛈️';
    if (c.contains('fog') || c.contains('mist')) return '🌫️';
    return '🌡️';
  }
}
