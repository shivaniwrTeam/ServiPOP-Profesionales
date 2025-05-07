import 'package:edemand_partner/ui/widgets/bottomSheets/layouts/additionalChargesBottomSheet.dart';
import 'package:edemand_partner/ui/widgets/dialog/layouts/verifyOTPDialog.dart';
import 'package:flutter/material.dart';
import '../../../app/generalImports.dart';
import '../../../utils/checkURLType.dart';

typedef PaymentGatewayDetails = ({String paymentType, String paymentImage});

class BookingDetails extends StatefulWidget {
  const BookingDetails({super.key, required this.bookingsModel});

  final BookingsModel bookingsModel;

  @override
  BookingDetailsState createState() => BookingDetailsState();

  static Route<BookingDetails> route(RouteSettings routeSettings) {
    final Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (_) => BlocProvider.value(
        value: arguments['cubit'] as UpdateBookingStatusCubit,
        child: BookingDetails(
          bookingsModel: arguments['bookingsModel'],
        ),
      ),
    );
  }
}

class BookingDetailsState extends State<BookingDetails> {
  ScrollController? scrollController = ScrollController();
  Map<String, String>? currentStatusOfBooking;
  Map<String, String>? temporarySelectedStatusOfBooking;
  int totalServiceQuantity = 0;

  DateTime? selectedRescheduleDate;
  String? selectedRescheduleTime;
  List<Map<String, String>> filters = [];
  List<Map<String, dynamic>>? selectedProofFiles;
  List<Map<String, dynamic>>? additionalCharged;
  ValueNotifier<bool> isBillDetailsCollapsed = ValueNotifier(true);
  String? otpFromProvider;
  @override
  void initState() {
    scrollController!.addListener(() => setState(() {}));
    _getTotalQuantity();
    Future.delayed(Duration.zero, () {
      filters = [
        {
          'value': '1',
          'title': 'awaiting'.translate(context: context),
        },
        {
          'value': '2',
          'title': 'confirmed'.translate(context: context),
        },
        {
          'value': '3',
          'title': 'started'.translate(context: context),
        },
        {'value': '4', 'title': 'rescheduled'.translate(context: context)},
        {
          'value': '5',
          'title': 'booking_ended'.translate(context: context),
        },
        {
          'value': '6',
          'title': 'completed'.translate(context: context),
        },
        {
          'value': '7',
          'title': 'cancelled'.translate(context: context),
        },
      ];
    });
    _getTranslatedInitialStatus();
    super.initState();
  }

  void _getTotalQuantity() {
    widget.bookingsModel.services?.forEach(
      (Services service) {
        totalServiceQuantity += int.parse(service.quantity!);
      },
    );
    setState(
      () {},
    );
  }

  void _getTranslatedInitialStatus() {
    Future.delayed(Duration.zero, () {
      final String? initialStatusValue = getStatusForApi
          .where((Map<String, String> e) =>
              e['title'] == widget.bookingsModel.status)
          .toList()[0]['value'];
      currentStatusOfBooking = filters.where((Map<String, String> element) {
        return element['value'] == initialStatusValue;
      }).toList()[0];

      setState(() {});
    });
  }

// Don't translate this because we need to send this title in api;
  List<Map<String, String>> getStatusForApi = [
    {'value': '1', 'title': 'awaiting'},
    {'value': '2', 'title': 'confirmed'},
    {'value': '3', 'title': 'started'},
    {'value': '4', 'title': 'rescheduled'},
    {'value': '5', 'title': 'booking_ended'},
    {'value': '6', 'title': 'completed'},
    {'value': '7', 'title': 'cancelled'},
  ];

  Future<void> _onDropDownClick(List<Map<String, String>> filters) async {
    //get current status of booking
    if (widget.bookingsModel.status != null &&
        temporarySelectedStatusOfBooking == null) {
      currentStatusOfBooking = getStatusForApi
          .where((Map<String, String> e) =>
              e['title'] == widget.bookingsModel.status)
          .toList()[0];
    } else {
      currentStatusOfBooking = temporarySelectedStatusOfBooking;
    }

    //show bottomSheet to select new status
    var selectedStatusOfBooking = await UiUtils.showModelBottomSheets(
      context: context,
      child: UpdateStatusBottomSheet(
        selectedItem: currentStatusOfBooking!,
        itemValues: [...filters],
      ),
    );

    if (selectedStatusOfBooking?['selectedStatus'] != null) {
      //
      //if selectedStatus is started then show uploadFiles bottomSheet
      if (selectedStatusOfBooking['selectedStatus']['title'] ==
          'started'.translate(context: context)) {
        UiUtils.showModelBottomSheets(
          context: context,
          child: UploadProofBottomSheet(preSelectedFiles: selectedProofFiles),
        ).then((value) {
          selectedProofFiles = value;
          setState(() {});
        });
      }
      //
      //if selectedStatus is booking_ended then show uploadFiles bottomSheet
      if (selectedStatusOfBooking['selectedStatus']['title'] ==
          'booking_ended'.translate(context: context)) {
        //
        await UiUtils.showModelBottomSheets(
          context: context,
          child: UploadProofBottomSheet(preSelectedFiles: selectedProofFiles),
        ).then((value) {
          selectedProofFiles = value;
          setState(() {});
        });

        await UiUtils.showModelBottomSheets(
          context: context,
          useSafeArea: true,
          child: AdditionalChargesBottomSheet(
            additionalCharges:
                additionalCharged, // pass any preselected charges if needed
          ),
        ).then((charges) {
          additionalCharged = charges;
          setState(() {}); // Update state after additional charges are set
        });
      } else {
        temporarySelectedStatusOfBooking =
            selectedStatusOfBooking['selectedStatus'];
        currentStatusOfBooking = selectedStatusOfBooking['selectedStatus'];
      }

      //if OTP validation is required then show OTP dialog
      if (currentStatusOfBooking?['title'] ==
              'completed'.translate(context: context) &&
          context
              .read<FetchSystemSettingsCubit>()
              .isOrderOTPVerificationEnable()) {
        UiUtils.showAnimatedDialog(
          context: context,
          child: VerifyOTPDialog(
            otp: widget.bookingsModel.otp ?? '0',
            confirmButtonPressed: () {
              temporarySelectedStatusOfBooking =
                  selectedStatusOfBooking['selectedStatus'];
              currentStatusOfBooking =
                  selectedStatusOfBooking['selectedStatus'];
              setState(() {});
            },
          ),
        ).then((value) {
          if (value != null) {
            otpFromProvider = value.toString();
          } else {
            otpFromProvider = '';
          }
        });
      } else if (currentStatusOfBooking?['title'] ==
              'completed'.translate(context: context) &&
          context
              .read<FetchSystemSettingsCubit>()
              .isOrderOTPVerificationEnable() &&
          widget.bookingsModel.paymentMethod == "cod") {
        UiUtils.showAnimatedDialog(
            context: context,
            child: CustomDialogLayout(
              title: "collectCashFromCustomer",
              confirmButtonName: "okay",
              cancelButtonName: "cancel",
              confirmButtonBackgroundColor:
                  Theme.of(context).colorScheme.accentColor,
              cancelButtonBackgroundColor:
                  Theme.of(context).colorScheme.secondaryColor,
              showProgressIndicator: false,
              cancelButtonPressed: () {
                Navigator.pop(context);
              },
              confirmButtonPressed: () {
                Navigator.pop(context);
                temporarySelectedStatusOfBooking =
                    selectedStatusOfBooking['selectedStatus'];
                currentStatusOfBooking =
                    selectedStatusOfBooking['selectedStatus'];
                setState(() {});
              },
            ));
      } else if (currentStatusOfBooking?['title'] ==
              'completed'.translate(context: context) &&
          context
                  .read<FetchSystemSettingsCubit>()
                  .isOrderOTPVerificationEnable() ==
              false &&
          widget.bookingsModel.paymentMethod == "cod") {
        UiUtils.showAnimatedDialog(
            context: context,
            child: CustomDialogLayout(
              title: "collectdCash",
              confirmButtonName: "okay",
              cancelButtonName: "cancel",
              confirmButtonBackgroundColor:
                  Theme.of(context).colorScheme.accentColor,
              cancelButtonBackgroundColor:
                  Theme.of(context).colorScheme.secondaryColor,
              showProgressIndicator: false,
              cancelButtonPressed: () {
                Navigator.pop(context);
              },
              confirmButtonPressed: () {
                Navigator.pop(context);
                temporarySelectedStatusOfBooking =
                    selectedStatusOfBooking['selectedStatus'];
                currentStatusOfBooking =
                    selectedStatusOfBooking['selectedStatus'];
                setState(() {});
              },
            ));
      } else {
        temporarySelectedStatusOfBooking =
            selectedStatusOfBooking['selectedStatus'];
        currentStatusOfBooking = selectedStatusOfBooking['selectedStatus'];
      }

      //
      //if selectedStatus is reschedule then show select new date and time bottomSheet
      if (selectedStatusOfBooking['selectedStatus']['title'] ==
          'rescheduled'.translate(context: context)) {
        final Map? result = await UiUtils.showModelBottomSheets(
            context: context,
            isScrollControlled: true,
            enableDrag: true,
            child: CustomContainer(
              height: MediaQuery.sizeOf(context).height * 0.7,
              borderRadiusStyle: const BorderRadius.only(
                topRight: Radius.circular(UiUtils.borderRadiusOf20),
                topLeft: Radius.circular(UiUtils.borderRadiusOf20),
              ),
              child: CalenderBottomSheet(
                  advanceBookingDays: widget.bookingsModel.advanceBookingDays!),
            ));

        selectedRescheduleDate = result?['selectedDate'];
        selectedRescheduleTime = result?['selectedTime'];

        if (selectedRescheduleDate == null || selectedRescheduleTime == null) {
          selectedStatusOfBooking = getStatusForApi[0];
          temporarySelectedStatusOfBooking = getStatusForApi[0];
          currentStatusOfBooking = getStatusForApi[0];
          setState(() {});
        }
      } else {
        //reset the values if choose different one
        selectedRescheduleDate = null;
        selectedRescheduleTime = null;
      }
    }
    setState(() {});
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.watch<UpdateBookingStatusCubit>().state
          is! UpdateBookingStatusInProgress,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        appBar: /* UiUtils.getSimpleAppBar(
            context: context,
            onTap: () {
              if (context.watch<UpdateBookingStatusCubit>().state
                  is! UpdateBookingStatusInProgress) {
                Navigator.pop(context);
              }
            },
            titleWidget: Column(
              children: [
                CustomText(
                  'bookingInformation'.translate(context: context),
                  color: context.colorScheme.blackColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                CustomText(
                  'customServiceRequest'.translate(context: context),
                  color: context.colorScheme.lightGreyColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                )
              ],
            )), */
            AppBar(
                surfaceTintColor: Theme.of(context).colorScheme.secondaryColor,
                backgroundColor: Theme.of(context).colorScheme.secondaryColor,
                elevation: 10,
                // centerTitle: true,
                leading: CustomBackArrow(
                  canGoBack: context.watch<UpdateBookingStatusCubit>().state
                      is! UpdateBookingStatusInProgress,
                ),
                title: Column(
                  children: [
                    CustomText(
                      'bookingInformation'.translate(context: context),
                      color: context.colorScheme.blackColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    if (widget.bookingsModel.customJobRequestId != null)
                      CustomText(
                        'customServiceRequest'.translate(context: context),
                        color: context.colorScheme.lightGreyColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      )
                  ],
                )),

        body: mainWidget(), //mainWidget(),

        bottomNavigationBar: bottomBarWidget(),
      ),
    );
  }

  Widget onMapsBtn() {
    return CustomInkWellContainer(
      onTap: () async {
        try {
          await launchUrl(
            Uri.parse(
              'https://www.google.com/maps/search/?api=1&query=${widget.bookingsModel.latitude},${widget.bookingsModel.longitude}',
            ),
            mode: LaunchMode.externalApplication,
          );
        } catch (e) {
          UiUtils.showMessage(
            context,
            'somethingWentWrong'.translate(context: context),
            ToastificationType.error,
          );
        }
      },
      child: CustomContainer(
        padding: const EdgeInsets.all(10),
        color: Theme.of(context).colorScheme.accentColor.withValues(alpha: 0.3),
        borderRadius: UiUtils.borderRadiusOf5,
        child: Text(
          'onMapsLbl'.translate(context: context),
          style: TextStyle(color: Theme.of(context).colorScheme.accentColor),
        ),
      ),
    );
  }

  Widget bottomBarWidget() {
    return BlocConsumer<UpdateBookingStatusCubit, UpdateBookingStatusState>(
      listener: (BuildContext context, UpdateBookingStatusState state) {
        // if (state is UpdateBookingStatusFailure) {
        //   UiUtils.showMessage(
        //       context,
        //       state.errorMessage.translate(context: context),
        //       ToastificationType.error);
        // }
        if (state is UpdateBookingStatusSuccess) {
          if (state.error == 'true') {
            //
            UiUtils.showMessage(
              context,
              state.message.translate(context: context),
              ToastificationType.error,
            );
            setState(() {
              selectedProofFiles = [];
              additionalCharged = [];
            });
            return;
          }
          //
          context.read<FetchBookingsCubit>().updateBookingDetailsLocally(
                bookingID: state.orderId.toString(),
                bookingStatus: state.status,
                listOfUploadedImages: state.imagesList,
                listOfAdditionalCharged: state.additionalCharges,
              );

          UiUtils.showMessage(
            context,
            'updatedSuccessfully'.translate(context: context),
            ToastificationType.success,
          );
        }
      },
      builder: (BuildContext context, UpdateBookingStatusState state) {
        Widget? child;
        if (state is UpdateBookingStatusInProgress) {
          child = CustomCircularProgressIndicator(
            color: AppColors.whiteColors,
          );
        }
        return CustomContainer(
          color: Theme.of(context).colorScheme.secondaryColor,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 15, vertical: 10),
            child: CustomSizedBox(
              width: MediaQuery.sizeOf(context).width / 2,
              height: (selectedRescheduleDate == null ||
                      selectedRescheduleTime == null)
                  ? 50
                  : 120,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedRescheduleDate != null &&
                      selectedRescheduleTime != null) ...[
                    CustomSizedBox(
                      height: 70,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  'selectedDate'.translate(context: context),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(selectedRescheduleDate
                                    .toString()
                                    .split(' ')[0])
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  'selectedTime'.translate(context: context),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(selectedRescheduleTime ?? '')
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 8,
                          child: CustomFormDropdown(
                            initialTitle: currentStatusOfBooking?['title']
                                    .toString()
                                    .capitalize() ??
                                widget.bookingsModel.status
                                    .toString()
                                    .capitalize(),
                            selectedValue: currentStatusOfBooking?['title'],
                            onTap: () {
                              _onDropDownClick(filters);
                            },
                          ),
                        ),
                        const CustomSizedBox(
                          width: 8,
                        ),
                        Expanded(
                          flex: 3,
                          child: CustomRoundedButton(
                            showBorder: false,
                            buttonTitle: 'update'.translate(context: context),
                            backgroundColor:
                                Theme.of(context).colorScheme.accentColor,
                            widthPercentage: 1,
                            height: 50,
                            textSize: 14,
                            child: child,
                            onTap: () {
                              if (state is UpdateBookingStatusInProgress) {
                                return;
                              }
                              Map<String, String>? bookingStatus;
                              //
                              final List<Map<String, String>>
                                  selectedBookingStatus = getStatusForApi.where(
                                (Map<String, String> element) {
                                  return element['value'] ==
                                      currentStatusOfBooking?['value'];
                                },
                              ).toList();

                              if (selectedBookingStatus.isNotEmpty) {
                                bookingStatus = selectedBookingStatus[0];
                              }
                              if (currentStatusOfBooking?['title'] ==
                                      'completed'.translate(context: context) &&
                                  context
                                      .read<FetchSystemSettingsCubit>()
                                      .isOrderOTPVerificationEnable()) {
                                if (otpFromProvider == null ||
                                    otpFromProvider!.trim().isEmpty) {
                                  UiUtils.showMessage(
                                      context,
                                      'pleaseEnterOTP'
                                          .translate(context: context),
                                      ToastificationType.error);
                                  return;
                                } else if (otpFromProvider!.trim() !=
                                        widget.bookingsModel.otp ||
                                    otpFromProvider!.trim() == '0') {
                                  UiUtils.showMessage(
                                      context,
                                      'invalidOTP'.translate(context: context),
                                      ToastificationType.error);
                                  return;
                                }
                              }

                              context
                                  .read<UpdateBookingStatusCubit>()
                                  .updateBookingStatus(
                                      orderId:
                                          int.parse(widget.bookingsModel.id!),
                                      customerId: int.parse(
                                          widget.bookingsModel.customerId!),
                                      status: bookingStatus?['title'] ??
                                          widget.bookingsModel.status!,
                                      //OTP validation applied locally, so status is completed then OTP verified already, so directly passing the OTP
                                      otp: otpFromProvider ??
                                          '' /* widget.bookingsModel.otp ?? '' */,
                                      date: selectedRescheduleDate
                                          .toString()
                                          .split(' ')[0],
                                      time: selectedRescheduleTime,
                                      proofData: selectedProofFiles,
                                      additionalCharges: additionalCharged);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget mainWidget() {
    return SingleChildScrollView(
      clipBehavior: Clip.none,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customerInfoWidget(),
          const CustomSizedBox(
            height: 10,
          ),
          statusAndInvoiceContainer(),
          const CustomSizedBox(
            height: 10,
          ),
          bookingDateAndTimeWidget(),
          Visibility(
            visible: widget.bookingsModel.workStartedProof!.isNotEmpty,
            child: uploadedProofWidget(
              title: 'workStartedProof',
              proofData: widget.bookingsModel.workStartedProof!,
            ),
          ),
          Visibility(
            visible: widget.bookingsModel.workCompletedProof!.isNotEmpty,
            child: uploadedProofWidget(
              title: 'workCompletedProof',
              proofData: widget.bookingsModel.workCompletedProof!,
            ),
          ),
          notesWidget(),

          serviceDetailsWidget(),
          _buildPriceSectionWidget()
        ],
      ),
    );
  }

  PaymentGatewayDetails _getPaymentGatewayDetails(
      {required String paymentMethod}) {
    switch (paymentMethod) {
      case "cod":
        return (paymentType: "cod", paymentImage: AppAssets.cod);
      case "stripe":
        return (paymentType: "stripe", paymentImage: AppAssets.icStripe);
      case "razorpay":
        return (paymentType: "razorpay", paymentImage: AppAssets.icRazorpay);
      case "paystack":
        return (paymentType: "paystack", paymentImage: AppAssets.icPaystack);
      case "paypal":
        return (paymentType: "paypal", paymentImage: AppAssets.icPaypal);
      case "flutterwave":
        return (
          paymentType: "flutterwave",
          paymentImage: AppAssets.icFlutterwave
        );
      default:
        return (paymentType: "cod", paymentImage: AppAssets.cod);
    }
  }

  Widget _buildPaymentModeWidget(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            CustomContainer(
              height: 44,
              width: 44,
              borderRadius: UiUtils.borderRadiusOf5,
              child: CustomSvgPicture(
                svgImage: _getPaymentGatewayDetails(
                        paymentMethod: widget.bookingsModel.paymentMethod ?? '')
                    .paymentImage,
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomText(
                    "paymentMode".translate(context: context),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: context.colorScheme.blackColor,
                  ),
                  const CustomSizedBox(
                    height: 4,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: CustomText(
                          _getPaymentGatewayDetails(
                                  paymentMethod:
                                      widget.bookingsModel.paymentMethod ?? '')
                              .paymentType
                              .translate(context: context),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: context.colorScheme.accentColor,
                        ),
                      ),
                      CustomText(
                        (widget.bookingsModel.status!.toLowerCase().isEmpty
                                    ? "pending"
                                    : widget.bookingsModel.status
                                        ?.toLowerCase())
                                ?.translate(context: context) ??
                            "",
                        color: UiUtils.getPaymentStatusColor(
                            paymentStatus: widget.bookingsModel.status ?? ""),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceSectionWidget(
    
      ) {
    return CustomContainer(
      color: context.colorScheme.secondaryColor,
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          CustomInkWellContainer(
            onTap: () {
              isBillDetailsCollapsed.value = !isBillDetailsCollapsed.value;
            },
            child: Row(
              children: [
                Expanded(
                  child: CustomText(
                    "billDetails".translate(context: context),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: context.colorScheme.lightGreyColor,
                  ),
                ),
                ValueListenableBuilder(
                    valueListenable: isBillDetailsCollapsed,
                    builder: (context, bool isCollapsed, _) {
                      return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: isCollapsed
                              ? Icon(Icons.arrow_drop_down_sharp,
                                  color: context.colorScheme.accentColor,
                                  size: 24)
                              : Icon(Icons.arrow_drop_up_sharp,
                                  color: context.colorScheme.accentColor,
                                  size: 24));
                    })
              ],
            ),
          ),
          ValueListenableBuilder(
              valueListenable: isBillDetailsCollapsed,
              builder: (context, bool isCollapsed, _) {
                return AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: CustomContainer(
                    constraints: isCollapsed
                        ? const BoxConstraints(maxHeight: 0.0)
                        : const BoxConstraints(
                            maxHeight: double.infinity,
                            maxWidth: double.maxFinite,
                          ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const CustomSizedBox(height: 10),
                        setServiceRowValues(
                          title: 'totalServiceChargesLbl'
                              .translate(context: context),
                          quantity: "" /*totalServiceQuantity.toString()*/,
                          price: (double.parse(widget.bookingsModel.total!
                                      .toString()
                                      .replaceAll(",", "")) -
                                  double.parse(
                                    widget.bookingsModel.taxAmount!
                                        .toString()
                                        .replaceAll(",", ""),
                                  ))
                              .toString(),
                        ),
                        const CustomSizedBox(height: 5),
                        if (widget.bookingsModel.totalAdditionalCharges != null)
                          setServiceRowValues(
                            title: 'totalAdditionServiceChargesLbl'
                                .translate(context: context),
                            quantity: "" /*totalServiceQuantity.toString()*/,
                            price: double.parse(widget
                                    .bookingsModel.totalAdditionalCharges!
                                    .toString()
                                    .replaceAll(",", ""))
                                .toString(),
                          ),
                        if (widget.bookingsModel.promoDiscount != '0') ...[
                          const CustomSizedBox(height: 5),
                          setServiceRowValues(
                            title: 'couponDiscLbl'.translate(context: context),
                            pricePrefix: "-",
                            quantity: "",
                            /*widget.bookingsModel.promoCode == '' ? '--' : widget.bookingsModel.promoCode!,*/
                            price: widget.bookingsModel.promoDiscount!,
                          ),
                        ],
                        if (widget.bookingsModel.taxAmount != '' &&
                            widget.bookingsModel.taxAmount != null &&
                            widget.bookingsModel.taxAmount != "0" &&
                            widget.bookingsModel.taxAmount != "0.00")
                          setServiceRowValues(
                              title: "taxLbl".translate(context: context),
                              price: widget.bookingsModel.taxAmount.toString(),
                              quantity: "",
                              pricePrefix: "+"),
                        const CustomSizedBox(height: 5),
                        if (widget.bookingsModel.visitingCharges != "0")
                          setServiceRowValues(
                              title:
                                  'visitingCharge'.translate(context: context),
                              quantity: '',
                              price: widget.bookingsModel.visitingCharges!,
                              pricePrefix: "+"),
                        const CustomSizedBox(height: 5),
                        const CustomDivider(),
                        setServiceRowValues(
                          title: 'totalAmtLbl'.translate(context: context),
                          quantity: '',
                          isTitleBold: true,
                          priceFontWeight: FontWeight.bold,
                          price: widget.bookingsModel.finalTotal!,
                        ),
                      ],
                    ),
                  ),
                );
              }),
          const SizedBox(
            height: 10,
          ),
          _getPriceSectionTile(
            context: context,
            fontSize: 20,
            heading: (widget.bookingsModel.paymentMethod == "cod"
                    ? "totalAmount".translate(context: context)
                    : 'paidAmount'.translate(context: context))
                .translate(context: context),
            subHeading: widget.bookingsModel.finalTotal!.priceFormat(),
            textColor: context.colorScheme.blackColor,
            fontWeight: FontWeight.w700,
            subHeadingTextColor: context.colorScheme.accentColor,
          ),
          const SizedBox(
            height: 10,
          ),
          Divider(
            color: context.colorScheme.lightGreyColor,
            thickness: 0.5,
            height: 0.5,
          ),
          const SizedBox(
            height: 10,
          ),
          _buildPaymentModeWidget(context),
        ],
      ),
    );
  }

  Widget _getPriceSectionTile({
    required final BuildContext context,
    required final String heading,
    required final String subHeading,
    required final Color textColor,
    final Color? subHeadingTextColor,
    required final double fontSize,
    final FontWeight? fontWeight,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(
              child: CustomText(heading,
                  color: textColor,
                  maxLines: 1,
                  fontWeight: fontWeight,
                  fontSize: fontSize),
            ),
            CustomText(subHeading,
                color: subHeadingTextColor ?? textColor,
                fontWeight: fontWeight,
                maxLines: 1,
                fontSize: fontSize),
          ],
        ),
      );

  Widget getTitleAndSubDetails({
    required String title,
    required String subDetails,
    Color? subTitleBackgroundColor,
    Color? subTitleColor,
    double? width,
    Function()? onTap,
  }) {
    return CustomInkWellContainer(
      onTap: () {
        onTap?.call();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (title != '') ...[
            CustomText(
              title.translate(context: context),
              fontSize: 14,
              maxLines: 2,
              color: Theme.of(context).colorScheme.lightGreyColor,
            ),
            const CustomSizedBox(
              height: 5,
            ),
          ],
          CustomContainer(
            width: width,
            color: subTitleBackgroundColor?.withValues(alpha: 0.2) ??
                Colors.transparent,
            borderRadius: UiUtils.borderRadiusOf5,
            child: CustomText(
              subDetails,
              fontSize: 14,
              maxLines: 2,
              color: subTitleColor ?? Theme.of(context).colorScheme.blackColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget getTitleAndSubDetailsWithBackgroundColor({
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
          fontSize: 14,
          maxLines: 2,
          color: Theme.of(context).colorScheme.lightGreyColor,
        ),
        const CustomSizedBox(
          height: 5,
        ),
        CustomContainer(
          width: width,
          color: subTitleBackgroundColor?.withValues(alpha: 0.2) ??
              Colors.transparent,
          borderRadius: UiUtils.borderRadiusOf5,
          padding: const EdgeInsets.all(5),
          child: CustomText(
            subDetails,
            fontSize: 14,
            maxLines: 2,
            color: subTitleColor ?? Theme.of(context).colorScheme.blackColor,
          ),
        ),
      ],
    );
  }

  Widget showDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Theme.of(context).colorScheme.lightGreyColor,
    );
  }

  Widget getTitle({
    required String title,
    String? subTitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          title.translate(context: context),
          maxLines: 1,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Theme.of(context).colorScheme.blackColor,
        ),
        if (subTitle != null) ...[
          const CustomSizedBox(
            height: 5,
          ),
          CustomText(
            subTitle.translate(context: context),
            maxLines: 1,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Theme.of(context).colorScheme.lightGreyColor,
          )
        ]
      ],
    );
  }

  Widget customerInfoWidget() {
    final bool phoneAndChatStatusActive =
        widget.bookingsModel.status.toString() == "cancelled" ||
                widget.bookingsModel.status.toString() == "completed"
            ? false
            : true;
    return CustomContainer(
      borderRadius: 0,
      color: Theme.of(context).colorScheme.secondaryColor,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: CustomText('customer'.translate(context: context),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.lightGreyColor),
          ),
          const CustomSizedBox(
            height: 5,
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CustomContainer(
                          height: 50,
                          width: 50,
                          shape: BoxShape.circle,
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(UiUtils.borderRadiusOf50),
                            child: CustomCachedNetworkImage(
                              imageUrl: widget.bookingsModel.profileImage!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const CustomSizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                widget.bookingsModel.customer ?? '',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.blackColor,
                              ),
                              _buildTitleAndValueRowWidget(
                                // title: "",
                                value: CustomText(
                                  widget.bookingsModel.customerNo ?? '',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: context.colorScheme.lightGreyColor,
                                ),
                                onTap: () {
                                  try {
                                    launchUrl(Uri.parse(
                                        "tel:${widget.bookingsModel.customerNo}"));
                                  } catch (e) {
                                    UiUtils.showMessage(
                                        context,
                                        "somethingWentWrong"
                                            .translate(context: context),
                                        ToastificationType.error);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const CustomSizedBox(
                          width: 15,
                        ),
                        CustomInkWellContainer(
                          borderRadius: BorderRadius.circular(5),
                          onTap: () {
                            if (!phoneAndChatStatusActive) {
                              return;
                            } else {
                              Navigator.pushNamed(context, Routes.chatMessages,
                                  arguments: {
                                    "chatUser": ChatUser(
                                      id: widget.bookingsModel.customerId ??
                                          "-",
                                      bookingId:
                                          widget.bookingsModel.id.toString(),
                                      bookingStatus: widget.bookingsModel.status
                                          .toString(),
                                      name: widget.bookingsModel.customer
                                          .toString(),
                                      receiverType: "2",
                                      unReadChats: 0,
                                      profile:
                                          widget.bookingsModel.profileImage,
                                      senderId: context
                                              .read<ProviderDetailsCubit>()
                                              .providerDetails
                                              .user
                                              ?.id ??
                                          "0",
                                    ),
                                  });
                            }
                          },
                          child: CustomContainer(
                              height: 40,
                              width: 40,
                              borderRadius: UiUtils.borderRadiusOf5,
                              padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: 10, vertical: 10),
                              color: !phoneAndChatStatusActive
                                  ? Theme.of(context)
                                      .colorScheme
                                      .lightGreyColor
                                      .withValues(alpha: 0.1)
                                  : Theme.of(context)
                                      .colorScheme
                                      .accentColor
                                      .withValues(alpha: 0.1),
                              child: CustomSvgPicture(
                                svgImage: AppAssets.drChat,
                                color: !phoneAndChatStatusActive
                                    ? Theme.of(context)
                                        .colorScheme
                                        .lightGreyColor
                                    : Theme.of(context).colorScheme.accentColor,
                              )),
                        ),
                       ],
                    ),
                    const CustomSizedBox(height: 16),
                    _buildTitleAndValueRowWidget(
                      // title: "email",
                      value: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CustomSvgPicture(
                                svgImage: AppAssets.letter,
                                color: context.colorScheme.accentColor,
                                height: 24,
                                width: 24,
                              ),
                              const CustomSizedBox(
                                width: 5,
                              ),
                              CustomText(
                                widget.bookingsModel.customerEmail ?? '',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ],
                          ),
                          CustomSvgPicture(
                            svgImage: AppAssets.arrowNext,
                            color: context.colorScheme.accentColor,
                          )
                        ],
                      ),

                      onTap: () {
                        try {
                          launchUrl(Uri.parse(
                              "mailto:${widget.bookingsModel.customerEmail}"));
                        } catch (e) {
                          UiUtils.showMessage(
                              context,
                              "somethingWentWrong".translate(context: context),
                              ToastificationType.error);
                        }
                      },
                    ),
               
                  ],
                ),
              ),
              const CustomSizedBox(
                height: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndValueRowWidget({
    // required String title,
    required Widget value,
    VoidCallback? onTap,
  }) {
    return CustomInkWellContainer(
      onTap: onTap,
      child: Row(
        children: [
          
          Expanded(child: value),
        ],
      ),
    );
  }

  Widget statusAndInvoiceContainer() {
    return CustomContainer(
      border: Border(
          bottom:
              BorderSide(color: context.colorScheme.accentColor, width: 0.5),
          top: BorderSide(
            color: context.colorScheme.accentColor,
            width: 0.5,
          )),
      color: context.colorScheme.secondaryColor,
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CustomText('statusLbl'.translate(context: context)),
              const CustomSizedBox(
                width: 5,
              ),
              CustomText(
                widget.bookingsModel.status
                    .toString()
                    .translate(context: context)
                    .capitalize(),
                color: UiUtils.getStatusColor(
                    context: context,
                    statusVal: widget.bookingsModel.status.toString()),
              )
            ],
          ),
          Row(
            children: [
              CustomText('invoiceNumber'.translate(context: context)),
              const CustomSizedBox(
                width: 5,
              ),
              CustomText(
                widget.bookingsModel.invoiceNo ?? '',
                color: context.colorScheme.accentColor,
              )
            ],
          )
        ],
      ),
    );
  }

  Future<void> _handleNumberTap(
      BuildContext context, String phoneNumber) async {
    //bookingDetails.addressId =="0" means booking booked as At store option
    final Uri url = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw "Could not launch $url";
    }
  }

  Widget bookingDateAndTimeWidget() {
    return CustomContainer(
      color: context.colorScheme.secondaryColor,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                'bookingAt'.translate(context: context),
                color: context.colorScheme.lightGreyColor,
              ),
              CustomText(
                widget.bookingsModel.addressId == "0"
                    ? 'atStore'.translate(context: context)
                    : "atDoorstep".translate(context: context),
                color: context.colorScheme.accentColor,
                fontWeight: FontWeight.w700,
              )
            ],
          ),
          const CustomSizedBox(
            height: 5,
          ),
          if (widget.bookingsModel.addressId != "0")
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomSvgPicture(
                  svgImage: AppAssets.mapPic,
                  color: context.colorScheme.accentColor,
                  height: 16,
                  width: 16,
                ),
                const CustomSizedBox(
                  width: 5,
                ),
                Expanded(
                    child: CustomText(
                  widget.bookingsModel.address ?? '',
                ))
              ],
            ),
          const CustomSizedBox(
            height: 8,
          ),
          if (widget.bookingsModel.addressId != "0") ...[
            CustomInkWellContainer(
              showSplashEffect: false,
              onTap: () => _handleNumberTap(
                  context, widget.bookingsModel.customerNo.toString()),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSvgPicture(
                    svgImage: AppAssets.call,
                    color: context.colorScheme.accentColor,
                    height: 16,
                    width: 16,
                  ),
                  const CustomSizedBox(
                    width: 5,
                  ),
                  Expanded(
                      child: CustomText(
                    widget.bookingsModel.customerNo ?? '',
                  ))
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
          DateAndTime(bookingModel: widget.bookingsModel),
        ],
      ),
    );
  }

  Widget uploadedProofWidget(
      {required String title, required List<dynamic> proofData}) {
    return Column(
      children: [
        const CustomSizedBox(
          height: 10,
        ),
        CustomContainer(
          color: Theme.of(context).colorScheme.secondaryColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getTitle(title: title.translate(context: context)),
                    const CustomSizedBox(
                      height: 10,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(proofData.length, (int index) {
                          return CustomContainer(
                            height: 50,
                            width: 50,
                            margin: const EdgeInsetsDirectional.only(end: 10),
                            border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .lightGreyColor),
                            child: CustomInkWellContainer(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.imagePreviewScreen,
                                  arguments: {
                                    'startFrom': index,
                                    'isReviewType': false,
                                    'dataURL': proofData
                                  },
                                ).then(
                                  (Object? value) {
                                    //locked in portrait mode only
                                    SystemChrome.setPreferredOrientations(
                                      [
                                        DeviceOrientation.portraitUp,
                                        DeviceOrientation.portraitDown
                                      ],
                                    );
                                  },
                                );
                              },
                              child: UrlTypeHelper.getType(proofData[index]) ==
                                      UrlType.image
                                  ? CustomCachedNetworkImage(
                                      imageUrl: proofData[index],
                                      height: 50,
                                      width: 50,
                                    )
                                  : UrlTypeHelper.getType(proofData[index]) ==
                                          UrlType.video
                                      ? Center(
                                          child: Icon(
                                            Icons.play_arrow,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .accentColor,
                                          ),
                                        )
                                      : const CustomContainer(),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              showDivider(),
            ],
          ),
        ),
      ],
    );
  }

 
  Widget serviceDetailsWidget() {
    return Column(
      children: [
        CustomContainer(
          color: Theme.of(context).colorScheme.secondaryColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getTitle(title: 'serviceDetailsLbl'),
                    const CustomSizedBox(
                      height: 10,
                    ),
                    for (Services service
                        in widget.bookingsModel.services!) ...[
                      setServiceRowValues(
                        title: service.serviceTitle!,
                        quantity: service.quantity!,
                        price: service.discountPrice != "0"
                            ? service.discountPrice!
                            : service.price!,
                      ),
                      const CustomSizedBox(
                        height: 5,
                      ),
                      if (widget.bookingsModel.additionalCharges!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              getTitle(
                                  title: 'additionalServiceChargesDetailsLbl'),
                              const CustomSizedBox(
                                height: 10,
                              ),
                              for (int i = 0;
                                  i <
                                      widget.bookingsModel.additionalCharges!
                                          .length;
                                  i++) ...[
                                setServiceRowValues(
                                  title: widget.bookingsModel
                                      .additionalCharges![i]["name"],
                                  quantity: "",
                                  price: widget.bookingsModel
                                      .additionalCharges![i]["charge"],
                                ),
                                
                              ],
                             ],
                          ),
                        ),
                    ],
                   ],
                ),
              ),
              showDivider()
            ],
          ),
        ),
      ],
    );
  }

  Widget setServiceRowValues({
    required String title,
    required String quantity,
    required String price,
    String? pricePrefix,
    bool? isTitleBold,
    FontWeight? priceFontWeight,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: CustomText(
            title,
            fontSize: 14,
            fontWeight: (isTitleBold ?? false)
                ? FontWeight.bold
                : ((title != 'serviceDetailsLbl'.translate(context: context))
                    ? FontWeight.w400
                    : FontWeight.w700),
            color: Theme.of(context).colorScheme.blackColor,
            maxLines: 1,
          ),
        ),
        if (quantity != '')
          Flexible(
            child: CustomText(
              (title == 'totalPriceLbl'.translate(context: context) ||
                      title ==
                          'totalServicePriceLbl'.translate(context: context))
                  ? "${"totalQtyLbl".translate(context: context)} $quantity"
                  : (title == 'gstLbl'.translate(context: context) ||
                          title == 'taxLbl'.translate(context: context))
                      ? quantity.formatPercentage()
                      : (title == 'couponDiscLbl'.translate(context: context))
                          ? "${quantity.formatPercentage()} ${"offLbl".translate(context: context)}"
                          : "${"qtyLbl".translate(context: context)} $quantity",
              fontSize: 14,
              textAlign: TextAlign.end,
              color: Theme.of(context).colorScheme.lightGreyColor,
            ),
          )
        else
          const CustomSizedBox(),
        if (price != '')
          CustomText(
            pricePrefix != null
                ? "$pricePrefix ${price.replaceAll(',', '').priceFormat()}"
                : price.replaceAll(',', '').priceFormat(),
            textAlign: TextAlign.end,
            fontSize: (title == 'totalPriceLbl'.translate(context: context))
                ? 14
                : 14,
            fontWeight: priceFontWeight ?? FontWeight.w500,
            color: Theme.of(context).colorScheme.blackColor,
          )
        else
          const CustomSizedBox()
      ],
    );
  }

  Widget notesWidget() {
    if (widget.bookingsModel.remarks == '') {
      return const CustomSizedBox(
        height: 10,
      );
    }
    return Column(
      children: [
        CustomContainer(
          // borderRadius: UiUtils.borderRadiusOf10,
          color: Theme.of(context).colorScheme.secondaryColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomSvgPicture(
                      svgImage: AppAssets.note,
                      color: context.colorScheme.accentColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: getTitle(title: 'notesLbl'),
                    ),
                  ],
                ),
                CustomText(
                  widget.bookingsModel.remarks ?? '',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.lightGreyColor,
                ),
                const CustomSizedBox(
                  height: 10,
                )
              ],
            ),
          ),
        ),
        const CustomSizedBox(
          height: 10,
        ),
      ],
    );
  }

 }
