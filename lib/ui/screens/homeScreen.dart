import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/generalImports.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen(
      {super.key, required this.scrollController, this.navigateToTab});

  final ScrollController scrollController;
  final void Function(int)? navigateToTab;

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  int gridItems = 4;
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

  late final ScrollController bookingController = ScrollController()
    ..addListener(pageScrollListen);
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

  void pageScrollListen() {
    if (mounted && bookingController.isEndReached()) {
      // Check if mounted first
      if (context.read<FetchBookingsCubit>().hasMoreData()) {
        context
            .read<FetchBookingsCubit>()
            .fetchMoreBookings(status: 'awaiting', fetchBothBookings: '1');
      }
    }
  }

  @override
  void initState() {
    widget.scrollController.addListener(scrollListener);

    context
        .read<FetchBookingsCubit>()
        .fetchBookings(status: 'awaiting', fetchBothBookings: '1');
    //
    context.read<FetchHomeDataCubit>().getHomeData();
    context.read<FetchSystemSettingsCubit>().getSettings(isAnonymous: false);

    super.initState();
  }

  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    FirebaseMessaging.instance.getToken().then((String? value) {});
    FirebaseMessaging.instance.getToken();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: UiUtils.getSystemUiOverlayStyle(
        context: context,
      ),
      child: SafeArea(
        child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.primaryColor,
            body: NestedScrollView(
                controller: widget.scrollController,
                headerSliverBuilder: (context, _) {
                  return [
                    SliverPersistentHeader(
                      delegate: AppBarPersistentHeaderDelegate(
                        child: Center(
                            child: AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, _) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomText(
                                        context
                                                .watch<ProviderDetailsCubit>()
                                                .providerDetails
                                                .user
                                                ?.username! ??
                                            '',
                                        fontSize: fontAnimation.value,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .blackColor,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CustomSvgPicture(
                                            svgImage: AppAssets.bCalender,
                                            height: fontAnimation2.value,
                                            width: fontAnimation2.value,
                                          ),
                                          const CustomSizedBox(
                                            width: 5,
                                          ),
                                          CustomText(
                                            DateFormat('EEEE d MMMM')
                                                .format(DateTime.now()),
                                            fontSize: fontAnimation2.value,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .lightGreyColor,
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                })),
                      ),
                      pinned: true,
                    )
                  ];
                },
                body: dashboard())),
      ),
    );
  }

  Widget _buildBookingBox(String count, String label) {
    return Expanded(
      child: CustomContainer(
        padding: const EdgeInsets.all(12),
        borderRadius: UiUtils.borderRadiusOf10,
        border: Border.all(
            color: context.colorScheme.lightGreyColor.withValues(alpha: 0.2),
            width: 0.5),
        color: context.colorScheme.secondaryColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              count,
              color: context.colorScheme.accentColor,
            ),
            CustomText(
              label,
              color: context.colorScheme.lightGreyColor,
              fontSize: 12,
            ),
          ],
        ),
      ),
    );
  }

  String getPendingDays(String expireDate) {
    final String dateString = expireDate;

    final DateTime enteredDate = DateTime.parse(dateString);

    DateTime currentDate = DateTime.now();
    currentDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    final int pendingDays = enteredDate.difference(currentDate).inDays;

    return pendingDays.toString();
  }

  Widget dashboard() {
    return CustomRefreshIndicator(
      onRefresh: () async {
        context.read<FetchHomeDataCubit>().getHomeData();
        context
            .read<FetchBookingsCubit>()
            .fetchBookings(status: 'awaiting', fetchBothBookings: '1');
        bookingController.animateTo(0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn);
      },
      child: BlocBuilder<FetchHomeDataCubit, FetchHomeDataState>(
        builder: (BuildContext context, FetchHomeDataState state) {
          if (state is FetchHomeDataFailure) {
            return Center(
              child: ErrorContainer(
                onTapRetry: () {
                  context.read<FetchHomeDataCubit>().getHomeData();
                  context.read<FetchBookingsCubit>().fetchBookings(
                      status: 'awaiting', fetchBothBookings: '1');
                },
                errorMessage: state.errorMessage.translate(context: context),
              ),
            );
          }
          if (state is FetchHomeDataSuccess) {
            final subscriptionInformation =
                state.homedata.subscriptionInformation;
            final bookingInformation = state.homedata.bookings;
            final earningReport = state.homedata.earningReport;
            final customJobs = state.homedata.customJobs;
            final salesData = state.homedata.salesData;
            return SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
             
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (subscriptionInformation != null)
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: CustomContainer(
                        padding: const EdgeInsets.all(15),
                        borderRadius: UiUtils.borderRadiusOf10,
                        color: context.colorScheme.accentColor,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CustomContainer(
                              color:
                                  AppColors.whiteColors.withValues(alpha: 0.2),
                              borderRadius: UiUtils.borderRadiusOf10,
                              padding: const EdgeInsets.all(10),
                              child: CustomSvgPicture(
                                svgImage: AppAssets.crown,
                                color: AppColors.whiteColors,
                              ),
                            ),
                            const SizedBox(width: 10), // Spacing

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Subscription Name
                                  CustomText(
                                    subscriptionInformation.name!,
                                    color: AppColors.whiteColors,
                                    fontSize: 18,
                                    maxLines: 1,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  const SizedBox(height: 5), // Spacing

                                  // Subscription Details Row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Valid Till Date
                                      if (subscriptionInformation.duration !=
                                          "unlimited")
                                        CustomText(
                                          '${'validTill'.translate(context: context)} ${DateFormat("d MMM yyyy").format(
                                            DateTime.parse(
                                                subscriptionInformation
                                                    .expiryDate!),
                                          )}',
                                          fontSize: 12,
                                          color: AppColors.whiteColors
                                              .withValues(alpha: 0.5, ),
                                        )
                                      else
                                        CustomText(
                                          'yoursforlifeNoexpiry!'
                                              .translate(context: context),
                                          fontSize: 12,
                                          color: AppColors.whiteColors
                                              .withValues(alpha: 0.5, ),
                                        ),

                                      // Days Left
                                      if (subscriptionInformation.duration !=
                                          "unlimited")
                                        CustomText(
                                          '${getPendingDays(subscriptionInformation.expiryDate!)} ${'daysLeft'.translate(context: context)}',
                                          color: AppColors.whiteColors,
                                          fontWeight: FontWeight.w500,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: CustomText(
                      'bookingTab'.translate(context: context),
                      color: context.colorScheme.blackColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 2,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBookingBox(
                            bookingInformation!.todayBookings!.toString(),
                            'todays'.translate(context: context)),
                        const CustomSizedBox(width: 5),
                        _buildBookingBox(
                            bookingInformation.tommorrowBookings.toString(),
                            'tomorrow'.translate(context: context)),
                        const CustomSizedBox(width: 5),
                        _buildBookingBox(
                            bookingInformation.upcomingBookings.toString(),
                            'upcoming'.translate(context: context)),
                      ],
                    ),
                  ),
                  const CustomSizedBox(height: 10),
               
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: CustomContainer(
                      height: 390,
                      padding: const EdgeInsets.only(
                        top: 15,
                      ),
                      child: MonthlyEarningBarChart(
                          monthlySales: salesData!.monthlySales,
                          yearlySales: salesData.yearlySales,
                          weeklySales: salesData.weeklySales
                          ),
                    ),
                  ),
                  // ],

                  const CustomSizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: CustomText(
                      'earningReport'.translate(context: context),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const CustomSizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: CustomContainer(
                      padding: const EdgeInsets.all(15),
                      color: context.colorScheme.secondaryColor,
                      borderRadius: UiUtils.borderRadiusOf10,
                      border: Border.all(
                          color: context.colorScheme.lightGreyColor
                              .withValues(alpha: 0.2),
                          width: 0.5),
                      
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(),
                          1: FlexColumnWidth(),
                        },
                        children: [
                          TableRow(children: [
                            _buildEarningItem(
                                'myIncome'.translate(context: context),
                                (earningReport!.myIncome ?? "0")
                                    .replaceAll(',', '')
                                    .toString()
                                    .priceFormat()),
                            _buildEarningItem(
                                'remainingIncome'.translate(context: context),
                                (earningReport.remainingIncome ?? "0")
                                    .replaceAll(',', '')
                                    .toString()
                                    .priceFormat()),
                          ]),
                          const TableRow(children: [
                            SizedBox(height: 10),
                            SizedBox(height: 10),
                          ]),
                          TableRow(children: [
                            _buildEarningItem(
                                'adminCommLbl'.translate(context: context),
                                (earningReport.adminCommission ?? "0")
                                    .replaceAll(',', '')
                                    .toString()
                                    .priceFormat()),
                            _buildEarningItem(
                                'futureEarning'.translate(context: context),
                                (earningReport.futureEarningFromBookings ?? "0")
                                    .replaceAll(',', '')
                                    .toString()
                                    .priceFormat()),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const CustomSizedBox(height: 8),
                  if ((context.watch<FetchBookingsCubit>().state
                          is FetchBookingsSuccess) &&
                      (context.watch<FetchBookingsCubit>().state
                              as FetchBookingsSuccess)
                          .bookings
                          .isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: CustomText(
                        'pendingBookings'.translate(context: context),
                        fontSize: 18,
                        textAlign: TextAlign.start,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const CustomSizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: CustomContainer(
                        height: context.watch<FetchBookingsCubit>().state
                                is FetchBookingsSuccess
                            ? 290
                            : 0,
                        child:
                            BlocBuilder<FetchBookingsCubit, FetchBookingsState>(
                          builder: (BuildContext context,
                              FetchBookingsState bookingState) {
                            if (bookingState is FetchBookingsInProgress) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 6.0),
                                child: ShimmerLoadingContainer(
                                  child: CustomShimmerContainer(
                                    width: 170,
                                  ),
                                ),
                              );
                            }

                            if (bookingState is FetchBookingsSuccess) {
                              if (bookingState.bookings.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return SingleChildScrollView(
                                controller: bookingController,
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    ListView.separated(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: bookingState.bookings.length,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final BookingsModel bookingModel =
                                            bookingState.bookings[index];
                                        return BlocProvider<
                                            UpdateBookingStatusCubit>(
                                          create: (BuildContext context) =>
                                              UpdateBookingStatusCubit(),
                                          child: Builder(builder: (context) {
                                            return SizedBox(
                                              width: 300,
                                              child: BookingCardContainer(
                                                bookingModel: bookingModel,
                                                isFrom: 'home',
                                              ),
                                            );
                                          }),
                                        );
                                      },
                                      separatorBuilder:
                                          (BuildContext context, int index) =>
                                              const CustomSizedBox(
                                        width: 10,
                                      ),
                                    ),
                                    if (bookingState.isLoadingMoreBookings)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: CustomCircularProgressIndicator(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .accentColor,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                  ],
                  if (customJobs!.totalOpenJobs! > 0) ...[
                    const CustomSizedBox(height: 10),
                    Container(
                      color: context.colorScheme.secondaryColor,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomContainer(
                                height: 50,
                                width: 50,
                                borderRadius: UiUtils.borderRadiusOf10,
                                color:
                                    Theme.of(context).colorScheme.primaryColor,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        UiUtils.borderRadiusOf10),
                                    child: const CustomSvgPicture(
                                      svgImage: AppAssets.bagImage,
                                      // boxFit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const CustomSizedBox(width: 10),
                              Expanded(
                                  child: CustomSizedBox(
                                      // height: 40,
                                      child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    "jobRequestsForYouLbl"
                                        .translate(context: context),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .blackColor,
                                    maxLines: 1,
                                  ),
                                  Row(
                                    children: [
                                      CustomText(
                                        customJobs.totalOpenJobs.toString(),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .blackColor,
                                      ),
                                      const CustomSizedBox(
                                        width: 3,
                                      ),
                                      CustomText(
                                        "requestLbl"
                                            .translate(context: context),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .blackColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ))),
                              const CustomSizedBox(width: 10),
                              InkWell(
                                child: CustomText(
                                  "viewAll".translate(context: context),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(context).colorScheme.blackColor,
                                  maxLines: 1,
                                  showUnderline: true,
                                ),
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, Routes.jobRequestScreen,
                                      arguments: widget.scrollController);
                                },
                              ),
                            ],
                          ),
                          const Divider(),
                          Column(
                            children: [
                              ListView.separated(
                                shrinkWrap: true,
                                itemCount: customJobs.openJobs!.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  final JobRequestModel jobRequestModel =
                                      customJobs.openJobs![index];

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        Routes.openJobRequestDetails,
                                        arguments: {
                                          'jobRequestModel': jobRequestModel
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          end: 10, start: 10, top: 5),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: CustomSizedBox(
                                              // height: 100,
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    CustomText(
                                                      jobRequestModel
                                                              .serviceTitle ??
                                                          "",
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .blackColor,
                                                      maxLines: 2,
                                                    ),
                                                    const CustomSizedBox(
                                                        height: 5),
                                                    CustomText(
                                                      jobRequestModel
                                                              .serviceShortDescription ??
                                                          "",
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .lightGreyColor,
                                                      maxLines: 2,
                                                    ),
                                                    const CustomSizedBox(
                                                        height: 5),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              CustomContainer(
                                                                height: 18,
                                                                width: 18,
                                                                shape: BoxShape
                                                                    .circle,
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          UiUtils
                                                                              .borderRadiusOf50),
                                                                  child:
                                                                      CustomCachedNetworkImage(
                                                                    imageUrl:
                                                                        jobRequestModel.image ??
                                                                            "",
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 10),
                                                              Expanded(
                                                                child:
                                                                    CustomText(
                                                                  jobRequestModel
                                                                          .username ??
                                                                      "",
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .blackColor,
                                                                  maxLines: 1,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        InkWell(
                                                          child: CustomText(
                                                            "view".translate(
                                                                context:
                                                                    context),
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .blackColor,
                                                            maxLines: 1,
                                                            showUnderline: true,
                                                          ),
                                                          onTap: () {
                                                            Navigator.pushNamed(
                                                              context,
                                                              Routes
                                                                  .openJobRequestDetails,
                                                              arguments: {
                                                                'jobRequestModel':
                                                                    jobRequestModel
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    )
                                                  ]),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  if (index == 0) {
                                    return const Divider();
                                  } else {
                                    return const CustomSizedBox(height: 10);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                  const CustomSizedBox(
                    height: 100,
                  ),
                ],
              ),
            );
          }
          return ShimmerHomeScreen();
        },
      ),
    );
  }

  Widget _buildEarningItem(String title, String amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          title,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: context.colorScheme.accentColor,
          maxLines: 1,
        ),
        const CustomSizedBox(height: 4),
        CustomText(
          amount,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
