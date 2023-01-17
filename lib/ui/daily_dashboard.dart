import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:negate/ui/common_ui.dart';
import 'package:negate/ui/globals.dart';

import '../sentiment_db.dart';

class DailyDashboard {

  static Widget dashboard(BuildContext context, SentimentDB sdb, WidgetRef ref, StateSetter setState) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daily Dashboard")),
      body: Column(children: [
        CommonUI.dateChanger(context, sdb, ref, setState),
        Expanded(child: PieChart(
            PieChartData(
              borderData: FlBorderData(
                show: false,
              ),
              sections: showingSections(),
        ))),
      ]),
    );
  }

  static List<PieChartSectionData> showingSections() {
    List<PieChartSectionData> data = [];
    return data;
  }

}