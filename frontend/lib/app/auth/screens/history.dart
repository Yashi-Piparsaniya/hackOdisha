import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hack_odisha/app/common/themes/colors.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

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
      disease: json['Disease'] ?? 'Unknown',
      confidence: (json['Confidence'] as num).toDouble(),
      severity: json['Severity'] ?? 'Unknown',
      specialist: json['Specialist'] ?? 'Unknown',
      careTips: json['Care_Tips'] ?? 'No tips available',
      timestamp: json['Timestamp'] ?? '',
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
  TooltipBehavior? _tooltipBehavior;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);
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
        centerTitle: true,
        title: const Text("History"),
        backgroundColor: AppColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
          ? const Center(child: Text("No history available"))
          : SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                tooltipBehavior: _tooltipBehavior,
                title: ChartTitle(text: 'Disease Confidence Overview'),
                series: <CartesianSeries>[
                  BarSeries<HistoryEntry, String>(
                    dataSource: _history,
                    xValueMapper: (HistoryEntry entry, _) => entry.disease,
                    yValueMapper: (HistoryEntry entry, _) => entry.confidence * 100,
                    name: 'Confidence (%)',
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final entry = _history[index];
                return Card(
                  color: index % 2 == 0 ? AppColors.background : AppColors.accent,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.history),
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
          ],
        ),
      ),
    );
  }
}
