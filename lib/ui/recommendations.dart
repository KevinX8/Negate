import 'package:flutter/services.dart';
import 'package:negate/sentiment_db.dart';
import 'package:negate/ui/globals.dart';

import 'package:flutter/material.dart' hide MenuItem;

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
                  future: sdb.getRecommendations(DateTime.now().subtract(const Duration(days: 7))),
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
                      Expanded(child:
                      ListView.separated(
                        itemCount: negativeLogs.length,
                        itemBuilder: (BuildContext context, int index) {
                          var timeUsed = Duration(
                              minutes: negativeLogs[index].value[1].toInt());
                          Text used = Text("Used for ${timeUsed.inMinutes} m");
                          if (timeUsed.inHours != 0) {
                            used = Text(
                                "Used for ${timeUsed.inHours} h ${timeUsed.inMinutes % 60} m");
                          }
                          return Container(
                              height: 50,
                              child: ListTile(
                                leading: FutureBuilder<Uint8List?>(
                                  future:
                                  sdb.getAppIcon(negativeLogs[index].key),
                                  builder: (ctx, ico) {
                                    if (ico.hasData) {
                                      return Image.memory(ico.data!);
                                    }
                                    return const ImageIcon(null);
                                  },
                                ),
                                trailing: Text(
                                    "${(negativeLogs[index].value[0] * 100).toStringAsFixed(2)}%"),
                                title: Text(negativeLogs[index].key),
                                subtitle: used,
                              ));
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                      )),
                      const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                              "Top 5 most Positive Apps of the last 7 days",
                              style:
                              TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child:
                      ListView.separated(
                        itemCount: positiveLogs.length,
                        itemBuilder: (BuildContext context, int index) {
                          var timeUsed = Duration(
                              minutes: positiveLogs[index].value[1].toInt());
                          Text used = Text("Used for ${timeUsed.inMinutes} m");
                          if (timeUsed.inHours != 0) {
                            used = Text(
                                "Used for ${timeUsed.inHours} h ${timeUsed.inMinutes % 60} m");
                          }
                          return Container(
                              height: 50,
                              child: ListTile(
                                leading: FutureBuilder<Uint8List?>(
                                  future:
                                  sdb.getAppIcon(positiveLogs[index].key),
                                  builder: (ctx, ico) {
                                    if (ico.hasData) {
                                      return Image.memory(ico.data!);
                                    }
                                    return const ImageIcon(null);
                                  },
                                ),
                                trailing: Text(
                                    "${(positiveLogs[index].value[0] * 100).toStringAsFixed(2)}%"),
                                title: Text(positiveLogs[index].key),
                                subtitle: used,
                              ));
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                      )),
                    ]);
                  })),
        ],
      ),
    );
  }
}