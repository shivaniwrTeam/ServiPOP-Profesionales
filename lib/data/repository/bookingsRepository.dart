import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

import '../../app/generalImports.dart';

class BookingsRepository {
  //
  Future<DataOutput<BookingsModel>> fetchBooking(
      {required int offset,
      required String? status,
      String? customRequestOrder,
      String? fetchBothBookings}) async {
    try {
      final Map<String, dynamic> response = await Api.post(
        url: Api.getBookings,
        parameter: {
          Api.limit: UiUtils.limit,
          Api.offset: offset,
          Api.status: status,
          Api.order: 'DESC',
          Api.customRequestOrders: customRequestOrder,
          Api.fetchBothBookings: fetchBothBookings
        },
        useAuthToken: true,
      );
      List<BookingsModel> modelList;
      if (response['data'].isEmpty) {
        modelList = [];
      } else {
        modelList = (response['data']['data'] as List).map((element) {
          return BookingsModel.fromJson(element);
        }).toList();
      }

      return DataOutput<BookingsModel>(
        total: int.parse(response['total'] ?? '0'),
        modelList: modelList,
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> updateBookingStatus({
    required int orderId,
    required int customerId,
    required String status,
    required String otp,
    List<Map<String, dynamic>>? proofData,
    List<Map<String, dynamic>>? additionalCharges,
    String? date,
    String? time,
  }) async {
    try {
      final Map<String, dynamic> parameters = {
        'order_id': orderId,
        'customer_id': customerId,
        'status': status
      };
      if (date != null && time != null) {
        parameters['date'] = date;
        parameters['time'] = time;
      }

      if (otp != '' && status == 'completed') {
        parameters['otp'] = otp;
      }

      if (proofData != null) {
        final List list = [];
        for (int i = 0; i < proofData.length; i++) {
          final element = proofData[i]['file'];

          final MultipartFile imagePart = await MultipartFile.fromFile(
            element.path,
            filename: p.basename(element.path),
            contentType: MediaType('image', proofData[i]['fileType']),
          );
          list.add(imagePart);
          if (status == 'started') {
            parameters['work_started_files[$i]'] = imagePart;
          } else {
            parameters['work_complete_files[$i]'] = imagePart;
          }
        }
      }
      if (additionalCharges != null) {
        for (int i = 0; i < additionalCharges.length; i++) {
          parameters['additional_charges[$i][name]'] =
              additionalCharges[i]['name'];
          parameters['additional_charges[$i][charge]'] =
              additionalCharges[i]['charge'];
        }
      }

      final Map<String, dynamic> response = await Api.post(
          url: Api.updateBookingStatus,
          parameter: parameters,
          useAuthToken: true);

      return {
        'error': response['error'],
        'message': response['message'],
        'data': response['data']
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<DataOutput<TimeSlotModel>> getAllTimeSlots(String date) async {
    try {
      final Map<String, dynamic> response = await Api.post(
        url: Api.getAvailableSlots,
        parameter: {Api.date: date},
        useAuthToken: true,
      );

      final List<TimeSlotModel> timeSlotList =
          (response['data']['all_slots'] as List).map((element) {
        return TimeSlotModel.fromMap(element);
      }).toList();

      return DataOutput<TimeSlotModel>(
        total: 0,
        modelList: timeSlotList,
        extraData: ExtraData(
          data: {
            'error': response['error'],
            'message': response['message'],
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}
