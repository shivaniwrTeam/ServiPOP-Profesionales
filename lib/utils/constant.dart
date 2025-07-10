import '../app/generalImports.dart';

const String appName = 'ServiPOP Profesionales';

const String baseUrl = 'https://admin.servipop.pro/partner/api/v1/';

const bool isDemoMode = false;

//add your default country code here
const String defaultCountryCode = 'ES';

//if you do not want user to select another country rather than default country,
//then make below variable true
const bool allowOnlySingleCountry = false;

const Map<String, dynamic> dateAndTimeSetting = {
  "dateFormat": "dd/MM/yyyy",
  "use24HourFormat": false,
};
//
const String defaultLanguageCode = 'es';
const String defaultLanguageName = 'Español';

const List<AppLanguage> appLanguages = [
  //Please add language code here and language name and svg image in assets/images/svg/
  AppLanguage(languageCode: 'en', languageName: 'English'),
  // AppLanguage(languageCode: 'hi', languageName: 'हिन्दी - Hindi'),
  // AppLanguage(languageCode: 'ar', languageName: 'عربى - Arabic'),
  AppLanguage(languageCode: 'es', languageName: 'Español'),
];
