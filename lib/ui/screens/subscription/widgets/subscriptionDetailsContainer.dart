import 'package:edemand_partner/app/generalImports.dart';
import 'package:flutter/material.dart';

class SubscriptionDetailsContainer extends StatelessWidget {
  final bool? showLoading;
  final bool isActiveSubscription;
  final bool isAvailableForPurchase;
  final bool isPreviousSubscription;
  final bool needToShowPaymentStatus;
  final SubscriptionInformation subscriptionDetails;
  final Function onBuyButtonPressed;

  const SubscriptionDetailsContainer({
    super.key,
    required this.subscriptionDetails,
    required this.onBuyButtonPressed,
    required this.isActiveSubscription,
    required this.isAvailableForPurchase,
    required this.isPreviousSubscription,
    this.showLoading,
    required this.needToShowPaymentStatus,
  });

  Widget getPaymentStatusContainer(
      {required String paymentStatus, required BuildContext context}) {
    return Row(
      children: [
        Icon(
          paymentStatus == "0"
              ? Icons.pending
              : paymentStatus == "1"
                  ? Icons.done
                  : Icons.close,
          size: 16,
          color: paymentStatus == "0"
              ? AppColors.starRatingColor
              : paymentStatus == "1"
                  ? AppColors.greenColor
                  : AppColors.redColor,
        ),
        const CustomSizedBox(
          width: 5,
        ),
        Text(
          paymentStatus == "0"
              ? "paymentPending".translate(context: context)
              : paymentStatus == "1"
                  ? "paymentSuccess".translate(context: context)
                  : "paymentFailed".translate(context: context),
          style: TextStyle(
            color: paymentStatus == "0"
                ? AppColors.starRatingColor
                : paymentStatus == "1"
                    ? AppColors.greenColor
                    : AppColors.redColor,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        ),
      ],
    );
  }

  Widget getTitle({required String title, required BuildContext context}) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.blackColor,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
    );
  }

  Widget setSubscriptionPlanDetailsPoint({
    required final String title,
    required final BuildContext context,
  }) {
    return Row(
      children: [
        Icon(
          Icons.check_circle_rounded,
          color: isAvailableForPurchase
              ? context.colorScheme.blackColor
              : AppColors.greenColor,
          // color: AppColors.greenColor,
        ),
        const CustomSizedBox(
          width: 5,
        ),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
                color: Theme.of(context).colorScheme.blackColor, fontSize: 12),
          ),
        )
      ],
    );
  }

  Widget buyButton({
    required final bool isLoading,
    required final String subscriptionId,
    required BuildContext context,
    required Function onBuyButtonPressed,
  }) {
    return CustomRoundedButton(
      widthPercentage: 0.3,
      width: double.infinity,
      height: 40,
      textSize: 14,
      radius: UiUtils.borderRadiusOf10,
      backgroundColor: Theme.of(context).colorScheme.blackColor,
      buttonTitle: "upgradeNow".translate(context: context),
      showBorder: false,
      titleColor: context.colorScheme.secondaryColor,
      onTap: () {
        onBuyButtonPressed.call();
      },
      child: isLoading
          ? CustomContainer(
              height: 30,
              child: FittedBox(
                child: CustomCircularProgressIndicator(
                  color: AppColors.whiteColors,
                  strokeWidth: 2,
                ),
              ),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(15),
      width: MediaQuery.sizeOf(context).width,
      border: isAvailableForPurchase
          ? Border.all(color: context.colorScheme.lightGreyColor)
          : Border.all(color: context.colorScheme.accentColor),
      color: Theme.of(context).colorScheme.secondaryColor,
      borderRadius: UiUtils.borderRadiusOf10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomContainer(
                borderRadius: UiUtils.borderRadiusOf6,
                color: isAvailableForPurchase
                    ? context.colorScheme.blackColor.withAlpha(20)
                    : context.colorScheme.accentColor.withAlpha(20),
                padding: const EdgeInsetsDirectional.all(8),
                child: CustomSvgPicture(
                  svgImage: AppAssets.crown,
                  color: isAvailableForPurchase
                      ? context.colorScheme.blackColor
                      : context.colorScheme.accentColor,
                ),
              ),
              const CustomSizedBox(
                width: 10,
              ),
              Expanded(
                  child: getTitle(
                      title: subscriptionDetails.name ?? "", context: context)),
              const CustomSizedBox(
                width: 10,
              ),
              Row(
                children: [
                  Text(
                    (subscriptionDetails.discountPrice ?? "0") != "0"
                        ? (subscriptionDetails.discountPriceWithTax ?? "0")
                            .priceFormat()
                        : (subscriptionDetails.priceWithTax ?? "0") == "0"
                            ? "free".translate(context: context)
                            : (subscriptionDetails.priceWithTax ?? "0")
                                .priceFormat(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.blackColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                  if ((subscriptionDetails.discountPrice ?? "0") != "0") ...[
                    const CustomSizedBox(width: 3),
                    CustomText(
                      (subscriptionDetails.priceWithTax ?? "0").priceFormat(),
                      color: isAvailableForPurchase
                          ? context.colorScheme.blackColor
                          : context.colorScheme.accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      underlineOrLineColor:
                          Theme.of(context).colorScheme.accentColor,
                      showLineThrough: true,
                      maxLines: 1,
                    ),
                  ],
                ],
              ),
            ],
          ),

          const CustomSizedBox(
            height: 15,
          ),
          if ((subscriptionDetails.taxPercenrage ?? "0") != "0")
            setSubscriptionPlanDetailsPoint(
              context: context,
              title:
                  "${subscriptionDetails.taxPercenrage ?? "0"}% ${"taxIncludedInPrice".translate(context: context)}",
            ),
          setSubscriptionPlanDetailsPoint(
            context: context,
            title: (subscriptionDetails.maxOrderLimit ?? "") != "" &&
                    (subscriptionDetails.maxOrderLimit ?? "") != "0"
                ? "${"enjoyGenerousOrderLimitOf".translate(context: context)} ${subscriptionDetails.maxOrderLimit ?? "0"} ${"ordersDuringYourSubscriptionPeriod".translate(context: context)}"
                : "enjoyUnlimitedOrders".translate(context: context),
          ),
          const CustomSizedBox(
            height: 5,
          ),
          setSubscriptionPlanDetailsPoint(
            context: context,
            title: (subscriptionDetails.duration ?? "") != "" &&
                    (subscriptionDetails.duration ?? "") != "unlimited"
                // ? "${"yourSubscriptionWillBeValidFor".translate(context: context)} ${subscriptionDetails.duration ?? ""} ${"days".translate(context: context)}"
                ? "${subscriptionDetails.duration ?? ""} ${"days".translate(context: context)} "
                : "enjoySubscriptionForUnlimitedDays"
                    .translate(context: context),
          ),

          const CustomSizedBox(
            height: 5,
          ),
          setSubscriptionPlanDetailsPoint(
            context: context,
            title: (subscriptionDetails.isCommision == "yes")
                ? "${subscriptionDetails.commissionPercentage ?? ""}% ${"commissionWillBeAppliedToYourEarnings".translate(context: context)}"
                : "noNeedToPayExtraCommission".translate(context: context),
          ),
          const CustomSizedBox(
            height: 5,
          ),
          setSubscriptionPlanDetailsPoint(
            context: context,
            title: subscriptionDetails.isCommision == "yes"
                ? "${"commissionThreshold".translate(context: context)} ${subscriptionDetails.commissionThreshold ?? "".priceFormat()} ${"AmountIsReached".translate(context: context)}"
                : "noThresholdOnPayOnDeliveryAmount"
                    .translate(context: context),
          ),
          //
          if (isAvailableForPurchase) ...[
            const CustomSizedBox(
              height: 5,
            ),
          ],
          if (isActiveSubscription || isPreviousSubscription) ...[
            CustomSizedBox(
              height: 10,
              child: Row(
                children: [
                  Expanded(
                    child: CustomContainer(
                      padding: const EdgeInsets.only(top: 10),
                      borderRadius: UiUtils.borderRadiusOf10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            "purchasedOn".translate(context: context),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: context.colorScheme.accentColor,
                          ),
                          Text(
                            (subscriptionDetails.purchaseDate ?? "")
                                .formatDate(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: TextStyle(
                              fontSize: 16,
                              color: context.colorScheme.blackColor,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const CustomSizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: CustomContainer(
                      padding: const EdgeInsets.only(top: 10),
                      borderRadius: UiUtils.borderRadiusOf10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            isPreviousSubscription
                                ? "expiredOn".translate(context: context)
                                : "validTill".translate(context: context),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: context.colorScheme.accentColor,
                          ),
                          Text(
                            (subscriptionDetails.duration ?? "") != "" &&
                                    (subscriptionDetails.duration ?? "") !=
                                        "unlimited"
                                ? (subscriptionDetails.expiryDate ?? "")
                                    .formatDate()
                                : "-",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: TextStyle(
                              fontSize: 16,
                              color: context.colorScheme.blackColor,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if ((subscriptionDetails.description ?? "") != "") ...[
            const CustomSizedBox(
              height: 5,
            ),
            CustomContainer(
              constraints: const BoxConstraints(minHeight: 65),
              child: CustomReadMoreTextContainer(
                text: subscriptionDetails.description ?? "",
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.lightGreyColor,
                  fontSize: 12,
                ),
                trimLines: 2,
              ),
            ),
            if (isAvailableForPurchase)
              Align(
                alignment: Alignment.center,
                child: buyButton(
                  subscriptionId: subscriptionDetails.id ?? "0",
                  isLoading: showLoading ?? false,
                  context: context,
                  onBuyButtonPressed: onBuyButtonPressed.call,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
