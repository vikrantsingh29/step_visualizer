import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import '../models/measurement.dart';
import '../services/data_loader.dart';
import 'measurement_detail_screen.dart';
import 'calculated_steps_options_screen.dart';

class MeasurementListScreen extends StatefulWidget {
  @override
  _MeasurementListScreenState createState() => _MeasurementListScreenState();
}

class _MeasurementListScreenState extends State<MeasurementListScreen> {
  late Future<List<Measurement>> measurementsFuture;
  List<Measurement> measurements = [];
  List<Measurement> filteredMeasurements = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    measurementsFuture = DataLoader.loadMeasurements();
    measurementsFuture.then((list) {
      setState(() {
        measurements = list;
        filteredMeasurements = list;
      });
    });
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredMeasurements = measurements
          .where((m) => m.id.toLowerCase().contains(query))
          .toList();
    });
  }

  /// Download all seven calculated steps files as a ZIP archive.
  Future<void> _downloadAllCalculatedFiles() async {
    final List<String> filePaths = [
      'assets/calculated_steps_algo.json',
      'assets/calculated_steps_CNN.json',
      'assets/calculated_steps_GRU.json',
      'assets/calculated_steps_LSTM2Layers.json',
      'assets/calculated_steps_LSTMBasic.json',
      'assets/calculated_steps_RandomForest.json',
      'assets/calculated_steps_XGBoost.json',
    ];

    // Create a new archive.
    Archive archive = Archive();

    // Loop through each file, load its content, and add to the archive.
    for (String path in filePaths) {
      try {
        String content = await DefaultAssetBundle.of(context).loadString(path);
        // Use the file's base name (without folder) for the archive entry.
        String fileName = path.split('/').last;
        ArchiveFile file = ArchiveFile(fileName, content.length, utf8.encode(content));
        archive.addFile(file);
      } catch (e) {
        print("Error loading $path: $e");
      }
    }

    // Encode the archive as a ZIP file.
    List<int>? zipData = ZipEncoder().encode(archive);
    if (zipData != null) {
      final blob = html.Blob([Uint8List.fromList(zipData)], 'application/zip');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..style.display = 'none'
        ..download = 'calculated_steps_files.zip';
      html.document.body!.append(anchor);
      anchor.click();
      anchor.remove();
      html.Url.revokeObjectUrl(url);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Measurements'),
        actions: [
          // Single download button for all calculated files.
          IconButton(
            icon: Icon(Icons.download),
            tooltip: 'Download All Calculated Files',
            onPressed: _downloadAllCalculatedFiles,
          ),
          // (Optional) You can keep or remove the button for viewing calculated steps options.
          IconButton(
            icon: Icon(Icons.analytics),
            tooltip: 'View Calculated Steps Options',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CalculatedStepsOptionsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search/filter field.
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Measurement ID',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // Measurements list.
          Expanded(
            child: filteredMeasurements.isEmpty
                ? Center(child: Text('No measurements found'))
                : ListView.builder(
                    itemCount: filteredMeasurements.length,
                    itemBuilder: (context, index) {
                      final measurement = filteredMeasurements[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(
                              measurement.id.substring(0, 2).toUpperCase(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            measurement.id,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(
                            'Start: ${measurement.startTime}\nEnd: ${measurement.endTime}',
                            style: TextStyle(fontSize: 12),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MeasurementDetailScreen(
                                    measurement: measurement),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
