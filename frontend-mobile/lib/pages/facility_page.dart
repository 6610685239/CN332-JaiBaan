import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/facility_model.dart';
import 'booking_page.dart';
import 'history_page.dart';

class FacilityListScreen extends StatelessWidget {
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F1E9), // สีครีมตาม Figma
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Facilities", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryPage()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Choose your Facilities", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Facility>>(
                future: apiService.getFacilities().then((list) => list.where((f) => !(f.imageUrl?.contains('placeholder') ?? false)).toList()),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final item = snapshot.data![index];
                        return _buildFacilityCard(context, item);
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityCard(BuildContext context, Facility facility) {
    final String imageUrl = (facility.imageUrl ?? '').toString().trim();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingPage(facility: facility),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.transparent, // โปร่งใสเพื่อไม่ให้มีกรอบสีขาวเกินออกมา
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20), // ให้มุมมนทุกด้านครอบรูปไปเลยตามดีไซน์
              child: Image.network(
                imageUrl.isNotEmpty
                    ? imageUrl
                    : "https://via.placeholder.com/400x200",
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                    alignment: Alignment.center,
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    facility.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.people_alt_rounded, size: 14, color: Colors.black87),
                      SizedBox(width: 4),
                      Text(
                        "${facility.capacityMin}-${facility.capacityMax}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}