import 'package:uni_tech/partials/animation_wrapper.dart';
import 'package:uni_tech/partials/glass_container.dart';
import 'package:uni_tech/partials/layout/layout.dart';
import 'package:uni_tech/screens/products/_partials/products_table.dart';
import 'package:uni_tech/styles/texts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:percent_indicator/percent_indicator.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Map<String, dynamic>> staics = [
    {
      "label": "74k",
      "icon": Icons.account_box,
      "iconColor": Colors.greenAccent,
      "iconText": "Users",
    },
    {
      "label": "1.5m",
      "icon": Icons.ads_click,
      "iconColor": Colors.pinkAccent,
      "iconText": "Clicks",
    },
    {
      "label": "\$3,6k",
      "icon": Icons.currency_bitcoin,
      "iconColor": Colors.yellowAccent,
      "iconText": "Sales",
    },
    {
      "label": "100+",
      "icon": Icons.account_balance,
      "iconColor": Colors.brown,
      "iconText": "Staff",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final List<SalesData> chartData1 = [
      SalesData(DateTime(2010), 0),
      SalesData(DateTime(2011), 28),
      SalesData(DateTime(2012), 20),
      SalesData(DateTime(2013), 29),
      SalesData(DateTime(2014), 10),
      SalesData(DateTime(2015), 20),
    ];

    final List<SalesData> chartData2 = [
      SalesData(DateTime(2010), 0),
      SalesData(DateTime(2011), 14),
      SalesData(DateTime(2012), 12),
      SalesData(DateTime(2013), 28),
      SalesData(DateTime(2014), 14),
      SalesData(DateTime(2015), 29),
    ];
    return Layout(
      content: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 5,
            children: [
              Expanded(
                flex: 6,
                child: AnimatedWrapper(
                  duration: Duration(milliseconds: 800),
                  animations: [AnimationAllowedType.fade],
                  child: GlassContainer(
                    height: 355,
                    padding: EdgeInsets.only(left: 5),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Image.asset(
                            "images/dashboard_card_image.png",
                            height: 350,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
                            height: 350,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Poplar Solution",
                                        style: GoogleFonts.michroma(
                                          color: kwhite,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      Text(
                                        "Optimize \nYour Matrics",
                                        style: GoogleFonts.michroma(
                                          color: kwhite,
                                          fontSize: 35,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      TextButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: kwhite,
                                          foregroundColor: Colors.black,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 15,
                                            horizontal: 40,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {},
                                        child: Text(
                                          "Start Now",
                                          style: GoogleFonts.michroma(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 35),
                                Container(
                                  margin: const EdgeInsets.only(
                                    right: 5,
                                    bottom: 5,
                                  ),
                                  child: GlassContainer(
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        ...staics.asMap().entries.map((entry) {
                                          final index = entry.key;
                                          final state = entry.value;
                                          return AnimatedWrapper(
                                            duration: Duration(
                                              milliseconds: index * 600,
                                            ),
                                            animations: [
                                              AnimationAllowedType.slide,
                                            ],
                                            slideDirection: SlideDirection.up,
                                            child: Column(
                                              children: [
                                                Text(
                                                  state["label"],
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 30,
                                                    color: kwhite,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      state["icon"],
                                                      color: state["iconColor"],
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      state["iconText"],
                                                      style: TextStyle(
                                                        color: kwhite,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                flex: 4,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    AnimatedWrapper(
                      duration: Duration(milliseconds: 500),
                      animations: fadeSlide,
                      slideDirection: SlideDirection.right,
                      child: GlassContainer(
                        padding: EdgeInsets.only(
                          top: 20,
                          right: 30,
                          left: 15,
                          bottom: 10,
                        ),
                        height: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 15,
                          children: [
                            Flexible(
                              flex: 2,
                              child: Text(
                                "\tActive Users Right Now",
                                style: TextStyle(color: kwhite, fontSize: 16),
                              ),
                            ),
                            Flexible(
                              flex: 8,
                              child: SfCartesianChart(
                                backgroundColor: Colors.transparent,
                                plotAreaBorderWidth: 0, // removes chart border

                                primaryXAxis: DateTimeAxis(
                                  majorGridLines: const MajorGridLines(
                                    width: 0,
                                  ), // no grid
                                  axisLine: const AxisLine(
                                    width: 0,
                                  ), // no X line
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                  ), // white labels
                                ),

                                primaryYAxis: NumericAxis(
                                  minimum: 0, // start at 0
                                  maximum: 30, // end at 30
                                  interval: 10, // steps of 10
                                  majorGridLines: const MajorGridLines(
                                    width: 0,
                                  ),
                                  axisLine: const AxisLine(width: 0),
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),

                                series: <CartesianSeries>[
                                  SplineSeries<SalesData, DateTime>(
                                    dataSource: chartData1,
                                    xValueMapper:
                                        (SalesData sales, _) => sales.year,
                                    yValueMapper:
                                        (SalesData sales, _) => sales.sales,
                                    color: kmutedtext,
                                    width: 3,
                                  ),
                                  SplineSeries<SalesData, DateTime>(
                                    dataSource: chartData2,
                                    xValueMapper:
                                        (SalesData sales, _) => sales.year,
                                    yValueMapper:
                                        (SalesData sales, _) => sales.sales,
                                    color: Colors.greenAccent,
                                    width: 3,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    AnimatedWrapper(
                      duration: Duration(milliseconds: 800),
                      animations: fadeSlide,
                      slideDirection: SlideDirection.right,
                      child: GlassContainer(
                        height: 150,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "System Status",
                                    style: GoogleFonts.michroma(
                                      color: kwhite,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "All services active. No issues\nin the last 24 hours.",
                                    style: GoogleFonts.michroma(
                                      color: kwhite,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  TextButton(
                                    style: primaryButton,
                                    onPressed: () {},
                                    child: Text(
                                      "View Logs",
                                      style: primaryButtonText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: GlassContainer(
                                child: Center(
                                  child: CircularPercentIndicator(
                                    radius: 40.0,
                                    lineWidth: 8.0,
                                    percent: 0.7, // 70% filled
                                    center: Text(
                                      "70\n%",
                                      style: GoogleFonts.michroma(
                                        fontSize: 10,
                                        color: kwhite,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    progressColor: Colors.greenAccent,
                                    backgroundColor: kmutedtext,
                                    circularStrokeCap: CircularStrokeCap.round,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          ProductsTable(),
        ],
      ),
    );
  }
}

class SalesData {
  SalesData(this.year, this.sales);
  final DateTime year;
  final double sales;
}
