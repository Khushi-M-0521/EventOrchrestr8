import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Hardcoded analytics values
    final Map<String, dynamic> eventAnalytics = {
      'totalAttendees': 150,
      'registeredAttendees': 120,
      'engagementRate': 75.0,
      'feedbackScore': 4.5,
      'revenueGenerated': 5000.0,
    };

    final double attendancePercentage = (eventAnalytics['registeredAttendees'] / eventAnalytics['totalAttendees']) * 100;
    final List<String> days = ["Nov 2", "Nov 3", "Nov 4", "Nov 5", "Nov 6"];

    return Scaffold(
      appBar: AppBar(
        title: Text('Event Analytics'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total vs. Registered Attendees',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                'Total Attendees: ${eventAnalytics['totalAttendees']}\nRegistered Attendees: ${eventAnalytics['registeredAttendees']}\nAttendance Percentage: ${attendancePercentage.toStringAsFixed(2)}%',
                style: TextStyle(fontSize: 16),
              ),
              Center(
                child: Container(
                  height: 200,
                  padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 20),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 160,
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barsSpace: 60,
                          barRods: [
                            BarChartRodData(
                              toY: eventAnalytics['totalAttendees'].toDouble(),
                              color: Colors.blue,
                              width: 60,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            BarChartRodData(
                              toY: eventAnalytics['registeredAttendees'].toDouble(),
                              color: Colors.green,
                              width: 60,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ],
                        ),
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, interval: 20, getTitlesWidget: (value, meta) {
                            return Text('${value.toInt()}', style: TextStyle(fontSize: 10));
                          }),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, getTitlesWidget: (double value, TitleMeta meta) {
                            const labels = ['Total', 'Registered'];
                            const style = TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10);
                            return SideTitleWidget(child: Text(labels[value.toInt()], style: style), axisSide: meta.axisSide);
                          }),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      barTouchData: BarTouchData(enabled: true),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 10,
                    color: Colors.blue,
                    margin: EdgeInsets.only(right: 4),
                  ),
                  Text(
                    'Total Attendees',
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(width: 16),
                  Container(
                    width: 20,
                    height: 10,
                    color: Colors.green,
                    margin: EdgeInsets.only(right: 4),
                  ),
                  Text(
                    'Registered Attendees',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Text(
                'Engagement Rate',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                'Engagement Rate over Days:',
                style: TextStyle(fontSize: 16),
              ),
              Center(
                child: Container(
                  height: 200,
                  padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 20),
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            FlSpot(0, 50.0),
                            FlSpot(1, 70.0),
                            FlSpot(2, 75.0),
                            FlSpot(3, 80.0),
                            FlSpot(4, eventAnalytics['engagementRate'].toDouble()),
                          ],
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 4,
                          belowBarData: BarAreaData(show: false),
                          dotData: FlDotData(show: true),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, interval: 20, getTitlesWidget: (value, meta) {
                            return Text('${value.toInt()}', style: TextStyle(fontSize: 10));
                          }),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, getTitlesWidget: (double value, TitleMeta meta) {
                            const style = TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10);
                            return SideTitleWidget(child: Text(days[value.toInt()], style: style), axisSide: meta.axisSide);
                          }),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineTouchData: LineTouchData(enabled: true),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: true),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Feedback Score',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                'Feedback Score: ${eventAnalytics['feedbackScore']} out of 5',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16.0),
              Center(
                child: Container(
                  height: 150,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: eventAnalytics['feedbackScore'].toDouble(),
                          color: Colors.orange,
                          title: '${eventAnalytics['feedbackScore']}',
                          radius: 50,
                        ),
                        PieChartSectionData(
                          value: (5 - eventAnalytics['feedbackScore']).toDouble(),
                          color: Colors.grey,
                          title: '',
                          radius: 50,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Revenue Generated',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                'Revenue Generated over Days:',
                style: TextStyle(fontSize: 16),
              ),
              Center(
                child: Container(
                  height: 200,
                  padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 20,),
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            FlSpot(0, 1000.0),
                            FlSpot(1, 2000.0),
                            FlSpot(2, 3000.0),
                            FlSpot(3, 4000.0),
                            FlSpot(4, eventAnalytics['revenueGenerated'].toDouble()),
                          ],
                          isCurved: true,
                          color: Colors.red,
                          barWidth: 4,
                          belowBarData: BarAreaData(show: false),
                          dotData: FlDotData(show: true),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, interval: 1000, reservedSize: 30, getTitlesWidget: (value, meta) {
                            return Text('${value.toInt()}', style: TextStyle(fontSize: 10));
                          }),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, getTitlesWidget: (double value, TitleMeta meta) {
                            const style = TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10);
                            return SideTitleWidget(child: Text(days[value.toInt()], style: style), axisSide: meta.axisSide);
                          }),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineTouchData: LineTouchData(enabled: true),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: true),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
