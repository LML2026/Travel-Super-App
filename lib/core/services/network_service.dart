import 'package:dio/dio.dart';

class NetworkService {
  NetworkService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<void> initialize() async {}

  Dio get client => _dio;
}
