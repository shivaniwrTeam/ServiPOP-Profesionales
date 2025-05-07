import 'package:flutter/material.dart';

import '../../../app/generalImports.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  BookingScreenState createState() => BookingScreenState();
}

class BookingScreenState extends State<BookingScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  int currFilter = 0;
  String? selectedStatus;
  String? selectedBookingOrder;
  int? currentOrder = 0;
  List<Map> filters = []; //set  model  from  API  Response
  List<Map> orderFilters = [];
  late final AnimationController _animationController =
      AnimationController(vsync: this);
  late Animation<double> fontAnimation = Tween<double>(begin: 22.0, end: 12.0)
      .animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
          reverseCurve: Curves.easeInOut));
  late Animation<double> fontAnimation2 = Tween<double>(begin: 16.0, end: 8.0)
      .animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
          reverseCurve: Curves.easeInOut));

  void scrollListener() {
    _animationController.value = UiUtils.inRange(
        currentValue: widget.scrollController.offset,
        minValue: widget.scrollController.position.minScrollExtent,
        maxValue: widget.scrollController.position.maxScrollExtent,
        newMaxValue: 1.0,
        newMinValue: 0.0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.scrollController.removeListener(scrollListener);
    widget.scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    widget.scrollController.addListener(scrollListener);
    filters = [
      {'id': '0', 'fName': 'all'.translate(context: context)},
      {'id': '1', 'fName': 'awaiting'.translate(context: context)},
      {'id': '2', 'fName': 'confirmed'.translate(context: context)},
      {'id': '3', 'fName': 'started'.translate(context: context)},
      {'id': '4', 'fName': 'rescheduled'.translate(context: context)},
      {'id': '5', 'fName': 'booking_ended'.translate(context: context)},
      {'id': '6', 'fName': 'completed'.translate(context: context)},
      {'id': '7', 'fName': 'cancelled'.translate(context: context)},
    ];
    orderFilters = [
      {'id': '0', 'fName': 'defaultBookings'.translate(context: context)},
      {'id': '1', 'fName': 'customBookings'.translate(context: context)},
    ];
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    filters = [
      {'id': '0', 'fName': 'all'.translate(context: context)},
      {'id': '1', 'fName': 'awaiting'.translate(context: context)},
      {'id': '2', 'fName': 'confirmed'.translate(context: context)},
      {'id': '3', 'fName': 'started'.translate(context: context)},
      {'id': '4', 'fName': 'rescheduled'.translate(context: context)},
      {'id': '5', 'fName': 'booking_ended'.translate(context: context)},
      {'id': '6', 'fName': 'completed'.translate(context: context)},
      {'id': '7', 'fName': 'cancelled'.translate(context: context)},
    ];
    orderFilters = [
      {'id': '0', 'fName': 'defaultBookings'.translate(context: context)},
      {'id': '1', 'fName': 'customBookings'.translate(context: context)},
    ];
    return DefaultTabController(
      length: filters.length,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: UiUtils.getSystemUiOverlayStyle(context: context),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.primaryColor,
            body: Stack(
              children: [
                NestedScrollView(
                  controller: widget.scrollController,
                  headerSliverBuilder: (context, _) {
                    return [
                      SliverPersistentHeader(
                        delegate: LongAppBarPersistentHeaderDelegate(
                          child: Center(
                              child: AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, _) {
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          children: [
                                            CustomText(
                                              'bookingTab'
                                                  .translate(context: context),
                                              fontSize: fontAnimation.value,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .blackColor,
                                            ),
                                            BlocBuilder<FetchBookingsCubit,
                                                FetchBookingsState>(
                                              builder: (context, state) {
                                                if (state
                                                    is FetchBookingsSuccess) {
                                                  return HeadingAmountAnimation(
                                                    key: ValueKey(state.total),
                                                    text:
                                                        '${state.total.toString()} ${'bookingTab'.translate(context: context)}',
                                                    textStyle: TextStyle(
                                                      color: context.colorScheme
                                                          .lightGreyColor,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize:
                                                          fontAnimation2.value,
                                                    ),
                                                  );
                                                } else {
                                                  return CustomSizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.7,
                                                    height:
                                                        fontAnimation2.value +
                                                            8,
                                                  );
                                                }
                                              },
                                            )
                                          ],
                                        ),
                                        CustomSizedBox(
                                          height: 55,
                                          child: _buildTabBar(context),
                                        ),
                                      ],
                                    );
                                  })),
                        ),
                        pinned: true,
                      )
                    ];
                  },
                  body: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification notification) {
                        if (notification is ScrollEndNotification &&
                            notification.metrics.extentAfter == 0) {
                          if (mounted &&
                              context
                                  .read<FetchBookingsCubit>()
                                  .hasMoreData()) {
                            context
                                .read<FetchBookingsCubit>()
                                .fetchMoreBookings(
                                    status: selectedStatus,
                                    customRequestOrder: selectedBookingOrder);
                          }
                        }
                        return false;
                      },
                      child: BookingsTabContent(
                        status: selectedStatus,
                        bookingOrder: selectedBookingOrder,
                      )),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 70),
                    child: CustomContainer(
                        height: 55,
                        borderRadius: UiUtils.borderRadiusOf50,
                        border: Border.all(
                          color: context.colorScheme.lightGreyColor,
                          width: 0.2,
                        ),
                        color: context.colorScheme.secondaryColor,
                        child: _buildBookingOrderTabBar(context)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: filters.length,
      itemBuilder: (BuildContext context, int index) {
        return CustomInkWellContainer(
          onTap: () {
            if (currFilter == index) {
              return;
            }
            currFilter = index;
            setState(() {});

            switch (currFilter) {
              case 0:
                selectedStatus = null;
                break;
              case 1:
                selectedStatus = 'awaiting';
                break;
              case 2:
                selectedStatus = 'confirmed';
                break;
              case 3:
                selectedStatus = 'started';
                break;
              case 4:
                selectedStatus = 'rescheduled';
                break;
              case 5:
                selectedStatus = 'booking_ended';
                break;
              case 6:
                selectedStatus = 'completed';
                break;
              case 7:
                selectedStatus = 'cancelled';
                break;
            }
            context.read<FetchBookingsCubit>().fetchBookings(
                status: selectedStatus,
                customRequestOrder: selectedBookingOrder);
          },
          child: CustomContainer(
            color: currFilter == index
                ? Theme.of(context).colorScheme.accentColor
                : Colors.transparent,
            borderRadius: UiUtils.borderRadiusOf10,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            
            constraints: const BoxConstraints(minWidth: 90),
            child: Center(
              child: Text(
                filters[index]['fName'],
                style: TextStyle(
                  color: currFilter == index
                      ? AppColors.whiteColors
                      : Theme.of(context).colorScheme.blackColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookingOrderTabBar(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center, // Centers the tabs horizontally

      children: List.generate(orderFilters.length, (int index) {
        return Expanded(
          child: CustomInkWellContainer(
            showSplashEffect: false,
            onTap: () {
              if (currentOrder == index) {
                return;
              }
              currentOrder = index;
              setState(() {});

              switch (currentOrder) {
                case 0:
                  selectedBookingOrder = '';
                  break;
                case 1:
                  selectedBookingOrder = '1';
                  break;
              }
              context.read<FetchBookingsCubit>().fetchBookings(
                  status: selectedStatus,
                  customRequestOrder: selectedBookingOrder);
            },
            child: CustomContainer(
              color: currentOrder == index
                  ? Theme.of(context).colorScheme.accentColor
                  : Theme.of(context).colorScheme.secondaryColor,
              borderRadius: UiUtils.borderRadiusOf50,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 50,
              child: Center(
                child: CustomText(
                  orderFilters[index]['fName'],
                  color: currentOrder == index
                      ? AppColors.whiteColors
                      : Theme.of(context).colorScheme.blackColor,
                  fontWeight: FontWeight.w500,
                  maxLines: 1,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
