import 'package:flutter/material.dart';

import '../../../app/generalImports.dart';

class MonthlyEarningBarChart extends StatefulWidget {
  const MonthlyEarningBarChart(
      {super.key,
      required this.monthlySales,
      required this.yearlySales,
      required this.weeklySales});

  final List<SalesModel> monthlySales;
  final List<SalesModel> yearlySales;
  final List<SalesModel> weeklySales;

  @override
  State<MonthlyEarningBarChart> createState() => _MonthlyEarningBarChartState();
}

class _MonthlyEarningBarChartState extends State<MonthlyEarningBarChart> {
  int maxAmount = 0;
  String selectedPeriod = 'Month';
  List<SalesModel>? saleValue;

  final List<String> filterList = ['Month', 'Year', 'Week'];
  @override
  void initState() {
    updateChart();

    super.initState();
  }

  void updateChart() {
    if (selectedPeriod == 'Month') {
      saleValue = widget.monthlySales;
    } else if (selectedPeriod == 'Year') {
      saleValue = widget.yearlySales;
    } else {
      saleValue = widget.weeklySales;
    }

    if (saleValue!.isNotEmpty) {
      final List<int> list = saleValue!
          .map((SalesModel e) =>
              int.parse(e.totalAmount.toString().split(".").first))
          .toList();

      maxAmount = list.reduce(max);
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      borderRadius: UiUtils.borderRadiusOf5,
      color: context.colorScheme.secondaryColor,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomContainer(
                width: 130,
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                borderRadius: UiUtils.borderRadiusOf5,
                color: context.colorScheme.accentColor.withValues(alpha: 0.2),
                child: DropdownButton<String>(
                  value: selectedPeriod,
                  isExpanded:
                      true, // Makes the dropdown take up all available width
                  icon: Icon(Icons.arrow_drop_down,
                      color: context.colorScheme.accentColor),
                  iconSize: 24,
                  style: TextStyle(
                    color: context.colorScheme.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                  underline: const SizedBox.shrink(),
                  dropdownColor: context.colorScheme.secondaryColor,
                  items: filterList.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: CustomText(
                        value,
                        color: context.colorScheme.accentColor,
                        fontSize: 16,
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (mounted) {
                      setState(() {
                        selectedPeriod = newValue!;
                        updateChart();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const CustomSizedBox(
            height: 25,
          ),
          Expanded(
            child: BarChart(
              mainBarData(),
            ),
          ),
          const CustomSizedBox(
            height: 12,
          ),
        ],
      ),
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    double width = 22,
    List<int>? showTooltips,
    LinearGradient? barChartRodGradient,
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          gradient: barChartRodGradient ??
              LinearGradient(
                colors: [Colors.green.shade300, Colors.green],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
          toY: isTouched ? y + 1 : y,
          width: width,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(UiUtils.borderRadiusOf5),
              topRight: Radius.circular(UiUtils.borderRadiusOf5)),
          borderSide: isTouched
              ? BorderSide(color: Theme.of(context).colorScheme.blackColor)
              : BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .blackColor
                      .withValues(alpha: 0.7),
                  width: 0,
                ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  // List<BarChartGroupData> showingGroups() {
  //   return List.generate(saleValue!.length, (int index) {
  //     int? colorIndex;
  //     colorIndex = index >= UiUtils.gradientColorForBarChart.length
  //         ? findColorIndex(index: index)
  //         : index;
  //     return makeGroupData(
  //       index,
  //       double.parse(saleValue![index].totalAmount!),
  //       width: (MediaQuery.sizeOf(context).width * 0.7) /
  //           (saleValue!.length > 3 ? saleValue!.length : 3),
  //       barChartRodGradient: UiUtils.gradientColorForBarChart[colorIndex!],
  //     );
  //   });
  // }
  List<BarChartGroupData> showingGroups() {
    // Ensure we only take the last 6 items
    final limitedData = saleValue!.length > 6
        ? saleValue!.sublist(saleValue!.length - 6)
        : saleValue!;

    return List.generate(limitedData.length, (int index) {
      int? colorIndex;
      colorIndex = index >= UiUtils.gradientColorForBarChart.length
          ? findColorIndex(index: index)
          : index;

      return makeGroupData(
        index,
        double.parse(limitedData[index].totalAmount!),
        width: (MediaQuery.sizeOf(context).width * 0.7) /
            (limitedData.length > 3 ? limitedData.length : 3),
        barChartRodGradient: UiUtils.gradientColorForBarChart[colorIndex!],
      );
    });
  }

  BarChartData mainBarData() {
    return BarChartData(
      maxY: maxAmount != 0 ? maxAmount + (maxAmount * 0.2) : 0,
      alignment: BarChartAlignment.spaceEvenly,
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      barTouchData: BarTouchData(
        enabled: true,
        touchCallback: (FlTouchEvent e, BarTouchResponse? f) {},
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (BarChartGroupData group, int groupIndex,
              BarChartRodData rod, int rodIndex) {
            final String? selectedDate = saleValue![groupIndex].month != null
                ? saleValue![group.x].month
                : saleValue![group.x].week != null
                    ? saleValue![group.x].week
                    : saleValue![group.x].year != null
                        ? saleValue![group.x].year
                        : '';
            final String salesCount = saleValue![group.x].totalAmount ?? '';
            return BarTooltipItem(
              '',
              TextStyle(
                color: Theme.of(context).colorScheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              children: [
                TextSpan(
                  text: '$selectedDate\n',
                ),
                TextSpan(
                  text: salesCount.priceFormat(),
                  style: const TextStyle(
                      fontSize: 14, fontStyle: FontStyle.italic),
                )
              ],
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitle,
            reservedSize: 38,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: maxAmount != 0 ? maxAmount / 4 : null,
            reservedSize: 40,
            getTitlesWidget: (double value, TitleMeta meta) {
              return CustomContainer(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  '${double.parse(
                    value.toString(),
                  )} ',
                  style: const TextStyle(fontSize: 10),
                  textAlign: TextAlign.end,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Theme.of(context).colorScheme.blackColor),
      ),
      barGroups: showingGroups(),
      gridData: const FlGridData(
        show: true,
        drawVerticalLine: true,
      ),
    );
  }

  Widget getTitle(double value, TitleMeta meta) {
    String? title;

    if (saleValue![value.toInt()].month != null) {
      title = saleValue![value.toInt()].month;
    } else if (saleValue![value.toInt()].week != null) {
      title = saleValue![value.toInt()].week;
    } else if (saleValue![value.toInt()].year != null) {
      title = saleValue![value.toInt()].year;
    } else {
      title = '';
    }

    return SideTitleWidget(
      meta: meta,
      // axisSide: meta.axisSide,
      child: Text(
        title!.isNotEmpty
            ? title.substring(0, title.length < 3 ? title.length : 3)
            : '',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        softWrap: true,
      ),
    );
  }

  dynamic findColorIndex({required int index}) {
    final int difference = index - UiUtils.gradientColorForBarChart.length;
    if (difference < UiUtils.gradientColorForBarChart.length) {
      return difference;
    }
    return findColorIndex(index: difference);
  }
}
