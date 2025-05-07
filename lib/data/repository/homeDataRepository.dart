import 'package:edemand_partner/data/model/home/homeDataModel.dart';

import '../../app/generalImports.dart';

class HomeDataRepository {
  Future<HomeDataModel> fetchHomeData() async {
    try {
      final Map<String, dynamic> response =
          await Api.get(url: Api.getHomeData, useAuthToken: true);

      return HomeDataModel.fromJson(response['data']);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
