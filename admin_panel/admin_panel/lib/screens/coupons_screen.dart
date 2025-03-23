import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import '../model/coupon_model.dart';
import '../service/coupon_service.dart';
import '../widgets/common_layout.dart'; // Import the CommonLayout

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
        String icon = '';
        String color = '';
        int cost = 0;
        double discount = 0;

        return AlertDialog(
          title: Text('Add Coupon', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                    labelStyle: GoogleFonts.roboto(),
                  ),
                  onChanged: (value) => title = value,
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    labelStyle: GoogleFonts.roboto(),
                  ),
                  onChanged: (value) => description = value,
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Icon',
                    border: OutlineInputBorder(),
                    labelStyle: GoogleFonts.roboto(),
                  ),
                  onChanged: (value) => icon = value,
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Color',
                    border: OutlineInputBorder(),
                    labelStyle: GoogleFonts.roboto(),
                  ),
                  onChanged: (value) => color = value,
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Cost',
                    border: OutlineInputBorder(),
                    labelStyle: GoogleFonts.roboto(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => cost = int.parse(value),
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Discount',
                    border: OutlineInputBorder(),
                    labelStyle: GoogleFonts.roboto(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => discount = double.parse(value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: GoogleFonts.roboto(color: Colors.blueGrey[900])),
            ),
            ElevatedButton(
              onPressed: () async {
                Coupon newCoupon = Coupon(
                  id: 0,
                  title: title,
                  icon: icon,
                  color: color,
                  cost: cost,
                  discount: discount,
                );
                await _couponService.createCoupon(newCoupon);
                _refreshCoupons();
                Navigator.of(context).pop();
              },
              child: Text('Add', style: GoogleFonts.roboto()),
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
    return CommonLayout(
      title: 'Coupon Management', // Title for the TopNavBar
      child: FutureBuilder<List<Coupon>>(
        future: _futureCoupons,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: GoogleFonts.roboto(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No coupons available', style: GoogleFonts.roboto(color: Colors.blueGrey[900])));
          } else {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Title')),
                  DataColumn(label: Text('Icon')),
                  DataColumn(label: Text('Color')),
                  DataColumn(label: Text('Cost')),
                  DataColumn(label: Text('Discount')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: snapshot.data!.map((coupon) {
                  return DataRow(
                    cells: [
                      // ID Column
                      DataCell(Text(coupon.id.toString())),
                      // Title Column
                      DataCell(Text(coupon.title)),
                      // Icon Column
                      DataCell(Text(coupon.icon)),
                      // Color Column
                      DataCell(Text(coupon.color)),
                      // Cost Column
                      DataCell(Text('${coupon.cost} GBP')),
                      // Discount Column
                      DataCell(Text('${coupon.discount}%')),
                      // Actions Column
                      DataCell(
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCoupon(coupon.id),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}