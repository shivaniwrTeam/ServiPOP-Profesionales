import '../../app/generalImports.dart';

abstract class SendVerificationCodeState {}

class SendVerificationCodeInitialState extends SendVerificationCodeState {}

class SendVerificationCodeInProgressState extends SendVerificationCodeState {}

class SendVerificationCodeSuccessState extends SendVerificationCodeState {
  String authenticationMode;

  SendVerificationCodeSuccessState({required this.authenticationMode});
}

class SendVerificationCodeFailureState extends SendVerificationCodeState {
  SendVerificationCodeFailureState(this.error);

  final dynamic error;
}

class SendVerificationCodeCubit extends Cubit<SendVerificationCodeState> {
  SendVerificationCodeCubit() : super(SendVerificationCodeInitialState());
  final AuthRepository authRepo = AuthRepository();

  Future<void> sendVerificationCodeUsingFirebase({
    required final String phoneNumber,
    required final String phoneNumberWithCountryCode,
    required final String countryCode,
  }) async {
    try {
      emit(SendVerificationCodeInProgressState());

      await authRepo.verifyPhoneNumber(
        phoneNumber,
        onError: (error) {
          emit(SendVerificationCodeFailureState(error));
        },
        onCodeSent: () {
          emit(SendVerificationCodeSuccessState(
            authenticationMode: "firebase",
          ));
        },
      );
    } on FirebaseAuthException catch (error) {
      emit(SendVerificationCodeFailureState(error.code.getFirebaseError()));
    }
  }

  Future<void> sendVerificationCodeUsingSMSGateway({
    required final String phoneNumberWithoutCountryCode,
    required final String phoneNumberWithCountryCode,
    required final String countryCode,
  }) async {
    try {
      emit(SendVerificationCodeInProgressState());

      final Map<String, dynamic> response = await authRepo.sendVerificationCodeUsingSMSGateway(
        phoneNumberWithoutCountryCode: phoneNumberWithoutCountryCode,
        countryCode: countryCode,
      );

      if (response['error']) {
        emit(SendVerificationCodeFailureState(response['message']));
      } else {
        emit(SendVerificationCodeSuccessState(
          authenticationMode: "sms_gateway",
        ));
      }
    } catch (error) {
      emit(SendVerificationCodeFailureState(error));
    }
  }

  void setInitialState() {
    if (state is SendVerificationCodeSuccessState) {
      emit(SendVerificationCodeInitialState());
    }
  }
}
