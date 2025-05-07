import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import '../app/generalImports.dart';
import 'package:vibration/vibration.dart';

class UiUtils {
  //key for Global navigation
  static GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static GlobalKey<MainActivityState> bottomNavigationBarGlobalKey =
      GlobalKey<MainActivityState>();
  static GlobalKey<MainActivityState> mainActivityNavigationBarGlobalKey =
      GlobalKey<MainActivityState>();

  static int animationDuration = 1; //value is in seconds

  //Price formats
  static String? systemCurrency;
  static String? systemCurrencyCountryCode;
  static String? decimalPointsForPrice;

  static int resendOTPCountDownTime = 30; //in seconds

  static int limit = 10;

  static double maxHeadingValue = 120;

  static double maxHeadingTitelSizeValue = 22;
  //
  /// Toast message display duration
  static const int messageDisplayDuration = 3000;

  ///space from bottom for buttons
  static const double bottomButtonSpacing = 56;

  ///required days to create PromoCode
  static const int noOfDaysAllowToCreatePromoCode = 365;

  static const int minimumMobileNumberDigit = 6;
  static const int maximumMobileNumberDigit = 15;

  static Locale getLocaleFromLanguageCode(String languageCode) {
    final List<String> result = languageCode.split('-');
    return result.length == 1
        ? Locale(result.first)
        : Locale(result.first, result.last);
  }

  static Future<void> getVibrationEffect() async {
    if (await Vibration.hasVibrator()) {
      await Vibration.vibrate(duration: 100);
    }
  }

  //border radius
  static const double borderRadiusOf5 = 5;
  static const double borderRadiusOf6 = 6;
  static const double borderRadiusOf10 = 10;
  static const double borderRadiusOf15 = 15;
  static const double borderRadiusOf20 = 20;
  static const double borderRadiusOf50 = 50;

//chat message sending related controls
  static int? maxFilesOrImagesInOneMessage;
  static int?
      maxFileSizeInMBCanBeSent; //1000000 = 1 MB (default is 10000000 = 10 MB)
  static int? maxCharactersInATextMessage;

  static Future<dynamic> showModelBottomSheets({
    required BuildContext context,
    required Widget child,
    Color? backgroundColor,
    bool? enableDrag,
    bool? useSafeArea,
    bool? isScrollControlled,
    BoxConstraints? constraints,
  }) async {
    final result = await showModalBottomSheet(
      enableDrag: enableDrag ?? false,
      isScrollControlled: isScrollControlled ?? true,
      useSafeArea: useSafeArea ?? false,
      backgroundColor: Theme.of(context).colorScheme.secondaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadiusOf20),
          topRight: Radius.circular(borderRadiusOf20),
        ),
      ),
      context: context,
      builder: (final _) {
        //using backdropFilter to blur the background screen
        //while bottomSheet is open
        return BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 1, sigmaY: 1), child: child);
      },
    );

    return result;
  }

  static void removeFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // Only numbers can be entered
  static List<TextInputFormatter> allowOnlyDigits() {
    return <TextInputFormatter>[
      FilteringTextInputFormatter.digitsOnly,
    ];
  }

  static SystemUiOverlayStyle getSystemUiOverlayStyle(
      {required BuildContext context, Color? statusBarColor}) {
    return SystemUiOverlayStyle(
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarColor: Theme.of(context).colorScheme.primaryColor,
      systemNavigationBarIconBrightness:
          context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
              ? Brightness.light
              : Brightness.dark,
      //
      statusBarColor:
          statusBarColor ?? Theme.of(context).colorScheme.primaryColor,
      statusBarIconBrightness:
          context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
              ? Brightness.light
              : Brightness.dark,
    );
  }

  static dynamic showDemoModeWarning({required BuildContext context}) {
    return showMessage(
      context,
      'demoModeWarning'.translate(context: context),
      ToastificationType.warning,
    );
  }

  static void showMessage(
    BuildContext context,
    String message,
    ToastificationType type, {
    VoidCallback? onMessageClosed,
  }) {
    toastification
      ..dismissAll()
      ..show(
        context: context,
        type: type,
        style: ToastificationStyle.fillColored,
        autoCloseDuration: const Duration(seconds: 3),
        title: Text(
          message,
          maxLines: 100,
          softWrap: true,
          overflow: TextOverflow.visible,
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
        alignment: Alignment.bottomCenter,
        direction: ui.TextDirection.ltr,
        animationDuration: const Duration(milliseconds: 300),
        icon: const Icon(Icons.check),
        showIcon: true,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 16,
            offset: Offset(0, 16),
          ),
        ],
        showProgressBar: false,
        closeButton:
            const ToastCloseButton(showType: CloseButtonShowType.always),
        // closeButtonShowType: CloseButtonShowType.always,
        closeOnClick: false,
        pauseOnHover: false,
        dragToClose: true,
        applyBlurEffect: true,
      );

    // Trigger the callback after the duration (if provided)
    if (onMessageClosed != null) {
      Future.delayed(const Duration(seconds: 3), onMessageClosed);
    }
  }

  static Color getPaymentStatusColor({required String paymentStatus}) {
    switch (paymentStatus) {
      case "pending":
        return AppColors.pendingPaymentStatusColor;
      case "failed":
        return AppColors.failedPaymentStatusColor;
      case "success":
        return AppColors.successPaymentStatusColor;
      case "1":
        return AppColors.successPaymentStatusColor;
      case "2":
        return AppColors.failedPaymentStatusColor;
      case "0":
        return AppColors.pendingPaymentStatusColor;
      default:
        return AppColors.pendingPaymentStatusColor;
    }
  }

  static Future<Object?> showAnimatedDialog(
      {required BuildContext context, required Widget child}) async {
    final result = await showGeneralDialog(
      context: context,
      pageBuilder: (final context, final animation, final secondaryAnimation) =>
          const CustomContainer(),
      transitionBuilder: (final context, final animation,
              final secondaryAnimation, Widget _) =>
          Transform.scale(
        scale: Curves.easeInOut.transform(animation.value),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: child,
          ),
        ),
      ),
    );
    return result;
  }

  static double inRange({
    required double currentValue,
    required double minValue,
    required double maxValue,
    required double newMaxValue,
    required double newMinValue,
  }) {
    double converatedValue = 0.0;
    converatedValue = (currentValue - minValue) /
            (maxValue - minValue) *
            (newMaxValue - newMinValue) +
        newMinValue;
    return converatedValue;
  }

  static Widget getBackArrow(BuildContext context, {VoidCallback? onTap}) {
    return CustomInkWellContainer(
      onTap: () {
        if (onTap != null) {
          onTap.call();
        } else {
          Navigator.pop(context);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: CustomSvgPicture(
            width: 50,
            height: 20,
            svgImage:
                // context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                Directionality.of(context)
                        .toString()
                        .contains(TextDirection.RTL.value.toLowerCase())
                    ? AppAssets.arrowNext
                    : AppAssets.backArrowLight,
            color: context.colorScheme.accentColor,
          ),
        ),
      ),
    );
  }

  static AppBar getSimpleAppBar(
          {required final BuildContext context,
          final String? title,
          final Widget? titleWidget,
          final Color? backgroundColor,
          final bool? centerTitle,
          final bool? isLeadingIconEnable,
          final double? elevation,
          final List<Widget>? actions,
          final FontWeight? fontWeight,
          final double? fontSize,
          final PreferredSize? bottom,
          final VoidCallback? onTap,
          Color? statusBarColor}) =>
      AppBar(
        leadingWidth: isLeadingIconEnable ?? true ? null : 0,
        surfaceTintColor: context.colorScheme.secondaryColor,
        systemOverlayStyle: UiUtils.getSystemUiOverlayStyle(
            context: context, statusBarColor: statusBarColor),
        leading: isLeadingIconEnable ?? true
            ? getBackArrow(context, onTap: onTap)
            : const CustomSizedBox(),
        title: title != null
            ? CustomText(
                title,
                color: context.colorScheme.blackColor,
                fontWeight: fontWeight ?? FontWeight.w500,
                fontSize: fontSize ?? 16,
              )
            : titleWidget,
        centerTitle: centerTitle ?? false,
        elevation: elevation ?? 0.0,
        backgroundColor: backgroundColor ?? context.colorScheme.secondaryColor,
        actions: actions ?? [],
        bottom: bottom,
      );

  static Color getStatusColor(
      {required final BuildContext context, required final String statusVal}) {
    switch (statusVal) {
      case "awaiting":
        // return AppColors.awaitingOrderColor;
        return context.colorScheme.blackColor;
      case "pending":
        return AppColors.rescheduledOrderColor;
      case "confirmed" || "approved":
        return AppColors.confirmedOrderColor;
      case "started":
        return AppColors.startedOrderColor;
      case "rescheduled" || "settled": //Rescheduled
        return AppColors.rescheduledOrderColor;
      case "cancelled" || "cancel" || "rejected": //Cancelled
        return AppColors.cancelledOrderColor;
      case "completed":
        return AppColors.completedOrderColor;
      case "booked":
        return AppColors.completedOrderColor;
      case "ended" || "booking_ended":
        return AppColors.startedOrderColor;
      default:
        return AppColors.redColor;
    }
  }

 
  static String formatTimeWithDateTime(
    DateTime dateTime,
  ) {
    if (dateAndTimeSetting["use24HourFormat"]) {
      return DateFormat("kk:mm").format(dateTime);
    } else {
      return DateFormat("hh:mm a").format(dateTime);
    }
  }

  static Future<void> downloadOrShareFile({
    required String url,
    String? customFileName,
    required bool isDownload,
  }) async {
    try {
      String downloadFilePath = isDownload
          ? (await getApplicationDocumentsDirectory()).path
          : (await getTemporaryDirectory()).path;
      downloadFilePath =
          "$downloadFilePath/${customFileName != null ? customFileName : DateTime.now().toIso8601String()}";

      if (await File(downloadFilePath).exists()) {
        if (isDownload) {
          OpenFilex.open(downloadFilePath);
        } else {
          Share.shareXFiles([XFile(downloadFilePath)]);
        }
        return;
      }

      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();
      final bytes = await consolidateHttpClientResponseBytes(response);

      await File(downloadFilePath).writeAsBytes(
        bytes,
        flush: !isDownload,
      );
      if (isDownload) {
        OpenFilex.open(downloadFilePath);
      } else {
        Share.shareXFiles([XFile(downloadFilePath)]);
      }
    } catch (_) {}
  }

//add  gradient color to show in the chart on home screen
  static List<LinearGradient> gradientColorForBarChart = [
    LinearGradient(
      colors: [Colors.green.shade300, Colors.green],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Colors.blue.shade300, Colors.blue],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Colors.purple.shade300, Colors.purple],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];

  static List<String> chatPredefineMessagesForProvider = [
    "chatPreDefineMessageForCustomer1",
    "chatPreDefineMessageForCustomer2",
    "chatPreDefineMessageForCustomer3",
    "chatPreDefineMessageForCustomer4",
    "chatPreDefineMessageForCustomer5",
    "chatPreDefineMessageForCustomer6",
  ];
  static List<String> chatPredefineMessagesForAdmin = [
    "chatPreDefineMessageForAdmin1",
    "chatPreDefineMessageForAdmin2",
    "chatPreDefineMessageForAdmin3",
    "chatPreDefineMessageForAdmin4",
    "chatPreDefineMessageForAdmin5",
    "chatPreDefineMessageForAdmin6",
  ];
}

//scroll controller extension
extension ScrollEndListen on ScrollController {
  ///It will check if scroll is at the bottom or not
  bool isEndReached() {
    return offset >= position.maxScrollExtent;
  }
}
