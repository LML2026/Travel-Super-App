class Weather {
  final String id;
  final String destination;
  final String condition;
  final int temperature;
  final int feelsLike;
  final int humidity;
  final int windSpeed;
  final String iconUrl;

  Weather({
    required this.id,
    required this.destination,
    required this.condition,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.iconUrl,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      id: json['id'] as String,
      destination: json['destination'] as String,
      condition: json['condition'] as String,
      temperature: json['temperature'] as int,
      feelsLike: json['feelsLike'] as int,
      humidity: json['humidity'] as int,
      windSpeed: json['windSpeed'] as int,
      iconUrl: json['iconUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destination': destination,
      'condition': condition,
      'temperature': temperature,
      'feelsLike': feelsLike,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'iconUrl': iconUrl,
    };
  }
}
