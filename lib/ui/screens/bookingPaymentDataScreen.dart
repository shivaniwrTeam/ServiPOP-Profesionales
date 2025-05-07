import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class BookingPaymentDataScreen extends StatefulWidget {
  const BookingPaymentDataScreen({super.key});

  @override
  BookingPaymentDataScreenState createState() =>
      BookingPaymentDataScreenState();

  static Route<BookingPaymentDataScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider(
        create: (BuildContext context) =>
            FetchBookingPaymentManagementDataCubit(),
        child: const BookingPaymentDataScreen(),
      ),
    );
  }
}

class BookingPaymentDataScreenState extends State<BookingPaymentDataScreen> {
  late final ScrollController _pageScrollController = ScrollController()
    ..addListener(_pageScrollListen);

  OverlayEntry? overlayEntry;

  @override
  void initState() {
    context
        .read<FetchBookingPaymentManagementDataCubit>()
        .fetchBookingPaymentManagementData();
    super.initState();
  }

  @override
  void dispose() {
    overlayEntry?.remove();
    overlayEntry?.dispose();
    super.dispose();
  }

  void _pageScrollListen() {
    if (_pageScrollController.isEndReached()) {
      if (context
          .read<FetchBookingPaymentManagementDataCubit>()
          .hasMoreData()) {
        context
            .read<FetchBookingPaymentManagementDataCubit>()
            .fetchMoreBookingPaymentManagementData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InterstitialAdWidget(
      child: Scaffold(
        bottomNavigationBar: const BannerAdWidget(),
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        appBar: UiUtils.getSimpleAppBar(
          statusBarColor: context.colorScheme.secondaryColor,
          context: context,
          elevation: 1,
          title: 'bookingPaymentManagement'.translate(context: context),
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 10),
              child: IconButton(
                onPressed: () {
                  if (overlayEntry?.mounted ?? false) {
                    return;
                  }
                  overlayEntry = OverlayEntry(
                    builder: (BuildContext context) => Positioned.directional(
                      textDirection: Directionality.of(context),
                      end: 10,
                      top: MediaQuery.sizeOf(context).height * .10,
                      child: CustomContainer(
                        width: MediaQuery.sizeOf(context).width * .9,
                        color: Theme.of(context).colorScheme.secondaryColor,
                        borderRadius: UiUtils.borderRadiusOf5,
                        boxShadow:  [
                          BoxShadow(
                            blurRadius: 0.5,
                            spreadRadius: 0.5,
                            color: context.colorScheme.lightGreyColor,
                          )
                        ],
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            'bookingPaymentManagementDescription'
                                .translate(context: context),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.blackColor,
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              fontStyle: FontStyle.normal,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );

                  Overlay.of(context).insert(overlayEntry!);
                  Timer(
                      const Duration(seconds: 5), () => overlayEntry?.remove());
                },
                icon: Icon(
                  Icons.help_outline_outlined,
                  color: Theme.of(context).colorScheme.blackColor,
                ),
              ),
            )
          ],
        ),
        body: mainWidget(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget getTitleAndDetails(
      {required String title, required String subDetails}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          title.translate(context: context),
          fontSize: 14,
          color: Theme.of(context).colorScheme.lightGreyColor,
        ),
        CustomText(
          subDetails,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Theme.of(context).colorScheme.blackColor,
        ),
      ],
    );
  }

  Widget showBookingPaymentDataList({
    required List<BookingPaymentDataModel> bookingPaymentData,
    required bool isLoadingMore,
  }) {
    return SingleChildScrollView(
      controller: _pageScrollController,
      clipBehavior: Clip.none,
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            itemCount: bookingPaymentData.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return CustomContainer(
                width: MediaQuery.sizeOf(context).width,
                padding: const EdgeInsetsDirectional.all(10),
                color: Theme.of(context).colorScheme.secondaryColor,
                borderRadius: UiUtils.borderRadiusOf10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (bookingPaymentData[index].orderId != "0") ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                "bookingId".translate(context: context),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .lightGreyColor,
                              ),
                              const CustomSizedBox(
                                width: 5,
                              ),
                              CustomText(
                                bookingPaymentData[index].orderId,
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.blackColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const CustomSizedBox(height: 5),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          "type".translate(context: context),
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.lightGreyColor,
                        ),
                        const CustomSizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: CustomText(
                            bookingPaymentData[index]
                                .type
                                .translate(context: context),
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.blackColor,
                          ),
                        ),
                      ],
                    ),
                    const CustomSizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: getTitleAndDetails(
                            title: 'amount',
                            subDetails: bookingPaymentData[index]
                                .amount
                                .replaceAll(',', '')
                                .toString()
                                .priceFormat(),
                          ),
                        ),
                        Expanded(
                          child: getTitleAndDetails(
                            title: 'totalAmount',
                            subDetails: bookingPaymentData[index]
                                .totalAmount
                                .replaceAll(',', '')
                                .toString()
                                .priceFormat(),
                          ),
                        ),
                      ],
                    ),
                    const CustomSizedBox(height: 5),
                    getTitleAndDetails(
                      title: 'adminCommissionAmount',
                      subDetails: bookingPaymentData[index]
                          .commissionAmount
                          .replaceAll(',', '')
                          .toString()
                          .priceFormat(),
                    ),
                    const CustomSizedBox(height: 5),
                    getTitleAndDetails(
                      title: 'message',
                      subDetails: bookingPaymentData[index].message,
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                const CustomSizedBox(
              height: 10,
            ),
          ),
          if (isLoadingMore) ...[
            CustomCircularProgressIndicator(
              color: Theme.of(context).colorScheme.accentColor,
            )
          ]
        ],
      ),
    );
  }

  Widget mainWidget() {
    return CustomRefreshIndicator(
      onRefresh: () async {
        context
            .read<FetchBookingPaymentManagementDataCubit>()
            .fetchBookingPaymentManagementData();
      },
      child: BlocBuilder<FetchBookingPaymentManagementDataCubit,
          FetchBookingPaymentManagementDataState>(
        builder: (BuildContext context,
            FetchBookingPaymentManagementDataState state) {
          if (state is FetchBookingPaymentManagementDataFailureState) {
            return Center(
              child: ErrorContainer(
                onTapRetry: () {
                  context
                      .read<FetchBookingPaymentManagementDataCubit>()
                      .fetchBookingPaymentManagementData();
                },
                errorMessage: state.errorMessage.translate(context: context),
              ),
            );
          }
          if (state is FetchBookingPaymentManagementDataSuccessState) {
            return state.bookingPaymentData.isEmpty
                ? Center(
                    child: NoDataContainer(
                      titleKey: 'noDataFound'.translate(context: context),
                    ),
                  )
                : showBookingPaymentDataList(
                    bookingPaymentData: state.bookingPaymentData,
                    isLoadingMore: state.isLoadingMore,
                  );
          }
          return ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            itemCount: 8,
            physics: const NeverScrollableScrollPhysics(),
            clipBehavior: Clip.none,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ShimmerLoadingContainer(
                  child: CustomShimmerContainer(
                    height: MediaQuery.sizeOf(context).height * 0.18,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
