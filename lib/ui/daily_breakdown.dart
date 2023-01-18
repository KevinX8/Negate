import 'dart:developer';
import 'dart:typed_data';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:negate/ui/common_ui.dart';
import 'package:negate/ui/globals.dart';

import '../sentiment_db.dart';

class DailyBreakdown {
  static Widget dashboard(BuildContext context, SentimentDB sdb, WidgetRef ref,
      StateSetter setState) {
    return Scaffold(
      appBar: AppBar(title: const Text("Breakdown")),
      body: Column(children: [
        CommonUI.dateChanger(context, sdb, ref, setState),
        const Text("Overall Breakdown of the day",
            style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
            child: Padding(
             padding: const EdgeInsets.all(30),
             child: FutureBuilder<List<MapEntry<String, List<double>>>>(
                future: sdb.getDailyBreakdown(selectedDate),
                builder: (context, s) {
                  List<MapEntry<String, List<double>>> breakdownList = [];
                  if (s.hasData) {
                    if (s.data!.isNotEmpty) {
                      breakdownList = s.data!;
                    }
                  }
                  return Column(
                    children: [
                      Expanded(child:
                    PieChart(PieChartData(
                    borderData: FlBorderData(
                      show: false,
                    ),
                    sections: showingSections(breakdownList, sdb),
                  ))),
                      Expanded(child:
                          CommonUI.appListView(breakdownList, sdb)
                      )
                  ]);
                }))),
      ]),
    );
  }

  static List<PieChartSectionData> showingSections(List<MapEntry<String, List<double>>> breakdownList, SentimentDB sdb) {
    List<PieChartSectionData> data = [];
    const fontSize = 16.0;
    const radius = 100.0;
    const widgetSize = 40.0;
    for (var entry in breakdownList) {
      data.add(PieChartSectionData(
        color: CommonUI.getBarColour(entry.value[0]),
        value: entry.value[2] * 360,
        title: entry.value[0] > 0 ? '${(entry.value[0] * 100).toStringAsFixed(0)}%' : '...',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.grey[900],
        ),
        badgeWidget: _Badge(
          entry.key,
          size: widgetSize,
          borderColor: CommonUI.getBarColour(entry.value[0]),
          sdb: sdb,
        ),
        badgePositionPercentageOffset: .98,
      ));
    }
    return data;
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.appName, {
    required this.size,
    required this.borderColor,
    required this.sdb,
  });

  final String appName;
  final double size;
  final Color borderColor;
  final SentimentDB sdb;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
        child: FutureBuilder<Uint8List?>(
          future: sdb.getAppIcon(appName),
          builder: (ctx, ico) {
            if (ico.hasData) {
              return Image.memory(ico.data!);
            }
            return const ImageIcon(null);
          },
        ),
      ),
    );
  }
}
