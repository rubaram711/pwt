import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';
import '../../Models/Rfq/rfq_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';
import '../../const/urls.dart';

Future<ApiResponse<RfqModel>> createRfq({
  required String companyName,
  String? email,
  String? phoneCountryCode,
  String? phone,
  String? contactName,
  String? jobTitle,
  String? businessEmail,
  // String? tradeLicenseFileId, // commented out — not collected yet
  List<int>? preferredProducts,
  String? totalQuantity,
  String? requiredBy,
  String? installationLocation,
  String? notes,
}) async {
  final dio.Dio di = AppState.instance.dioService.dio;
print('objectrfqrfqrfq444444444444');
  return ApiHandler.handleRequest<RfqModel>(
    request: () => di.post(
      kRfqUrl,
      data: {
        'company_name': companyName,
        if (email != null && email.isNotEmpty) 'email': email,
        if (phoneCountryCode != null && phoneCountryCode.isNotEmpty) 'phone_country_code': phoneCountryCode,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (contactName != null && contactName.isNotEmpty) 'contact_name': contactName,
        if (jobTitle != null && jobTitle.isNotEmpty) 'job_title': jobTitle,
        if (businessEmail != null && businessEmail.isNotEmpty) 'business_email': businessEmail,
        if (preferredProducts != null && preferredProducts.isNotEmpty) 'preferred_products': preferredProducts,
        if (totalQuantity != null && totalQuantity.isNotEmpty) 'total_quantity': totalQuantity,
        if (requiredBy != null && requiredBy.isNotEmpty) 'required_by': requiredBy,
        if (installationLocation != null && installationLocation.isNotEmpty) 'installation_location': installationLocation,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    ),
    parser: (data) => RfqModel.fromJson(data),
  );
}
