import '../../app/generalImports.dart';

class HiveRepository {
  //box-keys
  static const String userDetailBoxKey = 'userDetailsBox';

  static const String authStatusBoxKey = 'authBox';
  static String languageBoxKey = 'language';
  static String themeBoxKey = 'themeBox';

  //value-keys
  static const String tokenIdKey = 'token';
  static const String isAuthenticatedKey = 'isAuthenticated';
  static const String isUserFirstTimeKey = 'isUserFirstTime';
  static String currentLanguageKey = 'currentLanguage';
  static String currentThemeKey = 'currentTheme';
  static String resendTokenKey = 'resendToken';


  static Future<void> init() async {
    await Hive.openBox(languageBoxKey);
    await Hive.openBox(authStatusBoxKey);
    await Hive.openBox(themeBoxKey);
    await Hive.openBox(userDetailBoxKey);
    await Hive.openBox(placesBoxKey);

  }

  static AppTheme getCurrentTheme() {
    final current = Hive.box(themeBoxKey).get(currentThemeKey);

    if (current == null) {
      return AppTheme.light;
    }
    if (current == 'light') {
      return AppTheme.light;
    }
    if (current == 'dark') {
      return AppTheme.dark;
    }
    return AppTheme.light;
  }

  static void setCurrentTheme(AppTheme theme) {
    String newTheme;
    if (theme == AppTheme.light) {
      newTheme = 'light';
    } else {
      newTheme = 'dark';
    }
    Hive.box(themeBoxKey).put(HiveRepository.currentThemeKey, newTheme);
  }



  static String get getSelectedLanguageCode =>
      Hive.box(languageBoxKey).get(currentLanguageKey) ?? defaultLanguageCode;

  static set setSelectedLanguageCode(languageCode) =>
      Hive.box(languageBoxKey).put(currentLanguageKey, languageCode);

  static String get getUserToken => Hive.box(userDetailBoxKey).get(tokenIdKey) ?? "";

  static set setUserToken(value) => Hive.box(userDetailBoxKey).put(tokenIdKey, value);

  static Future<void> setUserData(Map data) async {
    await Hive.box(userDetailBoxKey).put("userDetails", data);
  }

  static ProviderDetails getProviderDetails() {
    try {
      return ProviderDetails.fromJson(
          Map.from(Hive.box(userDetailBoxKey).get("userDetails") ?? {}));
    } catch (_) {}
    return ProviderDetails();
  }


  ///--------------------------------- placeBox methods

  static String placesBoxKey = 'places';
  static String getStoredPlacesKey = 'getStoredPlaces';


  static List<Map> get getStoredPlaces {
    return ((Hive.box(placesBoxKey).get(getStoredPlacesKey) ?? []) as List)
        .map((e) => Map.from(e))
        .toList();
  }

  static set setPlaces(List<Map> enable) {
    Hive.box(placesBoxKey).put(getStoredPlacesKey, enable);
  }


  static Future<void> storePlaceInHive({
    required String placeId,
    required String placeName,
    required String latitude,
    required String longitude,
  }) async {
    //
    final List<Map> lists = HiveRepository.getStoredPlaces;

    lists.removeWhere((element) => element["placeId"] == placeId);
    lists.insert(0, {
      "name": placeName,
      "cityName": placeName,
      "placeId": placeId,
      "latitude": latitude,
      "longitude": longitude,
    });

    HiveRepository.setPlaces = lists;
  }
  ///--------------------------------- authStatusBoxKey
  static bool get isUserLoggedIn => Hive.box(authStatusBoxKey).get(isAuthenticatedKey) ?? false;

  static set setUserLoggedIn(enable) => Hive.box(authStatusBoxKey).put(isAuthenticatedKey, enable);

  static dynamic get getResendToken => Hive.box(userDetailBoxKey).get(resendTokenKey);

  static set setResendToken(enable) => Hive.box(userDetailBoxKey).put(resendTokenKey, enable);

  static bool get isUserFirstTimeInApp =>
      Hive.box(authStatusBoxKey).get(isUserFirstTimeKey) ?? true;

  static set setUserFirstTimeInApp(enable) =>
      Hive.box(authStatusBoxKey).put(isUserFirstTimeKey, enable);

  static Future<void> clearBoxValues({required String boxName}) async {
    await Hive.box(boxName).clear();
  }


}
