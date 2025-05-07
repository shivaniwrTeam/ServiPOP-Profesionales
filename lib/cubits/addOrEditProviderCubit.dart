import '../../app/generalImports.dart';

abstract class EditProviderDetailsState {}

class EditProviderDetailsInitial extends EditProviderDetailsState {}

class EditProviderDetailsInProgress extends EditProviderDetailsState {}

class EditProviderDetailsSuccess extends EditProviderDetailsState {
  EditProviderDetailsSuccess({
    required this.isError,
    required this.message,
    required this.providerDetails,
  });
  final bool isError;
  final String message;
  final ProviderDetails providerDetails;
}

class EditProviderDetailsFailure extends EditProviderDetailsState {
  EditProviderDetailsFailure({required this.errorMessage});
  final String errorMessage;
}

class EditProviderDetailsCubit extends Cubit<EditProviderDetailsState> {
  EditProviderDetailsCubit() : super(EditProviderDetailsInitial());
  final AuthRepository _authRepository = AuthRepository();

  //
  Future<void> editProviderDetails(
      {required ProviderDetails providerDetails,}) async {
    try {
      emit(EditProviderDetailsInProgress());
      //
      final Map<String, dynamic> parameters = providerDetails.toJson();
      if (parameters['other_images'] != null &&
          parameters['other_images'].isNotEmpty) {
        for (int i = 0; i < parameters['other_images'].length; i++) {
          parameters['other_images[$i]'] =
              await MultipartFile.fromFile(parameters['other_images'][i]);
        }
      }
      parameters.remove('other_images');
      if (parameters['image'] != '' && parameters['image'] != null) {
        parameters['image'] = await MultipartFile.fromFile(parameters['image']);
      } else {
        parameters.remove('image');
      }
      if (parameters['banner_image'] != '' &&
          parameters['banner_image'] != null) {
        parameters['banner_image'] =
            await MultipartFile.fromFile(parameters['banner_image']);
      } else {
        parameters.remove('banner_image');
      }
      if (parameters['national_id'] != '' &&
          parameters['national_id'] != null) {
        parameters['national_id'] =
            await MultipartFile.fromFile(parameters['national_id']);
      } else {
        parameters.remove('national_id');
      }
      if (parameters['address_id'] != '' && parameters['address_id'] != null) {
        parameters['address_id'] =
            await MultipartFile.fromFile(parameters['address_id']);
      } else {
        parameters.remove('address_id');
      }
      if (parameters['passport'] != '' && parameters['passport'] != null) {
        parameters['passport'] =
            await MultipartFile.fromFile(parameters['passport']);
      } else {
        parameters.remove('passport');
      }

      final Map<String, dynamic> responseData =
          await _authRepository.registerProvider(
        parameters: parameters,
        isAuthTokenRequired: false,
      );
      //

      if (!responseData['error']) {
        emit(
          EditProviderDetailsSuccess(
            providerDetails: responseData['providerDetails'],
            isError: responseData['error'],
            message: responseData['message'],
          ),
        );
        return;
      }
      //
      emit(EditProviderDetailsFailure(errorMessage: responseData['message']));
    } catch (e, st) {
      emit(EditProviderDetailsFailure(errorMessage: st.toString()));
    }
  }
}
