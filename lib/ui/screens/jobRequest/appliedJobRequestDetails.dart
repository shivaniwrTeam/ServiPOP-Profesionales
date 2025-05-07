import 'package:edemand_partner/app/generalImports.dart';
import 'package:flutter/material.dart';

class AppliedJobRequestDetails extends StatefulWidget {
  const AppliedJobRequestDetails({super.key, required this.jobRequestModel});

  final JobRequestModel jobRequestModel;

  @override
  State<AppliedJobRequestDetails> createState() =>
      _AppliedJobRequestDetailsState();

  static Route<AppliedJobRequestDetails> route(RouteSettings routeSettings) {
    final Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (_) => AppliedJobRequestDetails(
        jobRequestModel: arguments['jobRequestModel'],
      ),
    );
  }
}

class _AppliedJobRequestDetailsState extends State<AppliedJobRequestDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryColor,
      appBar: UiUtils.getSimpleAppBar(
          context: context,
          elevation: 1,
          title: 'submittedBidDetailsLbl'.translate(context: context),
          statusBarColor: context.colorScheme.secondaryColor),
      body: mainWidget(),
    );
  }

  Widget bottomNavigation() {
    return CustomContainer(
      color: Theme.of(context).colorScheme.secondaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: CustomRoundedButton(
        textSize: 15,
        widthPercentage: 1,
        backgroundColor: Theme.of(context).colorScheme.shimmerBaseColor,
        buttonTitle: 'submitBidBtnLbl'.translate(context: context),
        titleColor:
            Theme.of(context).colorScheme.blackColor.withValues(alpha: 0.5),
        showBorder: false,
        onTap: () {},
      ),
    );
  }

  Widget mainWidget() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      physics: const AlwaysScrollableScrollPhysics(),
      clipBehavior: Clip.none,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          summaryWidget(),
          showDivider(),
          customerInfoWidget(),
          yourBidWidget(),
        ],
      ),
    );
  }

  Widget summaryWidget() {
    return CustomContainer(
      borderRadius: UiUtils.borderRadiusOf10,
      color: Theme.of(context).colorScheme.primaryColor,
      padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Removed the Expanded with fixed height CustomSizedBox
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                widget.jobRequestModel.serviceTitle!,
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Theme.of(context).colorScheme.blackColor,
              ),
              CustomReadMoreTextContainer(
                text: widget.jobRequestModel.serviceShortDescription!,
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.lightGreyColor,
                ),
              )
            ],
          ),
          const CustomSizedBox(
            height: 8,
          ),
          Row(
            children: [
              CustomText(
                "category".translate(context: context),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.blackColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomContainer(
                  color: Theme.of(context)
                      .colorScheme
                      .accentColor
                      .withValues(alpha: 0.1),
                  borderRadius: UiUtils.borderRadiusOf5,
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(UiUtils.borderRadiusOf5),
                        child: CustomCachedNetworkImage(
                          imageUrl: widget.jobRequestModel.categoryImage ?? "",
                          height: 18,
                          width: 18,
                          fit: BoxFit.fill,
                        ),
                      ),
                      const CustomSizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: CustomText(
                          widget.jobRequestModel.categoryName!,
                          fontSize: 14,
                          maxLines: 1,
                          color: Theme.of(context).colorScheme.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget showDivider() {
    return CustomContainer(
      color: context.colorScheme.primaryColor,
      height: 30,
      child: Divider(
        indent: 15,
        endIndent: 15,
        thickness: 0.5,
        color:
            Theme.of(context).colorScheme.lightGreyColor.withValues(alpha: 0.3),
      ),
    );
  }

  Widget customerInfoWidget() {
    return CustomContainer(
      borderRadius: 0,
      //padding: const EdgeInsets.only(top: 15),
      color: Theme.of(context).colorScheme.primaryColor,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CustomContainer(
                  height: 40,
                  width: 40,
                  shape: BoxShape.circle,
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(UiUtils.borderRadiusOf50),
                    child: CustomCachedNetworkImage(
                      imageUrl: widget.jobRequestModel.image!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const CustomSizedBox(
                  width: 8,
                ),
                Expanded(
                  child: getTitleAndSubDetails(
                    title: 'customer'.translate(context: context),
                    subDetails: widget.jobRequestModel.username!,
                  ),
                ),
                Expanded(
                  child: getTitleAndSubDetails(
                    title: 'budget'.translate(context: context),
                    subDetails:
                        "${(widget.jobRequestModel.minPrice!).replaceAll(',', '').priceFormat()} - ${(widget.jobRequestModel.maxPrice!).replaceAll(',', '').priceFormat()}",
                  ),
                ),
              ],
            ),
            const CustomSizedBox(
              height: 20,
            ),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: getDateAndTimeDetails(
                      title: 'postedAt',
                      subDetails:
                          "${widget.jobRequestModel.requestedStartDate!.formatDate()} - ${widget.jobRequestModel.requestedStartTime!.formatTime()}",
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: VerticalDivider(
                      indent: 6,
                      endIndent: 6,
                      color: Theme.of(context)
                          .colorScheme
                          .lightGreyColor
                          .withValues(alpha: 0.3),
                      thickness: 1,
                    ),
                  ),
                  Expanded(
                    child: getDateAndTimeDetails(
                      title: 'expiredOn',
                      subDetails:
                          "${widget.jobRequestModel.requestedEndDate!.formatDate()} - ${widget.jobRequestModel.requestedEndTime!.formatTime()}",
                    ),
                  ),
                ],
              ),
            ),
            const CustomSizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget yourBidWidget() {
    return CustomContainer(
      borderRadius: 0,
      padding: const EdgeInsets.only(top: 20),
      color: Theme.of(context).colorScheme.secondaryColor,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              'yourBid'.translate(context: context),
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.blackColor,
            ),
            const CustomSizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomText(
                    'counterPrice'.translate(context: context),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.lightGreyColor,
                    maxLines: 1,
                  ),
                ),
                CustomText(
                  widget.jobRequestModel.counterPrice!
                      .replaceAll(',', '')
                      .priceFormat(),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.blackColor,
                ),
              ],
            ),
            const CustomSizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomText(
                    'taxPercentage'.translate(context: context),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.lightGreyColor,
                    maxLines: 1,
                  ),
                ),
                CustomText(
                  widget.jobRequestModel.taxPercentage != null
                      ? "${widget.jobRequestModel.taxPercentage!}%"
                      : "%",
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.blackColor,
                ),
              ],
            ),
            const CustomSizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomText(
                    'taxAmount'.translate(context: context),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.lightGreyColor,
                    maxLines: 1,
                  ),
                ),
                CustomText(
                  widget.jobRequestModel.taxAmount != null &&
                          widget.jobRequestModel.taxAmount != ''
                      ? widget.jobRequestModel.taxAmount!.priceFormat()
                      : "",
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.blackColor,
                ),
              ],
            ),
            const CustomSizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomText(
                    'finalTotal'.translate(context: context),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.lightGreyColor,
                    maxLines: 1,
                  ),
                ),
                CustomText(
                  (widget.jobRequestModel.finalTotal ?? '0').priceFormat(),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.blackColor,
                ),
              ],
            ),
            const CustomSizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomText(
                    'durationLbl'.translate(context: context),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.lightGreyColor,
                    maxLines: 1,
                  ),
                ),
                Row(
                  children: [
                    CustomText(
                      widget.jobRequestModel.duration!,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.blackColor,
                    ),
                    const CustomSizedBox(
                      width: 3,
                    ),
                    CustomText(
                      'minutesLbl'.translate(context: context),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.blackColor,
                    ),
                  ],
                ),
              ],
            ),
            const CustomSizedBox(
              height: 8,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  "coverNote".translate(context: context),
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.blackColor,
                ),
                const CustomSizedBox(
                  height: 2,
                ),
                CustomText(
                  widget.jobRequestModel.note!,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.lightGreyColor,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget getTitleAndSubDetails({
    required String title,
    required String subDetails,
    Color? subTitleBackgroundColor,
    Color? subTitleColor,
    double? width,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          title.translate(context: context),
          fontSize: 12,
          maxLines: 1,
          fontWeight: FontWeight.w400,
          color: Theme.of(context).colorScheme.lightGreyColor,
        ),
        CustomContainer(
          width: width,
          color: subTitleBackgroundColor?.withValues(alpha: 0.2) ??
              Colors.transparent,
          borderRadius: UiUtils.borderRadiusOf5,
          child: CustomReadMoreTextContainer(
            text: subDetails,
            textStyle: TextStyle(
              fontSize: 14,
              color: subTitleColor ?? Theme.of(context).colorScheme.blackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget getDateAndTimeDetails({
    required String title,
    required String subDetails,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          title.translate(context: context),
          fontSize: 14,
          maxLines: 1,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.blackColor,
        ),
        CustomText(
          subDetails,
          fontSize: 12,
          maxLines: 2,
          color: Theme.of(context).colorScheme.lightGreyColor,
          fontWeight: FontWeight.w400,
        ),
      ],
    );
  }
}
