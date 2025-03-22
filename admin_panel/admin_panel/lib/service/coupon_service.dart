import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/coupon_model.dart';


class CouponService {
  final String baseUrl = 'http://10.190.13.69:8080/api/admin';

  Future<List<Coupon>> getCoupons() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/listAllCoupon'));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Coupon.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load coupons: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch coupons: $e');
    }
  }

  Future<void> createCoupon(Coupon coupon) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/createCoupon'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'title': coupon.title,
          'icon' : coupon.icon,
          'color': coupon.color,
          'cost': coupon.cost,
          'discount': coupon.discount,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create coupon: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create coupon: $e');
    }
  }

  Future<void> deleteCoupon(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/deleteCoupon/$id'));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete coupon: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete coupon: $e');
    }
  }
}