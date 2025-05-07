import 'package:edemand_partner/app/generalImports.dart';
import 'package:flutter/material.dart';

class CustomRadioOptionsWidget extends StatelessWidget {
  final String image;
  final String title;
  final String subTitle;
  final String value;
  final String groupValue;
  final bool isFirst;
  final bool isLast;
  final Function(Object?)? onChanged;
  final bool? applyAccentColor;

  const CustomRadioOptionsWidget({
    super.key,
    required this.image,
    required this.title,
    required this.subTitle,
    required this.value,
    required this.groupValue,
    this.onChanged,
    required this.isFirst,
    required this.isLast,
    this.applyAccentColor = true,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile(
      enableFeedback: true,
      controlAffinity: ListTileControlAffinity.trailing,
      visualDensity: VisualDensity.compact,
      tileColor: context.colorScheme.secondaryColor,
      isThreeLine: false,contentPadding: EdgeInsets.zero,
      shape: isFirst
          ? const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(UiUtils.borderRadiusOf10),
                  topRight: Radius.circular(UiUtils.borderRadiusOf10)))
          : isLast
              ? const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(UiUtils.borderRadiusOf10),
                      bottomRight: Radius.circular(UiUtils.borderRadiusOf10)))
              : null,
      secondary: CustomSizedBox(
        height: 25,
        width: 25,
        child: CustomSvgPicture(
          svgImage:image,
          color: applyAccentColor! ? context.colorScheme.accentColor : null,
        ),
      ),
      title: CustomText(title.translate(context: context), fontSize: 14),
      subtitle: CustomText(
        subTitle.translate(context: context),
        fontSize: 12,
        maxLines: 1,
      ),
      value: value,
      activeColor: context.colorScheme.accentColor,
      groupValue: groupValue,
      onChanged: (final Object? selectedValue) {
        onChanged?.call(selectedValue);
      },
    );
  }
}
