import 'package:flutter/material.dart';

import '../../../app/generalImports.dart';

class ProviderRegistration extends StatefulWidget {
  const ProviderRegistration({
    super.key,
    required this.mobileNumber,
    required this.countryCode,
    required this.phoneNumberWithOutCountryCode,
  });

  final String mobileNumber;
  final String phoneNumberWithOutCountryCode;
  final String countryCode;

  @override
  ProviderRegistrationState createState() => ProviderRegistrationState();

  static Route<ProviderRegistration> route(RouteSettings routeSettings) {
    final Map<String, String> parameter =
        routeSettings.arguments as Map<String, String>;

    return CupertinoPageRoute(
      builder: (_) => BlocProvider(
        create: (BuildContext context) => RegisterProviderCubit(),
        child: ProviderRegistration(
          mobileNumber: parameter['registeredMobileNumber'].toString(),
          countryCode: parameter['countryCode'].toString(),
          phoneNumberWithOutCountryCode:
              parameter['phoneNumberWithOutCountryCode'].toString(),
        ),
      ),
    );
  }
}

class ProviderRegistrationState extends State<ProviderRegistration> {
  final GlobalKey<FormState> formKey1 = GlobalKey<FormState>();

  ScrollController scrollController = ScrollController();

  ///form1
  TextEditingController userNmController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobNoController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController companyNmController = TextEditingController();

  FocusNode userNmFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode mobNoFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();
  FocusNode companyNameFocus = FocusNode();

  @override
  void dispose() {
    userNmController.dispose();
    emailController.dispose();
    mobNoController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    companyNmController.dispose();

    userNmFocus.dispose();
    emailFocus.dispose();
    mobNoFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    companyNameFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    mobNoController.text = widget.mobileNumber;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      appBar: UiUtils.getSimpleAppBar(
          context: context,
          title: 'regFormTitle'.translate(context: context),
          elevation: 1,
          statusBarColor: context.colorScheme.secondaryColor),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(15.0),
            clipBehavior: Clip.none,
            child: Form(
              key: formKey1,
              child: Column(
                children: [
                  CustomTextFormField(
                    labelText: 'compNmLbl'.translate(context: context),
                    controller: companyNmController,
                    currentFocusNode: companyNameFocus,
                    validator: (String? companyName) =>
                        Validator.nullCheck(context, companyName),
                  ),
                  CustomTextFormField(
                    labelText: 'userNmLbl'.translate(context: context),
                    controller: userNmController,
                    currentFocusNode: userNmFocus,
                    nextFocusNode: emailFocus,
                    validator: (String? username) =>
                        Validator.nullCheck(context, username),
                  ),
                  CustomTextFormField(
                    labelText: 'emailLbl'.translate(context: context),
                    controller: emailController,
                    currentFocusNode: emailFocus,
                    nextFocusNode: mobNoFocus,
                    textInputType: TextInputType.emailAddress,
                    validator: (String? email) =>
                        Validator.validateEmail(context, email),
                  ),
                  CustomTextFormField(
                    labelText: 'mobNoLbl'.translate(context: context),
                    controller: mobNoController,
                    currentFocusNode: mobNoFocus,
                    nextFocusNode: passwordFocus,
                    textInputType: TextInputType.phone,
                    isReadOnly: true,
                  ),
                  CustomTextFormField(
                    labelText: 'passwordLbl'.translate(context: context),
                    controller: passwordController,
                    currentFocusNode: passwordFocus,
                    nextFocusNode: confirmPasswordFocus,
                    isPassword: true,
                    validator: (String? password) {
                      return Validator.nullCheck(context, password);
                    },
                  ),
                  CustomTextFormField(
                    labelText: 'confirmPasswordLbl'.translate(context: context),
                    controller: confirmPasswordController,
                    currentFocusNode: confirmPasswordFocus,
                    nextFocusNode: companyNameFocus,
                    isPassword: true,
                    validator: (String? confirmPassword) =>
                        Validator.nullCheck(context, confirmPassword),
                  ),
                  const CustomSizedBox(
                    height: 55,
                  )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 10,
                right: 15,
                left: 15,
              ),
              child: BlocConsumer<RegisterProviderCubit, RegisterProviderState>(
                listener: (BuildContext context, RegisterProviderState state) {
                  if (state is RegisterProviderSuccess) {
                    Navigator.pushReplacementNamed(
                      context,
                      Routes.successScreen,
                      arguments: {
                        'title': 'registration',
                        'message': 'doLoginAndCompleteKYC',
                        'imageName': AppAssets.registration
                      },
                    );
                  } else if (state is RegisterProviderFailure) {
                    UiUtils.showMessage(
                      context,
                      state.errorMessage.translate(context: context),
                      ToastificationType.error,
                    );
                  }
                },
                builder: (BuildContext context, RegisterProviderState state) {
                  Widget? child;
                  if (state is RegisterProviderInProgress) {
                    child = CustomCircularProgressIndicator(
                      color: AppColors.whiteColors,
                    );
                  } else if (state is RegisterProviderSuccess ||
                      state is RegisterProviderFailure) {
                    child = null;
                  }
                  return CustomRoundedButton(
                    showBorder: false,
                    buttonTitle: 'submitBtnLbl'.translate(context: context),
                    widthPercentage: 1,
                    backgroundColor: Theme.of(context).colorScheme.accentColor,
                    titleColor: AppColors.whiteColors,
                    child: child,
                    onTap: () {
                      if (state is RegisterProviderInProgress) {
                        return;
                      }
                      FocusScope.of(context).unfocus();
                      formKey1.currentState?.save();

                      if (formKey1.currentState!.validate()) {
                        if (passwordController.text.trim() !=
                            confirmPasswordController.text.trim()) {
                          UiUtils.showMessage(
                            context,
                            'confirmPasswordDoesNotMatch'
                                .translate(context: context),
                            ToastificationType.error,
                          );
                          return;
                        }

                        final Map<String, dynamic> parameter = {
                          'company_name': companyNmController.text.trim(),
                          'username': userNmController.text.trim(),
                          'password': passwordController.text.trim(),
                          'password_confirm': passwordController.text.trim(),
                          'email': emailController.text.trim(),
                          'mobile': widget.phoneNumberWithOutCountryCode,
                          'country_code': widget.countryCode,
                        };
                        context
                            .read<RegisterProviderCubit>()
                            .registerProvider(parameter: parameter);
                      }
                    },
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
