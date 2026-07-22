
const String  baseUrl='https://api-staging.pwtmegatech.com/api/v1';
const String adminBaseUrl='https://api-staging.pwtmegatech.com/api/v1/admin';



///Health
const kHealthUrl='$baseUrl/health';

///Reference
const kCountriesUrl='$baseUrl/countries';
const kPublicSettingsUrl='$baseUrl/settings/public';



///Auth URLs
const kLoginUrl='$baseUrl/auth/login';
const kLoginOtpUrl='$baseUrl/auth/login-otp';
const kVerifyLoginOtpUrl='$baseUrl/auth/login-otp/verify';
const kRegisterUrl='$baseUrl/auth/register';
const kRegisterOtpUrl='$baseUrl/auth/register-otp';
const kVerifyRegisterOtpUrl='$baseUrl/auth/verify-otp';
const kLogoutUrl='$baseUrl/auth/logout';
const kSendOtpUrl='$baseUrl/auth/send-otp';
const kVerifyOtpUrl='$baseUrl/auth/verify-otp';
const kForgotPasswordUrl='$baseUrl/auth/forgot-password';
const kVerifyResetOtpUrl='$baseUrl/auth/verify-reset-otp';
const kResetPasswordUrl='$baseUrl/auth/reset-password';


///User
const kProfileUrl='$baseUrl/me';
const kAvatarUrl='$baseUrl/me/avatar';
const kPaymentCardsUrl='$baseUrl/me/payment-cards';


///Address
const kAddressesUrl='$baseUrl/me/addresses';


///Products
const kProductsUrl='$baseUrl/products';


///Categories
const kCategoriesUrl='$baseUrl/categories';


///Banners
const kBannersUrl='$baseUrl/banners';

///Promotions
const kPromotionsUrl = '$baseUrl/promotions';
const kValidatePromotionUrl =
    '$baseUrl/promotions/validate';

///Testimonials
const kTestimonialsUrl = '$baseUrl/testimonials';


///Files
const kFilesUrl = '$baseUrl/files';

///cart
const kCartUrl='$baseUrl/cart';
const kCartItemsUrl='$baseUrl/cart/items';


///Orders
const kOrdersUrl='$baseUrl/orders';


///Payments
const kPaymentsInitiateUrl='$baseUrl/payments/initiate';
const kPaymentsWebhookUrl='$baseUrl/payments/webhook';
const kPaymentsUrl='$baseUrl/payments';


///Machines
const kMachinesUrl='$baseUrl/me/machines';


///Maintenance
const kMaintenanceUrl='$baseUrl/maintenance-requests';

///Notifications
const String kNotificationsUrl = '$baseUrl/notifications';

///Support
const kSupportTicketsUrl='$baseUrl/support-tickets';


///Contact
const String kContactUrl = '$baseUrl/contact';

///RFQ
const String kRfqUrl = '$baseUrl/rfq';


///Change Language
const kChangeLanguageUrl='$baseUrl/change-language';


///Admin
const String kAdminLoginUrl = '$adminBaseUrl/auth/login';
const String kAdminLogoutUrl = '$adminBaseUrl/auth/logout';
const String kAdminProfileUrl = '$adminBaseUrl/me';
const String kAdminUsersUrl = '$adminBaseUrl/users';
const String kAdminDashboardUrl = '$adminBaseUrl/dashboard';
const String kAdminCategoriesUrl =
    '$adminBaseUrl/categories';
const String kAdminProductsUrl =
    '$adminBaseUrl/products';
const String kAdminOrdersUrl =
    '$adminBaseUrl/orders';
const String kAdminMachinesUrl =
    '$adminBaseUrl/machines';
const String kAdminMaintenanceRequestsUrl =
    '$adminBaseUrl/maintenance-requests';
const String kAdminSupportTicketsUrl =
    '$adminBaseUrl/support-tickets';
const String kAdminBannersUrl =
    '$adminBaseUrl/banners';
const String kAdminPromotionsUrl =
    '$adminBaseUrl/promotions';
const String kAdminTestimonialsUrl =
    '$adminBaseUrl/testimonials';
const String kAdminReportsSalesUrl =
    '$adminBaseUrl/reports/sales';
const String kAdminReportsOrdersUrl =
    '$adminBaseUrl/reports/orders';
const String kAdminReportsMaintenanceUrl = '$adminBaseUrl/reports/maintenance';
const String kAdminReportsCustomersUrl = '$adminBaseUrl/reports/customers';
const String kAdminReportsExportUrl = '$adminBaseUrl/reports';
const String kAdminAuditLogsUrl = '$adminBaseUrl/audit-logs';
const String kAdminNotificationTemplatesUrl = '$adminBaseUrl/notification-templates';

