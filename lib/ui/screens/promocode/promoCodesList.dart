import 'package:flutter/material.dart';

import '../../../app/generalImports.dart';

class PromoCode extends StatefulWidget {
  const PromoCode({super.key});

  @override
  PromoCodeState createState() => PromoCodeState();

  static Route<PromoCode> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (BuildContext context) => DeletePromocodeCubit(),
          ),
        ],
        child: const PromoCode(),
      ),
    );
  }
}

class PromoCodeState extends State<PromoCode> {
  int? expandedIndex; // Keeps track of the currently expanded container

  late final ScrollController _pageScrollController = ScrollController()
    ..addListener(_pageScrollListener);

  @override
  void initState() {
    context.read<FetchPromocodesCubit>().fetchPromocodeList();

    super.initState();
  }

  void _pageScrollListener() {
    if (_pageScrollController.isEndReached()) {
      context.read<FetchPromocodesCubit>().fetchMorePromocodes();
    }
  }

  void deletePromocode(promocode) {
    UiUtils.showAnimatedDialog(
        context: context,
        child: BlocProvider.value(
          value: BlocProvider.of<DeletePromocodeCubit>(context),
          child: Builder(builder: (context) {
            return ConfirmationDialog(
                title: "deletePromocode",
                description: "deleteDescription",
                confirmButtonName: "delete",
                showProgressIndicator: context
                    .watch<DeletePromocodeCubit>()
                    .state is DeleteServiceInProgress,
                confirmButtonPressed: () {
                  if (promocode.id != null) {
                    if (context
                        .read<FetchSystemSettingsCubit>()
                        .isDemoModeEnable()) {
                      UiUtils.showDemoModeWarning(context: context);
                      return;
                    }
                    context.read<DeletePromocodeCubit>().deletePromocode(
                      int.parse(promocode.id!),
                      onDelete: () {
                        Navigator.pop(context);
                      },
                    );
                  } else {
                    UiUtils.showMessage(
                      context,
                      'somethingWentWrong'.translate(context: context),
                      ToastificationType.error,
                    );
                  }
                });
          }),
        ));
  }

  Widget durationContainer(String startDate, String endDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'durationLbl'.translate(context: context),
          fontSize: 13,
          color: context.colorScheme.lightGreyColor,
        ),
        CustomText(
          "${startDate.split(' ')[0].formatDate()} To ${endDate.split(' ')[0].formatDate()}",
          fontSize: 13,
        ),
      ],
    );
  }

  Widget discountAllusersUsedByContainer(String discount, String allowedUsers,
      String usedBy, String discountType) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                'discountLbl'.translate(context: context),
                fontSize: 13,
                color: context.colorScheme.lightGreyColor,
              ),
              CustomText(
                discountType == 'amount'
                    ? discount.replaceAll(',', '').toString().priceFormat()
                    : '$discount %',
                fontSize: 13,
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                'allowedUsers'.translate(context: context),
                fontSize: 13,
                color: context.colorScheme.lightGreyColor,
              ),
              CustomText(
                allowedUsers,
                fontSize: 13,
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                'usedBy'.translate(context: context),
                fontSize: 13,
                color: context.colorScheme.lightGreyColor,
              ),
              CustomText(
                '$usedBy ',
                fontSize: 13,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget setStatusAndButtons(
    BuildContext context, {
    required String promoCodeStatus,
    VoidCallback? editAction,
    VoidCallback? deleteAction,
    double? height,
  }) {
    //set required later
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: deleteAction,
            child: CustomContainer(
                borderRadius: UiUtils.borderRadiusOf6,
                color: AppColors.redColor.withAlpha(20),
                height: height,
                child: Center(
                  child: CustomText(
                    'deleteBtnLbl'.translate(context: context),
                    color: AppColors.redColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                )),
          ),
        ),
        const CustomSizedBox(width: 10),
        Expanded(
          child: setStatus(
            height: height,
            status: promoCodeStatus,
          ),
        ),
        const CustomSizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: editAction,
            child: CustomContainer(
                borderRadius: UiUtils.borderRadiusOf6,
                color: context.colorScheme.accentColor,
                height: height,
                child: Center(
                  child: CustomText(
                    'editBtnLbl'.translate(context: context),
                    color: AppColors.whiteColors,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                )
                ),
          ),
        ),
      ],
    );
  }

  Widget setStatus({required String status, double? height}) {
    final List<Map> statusFilterMap = [
      {
        'value': '0',
        'title': 'deactive'.translate(context: context),
        "color": AppColors.redColor
      },
      {
        'value': '1',
        'title': 'active'.translate(context: context),
        "color": AppColors.greenColor
      }
    ];

    final Map currentStatus = statusFilterMap
        .where((Map element) => element['value'] == status)
        .toList()[0];
    //
    return CustomContainer(
      height: height,
      color: (currentStatus['color'] as Color).withValues(alpha: 0.3),
      borderRadius: UiUtils.borderRadiusOf6,
      padding: const EdgeInsets.all(5),
      child: Center(
        child: CustomText(
          currentStatus['title'],
          fontSize: 14,
          maxLines: 2,
          color: currentStatus['color'] as Color,
        ),
      ),
    );
  }

  Widget mainWidget() {
    return CustomRefreshIndicator(
      onRefresh: () async {
        context.read<FetchPromocodesCubit>().fetchPromocodeList();
      },
      child: SingleChildScrollView(
        clipBehavior: Clip.none,
        physics: const AlwaysScrollableScrollPhysics(),
        child: BlocBuilder<FetchPromocodesCubit, FetchPromocodesState>(
          builder: (BuildContext context, FetchPromocodesState state) {
            if (state is FetchPromocodesInProgress) {
              return ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: 10,
                physics: const NeverScrollableScrollPhysics(),
                clipBehavior: Clip.none,
                itemBuilder: (BuildContext context, int index) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.0),
                    child: ShimmerLoadingContainer(
                      child: CustomShimmerContainer(
                        height: 100,
                      ),
                    ),
                  );
                },
              );
            }
            if (state is FetchPromocodesFailure) {
              return Center(
                child: ErrorContainer(
                  onTapRetry: () {
                    context.read<FetchPromocodesCubit>().fetchPromocodeList();
                  },
                  errorMessage: state.errorMessage.translate(context: context),
                ),
              );
            }
            if (state is FetchPromocodesSuccess) {
              if (state.promocodes.isEmpty) {
                return NoDataContainer(
                    titleKey: 'noDataFound'.translate(context: context));
              }
              return ListView.separated(
                controller: _pageScrollController,
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: state.promocodes.length,
                physics: const NeverScrollableScrollPhysics(),
                clipBehavior: Clip.none,
                itemBuilder: (BuildContext context, int index) {
                  final bool isExpanded = expandedIndex == index;

                  final PromocodeModel promocode = state.promocodes[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        expandedIndex = isExpanded ? null : index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: context.colorScheme.secondaryColor,
                        boxShadow: [
                          if (isExpanded)
                            BoxShadow(
                              color: context.colorScheme.lightGreyColor
                                  .withAlpha(50),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomImageContainer(
                                borderRadius: UiUtils.borderRadiusOf6,
                                imageURL: promocode.image!,
                                height: 80,
                                width: 80,
                                border: Border.all(
                                    color: context.colorScheme.blackColor,
                                    width: 0.2),
                                boxShadow: [],
                              ),
                              const CustomSizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        promocode.promoCode!,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .blackColor,
                                      ),
                                      const CustomSizedBox(
                                        height: 8,
                                      ),
                                      CustomText(
                                        promocode.message!,
                                        maxLines: 2,
                                        fontWeight: FontWeight.w400,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .lightGreyColor,
                                        fontSize: 13,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 300),
                            firstChild: const SizedBox.shrink(),
                            secondChild: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: discountAllusersUsedByContainer(
                                      promocode.discount!,
                                      promocode.noOfUsers!,
                                      promocode.totalUsedNumber!,
                                      promocode.discountType!),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: durationContainer(
                                      promocode.startDate!, promocode.endDate!),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: setStatusAndButtons(
                                    promoCodeStatus: promocode.status!,
                                    context,
                                    height: 40,
                                    editAction: () {
                                      Navigator.pushNamed(
                                        context,
                                        Routes.addPromoCode,
                                        arguments: {'promocode': promocode},
                                      );
                                    },
                                    deleteAction: () {
                                      deletePromocode(promocode);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            crossFadeState: isExpanded
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    CustomDivider(
                  color: context.colorScheme.primaryColor,
                  height: 10,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InterstitialAdWidget(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        appBar: UiUtils.getSimpleAppBar(
          statusBarColor: context.colorScheme.secondaryColor,
          context: context,
          title: 'promoCodeLbl'.translate(context: context),
        ),
        bottomNavigationBar: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomContainer(
              color: context.colorScheme.secondaryColor,
              child: CustomAddButton(
                onTap: () {
                  Navigator.pushNamed(context, Routes.addPromoCode);
                },
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: CustomText(
                    'addNew'.translate(context: context),
                    color: AppColors.whiteColors,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const BannerAdWidget(),
          ],
        ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: BlocListener<DeletePromocodeCubit, DeletePromocodeState>(
          listener: (BuildContext context, DeletePromocodeState state) {
            if (state is DeletePromocodeSuccess) {
              context
                  .read<FetchPromocodesCubit>()
                  .deletePromocodeFromCubit(state.id);

              UiUtils.showMessage(
                context,
                'promocodeDeleteSuccess'.translate(context: context),
                ToastificationType.success,
              );
            }
            if (state is DeletePromocodeFailure) {
              UiUtils.showMessage(
                  context,
                  state.errorMessage.translate(context: context),
                  ToastificationType.error);
            }
          },
          child: mainWidget(),
        ),
      ),
    );
  }
}
