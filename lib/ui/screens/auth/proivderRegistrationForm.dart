import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:intl/intl.dart';

import '../../../app/generalImports.dart';
import '../../../utils/location.dart';
import 'map.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key, required this.isEditing});

  final bool isEditing;

  @override
  RegistrationFormState createState() => RegistrationFormState();

  static Route<RegistrationForm> route(RouteSettings routeSettings) {
    final Map<String, dynamic> parameters =
        routeSettings.arguments as Map<String, dynamic>;

    return CupertinoPageRoute(
      builder: (_) => BlocProvider(
        create: (BuildContext context) => EditProviderDetailsCubit(),
        child: RegistrationForm(
          isEditing: parameters['isEditing'],
        ),
      ),
    );
  }
}

class RegistrationFormState extends State<RegistrationForm> {

  int currentIndex = 1;

  final GlobalKey<FormState> formKey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey2 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey4 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey5 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey6 = GlobalKey<FormState>();

  ScrollController scrollController = ScrollController();
  HtmlEditorController htmlController = HtmlEditorController();

  ///form1
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  FocusNode userNmFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode mobNoFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();

  Map<String, dynamic> pickedLocalImages = {
    'nationalIdImage': '',
    'addressIdImage': '',
    'passportIdImage': '',
    'logoImage': '',
    'bannerImage': ''
  };

  ///form2
  TextEditingController cityController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController companyNameController = TextEditingController();
  TextEditingController aboutCompanyController = TextEditingController();
  TextEditingController visitingChargesController = TextEditingController();
  TextEditingController advanceBookingDaysController = TextEditingController();
  TextEditingController numberOfMemberController = TextEditingController();

  FocusNode aboutCompanyFocus = FocusNode();
  FocusNode cityFocus = FocusNode();
  FocusNode addressFocus = FocusNode();
  FocusNode latitudeFocus = FocusNode();
  FocusNode longitudeFocus = FocusNode();
  FocusNode companyNmFocus = FocusNode();
  FocusNode visitingChargeFocus = FocusNode();
  FocusNode advanceBookingDaysFocus = FocusNode();
  FocusNode numberOfMemberFocus = FocusNode();
  Map? selectCompanyType;
  Map companyType = {'0': 'Individual', '1': 'Organisation'};

  ///form3
  List<bool> isChecked =
      List<bool>.generate(7, (int index) => false); //7 = daysOfWeek.length
  List<TimeOfDay> selectedStartTime = [];
  List<TimeOfDay> selectedEndTime = [];

  late List<String> daysOfWeek = [
    'monLbl'.translate(context: context),
    'tueLbl'.translate(context: context),
    'wedLbl'.translate(context: context),
    'thuLbl'.translate(context: context),
    'friLbl'.translate(context: context),
    'satLbl'.translate(context: context),
    'sunLbl'.translate(context: context),
  ];

  late List<String> daysInWeek = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday'
  ];

  late List<String> _participant = [
    "personal",
    "company",
    "description",
    "workingDaysLbl",
    "bankAccount",
    "location"
  ];

  ///form4
  TextEditingController bankNameController = TextEditingController();
  TextEditingController bankCodeController = TextEditingController();
  TextEditingController accountNameController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController taxNameController = TextEditingController();
  TextEditingController taxNumberController = TextEditingController();
  TextEditingController swiftCodeController = TextEditingController();

  FocusNode bankNameFocus = FocusNode();
  FocusNode bankCodeFocus = FocusNode();
  FocusNode bankAccountNumberFocus = FocusNode();
  FocusNode accountNameFocus = FocusNode();
  FocusNode accountNumberFocus = FocusNode();
  FocusNode taxNameFocus = FocusNode();
  FocusNode taxNumberFocus = FocusNode();
  FocusNode swiftCodeFocus = FocusNode();

  PickImage pickLogoImage = PickImage();
  PickImage pickBannerImage = PickImage();
  PickImage pickAddressProofImage = PickImage();
  PickImage pickPassportImage = PickImage();
  PickImage pickNationalIdImage = PickImage();

  PickImage pickOtherImage = PickImage();

  ProviderDetails? providerData;
  bool? isIndividualType;

  String? isPreBookingChatAllowed;
  String? isPostBookingChatAllowed;
  String? atDoorstepAllowed;
  String? atStore;
  String? longDescription;
  ValueNotifier<List<String>> pickedOtherImages = ValueNotifier([]);
  List<String>? previouslyAddedOtherImages = [];


  @override
  void initState() {
    super.initState();

    initializeData();
  }

  void initializeData() {
    Future.delayed(Duration.zero).then((value) {
      //
      providerData = context.read<ProviderDetailsCubit>().providerDetails;
      //
      userNameController.text = providerData?.user?.username ?? '';
      emailController.text = providerData?.user?.email ?? '';
      mobileNumberController.text =
          "${providerData?.user?.countryCode ?? ""} ${providerData?.user?.phone ?? ""}";
      companyNameController.text =
          providerData?.providerInformation?.companyName ?? '';
      aboutCompanyController.text =
          providerData?.providerInformation?.about ?? '';
      //
      isPostBookingChatAllowed =
          providerData?.providerInformation?.isPostBookingChatAllowed ?? "0";
      isPreBookingChatAllowed =
          providerData?.providerInformation?.isPreBookingChatAllowed ?? "0";

      atDoorstepAllowed = providerData?.providerInformation?.atDoorstep ?? "0";

      atStore = providerData?.providerInformation?.atStore ?? "0";

      bankNameController.text = providerData?.bankInformation?.bankName ?? '';
      bankCodeController.text = providerData?.bankInformation?.bankCode ?? '';
      accountNameController.text =
          providerData?.bankInformation?.accountName ?? '';
      accountNumberController.text =
          providerData?.bankInformation?.accountNumber ?? '';
      taxNameController.text = providerData?.bankInformation?.taxName ?? '';
      taxNumberController.text = providerData?.bankInformation?.taxNumber ?? '';
      swiftCodeController.text = providerData?.bankInformation?.swiftCode ?? '';
      //
      cityController.text = providerData?.locationInformation?.city ?? '';
      addressController.text = providerData?.locationInformation?.address ?? '';
      latitudeController.text =
          providerData?.locationInformation?.latitude ?? '';
      longitudeController.text =
          providerData?.locationInformation?.longitude ?? '';
      companyNameController.text =
          providerData?.providerInformation?.companyName ?? '';
      aboutCompanyController.text =
          providerData?.providerInformation?.about ?? '';
      visitingChargesController.text =
          providerData?.providerInformation?.visitingCharges ?? '';
      advanceBookingDaysController.text =
          providerData?.providerInformation?.advanceBookingDays ?? '';
      numberOfMemberController.text =
          providerData?.providerInformation?.numberOfMembers ?? '';
      selectCompanyType = providerData?.providerInformation?.type == '0'
          ? {'title': 'Individual', 'value': '0'}
          : {'title': 'Organization', 'value': '1'};
      isIndividualType = providerData?.providerInformation?.type == '1';
      //add elements in TimeOfDay List
      //
      final List<WorkingDay>? data =
          providerData?.workingDays?.reversed.toList();
      for (int i = 0; i < daysInWeek.length; i++) {
        //assign Default time @ start
        final List<String> startTime =
            (data?[i].startTime ?? '09:00:00').split(':');
        final List<String> endTime =
            (data?[i].endTime ?? '18:00:00').split(':');

        final int startTimeHour = int.parse(startTime[0]);
        final int startTimeMinute = int.parse(startTime[1]);
        selectedStartTime.insert(
          i,
          TimeOfDay(hour: startTimeHour, minute: startTimeMinute),
        );
        //
        final int endTimeHour = int.parse(endTime[0]);
        final int endTimeMinute = int.parse(endTime[1]);
        selectedEndTime.insert(
          i,
          TimeOfDay(hour: endTimeHour, minute: endTimeMinute),
        );
        isChecked[i] = data?[i].isOpen == 1;
      }

      longDescription = providerData?.providerInformation?.longDescription;
      previouslyAddedOtherImages =
          providerData?.providerInformation?.otherImages;
      setState(() {});
    });
  }

  @override
  void dispose() {
    userNameController.dispose();
    emailController.dispose();
    mobileNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    companyNameController.dispose();
    visitingChargesController.dispose();
    advanceBookingDaysController.dispose();
    numberOfMemberController.dispose();
    aboutCompanyController.dispose();
    cityController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    addressController.dispose();
    bankNameController.dispose();
    bankCodeController.dispose();
    accountNameController.dispose();
    accountNumberController.dispose();
    taxNumberController.dispose();
    taxNameController.dispose();
    swiftCodeController.dispose();
    //
    pickedLocalImages.clear();
    pickedOtherImages.dispose();
    //
    confirmPasswordFocus.dispose();
    passwordFocus.dispose();
    mobNoFocus.dispose();
    emailFocus.dispose();
    userNmFocus.dispose();
    numberOfMemberFocus.dispose();
    advanceBookingDaysFocus.dispose();
    visitingChargeFocus.dispose();
    companyNmFocus.dispose();
    longitudeFocus.dispose();
    latitudeFocus.dispose();
    addressFocus.dispose();
    cityFocus.dispose();
    aboutCompanyFocus.dispose();
    swiftCodeFocus.dispose();
    taxNumberFocus.dispose();
    taxNameFocus.dispose();
    accountNumberFocus.dispose();
    accountNameFocus.dispose();
    bankAccountNumberFocus.dispose();
    bankCodeFocus.dispose();
    bankNameFocus.dispose();
    //
    pickNationalIdImage.dispose();
    pickPassportImage.dispose();
    pickAddressProofImage.dispose();
    pickBannerImage.dispose();
    pickLogoImage.dispose();
    //
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: PopScope(
        canPop: currentIndex == 1,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) {
            return;
          } else {
            if (currentIndex > 1) {
              currentIndex--;
              pickedLocalImages = pickedLocalImages;
              setState(() {});
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 1,
            title: CustomText(
              widget.isEditing
                  ? 'completeRegistration'.translate(context: context)
                  : 'completeKYCDetails'.translate(context: context),
              color: Theme.of(context).colorScheme.blackColor,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            leading: widget.isEditing
                ? InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                      color: context.colorScheme.blackColor,
                    ),
                  )
                : null,
             backgroundColor: Theme.of(context).colorScheme.secondaryColor,
            surfaceTintColor: Theme.of(context).colorScheme.secondaryColor,
            bottom: PreferredSize(
              preferredSize: const Size(double.infinity, 70),
              child: SizedBox(
                height: 70,
                child: EasyStepper(
                  internalPadding: 0,
                  borderThickness: 0,
                  stepBorderRadius: 0,
                  showStepBorder: false,
                  activeStep: currentIndex - 1,
                  lineStyle: LineStyle(
                      lineSpace: 0,
                      finishedLineColor: context.colorScheme.accentColor,
                      defaultLineColor: context.colorScheme.primaryColor,
                      lineLength: 100,
                      lineType: LineType.normal,
                      lineThickness: 2,
                      lineWidth: 30,
                      progress: 0.5,
                      progressColor: context.colorScheme.accentColor),
                  stepRadius: 11,
                  finishedStepBackgroundColor:
                      context.colorScheme.secondaryColor,
                  finishedStepIconColor: context.colorScheme.accentColor,
                  finishedStepBorderColor: context.colorScheme.accentColor,
                  finishedStepBorderType: BorderType.normal,
                  showLoadingAnimation: false,
                  unreachedStepBackgroundColor:
                      context.colorScheme.primaryColor.withValues(alpha: 0.2),
                  steps: List<EasyStep>.generate(
                      _participant.length,
                      (index) => EasyStep(
                            customStep: CustomSvgPicture(
                              svgImage: AppAssets.bClock,
                              color: index <= currentIndex - 1
                                  ? context.colorScheme.accentColor
                                  : context.colorScheme.lightGreyColor,
                            ),
                            customTitle: CustomText(
                                _participant[index].translate(context: context),
                                textAlign: index == 0
                                    ? TextAlign.right
                                    : index == _participant.length - 1
                                        ? TextAlign.left
                                        : TextAlign.center,
                                color: index == currentIndex - 1
                                    ? context.colorScheme.accentColor
                                    : context.colorScheme.blackColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          )).toList(),
                ),
              ),

              
            ),
          ),
          bottomNavigationBar: bottomNavigation(currentIndex: currentIndex),
          body: screenBuilder(currentIndex),
        ),
      ),
    );
  }

  Widget bottomNavigation({required int currentIndex}) {
    return CustomContainer(
      color: context.colorScheme.secondaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentIndex > 1) ...[
            Expanded(
              flex: 1,
              child: nextPrevBtnWidget(
                isNext: false,
                currentIndex: currentIndex,
              ),
            ),
            const CustomSizedBox(width: 10),
          ],
          Expanded(
            flex: 5,
            child: BlocListener<EditProviderDetailsCubit,
                    EditProviderDetailsState>(
                listener: (BuildContext context,
                    EditProviderDetailsState state) async {
                  if (state is EditProviderDetailsSuccess) {
                    UiUtils.showMessage(
                      context,
                      'detailsUpdatedSuccessfully'.translate(context: context),
                      ToastificationType.success,
                    );
                    //
                    if (widget.isEditing) {
                      context
                          .read<ProviderDetailsCubit>()
                          .setUserInfo(state.providerDetails);
                      Future.delayed(const Duration(seconds: 1)).then((value) {
                        Navigator.pop(context);
                      });
                    } else {
                      Future.delayed(
                        Duration.zero,
                        () {
                          HiveRepository.setUserLoggedIn = false;
                          HiveRepository.clearBoxValues(
                              boxName: HiveRepository.userDetailBoxKey);
                          context
                              .read<AuthenticationCubit>()
                              .setUnAuthenticated();
                          AppQuickActions.clearShortcutItems();
                        },
                      );

//
                      Future.delayed(const Duration(seconds: 1)).then((value) {
                        Navigator.pushReplacementNamed(
                          context,
                          Routes.successScreen,
                          arguments: {
                            'title':
                                'detailsSubmitted'.translate(context: context),
                            'message':
                                'detailsHasBeenSubmittedWaitForAdminApproval'
                                    .translate(context: context),
                            'imageName': 'registration'
                          },
                        );
                      });
                    }
                  } else if (state is EditProviderDetailsFailure) {
                    UiUtils.showMessage(
                      context,
                      state.errorMessage.translate(context: context),
                      ToastificationType.error,
                    );
                  }
                },
                child: nextPrevBtnWidget(
                  isNext: true,
                  currentIndex: currentIndex,
                )),
          ),
        ],
      ),
    );
  }

  BlocBuilder<EditProviderDetailsCubit, EditProviderDetailsState>
      nextPrevBtnWidget({required bool isNext, required int currentIndex}) {
    return BlocBuilder<EditProviderDetailsCubit, EditProviderDetailsState>(
      builder: (BuildContext context, EditProviderDetailsState state) {
        Widget? child;
        if (state is EditProviderDetailsInProgress) {
          child = CustomCircularProgressIndicator(
            color: AppColors.whiteColors,
          );
        } else if (state is EditProviderDetailsSuccess ||
            state is EditProviderDetailsFailure) {
          child = null;
        }
        return CustomRoundedButton(
          textSize: 16,
          widthPercentage: isNext ? 1 : 0.5,
          backgroundColor: isNext
              ? Theme.of(context).colorScheme.accentColor
              : Theme.of(context).colorScheme.accentColor.withAlpha(20),
         showBorder: false,

          titleColor: isNext
              ? AppColors.whiteColors
              : Theme.of(context).colorScheme.blackColor,
          onTap: () => state is EditProviderDetailsInProgress
              ? () {}
              : onNextPrevBtnClick(isNext: isNext, currentPage: currentIndex),
          buttonTitleWidget: isNext && currentIndex >= _participant.length
              ? CustomText(
                  'submitBtnLbl'.translate(context: context),
                  fontSize: 16.0,
                  color: AppColors.whiteColors,
                )
              : isNext
                  ? CustomText(
                      'nxtBtnLbl'.translate(context: context),
                      fontSize: 16.0,
                      color: AppColors.whiteColors,
                    )
                  : CustomSvgPicture(
                      svgImage: AppAssets.backArrowLight,
                      color: context.colorScheme.accentColor,
                    ),
          child: isNext && currentIndex >= _participant.length ? child : null,
        );
      },
    );
  }

  Future<void> onNextPrevBtnClick({
    required bool isNext,
    required int currentPage,
  }) async {
    if (currentPage == 3) {
      final tempText = await htmlController.getText();

      if (tempText.trim().isNotEmpty) {
        longDescription = tempText;
      }
    }
    if (isNext) {
      FormState? form = formKey1.currentState; //default value
      switch (currentPage) {
        case 2:
          form = formKey2.currentState;
          break;
        case 4:
          form = formKey4.currentState;
          break;
        case 5:
          form = formKey5.currentState;
          break;
        case 6:
          form = formKey6.currentState;
          break;
        default:
          form = formKey1.currentState;
          break;
      }
      if (currentPage != 3) {
        if (form == null) return;
        form.save();
      }

      if (currentPage == 3 || form!.validate()) {
        if (currentPage < _participant.length) {
          currentIndex++;
          if (currentPage != 3) {
            scrollController.jumpTo(0); //reset Scrolling on Form change
          }
          pickedLocalImages = pickedLocalImages;
          setState(() {});
        } else {
          final List<WorkingDay> workingDays = [];
          for (int i = 0; i < daysInWeek.length; i++) {
            //
            workingDays.add(
              WorkingDay(
                isOpen: isChecked[i] ? 1 : 0,
                endTime:
                    "${selectedEndTime[i].hour.toString().padLeft(2, "0")}:${selectedEndTime[i].minute.toString().padLeft(2, "0")}:00",
                startTime:
                    "${selectedStartTime[i].hour.toString().padLeft(2, "0")}:${selectedStartTime[i].minute.toString().padLeft(2, "0")}:00",
                day: daysInWeek[i],
              ),
            );
          }

          final ProviderDetails editProviderDetails = ProviderDetails(
            workingDays: workingDays,
            user: UserDetails(
              id: providerData?.user?.id,
              username: userNameController.text.trim(),
              email: emailController.text.trim(),
              phone: providerData?.user?.phone,
              countryCode: providerData?.user?.countryCode,
              company: companyNameController.text.trim(),
              image: pickedLocalImages['logoImage'],
            ),
            providerInformation: ProviderInformation(
              type: selectCompanyType?['value'],
              companyName: companyNameController.text.trim(),
              visitingCharges: visitingChargesController.text.trim(),
              advanceBookingDays: advanceBookingDaysController.text.trim(),
              about: aboutCompanyController.text.trim(),
              numberOfMembers: numberOfMemberController.text.trim(),
              banner: pickedLocalImages['bannerImage'],
              nationalId: pickedLocalImages['nationalIdImage'],
              passport: pickedLocalImages['passportIdImage'],
              addressId: pickedLocalImages['addressIdImage'],
              otherImages: pickedOtherImages.value,
              longDescription: longDescription,
              isPostBookingChatAllowed: isPostBookingChatAllowed,
              isPreBookingChatAllowed: isPreBookingChatAllowed,
              atDoorstep: atDoorstepAllowed,
              atStore: atStore,
            ),
            bankInformation: BankInformation(
              accountName: accountNameController.text.trim(),
              accountNumber: accountNumberController.text.trim(),
              bankCode: bankCodeController.text.trim(),
              bankName: bankNameController.text.trim(),
              taxName: taxNameController.text.trim(),
              taxNumber: taxNumberController.text.trim(),
              swiftCode: swiftCodeController.text.trim(),
            ),
            locationInformation: LocationInformation(
              longitude: longitudeController.text.trim(),
              latitude: latitudeController.text.trim(),
              address: addressController.text.trim(),
              city: cityController.text.trim(),
            ),
          );
          //
          if (context.read<FetchSystemSettingsCubit>().isDemoModeEnable() &&
              widget.isEditing) {
            UiUtils.showDemoModeWarning(context: context);
            return;
          }
          context
              .read<EditProviderDetailsCubit>()
              .editProviderDetails(providerDetails: editProviderDetails);
        }
      }
    } else if (currentPage > 1) {
      currentIndex--;
      pickedLocalImages = pickedLocalImages;
      setState(() {});
    }
  }

  Widget screenBuilder(int currentPage) {
    Widget currentForm = form1(); //default form1
    switch (currentPage) {
      case 2:
        currentForm = form2();
        break;
      case 3:
        currentForm = form3();
        break;
      case 4:
        currentForm = form4();
        break;
      case 5:
        currentForm = form5();
        break;
      case 6:
        currentForm = form6();
        break;
      default:
        currentForm = form1();
        break;
    }
    return currentPage == 3
        ? currentForm
        : SingleChildScrollView(
            clipBehavior: Clip.none,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: currentForm,
          );
  }

  Widget form1() {
    return Form(
      key: formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomSizedBox(
            height: 10,
          ),
          CustomTextFormField(
            labelText: 'userNmLbl'.translate(context: context),
            controller: userNameController,
            currentFocusNode: userNmFocus,
            prefix: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.person,
                    color: userNmFocus.hasFocus
                        ? context.colorScheme.accentColor
                        : context.colorScheme.blackColor,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 1,
                  height: 15,
                  color: context.colorScheme.lightGreyColor,
                ),
              ],
            ),
            nextFocusNode: emailFocus,
            validator: (String? userName) =>
                Validator.nullCheck(context, userName),
          ),
          const CustomSizedBox(
            height: 5,
          ),
          CustomTextFormField(
            labelText: 'emailLbl'.translate(context: context),
            controller: emailController,
            currentFocusNode: emailFocus,
            prefix: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.mail,
                    color: emailFocus.hasFocus
                        ? context.colorScheme.accentColor
                        : context.colorScheme.blackColor,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 1,
                  height: 15,
                  color: context.colorScheme.lightGreyColor,
                ),
              ],
            ),
            nextFocusNode: mobNoFocus,
            textInputType: TextInputType.emailAddress,
            validator: (String? email) => Validator.nullCheck(context, email),
          ),
          const CustomSizedBox(
            height: 5,
          ),
          CustomTextFormField(
            labelText: 'mobNoLbl'.translate(context: context),
            controller: mobileNumberController,
            currentFocusNode: mobNoFocus,
            prefix: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.phone,
                    color: mobNoFocus.hasFocus
                        ? context.colorScheme.accentColor
                        : context.colorScheme.blackColor,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 1,
                  height: 15,
                  color: context.colorScheme.lightGreyColor,
                ),
              ],
            ),
            textInputType: TextInputType.phone,
            isReadOnly: true,
            validator: (String? mobileNumber) =>
                Validator.nullCheck(context, mobileNumber),
          ),
          const CustomSizedBox(
            height: 12,
          ),
          Row(
            children: [
              const Expanded(
                child: Divider(
                  thickness: 0.5,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: CustomText(
                  'idProofLbl'.translate(context: context),
                  color: Theme.of(context).colorScheme.blackColor,
                ),
              ),
              const Expanded(
                child: Divider(
                  thickness: 0.5,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  idImageWidget(
                    imageController: pickNationalIdImage,
                    titleTxt: 'nationalIdLbl'.translate(context: context),
                    imageHintText: 'chooseFileLbl'.translate(context: context),
                    imageType: 'nationalIdImage',
                    oldImage: context
                            .read<ProviderDetailsCubit>()
                            .providerDetails
                            .providerInformation
                            ?.nationalId ??
                        '',
                  ),
                  idImageWidget(
                    imageController: pickAddressProofImage,
                    titleTxt: 'addressLabel'.translate(context: context),
                    imageHintText: 'chooseFileLbl'.translate(context: context),
                    imageType: 'addressIdImage',
                    oldImage: context
                            .read<ProviderDetailsCubit>()
                            .providerDetails
                            .providerInformation
                            ?.addressId ??
                        '',
                  ),
                  idImageWidget(
                    imageController: pickPassportImage,
                    titleTxt: 'passportLbl'.translate(context: context),
                    imageHintText: 'chooseFileLbl'.translate(context: context),
                    imageType: 'passportIdImage',
                    oldImage: context
                            .read<ProviderDetailsCubit>()
                            .providerDetails
                            .providerInformation
                            ?.passport ??
                        '',
                  ),
                ],
              ),
            ),
          ),
          const CustomSizedBox(
            height: 12,
          ),
          Row(
            children: [
              const Expanded(
                child: Divider(
                  thickness: 0.5,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: CustomText(
                  'bookingSetting'.translate(context: context),
                  color: Theme.of(context).colorScheme.blackColor,
                ),
              ),
              const Expanded(
                child: Divider(
                  thickness: 0.5,
                ),
              ),
            ],
          ),
          const CustomSizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: CustomCheckIconTextButton(
                  title: "atStore",
                  isSelected: atStore == "1",
                  onTap: () {
                    setState(() {
                      atStore = atStore == "1" ? "0" : "1";
                    });
                  },
                ),
              ),
              const CustomSizedBox(
                width: 5,
              ),
              Expanded(
                child: CustomCheckIconTextButton(
                  title: "atDoorstep",
                  isSelected: atDoorstepAllowed == "1",
                  onTap: () {
                    setState(() {
                      atDoorstepAllowed = atDoorstepAllowed == "1" ? "0" : "1";
                    });
                  },
                ),
              ),
            ],
          ),
          const CustomSizedBox(
            height: 12,
          ),
          if ((context.read<FetchSystemSettingsCubit>().state
                      as FetchSystemSettingsSuccess)
                  .generalSettings
                  .allowPostBookingChat! ||
              (context.read<FetchSystemSettingsCubit>().state
                      as FetchSystemSettingsSuccess)
                  .generalSettings
                  .allowPreBookingChat!)
            Row(
              children: [
                const Expanded(
                  child: Divider(
                    thickness: 0.5,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: CustomText(
                    'chatSetting'.translate(context: context),
                    color: Theme.of(context).colorScheme.blackColor,
                  ),
                ),
                const Expanded(
                  child: Divider(
                    thickness: 0.5,
                  ),
                ),
              ],
            ),
          const CustomSizedBox(
            height: 10,
          ),

          Row(
            children: [
              if ((context.read<FetchSystemSettingsCubit>().state
                      as FetchSystemSettingsSuccess)
                  .generalSettings
                  .allowPreBookingChat!)
                Expanded(
                  child: CustomCheckIconTextButton(
                    title: "preBooking",
                    isSelected: isPreBookingChatAllowed == "1",
                    onTap: () {
                      setState(() {
                        isPreBookingChatAllowed =
                            isPreBookingChatAllowed == "1" ? "0" : "1";
                      });
                    },
                  ),
                ),
              if ((context.read<FetchSystemSettingsCubit>().state
                          as FetchSystemSettingsSuccess)
                      .generalSettings
                      .allowPostBookingChat! &&
                  (context.read<FetchSystemSettingsCubit>().state
                          as FetchSystemSettingsSuccess)
                      .generalSettings
                      .allowPreBookingChat!)
                const CustomSizedBox(
                  width: 5,
                ),
              if ((context.read<FetchSystemSettingsCubit>().state
                      as FetchSystemSettingsSuccess)
                  .generalSettings
                  .allowPostBookingChat!)
                Expanded(
                  child: CustomCheckIconTextButton(
                    title: "postBooking",
                    isSelected: isPostBookingChatAllowed == "1",
                    onTap: () {
                      setState(() {
                        isPostBookingChatAllowed =
                            isPostBookingChatAllowed == "1" ? "0" : "1";
                      });
                    },
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }

  Widget form2() {
    return Form(
      key: formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomSizedBox(
            height: 5,
          ),
          Center(
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip
                  .none, // Allows the CircleAvatar to overflow the container
              children: [
                CustomContainer(
                    width: MediaQuery.of(context).size.width / 0.5,
                    height: 200,
                    color: context.colorScheme.accentColor.withAlpha(30),
                    borderRadius: UiUtils.borderRadiusOf10,
                    border: Border.all(
                      color: context.colorScheme.accentColor,
                      width: 1,
                    ),
                    child: bennerPicker(
                      imageController: pickBannerImage,
                      oldImage: providerData?.providerInformation?.banner ?? '',
                      hintLabel:
                          "${"addLbl".translate(context: context)} ${"bannerImgLbl".translate(context: context)}",
                      imageType: 'bannerImage',
                    )
                     ),
                Positioned(
                  bottom: -35,
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: context.colorScheme.secondaryColor,
                    child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: context.colorScheme.accentColor,
                            width: 1,
                          ),
                        ),
                        child: logoPicker(
                          imageController: pickLogoImage,
                          oldImage: providerData?.user?.image ?? '',
                          hintLabel:
                              "${"addLbl".translate(context: context)} ${"logoLbl".translate(context: context)}",
                          imageType: 'logoImage',
                        )),
                  ),
                ),
              ],
            ),
          ),
          const CustomSizedBox(
            height: 50,
          ),
          CustomTextFormField(
            bottomPadding: 15,
            labelText: 'compNmLbl'.translate(context: context),
            controller: companyNameController,
            currentFocusNode: companyNmFocus,
            prefix: CustomSvgPicture(
              svgImage: AppAssets.pProfile,
              color: context.colorScheme.accentColor,
              boxFit: BoxFit.scaleDown,
            ),
            nextFocusNode: visitingChargeFocus,
            validator: (String? companyName) =>
                Validator.nullCheck(context, companyName),
          ),

          CustomTextFormField(
            bottomPadding: 15,
            labelText: 'visitingCharge'.translate(context: context),
            controller: visitingChargesController,
            currentFocusNode: visitingChargeFocus,
            nextFocusNode: companyNmFocus,
            validator: (String? visitingCharge) =>
                Validator.nullCheck(context, visitingCharge),
            textInputType: TextInputType.number,
            allowOnlySingleDecimalPoint: true,
            prefix: Padding(
              padding: const EdgeInsetsDirectional.all(15.0),
              child: CustomText(
                UiUtils.systemCurrency ?? '',
                fontSize: 14.0,
                color: Theme.of(context).colorScheme.blackColor,
              ),
            ),
          ),
          CustomTextFormField(
            bottomPadding: 15,
            labelText: 'advanceBookingDay'.translate(context: context),
            controller: advanceBookingDaysController,
            currentFocusNode: advanceBookingDaysFocus,
            prefix: CustomSvgPicture(
              svgImage: AppAssets.pDate,
              color: context.colorScheme.accentColor,
              boxFit: BoxFit.scaleDown,
            ),
            nextFocusNode: numberOfMemberFocus,
            validator: (String? advancedBooking) {
              final String? value =
                  Validator.nullCheck(context, advancedBooking);
              if (value != null) {
                return value;
              }
              if (int.parse(advancedBooking ?? '0') < 1) {
                return 'advanceBookingDaysShouldBeGreaterThan0'
                    .translate(context: context);
              }
              return null;
            },
            textInputType: TextInputType.number,
          ),
          CustomTextFormField(
            bottomPadding: 15,
            labelText: 'aboutCompany'.translate(context: context),
            controller: aboutCompanyController,
            prefix: CustomSvgPicture(
              svgImage: AppAssets.pQuestion,
              color: context.colorScheme.accentColor,
              boxFit: BoxFit.scaleDown,
            ),
            currentFocusNode: aboutCompanyFocus,
            expands: true,
            textInputType: TextInputType.multiline,
            validator: (String? aboutCompany) =>
                Validator.nullCheck(context, aboutCompany),
          ),

          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  bottomPadding: 0,
                  controller: TextEditingController(
                      text: selectCompanyType?["title"] ?? ""),
                  labelText: 'selectType'.translate(context: context),
                  isReadOnly: true,
                  hintText: 'selectType'.translate(context: context),
                  suffixIcon: const Icon(Icons.keyboard_arrow_down),
                  callback: () {
                    selectCompanyTypes();
                  },
                ),
              ),
              const CustomSizedBox(
                width: 10,
              ),
              Expanded(
                child: CustomTextFormField(
                  bottomPadding: 0,
                  labelText: 'numberOfMember'.translate(context: context),
                  controller: numberOfMemberController,
                  currentFocusNode: numberOfMemberFocus,
                  nextFocusNode: aboutCompanyFocus,
                  validator: (String? numberOfMembers) =>
                      Validator.nullCheck(context, numberOfMembers),
                  isReadOnly: isIndividualType ?? false,
                  textInputType: TextInputType.number,
                ),
              ),
            ],
          ),
          const CustomSizedBox(
            height: 5,
          ),
          Row(
            children: [
              const Expanded(
                child: Divider(
                  thickness: 0.5,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: CustomText(
                  'otherImages'.translate(context: context),
                  color: Theme.of(context).colorScheme.blackColor,
                ),
              ),
              const Expanded(
                child: Divider(
                  thickness: 0.5,
                ),
              ),
            ],
          ),
          const CustomSizedBox(height: 5),
          //other image picker builder
          ValueListenableBuilder(
            valueListenable: pickedOtherImages,
            builder: (BuildContext context, Object? value, Widget? child) {
              final bool isThereAnyImage = pickedOtherImages.value.isNotEmpty ||
                  (previouslyAddedOtherImages != null &&
                      previouslyAddedOtherImages!.isNotEmpty);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: CustomSizedBox(
                  height: 120,
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        CustomInkWellContainer(
                          onTap: () async {
                            try {
                              final FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                allowMultiple: true,
                                type: FileType.image,
                              );
                              if (result != null) {
                                if (previouslyAddedOtherImages != null &&
                                    previouslyAddedOtherImages!.isNotEmpty) {
                                  previouslyAddedOtherImages = null;
                                }
                                for (int i = 0; i < result.files.length; i++) {
                                  if (!pickedOtherImages.value
                                      .contains(result.files[i].path)) {
                                    pickedOtherImages.value =
                                        List.from(pickedOtherImages.value)
                                          ..insert(0, result.files[i].path!);
                                  }
                                }
                              } else {
                                // User canceled the picker
                              }
                            } catch (_) {}
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: isThereAnyImage ? 5 : 0,
                            ),
                            child: SetDottedBorderWithHint(
                              height: 100,
                              width: isThereAnyImage
                                  ? 150
                                  : MediaQuery.sizeOf(context).width - 35,
                              radius: 7,
                              str: (isThereAnyImage
                                      ? previouslyAddedOtherImages != null &&
                                              previouslyAddedOtherImages!
                                                  .isNotEmpty
                                          ? "changeImages"
                                          : "addImages"
                                      : "chooseImages")
                                  .translate(context: context),
                              strPrefix: '',
                              borderColor:
                                  Theme.of(context).colorScheme.blackColor,
                            ),
                          ),
                        ),
                        if (isThereAnyImage &&
                            pickedOtherImages.value.isNotEmpty)
                          for (int i = 0;
                              i < pickedOtherImages.value.length;
                              i++)
                            CustomContainer(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              height: 100 + 20,
                              width: isThereAnyImage
                                  ? 150
                                  : MediaQuery.sizeOf(context).width - 35,
                              borderRadius: UiUtils.borderRadiusOf10,
                              child: Stack(
                                children: [
                                  Center(
                                    child: CustomContainer(
                                      height: 100,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(
                                                UiUtils.borderRadiusOf10)),
                                        child: Image.file(
                                          File(
                                            pickedOtherImages.value[i],
                                          ),
                                          height: double.maxFinite,
                                          width: double.maxFinite,
                                          fit: BoxFit
                                              .cover, //other image box fit
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional.topEnd,
                                    child: CustomInkWellContainer(
                                      onTap: () {
                                        //assigning new list, because listener will not notify if we remove the values only to the list
                                        pickedOtherImages.value =
                                            List.from(pickedOtherImages.value)
                                              ..removeAt(i);
                                      },
                                      child: CustomContainer(
                                        height: 20,
                                        borderRadius: UiUtils.borderRadiusOf50,
                                        width: 20,
                                        color: AppColors.redColor
                                            .withValues(alpha: 0.5),
                                        child: const Center(
                                          child: Icon(
                                            Icons.clear_rounded,
                                            size: 15,
                                            color: AppColors.redColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                        if (isThereAnyImage &&
                            previouslyAddedOtherImages != null &&
                            previouslyAddedOtherImages!.isNotEmpty)
                          for (int i = 0;
                              i < previouslyAddedOtherImages!.length;
                              i++)
                            CustomContainer(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              height: 100,
                              width: isThereAnyImage
                                  ? 150
                                  : MediaQuery.sizeOf(context).width - 35,
                              borderRadius: UiUtils.borderRadiusOf10,
                              color:
                                  context.colorScheme.accentColor.withAlpha(20),
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(
                                          UiUtils.borderRadiusOf10)),
                                  child: CustomCachedNetworkImage(
                                    imageUrl: previouslyAddedOtherImages![i],
                                    fit: BoxFit.fill, //other image box fit
                                  ),
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const CustomSizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget form3() {
    return Wrap(
      children: [
        Padding(
            padding:
                const EdgeInsets.only(bottom: 0, left: 15, right: 15, top: 10),
            child: Container()),
        SingleChildScrollView(
          child: CustomHTMLEditor(
            controller: htmlController,
            initialHTML: longDescription,
            hint: 'describeCompanyInDetail'.translate(context: context),
          ),
        ),
      ],
    );
  }

  Widget form6() {
    return Form(
      key: formKey6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomSizedBox(
            height: 10,
          ),
          CustomInkWellContainer(
            onTap: () async {
              UiUtils.removeFocus();
              //
              String latitude = latitudeController.text.trim();
              String longitude = longitudeController.text.trim();
              if (latitude == '' && longitude == '') {
                await GetLocation().requestPermission(
                  onGranted: (Position position) {
                    latitude = position.latitude.toString();
                    longitude = position.longitude.toString();
                  },
                  allowed: (Position position) {
                    latitude = position.latitude.toString();
                    longitude = position.longitude.toString();
                  },
                  onRejected: () {},
                );
              }
              if (mounted) {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (BuildContext context) => BlocProvider(
                      create: (context) => FetchUserCurrentLocationCubit(),
                      child: GoogleMapScreen(
                        latitude: latitude,
                        longitude: longitude,
                      ),
                    ),
                  ),
                ).then((value) {
                  latitudeController.text = value['selectedLatitude'];
                  longitudeController.text = value['selectedLongitude'];
                  addressController.text = value['selectedAddress'];
                  cityController.text = value['selectedCity'];
                });
              }
            },
            child: CustomContainer(
              margin: const EdgeInsets.only(
                bottom: 15,
              ),
              height: 50,
              border: Border.all(
                color: Theme.of(context).colorScheme.lightGreyColor,
              ),
              borderRadius: UiUtils.borderRadiusOf10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(
                    Icons.my_location_sharp,
                    color: Theme.of(context).colorScheme.accentColor,
                  ),
                  Text(
                    'chooseYourLocation'.translate(context: context),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.accentColor,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).colorScheme.accentColor,
                  ),
                ],
              ),
            ),
          ),
          CustomTextFormField(
            bottomPadding: 15,
            labelText: 'cityLbl'.translate(context: context),
            controller: cityController,
            currentFocusNode: cityFocus,
            nextFocusNode: latitudeFocus,
            validator: (String? cityValue) =>
                Validator.nullCheck(context, cityValue),
          ),
          CustomTextFormField(
            bottomPadding: 15,
            labelText: 'latitudeLbl'.translate(context: context),
            controller: latitudeController,
            currentFocusNode: latitudeFocus,
            nextFocusNode: longitudeFocus,
            textInputType: TextInputType.number,
            validator: (String? latitude) =>
                Validator.validateLatitude(context, latitude),
            allowOnlySingleDecimalPoint: true,
          ),
          CustomTextFormField(
            bottomPadding: 15,
            labelText: 'longitudeLbl'.translate(context: context),
            controller: longitudeController,
            currentFocusNode: longitudeFocus,
            nextFocusNode: addressFocus,
            textInputType: TextInputType.number,
            validator: (String? longitude) =>
                Validator.validateLongitude(context, longitude),
            allowOnlySingleDecimalPoint: true,
          ),
          CustomTextFormField(
            bottomPadding: 15,
            labelText: 'addressLbl'.translate(context: context),
            controller: addressController,
            currentFocusNode: addressFocus,
            textInputType: TextInputType.multiline,
            expands: true,
            minLines: 3,
            validator: (String? addressValue) =>
                Validator.nullCheck(context, addressValue),
          ),
        ],
      ),
    );
  }

  Widget form4() {
    return Form(
      key: formKey4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomSizedBox(
            height: 15,
          ),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                mainAxisExtent: 80),
            padding: EdgeInsets.zero,
            itemCount: daysOfWeek.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return CustomCheckIconTextButton(
                  startDate: DateFormat.jm().format(
                    DateTime.parse(
                      "2020-07-20T${selectedStartTime[index].hour.toString().padLeft(2, "0")}:${selectedStartTime[index].minute.toString().padLeft(2, "0")}:00",
                    ),
                  ),
                  onStartDateTap: () {
                    _selectTime(
                      selectedTime: selectedStartTime[index],
                      indexVal: index,
                      isTimePickerForStarTime: true,
                    );
                  },
                  endDate:
                      "${DateFormat.jm().format(DateTime.parse("2020-07-20T${selectedEndTime[index].hour.toString().padLeft(2, "0")}:${selectedEndTime[index].minute.toString().padLeft(2, "0")}:00"))} ",
                  onEndDateTap: () {
                    _selectTime(
                      selectedTime: selectedEndTime[index],
                      indexVal: index,
                      isTimePickerForStarTime: false,
                    );
                  },
                  title: daysOfWeek[index],
                  isSelected: isChecked[index],
                  onTap: () {
                    setState(
                      () {
                        pickedLocalImages = pickedLocalImages;
                        isChecked[index] =
                            isChecked[index] == true ? false : true;
                      },
                    );
                  });
            },
            
          ),
        ],
      ),
    );
  }

  Widget form5() {
    return Form(
      key: formKey5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomSizedBox(
            height: 10,
          ),
          CustomTextFormField(
            bottomPadding: 15,
            labelText: 'bankNmLbl'.translate(context: context),
            controller: bankNameController,
            currentFocusNode: bankNameFocus,
            nextFocusNode: bankCodeFocus,
            // validator: (String? name) => Validator.nullCheck(context, name),
          ),
          CustomTextFormField(
            bottomPadding: 15,
            labelText: 'bankCodeLbl'.translate(context: context),
            controller: bankCodeController,
            currentFocusNode: bankCodeFocus,
            nextFocusNode: accountNameFocus,
            // validator: (String? bankCode) =>
            //     Validator.nullCheck(context, bankCode),
          ),
          CustomTextFormField(
            bottomPadding: 15,
            labelText: 'accountName'.translate(context: context),
            controller: accountNameController,
            currentFocusNode: accountNameFocus,
            nextFocusNode: accountNumberFocus,
            // validator: (String? accountName) =>
            //     Validator.nullCheck(context, accountName),
          ),
          CustomTextFormField(
            bottomPadding: 15,
            labelText: 'accNumLbl'.translate(context: context),
            controller: accountNumberController,
            currentFocusNode: accountNumberFocus,
            nextFocusNode: taxNameFocus,
            textInputType: TextInputType.phone,
            // validator: (String? accountNumber) =>
            //     Validator.nullCheck(context, accountNumber),
          ),
          CustomTextFormField(
            bottomPadding: 15,
            labelText: 'taxName'.translate(context: context),
            controller: taxNameController,
            currentFocusNode: taxNameFocus,
            nextFocusNode: taxNumberFocus,
            // validator: (String? mobileNumber) =>
            //     Validator.nullCheck(context, mobileNumber),
          ),
          CustomTextFormField(
            bottomPadding: 15,
            labelText: 'taxNumber'.translate(context: context),
            controller: taxNumberController,
            currentFocusNode: taxNumberFocus,
            nextFocusNode: swiftCodeFocus,
            // validator: (String? taxName) =>
            //     Validator.nullCheck(context, taxName),
            textInputType: const TextInputType.numberWithOptions(decimal: true),
          ),
          CustomTextFormField(
            bottomPadding: 15,
            labelText: 'swiftCode'.translate(context: context),
            controller: swiftCodeController,
            currentFocusNode: swiftCodeFocus,
            // validator: (String? swiftCode) =>
            //     Validator.nullCheck(context, swiftCode),
          ),
        ],
      ),
    );
  }

  
  Future<void> _selectTime({
    required TimeOfDay selectedTime,
    required int indexVal,
    required bool isTimePickerForStarTime,
  }) async {
    try {
      final TimeOfDay? timeOfDay = await showTimePicker(
        context: context,
        initialTime: selectedTime, //TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          );
        },
      );
      //

      if (isTimePickerForStarTime) {
        //
        final bool isStartTimeBeforeOfEndTime = timeOfDay!.hour <=
                (selectedEndTime[indexVal].hour == 00
                    ? 24
                    : selectedEndTime[indexVal].hour) &&
            timeOfDay.minute <= selectedEndTime[indexVal].minute;
        //
        if (isStartTimeBeforeOfEndTime) {
          selectedStartTime[indexVal] = timeOfDay;
        } else if (mounted) {
          UiUtils.showMessage(
            context,
            'companyStartTimeCanNotBeAfterOfEndTime'
                .translate(context: context),
            ToastificationType.warning,
          );
        }
      } else {
        //
        final bool isEndTimeAfterOfStartTime = timeOfDay!.hour >=
                (selectedStartTime[indexVal].hour == 00
                    ? 24
                    : selectedStartTime[indexVal].hour) &&
            timeOfDay.minute >= selectedStartTime[indexVal].minute;
        //
        if (isEndTimeAfterOfStartTime) {
          selectedEndTime[indexVal] = timeOfDay;
        } else {
          if (mounted) {
            UiUtils.showMessage(
              context,
              'companyEndTimeCanNotBeBeforeOfStartTime'
                  .translate(context: context),
              ToastificationType.warning,
            );
          }
        }
      }
    } catch (_) {}

    setState(() {
      pickedLocalImages = pickedLocalImages;
    });
  }

  Widget idImageWidget({
    required String titleTxt,
    required String imageHintText,
    required PickImage imageController,
    required String imageType,
    required String oldImage,
  }) {
    return CustomContainer(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width / 1.4,
      color: context.colorScheme.secondaryColor,
      borderRadius: UiUtils.borderRadiusOf10,
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                titleTxt,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              const CustomSizedBox(height: 5),
              pickedLocalImages[imageType] != ''
                  ? CustomText(
                      pickedLocalImages[imageType].split('/').last,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      maxLines: 1,
                      color: context.colorScheme.lightGreyColor,
                    )
                  : oldImage != 'null'
                      ? CustomText(
                          oldImage.split('/').last,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          maxLines: 1,
                          color: context.colorScheme.lightGreyColor,
                        )
                      : const SizedBox(
                          height: 12,
                        ),
              const CustomSizedBox(height: 5),
              imagePicker(
                imageType: imageType,
                imageController: imageController,
                oldImage: oldImage,
                hintLabel: imageHintText,
                width: MediaQuery.of(context).size.width / 1.5,
                onImagePicked: (newImage) {
                  setState(() {
                    pickedLocalImages[imageType] = newImage;
                  });
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget bennerPicker(
      {required PickImage imageController,
      required String oldImage,
      required String hintLabel,
      required String imageType}) {
    return imageController.ListenImageChange(
      (BuildContext context, image) {
        if (image == null) {
          if (pickedLocalImages[imageType] != '') {
            return GestureDetector(
              onTap: () {
                showCameraAndGalleryOption(
                  imageController: imageController,
                  title: hintLabel,
                );
              },
              child: Center(
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                      Radius.circular(UiUtils.borderRadiusOf10)),
                  child: Image.file(
                    File(pickedLocalImages[imageType]!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }

          if (oldImage.isNotEmpty) {
            return GestureDetector(
                onTap: () {
                  showCameraAndGalleryOption(
                    imageController: imageController,
                    title: hintLabel,
                  );
                },
                child: Center(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                        Radius.circular(UiUtils.borderRadiusOf10)),
                    child: CustomCachedNetworkImage(
                      imageUrl: oldImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ));
          }

          return CustomInkWellContainer(
            onTap: () {
              showCameraAndGalleryOption(
                imageController: imageController,
                title: hintLabel,
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomSvgPicture(
                  svgImage: AppAssets.camera,
                  color: context.colorScheme.accentColor,
                  height: 20,
                  width: 20,
                ),
                const CustomSizedBox(height: 10),
                CustomText(
                  'uploadBannerImage'.translate(context: context),
                  color: context.colorScheme.accentColor,
                  fontSize: 12,
                ),
              ],
            ),
          );
        }

        pickedLocalImages[imageType] = image?.path;

        return GestureDetector(
            onTap: () {
              showCameraAndGalleryOption(
                imageController: imageController,
                title: hintLabel,
              );
            },
            child: Center(
              child: ClipRRect(
                borderRadius: const BorderRadius.all(
                    Radius.circular(UiUtils.borderRadiusOf10)),
                child: Image.file(
                  File(image.path),
                  fit: BoxFit.cover,
                ),
              ),
            ));
      },
    );
  }

  Widget logoPicker(
      {required PickImage imageController,
      required String oldImage,
      required String hintLabel,
      required String imageType}) {
    return imageController.ListenImageChange(
      (BuildContext context, image) {
        if (image == null) {
          if (pickedLocalImages[imageType] != '') {
            return GestureDetector(
              onTap: () {
                showCameraAndGalleryOption(
                  imageController: imageController,
                  title: hintLabel,
                );
              },
              child: Center(
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                      Radius.circular(UiUtils.borderRadiusOf50)),
                  child: Image.file(
                    File(pickedLocalImages[imageType]!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }

          if (oldImage.isNotEmpty) {
            return GestureDetector(
                onTap: () {
                  showCameraAndGalleryOption(
                    imageController: imageController,
                    title: hintLabel,
                  );
                },
                child: Center(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                        Radius.circular(UiUtils.borderRadiusOf50)),
                    child: CustomCachedNetworkImage(
                      imageUrl: oldImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ));
          }

          return CustomInkWellContainer(
            onTap: () {
              showCameraAndGalleryOption(
                imageController: imageController,
                title: hintLabel,
              );
            },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomSvgPicture(
                    svgImage: AppAssets.camera,
                    color: context.colorScheme.accentColor,
                    height: 20,
                    width: 20,
                  ),
                  CustomText(
                    "logoLbl".translate(context: context),
                    color: context.colorScheme.accentColor,
                    fontSize: 12,
                  ),
                ],
              ),
            ),
          );
        }

        pickedLocalImages[imageType] = image?.path;

        return GestureDetector(
            onTap: () {
              showCameraAndGalleryOption(
                imageController: imageController,
                title: hintLabel,
              );
            },
            child: Center(
              child: ClipRRect(
                borderRadius: const BorderRadius.all(
                    Radius.circular(UiUtils.borderRadiusOf50)),
                child: Image.file(
                  File(image.path),
                  fit: BoxFit.cover,
                ),
              ),
            ));
      },
    );
  }

  Widget imagePicker({
    required PickImage imageController,
    required String oldImage,
    required String hintLabel,
    required String imageType,
    double? width,
    required void Function(String newImagePath) onImagePicked,
  }) {
    return imageController.ListenImageChange(
      (BuildContext context, image) {
        if (image == null) {
          if (pickedLocalImages[imageType] != '') {
            return GestureDetector(
              onTap: () {
                showCameraAndGalleryOption(
                  imageController: imageController,
                  title: hintLabel,
                ).then((_) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    onImagePicked(pickedLocalImages[imageType]!);
                  });
                });
              },
              child: CustomContainer(
                color: context.colorScheme.accentColor.withAlpha(20),
                borderRadius: UiUtils.borderRadiusOf10,
                height: 100,
                width: (width ?? MediaQuery.sizeOf(context).width) - 5.0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                      Radius.circular(UiUtils.borderRadiusOf10)),
                  child: Image.file(
                    File(pickedLocalImages[imageType]!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }

          if (oldImage.isNotEmpty) {
            return GestureDetector(
              onTap: () {
                showCameraAndGalleryOption(
                  imageController: imageController,
                  title: hintLabel,
                ).then((_) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    onImagePicked(pickedLocalImages[imageType]!);
                  });
                });
              },
              child: Stack(
                children: [
                  CustomContainer(
                    borderRadius: UiUtils.borderRadiusOf10,
                    height: 100,
                    width: (width ?? MediaQuery.sizeOf(context).width) - 5.0,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(
                          Radius.circular(UiUtils.borderRadiusOf10)),
                      child: CustomCachedNetworkImage(
                        imageUrl: oldImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  CustomContainer(
                    borderRadius: UiUtils.borderRadiusOf10,
                    color: context.colorScheme.lightGreyColor.withAlpha(40),
                    height: 100,
                    width: (width ?? MediaQuery.sizeOf(context).width) - 5.0,
                    child: Center(
                      child: CustomSvgPicture(
                        svgImage: AppAssets.edit,
                        color: AppColors.whiteColors,
                        height: 25,
                        width: 25,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return CustomInkWellContainer(
            onTap: () {
              showCameraAndGalleryOption(
                imageController: imageController,
                title: hintLabel,
              ).then((_) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  onImagePicked(pickedLocalImages[imageType]!);
                });
              });
            },
            child: CustomContainer(
              borderRadius: UiUtils.borderRadiusOf10,
              color: context.colorScheme.accentColor.withAlpha(20),
              height: 100,
              width: (width ?? MediaQuery.sizeOf(context).width) - 5.0,
              child: Center(
                child: CustomSvgPicture(
                  svgImage: AppAssets.addCircle,
                  color: context.colorScheme.accentColor,
                  height: 50,
                  width: 50,
                ),
              ),
            ),
          );
        }

        pickedLocalImages[imageType] = image?.path;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onImagePicked(image!.path);
        });

        return GestureDetector(
          onTap: () {
            showCameraAndGalleryOption(
              imageController: imageController,
              title: hintLabel,
            ).then((_) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onImagePicked(image.path);
              });
            });
          },
          child: CustomContainer(
            borderRadius: UiUtils.borderRadiusOf10,
            height: 100,
            width: (width ?? MediaQuery.sizeOf(context).width) - 5.0,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(
                  Radius.circular(UiUtils.borderRadiusOf10)),
              child: Image.file(
                File(image.path),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildDropDown(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
    required String initialValue,
    String? value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          title,
          color: Theme.of(context).colorScheme.blackColor,
          fontWeight: FontWeight.w400,
        ),
        const CustomSizedBox(
          height: 10,
        ),
        CustomFormDropdown(
          onTap: () {
            onTap.call();
          },
          initialTitle: initialValue,
          selectedValue: value,
          validator: (String? p0) {
            return Validator.nullCheck(context, p0);
          },
        ),
      ],
    );
  }

  Future showCameraAndGalleryOption({
    required PickImage imageController,
    required String title,
  }) {
    return UiUtils.showModelBottomSheets(
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      context: context,
      child: ShowImagePickerOptionBottomSheet(
        title: title,
        onCameraButtonClick: () {
          imageController.pick(source: ImageSource.camera);
        },
        onGalleryButtonClick: () {
          imageController.pick(source: ImageSource.gallery);
        },
      ),
    );
  }

  Future<void> selectCompanyTypes() async {
    final List<Map<String, dynamic>> itemList = [
      {
        'title': 'Individual'.translate(context: context),
        'id': '0',
        "isSelected": selectCompanyType?['value'] == "0"
      },
      {
        'title': 'Organisation'.translate(context: context),
        'id': '1',
        "isSelected": selectCompanyType?['value'] == "1"
      }
    ];
    UiUtils.showModelBottomSheets(
      context: context,
      child: SelectableListBottomSheet(
          bottomSheetTitle: "selectType", itemList: itemList),
    ).then((value) {
      if (value != null) {
        selectCompanyType = {
          'title': value["selectedItemName"],
          'value': value["selectedItemId"]
        };

        if (value?['selectedItemName'] == 'Individual') {
          numberOfMemberController.text = '1';
          isIndividualType = true;
        } else {
          isIndividualType = false;
        }
        setState(() {
          pickedLocalImages = pickedLocalImages;
        });
      }
    });
  }
}
