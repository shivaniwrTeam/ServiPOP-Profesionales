import 'package:edemand_partner/app/generalImports.dart';
import 'package:edemand_partner/ui/screens/services/enum/statusEnum.dart';
import 'package:flutter/material.dart';

class ServiceContainer extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;
  final bool listingUI;

  const ServiceContainer({
    Key? key,
    required this.service,
    this.onTap,
    required this.listingUI,
  }) : super(key: key);

  Widget setImage({required String imageURL}) {
    return CustomContainer(
      borderRadius: UiUtils.borderRadiusOf10,
      color: Colors.transparent,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
          child: CustomCachedNetworkImage(
            imageUrl: imageURL,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final StateStatus status = StateStatus.fromApi(service.status!);
    return GestureDetector(
      onTap: onTap,
      child: CustomContainer(
        border: listingUI
            ? Border.all(color: context.colorScheme.primaryColor)
            : null,
        padding: const EdgeInsets.all(15),
        color: context.colorScheme.secondaryColor,
        borderRadius: listingUI ? UiUtils.borderRadiusOf10 : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            !listingUI
                ? Expanded(
                    flex: 2,
                    child: CustomSizedBox(
                      height: 120,
                      child: setImage(
                        imageURL: service.imageOfTheService!,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            !listingUI
                ? const CustomSizedBox(
                    width: 10,
                  )
                : const SizedBox.shrink(),
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  listingUI
                      ? Row(
                          children: [
                            CustomSvgPicture(
                                svgImage: status.svgImage,
                                color: status.getStatusColor(context)),
                            const CustomSizedBox(
                              width: 5,
                            ),
                            CustomText(
                              status.label.translate(context: context),
                              fontSize: 14,
                              color: status.getTextColor(context),
                              fontWeight: FontWeight.w400,
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 5),
                  CustomText(
                    service.title!,
                    fontSize: 16,
                    color: context.colorScheme.blackColor,
                    fontWeight: FontWeight.w600,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 5),
                  if (service.rating != '0' && service.rating != '')
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          const CustomSvgPicture(
                            svgImage: AppAssets.star,
                            height: 16,
                            width: 16,
                            color: AppColors.starRatingColor,
                          ),
                          const SizedBox(width: 5),
                          CustomText(
                            service.rating!,
                            fontSize: 14,
                            color: context.colorScheme.blackColor,
                            fontWeight: FontWeight.w600,
                          ),
                          VerticalDivider(
                            color: context.colorScheme.lightGreyColor,
                            thickness: 0.2,
                          ),
                          CustomText(
                            '${service.numberOfRatings!} ${'reviewsTitleLbl'.translate(context: context)}',
                            fontSize: 14,
                            color: context.colorScheme.blackColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 5,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomSvgPicture(
                            svgImage: AppAssets.group,
                            height: 16,
                            width: 16,
                            color: context.colorScheme.accentColor,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: CustomText(
                              "${service.numberOfMembersRequired} ${'persons'.translate(context: context)}",
                              fontSize: 12,
                              color: context.colorScheme.blackColor,
                              fontWeight: FontWeight.w600,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),

                      // const SizedBox(width: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomSvgPicture(
                            svgImage: AppAssets.duration,
                            height: 16,
                            width: 16,
                            color: context.colorScheme.accentColor,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: CustomText(
                              "${service.duration} ${'minutesLbl'.translate(context: context)}",
                              fontSize: 12,
                              color: context.colorScheme.blackColor,
                              fontWeight: FontWeight.w600,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 5,
                      children: [
                        if (service.discountedPrice != '0') ...[
                          CustomText(
                            (service.discountedPrice ?? "0")
                                .replaceAll(',', '')
                                .toString()
                                .priceFormat(),
                            color: context.colorScheme.blackColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          CustomText(
                            (service.price ?? "0")
                                .replaceAll(',', '')
                                .toString()
                                .priceFormat(),
                            color: context.colorScheme.accentColor,
                            underlineOrLineColor:
                                context.colorScheme.accentColor,
                            showLineThrough: true,
                            fontSize: 12,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ] else ...[
                          CustomText(
                            (service.price ?? "0")
                                .replaceAll(',', '')
                                .toString()
                                .priceFormat(),
                            color: context.colorScheme.blackColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ]
                      ]),
                ],
              ),
            ),
            listingUI
                ? Expanded(
                    flex: 2,
                    child: CustomSizedBox(
                      height: 120,
                      child: setImage(
                        imageURL: service.imageOfTheService!,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
