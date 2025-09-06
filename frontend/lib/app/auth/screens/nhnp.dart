import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../common/themes/colors.dart';

class NHNPPage extends StatefulWidget {
  const NHNPPage({super.key});

  @override
  State<NHNPPage> createState() => _NHNPPageState();
}

class _NHNPPageState extends State<NHNPPage> {
  String city = "Rourkela"; // default city
  bool isLoading = false;
  List<Map<String, dynamic>> places = [];

  final TextEditingController _controller = TextEditingController(text: "Rourkela");

  @override
  void initState() {
    super.initState();
    fetchPlaces(); // fetch for default city
  }

  Future<void> fetchPlaces() async {
    if (city.trim().isEmpty) return;

    setState(() => isLoading = true);

    try {
      // Step 1: Find city coordinates
      final cityQuery =
          '[out:json];node["place"="city"]["name"~"^$city\$",i];out;';
      final cityUrl = Uri.parse(
          "https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(cityQuery)}");
      final cityResp = await http.get(cityUrl);

      if (cityResp.statusCode != 200) throw "City not found";

      final cityData = json.decode(cityResp.body);
      if ((cityData["elements"] as List).isEmpty) {
        setState(() {
          places = [];
          isLoading = false;
        });
        return;
      }

      final cityNode = cityData["elements"][0];
      final lat = cityNode["lat"];
      final lon = cityNode["lon"];

      // Step 2: Fetch hospitals/pharmacies within 10 km radius
      final placesQuery = """
        [out:json][timeout:25];
        (
          node(around:10000,$lat,$lon)["amenity"="hospital"];
          node(around:10000,$lat,$lon)["amenity"="pharmacy"];
        );
        out center;
      """;

      final placesUrl = Uri.parse(
          "https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(placesQuery)}");

      final placesResp = await http.get(placesUrl);

      if (placesResp.statusCode != 200) throw "Error fetching places";

      final data = json.decode(placesResp.body);
      final elements = data["elements"] as List;

      final fetchedPlaces = elements.map((e) {
        return {
          "name": e["tags"]?["name"] ?? "Unknown",
          "type": e["tags"]?["amenity"] ?? "",
          "address": e["tags"]?["addr:street"] ?? "",
          "lat": e["lat"] ?? e["center"]?["lat"],
          "lon": e["lon"] ?? e["center"]?["lon"],
        };
      }).toList();

      setState(() => places = fetchedPlaces.cast<Map<String, dynamic>>());
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => places = []);
    }

    setState(() => isLoading = false);
  }

  Future<void> openMap(double lat, double lon) async {
    final Uri googleMapsUrl = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$lat,$lon");

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(
        googleMapsUrl,
        mode: LaunchMode.externalApplication, // Open in Google Maps app / browser
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open map")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: AppColors.accent,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: TextStyle(color: AppColors.text),
                  decoration: InputDecoration(
                    hintText: "Enter city name",
                    hintStyle: TextStyle(color: AppColors.text.withOpacity(0.6)),
                    border: InputBorder.none,
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear, color: AppColors.text),
                      onPressed: () {
                        _controller.clear();
                        setState(() => city = "Rourkela"); // default city
                        fetchPlaces();
                      },
                    )
                        : null,
                  ),
                  onSubmitted: (value) {
                    setState(() => city = value);
                    fetchPlaces();
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.search, color: AppColors.text),
                onPressed: () {
                  setState(() => city = _controller.text);
                  fetchPlaces();
                },
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : places.isEmpty
          ? const Center(child: Text("No data found"))
          : ListView.builder(
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          final tileColor = index % 2 == 0
              ? AppColors.primary
              : Colors.white;

          return Card(
            color: tileColor,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(
                place["type"] == "hospital"
                    ? Icons.local_hospital
                    : Icons.local_pharmacy,
                color:
                place["type"] == "hospital" ? Colors.red : Colors.green,
              ),
              title: Text(place["name"]),
              subtitle: Text(
                place["address"].isEmpty
                    ? "Address not available"
                    : place["address"],
              ),
              onTap: () {
                final lat = place["lat"];
                final lon = place["lon"];
                if (lat != null && lon != null) {
                  openMap(lat, lon);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
