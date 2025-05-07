import 'package:edemand_partner/ui/screens/services/enum/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import '../../../app/generalImports.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  ServicesScreenState createState() => ServicesScreenState();
}

class ServicesScreenState extends State<ServicesScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  //
  double? minFilterRange;
  double? maxFilterRange;

  double _bottomPadding = 50.0;

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

    if (widget.scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_bottomPadding != 10.0) {
        setState(() {
          _bottomPadding = 10.0;
        });
      }
    } else if (widget.scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (_bottomPadding != 50.0) {
        setState(() {
          _bottomPadding = 50.0;
        });
      }
    }
  }

  //
  String prevVal = '';

  Timer? _searchDelay;
  String previouseSearchQuery = '';
  final ScrollController searchScrollController = ScrollController();
  bool searchTap = false;
  bool isSearching = false;
  bool isFiltering = false;
  SortOrder rating = SortOrder.none;
  SortOrder pricing = SortOrder.none;
  SortOrder booking = SortOrder.none;

  //
  late TextEditingController searchController = TextEditingController()
    ..addListener(searchServiceListener);

  late final AnimationController _filterButtonOpacityAnimation =
      AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  
  @override
  void initState() {
    widget.scrollController.addListener(scrollListener);
    getServices();
    context.read<FetchServiceCategoryCubit>().fetchCategories();
    context.read<FetchTaxesCubit>().fetchTaxes();
    super.initState();
  }

  void getServices() {
    final Map<String, String> params = getSortParameter();

    context
        .read<FetchServicesCubit>()
        .fetchServices(order: params['order'], sort: params['sort']);
  }

  

  String getSortBy() {
    if (rating != SortOrder.none) {
      return "average_rating";
    } else if (pricing != SortOrder.none) {
      return "price";
    } else if (booking != SortOrder.none) {
      return "total_bookings";
    }
    return "";
  }

  String getSortOrder() {
    if (rating != SortOrder.none) {
      return rating == SortOrder.ascending ? "asc" : "desc";
    } else if (pricing != SortOrder.none) {
      return pricing == SortOrder.ascending ? "asc" : "desc";
    } else if (booking != SortOrder.none) {
      return booking == SortOrder.ascending ? "asc" : "desc";
    }
    return "";
  }

  Map<String, String> getSortParameter() {
    final String sortBy = getSortBy();
    final String sortOrder = getSortOrder();

    if (sortBy.isNotEmpty && sortOrder.isNotEmpty) {
      return {
        "sort": sortBy,
        "order": sortOrder,
      };
    }
    return {};
  }

  void searchServiceListener() {
    _searchDelay?.cancel();
    searchCallAfterDelay();
  }

  void searchCallAfterDelay() {
    _searchDelay = Timer(const Duration(milliseconds: 500), searchService);
    /* else {
      context.read<FetchServicesCubit>().fetchServices();
    } */
  }

  Future<void> searchService() async {
    if (searchController.text.isNotEmpty || previouseSearchQuery != '') {
      if (previouseSearchQuery != searchController.text) {
        final Map<String, String> params = getSortParameter();
        context.read<FetchServicesCubit>().searchService(
            searchController.text, params['order'], params['sort']);
        previouseSearchQuery = searchController.text;
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    searchScrollController.dispose();
    widget.scrollController.removeListener(scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: UiUtils.getSystemUiOverlayStyle(
        context: context,
      ),
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
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
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceAround, //MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          CustomText(
                                            'serviceTab'
                                                .translate(context: context),
                                            fontSize: fontAnimation.value,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .blackColor,
                                          ),
                                          context
                                                  .watch<FetchServicesCubit>()
                                                  .state is FetchServicesSuccess
                                              ? HeadingAmountAnimation(
                                                  key: ValueKey((context
                                                              .read<
                                                                  FetchServicesCubit>()
                                                              .state
                                                          as FetchServicesSuccess)
                                                      .total),
                                                  text:
                                                      '${(context.read<FetchServicesCubit>().state as FetchServicesSuccess).total.toString()} ${'serviceTab'.translate(context: context)}',
                                                  textStyle: TextStyle(
                                                    color: context.colorScheme
                                                        .lightGreyColor,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize:
                                                        fontAnimation2.value,
                                                  ),
                                                )
                                              : CustomSizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.7,
                                                  height: fontAnimation2.value,
                                                )
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        child: topWidget(),
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
                     
                      if (widget.scrollController.isEndReached()) {
                        if (context
                            .read<FetchServicesCubit>()
                            .hasMoreServices()) {
                          final Map<String, String> params = getSortParameter();
                          context.read<FetchServicesCubit>().fetchMoreServices(
                              order: params['order'], sort: params['sort']);
                        }
                      }
                    }
                    return false;
                  },
                  child: mainWidget(),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.only(
                      bottom: _bottomPadding, left: 15, right: 15),
                  child: const AddFloatingButton(
                    routeNm: Routes.createService,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget topWidget() {
    return BlocConsumer<FetchServicesCubit, FetchServicesState>(
      listener: (BuildContext context, FetchServicesState state) {
        if (state is FetchServicesSuccess) {
          _filterButtonOpacityAnimation.forward();
        }
      },
      builder: (BuildContext context, FetchServicesState state) {
        return Padding(
          padding: const EdgeInsetsDirectional.only(top: 10, start: 20),
          child: SingleChildScrollView(
            controller: searchScrollController,
            physics: isFiltering
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _customButton(
                  svg: isFiltering ? AppAssets.close : AppAssets.filter,
                  bgColor: isFiltering
                      ? context.colorScheme.secondaryColor
                      : searchTap
                          ? context.colorScheme.accentColor
                          : context.colorScheme.accentColor
                              .withValues(alpha: 0.12),
                  svgColor: isFiltering
                      ? context.colorScheme.blackColor
                      : searchTap
                          ? context.colorScheme.secondaryColor
                          : context.colorScheme.accentColor),
              Stack(
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      _buildFilterButton(
                        svgColor: rating.svgColor(context),
                        svg: rating.asset,
                        bgColor: rating.backgroundColor(context),
                        text: 'ratings'.translate(context: context),
                        onTap: () {
                          setState(() {
                            rating = SortOrder.values[(rating.index + 1) % 3];
                            pricing = SortOrder.none;
                            booking = SortOrder.none;
                            getServices();
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildFilterButton(
                        svgColor: pricing.svgColor(context),
                        svg: pricing.asset,
                        bgColor: pricing.backgroundColor(context),
                        text: 'pricing'.translate(context: context),
                        onTap: () {
                          setState(() {
                            pricing = SortOrder.values[(pricing.index + 1) % 3];
                            rating = SortOrder.none;
                            booking = SortOrder.none;
                            getServices();
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildFilterButton(
                        svgColor: booking.svgColor(context),
                        svg: booking.asset,
                        bgColor: booking.backgroundColor(context),
                        text: 'booking'.translate(context: context),
                        onTap: () {
                          setState(() {
                            booking = SortOrder.values[(booking.index + 1) % 3];
                            pricing = SortOrder.none;
                            rating = SortOrder.none;
                            getServices();
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      _customButton(
                        svg: AppAssets.search,
                        bgColor: context.colorScheme.secondaryColor,
                        svgColor: Theme.of(context).colorScheme.lightGreyColor,
                        borderColor: context.colorScheme.lightGreyColor,
                        onTap: () {
                          searchScrollController.animateTo(
                            0.0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                  AnimatedSwitcher(
                      duration: const Duration(seconds: 1),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return SlideTransition(
                          position: Directionality.of(context)
                                  .toString()
                                  .contains(
                                      TextDirection.RTL.value.toLowerCase())
                              ? Tween<Offset>(
                                  begin: const Offset(-1, 0),
                                  end: Offset.zero,
                                ).animate(animation)
                              : Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                          child: child,
                        );
                      },
                      child:
                          isFiltering ? const SizedBox.shrink() : _searchBar()),
                ],
              )
            ]),
          ),
        );
      },
    );
  }

  Widget _customButton(
      {required String svg,
      Color? bgColor,
      Color? svgColor,
      VoidCallback? onTap,
      Color? borderColor}) {
    return GestureDetector(
      onTap: () {
        onTap?.call();
        setState(() {
          isFiltering = !isFiltering;
          isSearching = !isSearching;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(seconds: 2),
        curve: Curves.easeInOut,
        height: 40,
        width: 40,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: borderColor != null
              ? Border.all(
                  color: borderColor.withValues(alpha: 0.5), width: 0.5)
              : null,
          color: bgColor ?? const Color(0XFF212121).withAlpha(50),
          borderRadius: BorderRadius.circular(6),
        ),
        child: CustomSvgPicture(
          svgImage: svg,
          color: svgColor,
        ),
      ),
    );
  }

  Widget _searchBar() {
    return ColoredBox(
      color: context.colorScheme.primaryColor,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(end: 50),
        child: AnimatedContainer(
          duration: const Duration(seconds: 2),
          height: 40,
          width: 260,
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf6),
              border: Border.all(
                  color: searchTap
                      ? context.colorScheme.accentColor
                      : context.colorScheme.lightGreyColor),
              color: searchTap
                  ? context.colorScheme.accentColor.withValues(alpha: 0.05)
                  : context.colorScheme.secondaryColor),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: TextFormField(
            onTap: () {
              setState(() {
                searchTap = true;
                isSearching = true;
              });
            },
            onTapOutside: (event) {
              setState(() {
                searchTap = false;
                isSearching = false;
              });
            },
            controller: searchController,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
              border: InputBorder.none,
              fillColor: Theme.of(context).colorScheme.blackColor,
              hintText: 'searchServicesLbl'.translate(context: context),
              hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.lightGreyColor,
                  fontSize: 15),
              prefixIcon: CustomSvgPicture(
                svgImage: AppAssets.search,
                color: context.colorScheme.lightGreyColor,
              ),
            ),
            textAlignVertical: TextAlignVertical.center,
            onEditingComplete: () {
              FocusScope.of(context).unfocus();
              setState(() {
                isSearching = false;
                searchTap = false;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton({
    required String svg,
    required String text,
    Color? bgColor,
    Color? svgColor,
    VoidCallback? onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color:
            bgColor ?? context.colorScheme.accentColor.withValues(alpha: 0.05),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: CustomContainer(
          borderRadius: UiUtils.borderRadiusOf6,
          color: bgColor ??
              context.colorScheme.accentColor.withValues(alpha: 0.05),
          gradient: bgColor == null
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.colorScheme.accentColor,
                    context.colorScheme.accentColor.withValues(alpha: 0.05),
                    Colors.transparent,
                    Colors.transparent,
                    context.colorScheme.accentColor.withValues(alpha: 0.05),
                    context.colorScheme.accentColor,
                  ],
                  stops: const [0.03, 0.25, 0.3, 0.7, 0.75, 0.97],
                  transform: const GradientRotation(0.5),
                ),
          child: CustomContainer(
            margin: const EdgeInsets.all(2),
            color: context.colorScheme.secondaryColor,
            borderRadius: UiUtils.borderRadiusOf6,
            child: CustomContainer(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              color: bgColor ??
                  context.colorScheme.accentColor.withValues(alpha: 0.05),
              borderRadius: UiUtils.borderRadiusOf6,
              child: Row(
                children: [
                  CustomText(
                    text,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  CustomSvgPicture(
                    svgImage: svg,
                    color: svgColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getTitleAndSubDetails({
    required String title,
    required String subDetails,
    bool? showRatingIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          title.translate(context: context),
          fontSize: 14,
          maxLines: 2,
          color: Theme.of(context).colorScheme.lightGreyColor,
        ),
        const CustomSizedBox(
          height: 5,
        ),
        Row(
          children: [
            Visibility(
              visible: showRatingIcon ?? false,
              child: const Icon(
                Icons.star_outlined,
                color: AppColors.starRatingColor,
                size: 20,
              ),
            ),
            CustomText(
              subDetails,
              fontSize: 14,
              maxLines: 2,
              color: Theme.of(context).colorScheme.blackColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget mainWidget() {
    return BlocListener<DeleteServiceCubit, DeleteServiceState>(
      listener: (BuildContext context, DeleteServiceState deleteServiceState) {
        if (deleteServiceState is DeleteServiceSuccess) {
          Navigator.pop(context);
          context
              .read<FetchServicesCubit>()
              .deleteServiceFromCubit(deleteServiceState.id);
          UiUtils.showMessage(
            context,
            'serviceDeletedSuccessfully'.translate(context: context),
            ToastificationType.success,
          );
        }
        if (deleteServiceState is DeleteServiceFailure) {
          UiUtils.showMessage(
            context,
            deleteServiceState.errorMessage.translate(context: context),
            ToastificationType.error,
          );
        }
      },
      child: CustomRefreshIndicator(
        onRefresh: () async {
          getServices();
          context.read<FetchTaxesCubit>().fetchTaxes();
          context.read<FetchServiceCategoryCubit>().fetchCategories();
        },
        child: BlocBuilder<FetchServicesCubit, FetchServicesState>(
          builder: (BuildContext context, FetchServicesState state) {
            if (state is FetchServicesFailure) {
              return Center(
                child: ErrorContainer(
                  onTapRetry: () {
                    getServices();
                    context.read<FetchTaxesCubit>().fetchTaxes();
                  },
                  errorMessage: state.errorMessage.translate(context: context),
                ),
              );
            }
            if (state is FetchServicesSuccess) {
              if (state.services.isEmpty) {
                return Center(
                  child: NoDataContainer(
                    titleKey: 'noDataFound'.translate(context: context),
                  ),
                );
              }
              return SingleChildScrollView(
                clipBehavior: Clip.hardEdge,
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(
                          bottom: 80, left: 15, right: 15, top: 15),
                      itemCount: state.services.length,
                      physics: const NeverScrollableScrollPhysics(),
                      clipBehavior: Clip.hardEdge,
                      itemBuilder: (BuildContext context, int index) {
                        final ServiceModel service = state.services[index];

                        return ServiceContainer(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Routes.serviceDetails,
                              arguments: {'serviceModel': service},
                            );
                          },
                          listingUI: true,
                          service: service,
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const CustomSizedBox(
                        height: 10,
                      ),
                    ),
                    if (state.isLoadingMoreServices)
                      CustomCircularProgressIndicator(
                        color: Theme.of(context).colorScheme.accentColor,
                      )
                  ],
                ),
              );
            }
            return SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              clipBehavior: Clip.none,
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsetsDirectional.all(16),
                    itemCount: 8,
                    itemBuilder: (BuildContext context, int index) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.0),
                        child: ShimmerLoadingContainer(
                          child: CustomShimmerContainer(
                            height: 150,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  
  @override
  bool get wantKeepAlive => true;
}



          