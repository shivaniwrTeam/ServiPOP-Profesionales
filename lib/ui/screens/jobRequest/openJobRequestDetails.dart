import 'package:edemand_partner/app/generalImports.dart';
import 'package:flutter/material.dart';

class OpenJobRequestDetails extends StatefulWidget {
  const OpenJobRequestDetails({super.key, required this.jobRequestModel});

  final JobRequestModel jobRequestModel;

  @override
  State<OpenJobRequestDetails> createState() => _OpenJobRequestDetailsState();

  static Route<OpenJobRequestDetails> route(RouteSettings routeSettings) {
    final Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (_) => OpenJobRequestDetails(
        jobRequestModel: arguments['jobRequestModel'],
      ),
    );
  }
}

class _OpenJobRequestDetailsState extends State<OpenJobRequestDetails> {
  late TextEditingController priceController = TextEditingController();
  late TextEditingController coverNoteController = TextEditingController();
  late TextEditingController minuteController = TextEditingController();
  FocusNode priceFocus = FocusNode();
  FocusNode coverNoteFocus = FocusNode();
  FocusNode minuteNoteFocus = FocusNode();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String selectedTaxTitle = '';
  String selectedTax = "";

  @override
  void dispose() {
    priceController.dispose();
    coverNoteController.dispose();
    minuteController.dispose();
    priceFocus.dispose();
    coverNoteFocus.dispose();
    minuteNoteFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    context.read<FetchTaxesCubit>().fetchTaxes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.watch<ApplyForCustomJobCubit>().state
          is! ApplyForCustomJobInProgress,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondaryColor,
        bottomNavigationBar: bottomNavigation(),
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondaryColor,
          surfaceTintColor: Theme.of(context).colorScheme.secondaryColor,
          elevation: 1,
          title: CustomText(
            'submitYourBidLbl'.translate(context: context),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.blackColor,
          ),
          leading: CustomBackArrow(
            canGoBack: context.watch<ApplyForCustomJobCubit>().state
                is! ApplyForCustomJobInProgress,
          ),
        ),
        body: mainWidget(),
      ),
    );
  }

  Widget bottomNavigation() {
    return BlocConsumer<ApplyForCustomJobCubit, ApplyForCustomJobCubitState>(
        listener: (context, state) {
      if (state is ApplyForCustomJobFailure) {
        UiUtils.showMessage(
          context,
          state.errorMessage.translate(context: context),
          ToastificationType.error,
        );
      }
      if (state is ApplyForCustomJobSuccess) {
        if (state.error == "true") {
          UiUtils.showMessage(
            context,
            state.message,
            ToastificationType.error,
          );
          return;
        }
        UiUtils.showMessage(
          context,
          'bidSubmittedsuccessfully'.translate(context: context),
          ToastificationType.success,
        );
        context
            .read<FetchJobRequestCubit>()
            .deleteOpenJobRequest(widget.jobRequestModel.id, 'open_jobs');

        Navigator.pop(context);
      }
    }, builder: (context, state) {
      /*if (state is ApplyForCustomJobInProgress) {
        return const Center(
          child: CustomCircularProgressIndicator(),
        );
      }*/
      final bool isLoading = state is ApplyForCustomJobInProgress;
      return CustomContainer(
        color: Theme.of(context).colorScheme.secondaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: CustomRoundedButton(
          textSize: 15,
          widthPercentage: 1,
          backgroundColor: Theme.of(context).colorScheme.accentColor,
          buttonTitle: 'submitBidBtnLbl'.translate(context: context),
          showBorder: false,
          child: isLoading
              ? Center(
                  child: CustomCircularProgressIndicator(
                  color: AppColors.whiteColors,
                ))
              : null,
          onTap: () {
            UiUtils.removeFocus();
            if (isLoading) return;
            final FormState? form = formKey.currentState; //default value
            if (form == null) return;
            //
            form.save();
            //
            if (!form.validate()) {
              return;
            }
            if (selectedTax == '') {
              UiUtils.showMessage(
                  context,
                  'pleaseSelectTax'.translate(context: context),
                  ToastificationType.warning);
              return;
            }
            context.read<ApplyForCustomJobCubit>().applyForCustomJob(
                widget.jobRequestModel.id,
                priceController.text,
                coverNoteController.text,
                minuteController.text,
                selectedTax.toString());
          },
        ),
      );
    });
  }

  Future selectTaxesBottomSheet() {
    return UiUtils.showModelBottomSheets(
      context: context,
      enableDrag: true,
      child: BlocBuilder<FetchTaxesCubit, FetchTaxesState>(
        builder: (BuildContext context, FetchTaxesState state) {
          if (state is FetchTaxesFailure) {
            return Center(
              child: ErrorContainer(
                showRetryButton: false,
                onTapRetry: () {},
                errorMessage: state.errorMessage,
              ),
            );
          }
          if (state is FetchTaxesSuccess) {
            if (state.taxes.isEmpty) {
              return NoDataContainer(
                titleKey: 'noDataFound'.translate(context: context),
              );
            }
            final List<Map<String, dynamic>> itemList = [];
            state.taxes.forEach((element) {
              itemList.add({
                "title": "${element.title!} (${element.percentage}%)",
                "id": element.id,
                "isSelected": selectedTax == element.id,
              });
            });

            return SelectableListBottomSheet(
                bottomSheetTitle: "chooseTaxes", itemList: itemList);
          }
          return Center(
            child: CustomCircularProgressIndicator(
              color: AppColors.whiteColors,
            ),
          );
        },
      ),
    ).then((value) {
      if (value != null) {
        selectedTax = value["selectedItemId"];
        selectedTaxTitle = value["selectedItemName"];
        setState(() {});
      }
    });
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
          applyBidWidget(),
        ],
      ),
    );
  }

  Widget summaryWidget() {
    return CustomContainer(
      color: Theme.of(context).colorScheme.primaryColor,
      padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  color: Theme.of(context)
                      .colorScheme
                      .blackColor
                      .withValues(alpha: 0.5),
                ),
              )
            ],
          ),
          const CustomSizedBox(
            height: 10,
          ),
          Row(
            children: [
              CustomText(
                "category".translate(context: context),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.blackColor,
              ),
              const CustomSizedBox(
                width: 8,
              ),
              Expanded(
                child: CustomContainer(
                  color: Theme.of(context)
                      .colorScheme
                      .accentColor
                      .withValues(alpha: 0.1),
                  borderRadius: UiUtils.borderRadiusOf5,
                  padding: const EdgeInsets.all(5),
                  child: Row(children: [
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
                    )
                  ]),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget showDivider() {
    return CustomContainer(
      height: 30,
      color: context.colorScheme.primaryColor,
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
      color: Theme.of(context).colorScheme.primaryColor,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Row(
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
                      imageUrl: widget.jobRequestModel.image ?? "",
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
                          "${(widget.jobRequestModel.minPrice!).replaceAll(',', '').priceFormat()} - ${(widget.jobRequestModel.maxPrice!).replaceAll(',', '').priceFormat()}"),
                ),
              ],
            ),
            const CustomSizedBox(
              height: 20,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Wrapping the first date and time details in Expanded
                Expanded(
                  child: getDateAndTimeDetails(
                    title: 'postedAt',
                    subDetails:
                        "${widget.jobRequestModel.requestedStartDate!.formatDate()} - ${widget.jobRequestModel.requestedStartTime!.formatTime()}",
                  ),
                ),
                // Adding some fixed width for the
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
                // Wrapping the second date and time details in Expanded
                Expanded(
                  child: getDateAndTimeDetails(
                    title: 'expiredOn',
                    subDetails:
                        "${widget.jobRequestModel.requestedEndDate!.formatDate()} - ${widget.jobRequestModel.requestedEndTime!.formatTime()}",
                  ),
                ),
              ],
            ),
            const CustomSizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget applyBidWidget() {
    return Form(
      key: formKey,
      child: CustomContainer(
        borderRadius: 0,
        padding: const EdgeInsets.only(top: 16),
        color: Theme.of(context).colorScheme.secondaryColor,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                'applyBid'.translate(context: context),
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.blackColor,
              ),
              const CustomSizedBox(
                height: 16,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child:
                        CustomText('counterPrice'.translate(context: context)),
                  ),
                  const CustomSizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: CustomTextFormField(
                      bottomPadding: 12,
                      isDense: false,
                      hintText: 'counterPrice'.translate(context: context),
                      labelText: 'counterPrice'.translate(context: context),
                      allowOnlySingleDecimalPoint: true,
                      controller: priceController,
                      currentFocusNode: priceFocus,
                      nextFocusNode: coverNoteFocus,
                      prefix: Padding(
                        padding: const EdgeInsetsDirectional.all(15.0),
                        child: CustomText(
                          UiUtils.systemCurrency ?? '',
                          fontSize: 14.0,
                          color: Theme.of(context).colorScheme.blackColor,
                        ),
                      ),
                      validator: (String? value) =>
                          Validator.nullCheck(context, value),
                      textInputType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              CustomTextFormField(
                bottomPadding: 12,
                controller: TextEditingController(text: selectedTaxTitle),
                suffixIcon: const Icon(
                  Icons.arrow_drop_down_outlined,
                ),
                hintText: 'selectTax'.translate(context: context),
                labelText: 'selectTax'.translate(context: context),
                isReadOnly: true,
                callback: () {
                  selectTaxesBottomSheet();
                },
              ),
              CustomTextFormField(
                expands: true,
                bottomPadding: 12,
                labelText: 'writeCoverNoteLbl'.translate(context: context),
                isDense: false,
                minLines: 3,
                controller: coverNoteController,
                currentFocusNode: coverNoteFocus,
                nextFocusNode: minuteNoteFocus,
                validator: (String? value) {
                  return Validator.nullCheck(context, value);
                },
                hintText: "writeCoverNoteLbl".translate(context: context),
                textInputType: TextInputType.multiline,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    'serviceTimeLbl'.translate(context: context),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.blackColor,
                  ),
                  const CustomSizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: CustomTextFormField(
                          bottomPadding: 10,
                          isDense: false,
                          labelText: 'enterTime'.translate(context: context),
                          hintText: 'enterTime'.translate(context: context),
                          allowOnlySingleDecimalPoint: true,
                          controller: minuteController,
                          currentFocusNode: minuteNoteFocus,
                          validator: (String? value) {
                            return Validator.nullCheck(context, value);
                          },
                          textInputType: TextInputType.number,
                        ),
                      ),
                      const CustomSizedBox(
                        width: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: CustomText(
                          'minutesLbl'.translate(context: context),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.blackColor,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
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
          child: CustomText(
            subDetails,
            fontSize: 14,
            color: subTitleColor ?? Theme.of(context).colorScheme.blackColor,
            fontWeight: FontWeight.w600,
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
