import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../model/coupon_model.dart';
import '../service/coupon_service.dart';
=======
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import '../model/coupon_model.dart';
import '../service/coupon_service.dart';
import '../widgets/common_layout.dart'; // Import the CommonLayout widget
>>>>>>> main

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
<<<<<<< HEAD
        String icon = ''; // Initialize icon
        String color = ''; // Initialize color
=======
        String icon = '';
        String color = '';
>>>>>>> main
        int cost = 0;
        double discount = 0;

        return AlertDialog(
<<<<<<< HEAD
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
=======
          title: Text('Add Coupon', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8), // Reduced border radius
                    ),
                    labelStyle: GoogleFonts.roboto(),
                  ),
                  onChanged: (value) => title = value,
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8), // Reduced border radius
                    ),
                    labelStyle: GoogleFonts.roboto(),
                  ),
                  onChanged: (value) => description = value,
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Icon',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8), // Reduced border radius
                    ),
                    labelStyle: GoogleFonts.roboto(),
                  ),
                  onChanged: (value) => icon = value,
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Color',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8), // Reduced border radius
                    ),
                    labelStyle: GoogleFonts.roboto(),
                  ),
                  onChanged: (value) => color = value,
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Cost',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8), // Reduced border radius
                    ),
                    labelStyle: GoogleFonts.roboto(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => cost = int.parse(value),
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Discount',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8), // Reduced border radius
                    ),
                    labelStyle: GoogleFonts.roboto(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => discount = double.parse(value),
                ),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Reduced border radius for AlertDialog
>>>>>>> main
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
<<<<<<< HEAD
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Coupon newCoupon = Coupon(
                  id: 0, // ID will be assigned by the backend
                  title: title,
                  icon: icon, // Pass icon value
                  color: color, // Pass color value
=======
              child: Text('Cancel', style: GoogleFonts.roboto(color: Colors.blueGrey[900])),
            ),
            ElevatedButton(
              onPressed: () async {
                Coupon newCoupon = Coupon(
                  id: 0,
                  title: title,
                  icon: icon,
                  color: color,
>>>>>>> main
                  cost: cost,
                  discount: discount,
                );
                await _couponService.createCoupon(newCoupon);
                _refreshCoupons();
                Navigator.of(context).pop();
              },
<<<<<<< HEAD
              child: Text('Add'),
=======
              child: Text('Add', style: GoogleFonts.roboto()),
>>>>>>> main
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
<<<<<<< HEAD
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
=======
    return CommonLayout(
      title: "Coupon Management", // Pass the title for the TopNavBar
      child: FutureBuilder<List<Coupon>>(
>>>>>>> main
        future: _futureCoupons,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
<<<<<<< HEAD
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
                  subtitle: Text(
                      'Cost: ${coupon.cost} GBP, Discount: ${coupon.discount}%'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteCoupon(coupon.id),
                  ),
                );
              },
=======
            return Center(child: Text('Error: ${snapshot.error}', style: GoogleFonts.roboto(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No coupons available', style: GoogleFonts.roboto(color: Colors.blueGrey[900])));
          } else {
            return ListView(
              padding: EdgeInsets.all(16), // Add padding around the table
              children: [
                // Table Header
                Card(
                  elevation: 4, // Add shadow
                  color: Colors.blueGrey[900], // Match sidebar color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Reduced border radius
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(flex: 1, child: Text('ID', style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.white))),
                        Expanded(flex: 2, child: Text('Title', style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.white))),
                        Expanded(flex: 2, child: Text('Icon', style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.white))),
                        Expanded(flex: 2, child: Text('Color', style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.white))),
                        Expanded(flex: 1, child: Text('Cost', style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.white))),
                        Expanded(flex: 1, child: Text('Discount', style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.white))),
                        Expanded(flex: 1, child: Text('Actions', style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.white))),
                      ],
                    ),
                  ),
                ),
                // Table Rows
                ...snapshot.data!.map((coupon) {
                  return Card(
                    elevation: 2, // Add shadow
                    margin: EdgeInsets.symmetric(vertical: 4), // Reduced vertical margin
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Reduced border radius
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(flex: 1, child: Text(coupon.id.toString(), style: GoogleFonts.roboto())),
                          Expanded(flex: 2, child: Text(coupon.title, style: GoogleFonts.roboto())),
                          Expanded(flex: 2, child: Text(coupon.icon, style: GoogleFonts.roboto())),
                          Expanded(flex: 2, child: Text(coupon.color, style: GoogleFonts.roboto())),
                          Expanded(flex: 1, child: Text('${coupon.cost} GBP', style: GoogleFonts.roboto())),
                          Expanded(flex: 1, child: Text('${coupon.discount}%', style: GoogleFonts.roboto())),
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCoupon(coupon.id),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
>>>>>>> main
            );
          }
        },
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> main
