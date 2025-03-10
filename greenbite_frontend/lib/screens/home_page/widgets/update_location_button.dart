import 'package:flutter/material.dart';
import 'package:greenbite_frontend/service/location_service.dart';

class UpdateLocationButton extends StatelessWidget {
  final int userId;
  const UpdateLocationButton({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        print("UpdateLocationButton pressed");
        await LocationService.updateUserLocation(userId);
      },
      child: const Text("Update My Location"),
    );
  }
}
