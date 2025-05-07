import 'package:edemand_partner/app/generalImports.dart';


class CustomCachedNetworkImage extends StatelessWidget {
  const CustomCachedNetworkImage({
    required this.imageUrl,
    final Key? key,
    this.width,
    this.height,
    this.fit,
    this.isFile,
  }) : super(key: key);
  final String imageUrl;
  final double? width, height;
  final BoxFit? fit;
  final bool? isFile;

  @override
  Widget build(final BuildContext context) {
    return imageUrl.endsWith('.svg')
        ? SvgPicture.network(
            imageUrl,
            fit: fit ?? BoxFit.fill,
            width: width,
            height: height,
            colorFilter: ColorFilter.mode(
                context.colorScheme.accentColor, BlendMode.srcIn),
            placeholderBuilder: (final BuildContext context) => Center(
              child: CustomSvgPicture(
                svgImage: AppAssets.placeholder,
                width: width,
                height: height,
                boxFit: BoxFit.contain,
              ),
            ),
          )
        : CachedNetworkImage(
            imageUrl: imageUrl,
            imageBuilder: (context, imageProvider) {
              return CustomContainer(
                image: DecorationImage(
                  image: imageProvider,
                  fit: fit ?? BoxFit.contain,
                ),
              );
            },
            maxWidthDiskCache: 500,
            maxHeightDiskCache: 500,
            memCacheWidth: 150,
            memCacheHeight: 150,
            width: width,
            height: height,
            fit: fit ?? BoxFit.contain,
            errorWidget: (BuildContext context, String url, final error) =>
                Center(
              child: Center(
                child: CustomSvgPicture(
                  svgImage: AppAssets.noImageFound,
                  width: width,
                  height: height,
                  boxFit: BoxFit.contain,
                ),
              ),
            ),
            placeholder: (final BuildContext context, final String url) =>
                Center(
              child: CustomSvgPicture(
                svgImage: AppAssets.placeholder,
                width: width,
                height: height,
                boxFit: BoxFit.cover,
              ),
            ),
          );
  }
}
