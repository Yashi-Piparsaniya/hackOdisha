import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Model for history entry
class HistoryEntry {
  final String disease;
  final double confidence;
  final String severity;
  final String specialist;
  final String careTips;
  final String timestamp;

  HistoryEntry({
    required this.disease,
    required this.confidence,
    required this.severity,
    required this.specialist,
    required this.careTips,
    required this.timestamp,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      disease: json['Disease'],
      confidence: (json['Confidence'] as num).toDouble(),
      severity: json['Severity'],
      specialist: json['Specialist'],
      careTips: json['Care_Tips'],
      timestamp: json['Timestamp'],
    );
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<HistoryEntry> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    final url = Uri.parse('http://172.24.219.246:8000/history');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        final data = body.map((e) => HistoryEntry.fromJson(e)).toList();
        setState(() {
          _history = data;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _history.isEmpty
          ? Center(child: Text("No history available"))
          : ListView.builder(
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final entry = _history[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListTile(
              leading: Icon(Icons.history),
              title: Text(entry.disease),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Confidence: ${(entry.confidence * 100).toStringAsFixed(1)}%"),
                  Text("Severity: ${entry.severity}"),
                  Text("Specialist: ${entry.specialist}"),
                  Text("Care Tips: ${entry.careTips}"),
                  Text("Timestamp: ${entry.timestamp}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
