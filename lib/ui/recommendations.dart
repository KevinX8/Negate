import 'package:flutter/material.dart';

import 'package:negate/sentiment_db.dart';
import 'package:negate/ui/common_ui.dart';
import 'package:negate/ui/globals.dart';

class RecommendationsPage extends StatelessWidget {
  const RecommendationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var sdb = getIt<SentimentDB>.call();
    return Scaffold(
      appBar: AppBar(title: const Text("Weekly Recommendations")),
      body: Column(
        children: [
          const Padding(
              padding: EdgeInsets.all(10),
              child: Text("Top 5 most Negative Apps of the last 7 days",
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              child: FutureBuilder<List<List<MapEntry<String, List<double>>>>>(
                  future: sdb.getRecommendations(
                      DateTime.now().subtract(const Duration(days: 7))),
                  builder: (context, s) {
                    var negativeLogs = <MapEntry<String, List<double>>>[];
                    var positiveLogs = <MapEntry<String, List<double>>>[];
                    if (s.hasData) {
                      if (s.data!.isNotEmpty) {
                        negativeLogs = s.data![0];
                        positiveLogs = s.data![1];
                      }
                    }
                    return Column(children: [
                      Expanded(child: CommonUI.appListView(negativeLogs, sdb)),
                      const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                              "Top 5 most Positive Apps of the last 7 days",
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: CommonUI.appListView(positiveLogs, sdb)),
                    ]);
                  })),
        ],
      ),
    );
  }
}
