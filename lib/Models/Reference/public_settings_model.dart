import 'package:pwt_website/Models/Reference/social_links_model.dart';
import 'package:pwt_website/Models/Reference/settings_location_model.dart';

class PublicSettingsModel {

  final List<String>? supportedLocales;

  final String? defaultLocale;

  final String? phoneNumber;

  final String? whatsappNumber;

  final String? contactEmail;

  final SettingsLocationModel? location;

  final SocialLinksModel? socialLinks;

  final String? supportHours;

  final Map<String, dynamic>? currenciesByCountry;

  final Map<String, dynamic>? vatRatesByCountry;

  PublicSettingsModel({

    this.supportedLocales,

    this.defaultLocale,

    this.phoneNumber,

    this.whatsappNumber,

    this.contactEmail,

    this.location,

    this.socialLinks,

    this.supportHours,

    this.currenciesByCountry,

    this.vatRatesByCountry,
  });

  factory PublicSettingsModel.fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return PublicSettingsModel();
    }

    return PublicSettingsModel(

      supportedLocales:
      json['supported_locales'] != null

          ? List<String>.from(
        json['supported_locales'],
      )

          : null,

      defaultLocale:
      json['default_locale'],

      phoneNumber:
      json['phone_number'],

      whatsappNumber:
      json['whatsapp_number'],

      contactEmail:
      json['contact_email'],

      location:
      json['location'] != null
          ? SettingsLocationModel.fromJson(json['location'])
          : null,

      socialLinks:
      json['social_links'] != null

          ? SocialLinksModel.fromJson(
        json['social_links'],
      )

          : null,

      supportHours:
      json['support_hours'],

      currenciesByCountry:
      json['currencies_by_country'] != null

          ? Map<String, dynamic>.from(
        json['currencies_by_country'],
      )

          : null,

      vatRatesByCountry:
      json['vat_rates_by_country'] != null

          ? Map<String, dynamic>.from(
        json['vat_rates_by_country'],
      )

          : null,
    );
  }

  Map<String, dynamic> toJson() {

    return {

      'supported_locales':
      supportedLocales,

      'default_locale':
      defaultLocale,

      'phone_number':
      phoneNumber,

      'whatsapp_number':
      whatsappNumber,

      'contact_email':
      contactEmail,

      'location':
      location?.toJson(),

      'social_links':
      socialLinks?.toJson(),

      'support_hours':
      supportHours,

      'currencies_by_country':
      currenciesByCountry,

      'vat_rates_by_country':
      vatRatesByCountry,
    };
  }
}