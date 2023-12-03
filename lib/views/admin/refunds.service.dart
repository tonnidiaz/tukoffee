import 'package:dio/dio.dart';
import 'package:lebzcafe/utils/constants.dart';

class RefundsService {
  static Future<Response> getRefunds() async {
    return await paystackDio.get("/refund");
  }
}
