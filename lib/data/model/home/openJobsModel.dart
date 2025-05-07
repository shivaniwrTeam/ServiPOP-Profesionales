// class OpenJobsModel {
//   final String? id;
//   final String? userId;
//   final String? categoryId;
//   final String? serviceTitle;
//   final String? serviceShortDescription;
//   final String? minPrice;
//   final String? maxPrice;
//   final String? requestedStartDate;
//   final String? requestedStartTime;
//   final String? requestedEndDate;
//   final String? requestedEndTime;
//   final String? createdAt;
//   final String? updatedAt;
//   final String? status;
//   final String? username;
//   final String? image;
//   final String? categoryName;
//   final String? categoryImage;

//   OpenJobsModel({
//     this.id,
//     this.userId,
//     this.categoryId,
//     this.serviceTitle,
//     this.serviceShortDescription,
//     this.minPrice,
//     this.maxPrice,
//     this.requestedStartDate,
//     this.requestedStartTime,
//     this.requestedEndDate,
//     this.requestedEndTime,
//     this.createdAt,
//     this.updatedAt,
//     this.status,
//     this.username,
//     this.image,
//     this.categoryName,
//     this.categoryImage,
//   });

//   OpenJobsModel.fromJson(Map<String, dynamic> json)
//       : id = json['id'] as String?,
//         userId = json['user_id'] as String?,
//         categoryId = json['category_id'] as String?,
//         serviceTitle = json['service_title'] as String?,
//         serviceShortDescription = json['service_short_description'] as String?,
//         minPrice = json['min_price'] as String?,
//         maxPrice = json['max_price'] as String?,
//         requestedStartDate = json['requested_start_date'] as String?,
//         requestedStartTime = json['requested_start_time'] as String?,
//         requestedEndDate = json['requested_end_date'] as String?,
//         requestedEndTime = json['requested_end_time'] as String?,
//         createdAt = json['created_at'] as String?,
//         updatedAt = json['updated_at'] as String?,
//         status = json['status'] as String?,
//         username = json['username'] as String?,
//         image = json['image'] as String?,
//         categoryName = json['category_name'] as String?,
//         categoryImage = json['category_image'] as String?;

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'user_id': userId,
//         'category_id': categoryId,
//         'service_title': serviceTitle,
//         'service_short_description': serviceShortDescription,
//         'min_price': minPrice,
//         'max_price': maxPrice,
//         'requested_start_date': requestedStartDate,
//         'requested_start_time': requestedStartTime,
//         'requested_end_date': requestedEndDate,
//         'requested_end_time': requestedEndTime,
//         'created_at': createdAt,
//         'updated_at': updatedAt,
//         'status': status,
//         'username': username,
//         'image': image,
//         'category_name': categoryName,
//         'category_image': categoryImage
//       };
// }
