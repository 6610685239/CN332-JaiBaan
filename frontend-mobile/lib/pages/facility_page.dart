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
      backgroundColor: Colors.white,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // base background image
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
            ),
          ),
          // lpr_bg1 top left
          Positioned(
            top: -250,
            left: -250,
            child: Image.asset('assets/images/lpr_bg1.png', width: 700),
          ),
          // lpr_bg2 bottom
          Positioned(
            bottom: 0,
            left: -100,
            right: -160,
            child: Image.asset('assets/images/lpr_bg2.png', width: double.infinity, height: 220, fit: BoxFit.fill),
          ),
          SafeArea(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'Facilities',
                  style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w700, fontSize: 18),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF424242)),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.history_rounded, color: Color(0xFF424242)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HistoryPage()),
                      );
                    },
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose your Facilities',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: FutureBuilder<List<Facility>>(
                        future: apiService.getFacilities(),
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
                          return const Center(
                            child: CircularProgressIndicator(color: Color(0xFFFF7043), strokeWidth: 2.5),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderBox() => Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.image_outlined, size: 48, color: Colors.grey.shade400),
      );

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
        margin: const EdgeInsets.only(bottom: 24),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _placeholderBox(),
                    )
                  : _placeholderBox(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 4.0, right: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          facility.name,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black87),
                        ),
                        if (facility.openTime != null && facility.closeTime != null) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFFFF9A8B)),
                              const SizedBox(width: 4),
                              Text(
                                '${facility.openTime} – ${facility.closeTime}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.people_alt_rounded, size: 13, color: Color(0xFF888888)),
                      const SizedBox(width: 4),
                      Text(
                        '${facility.capacityMin}–${facility.capacityMax}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF888888)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
