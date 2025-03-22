import 'package:flutter/material.dart';
import '../model/coupon_model.dart';
import '../service/coupon_service.dart';

class CouponsScreen extends StatefulWidget {
  @override
  _CouponScreenState createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponsScreen> {
  final CouponService _couponService = CouponService();
  late Future<List<Coupon>> _futureCoupons;

  @override
  void initState() {
    super.initState();
    _futureCoupons = _couponService.getCoupons();
  }

  void _refreshCoupons() {
    setState(() {
      _futureCoupons = _couponService.getCoupons();
    });
  }

  void _addCoupon() {
    showDialog(
      context: context,
      builder: (context) {
        String title = '';
        String description = '';
        String icon = ''; // Initialize icon
        String color = ''; // Initialize color
        int cost = 0;
        double discount = 0;

        return AlertDialog(
          title: Text('Add Coupon'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Title'),
                onChanged: (value) => title = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) => description = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Icon'),
                onChanged: (value) => icon = value, // Set icon value
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Color'),
                onChanged: (value) => color = value, // Set color value
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Cost'),
                keyboardType: TextInputType.number,
                onChanged: (value) => cost = int.parse(value),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Discount'),
                keyboardType: TextInputType.number,
                onChanged: (value) => discount = double.parse(value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Coupon newCoupon = Coupon(
                  id: 0, // ID will be assigned by the backend
                  title: title,
                  icon: icon, // Pass icon value
                  color: color, // Pass color value
                  cost: cost,
                  discount: discount,
                );
                await _couponService.createCoupon(newCoupon);
                _refreshCoupons();
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCoupon(int id) async {
    await _couponService.deleteCoupon(id);
    _refreshCoupons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coupon Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addCoupon,
          ),
        ],
      ),
      body: FutureBuilder<List<Coupon>>(
        future: _futureCoupons,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No coupons available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Coupon coupon = snapshot.data![index];
                return ListTile(
                  title: Text(coupon.title),
                  subtitle: Text('Cost: ${coupon.cost} GBP, Discount: ${coupon.discount}%'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteCoupon(coupon.id),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}