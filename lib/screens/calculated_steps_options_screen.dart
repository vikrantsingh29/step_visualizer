import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'calculated_steps_visualization_screen.dart';

class CalculatedStepsOptionsScreen extends StatelessWidget {
  // List of calculated files with descriptions.
  final List<Map<String, String>> files = [
    {
      'filePath': 'assets/calculated_steps_algo.json',
      'name': 'Algorithm (SciPy Peak)',
      'description': 'Calculated using SciPy peak and filtration'
    },
    {
      'filePath': 'assets/calculated_steps_CNN.json',
      'name': 'CNN',
      'description': 'Calculated using CNN'
    },
    {
      'filePath': 'assets/calculated_steps_GRU.json',
      'name': 'GRU',
      'description': 'Calculated using GRU'
    },
    {
      'filePath': 'assets/calculated_steps_LSTM2Layers.json',
      'name': 'LSTM 2 Layers',
      'description': 'Calculated using LSTM with 2 layers'
    },
    {
      'filePath': 'assets/calculated_steps_LSTMBasic.json',
      'name': 'LSTM Basic',
      'description': 'Calculated using basic LSTM'
    },
    {
      'filePath': 'assets/calculated_steps_RandomForest.json',
      'name': 'RandomForest',
      'description': 'Calculated using RandomForest'
    },
    {
      'filePath': 'assets/calculated_steps_XGBoost.json',
      'name': 'XGBoost',
      'description': 'Calculated using XGBoost'
    },
  ];

  Future<void> _downloadFile(BuildContext context, String filePath, String fileName) async {
    final jsonString = await DefaultAssetBundle.of(context).loadString(filePath);
    final bytes = utf8.encode(jsonString);
    final blob = html.Blob([bytes], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..style.display = 'none'
      ..download = '$fileName.json';
    html.document.body!.append(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calculated Steps Options"),
      ),
      body: ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          final file = files[index];
          return Card(
            margin: EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(file['name']!),
              subtitle: Text(file['description']!),
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    icon: Icon(Icons.visibility),
                    tooltip: 'View Visualization',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CalculatedStepsVisualizationScreen(
                            filePath: file['filePath']!,
                            architectureName: file['name']!,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.download),
                    tooltip: 'Download File',
                    onPressed: () {
                      _downloadFile(context, file['filePath']!, file['name']!);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
