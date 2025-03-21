import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About GreenBite'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(),
            _buildSection(
              title: 'Our Mission',
              content:
                  'GreenBite is on a mission to reduce food waste and promote sustainable living. We connect vendors with customers to save food that would otherwise be thrown away.',
              image:
                  'https://t4.ftcdn.net/jpg/04/98/47/53/360_F_498475327_1fHyorA3Pf0PVeOaIBc5XcjKvliiZCrs.jpg',
            ),
            _buildSection(
              title: 'How It Works',
              content:
                  'Vendors list surplus food items on GreenBite, and users can purchase them at discounted prices. It’s a win-win for the environment and your wallet!',
              image:
                  'https://mir-s3-cdn-cf.behance.net/projects/404/c91f62145289695.Y3JvcCwyMTU4LDE2ODgsNDIyLDA.jpg',
            ),
            _buildSection(
              title: 'Our Impact',
              content:
                  'Since our launch, GreenBite has saved thousands of meals from being wasted, reducing carbon emissions and promoting a greener planet.',
              image:
                  'https://cdn.prod.website-files.com/65258e8681b80e99173d058a/655c09b9861f45797f4cf0c3_the-community-meal-that-changed-my-life-2.jpeg',
            ),
            _buildJoinUsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSh5FGz_XqZMqJywCK1g3ntfzg8py26_PRsbQ&s'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Fighting Food Waste, One Bite at a Time',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required String image,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              image,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinUsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.green.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Join Us in Making a Difference',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Download GreenBite today and start saving food, money, and the planet!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text(
              'Get Started',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
