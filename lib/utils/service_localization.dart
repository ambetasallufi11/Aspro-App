import 'package:aspro_app/l10n/app_localizations.dart';

String localizeServiceName(AppLocalizations l10n, String name) {
  switch (name) {
    case 'Wash & Fold':
      return l10n.serviceWashFold;
    case 'Dry Clean':
      return l10n.serviceDryClean;
    case 'Express':
      return l10n.serviceExpress;
    case 'Premium Care':
      return l10n.servicePremiumCare;
    default:
      return name;
  }
}

String localizeServiceDescription(AppLocalizations l10n, String description) {
  switch (description) {
    case 'Everyday laundry with gentle detergent.':
      return l10n.serviceWashFoldDesc;
    case 'Professional dry cleaning for delicates.':
      return l10n.serviceDryCleanDesc;
    case 'Priority turnaround within 8 hours.':
      return l10n.serviceExpressDesc;
    case 'Hand-finished premium garments.':
      return l10n.servicePremiumCareDesc;
    default:
      return description;
  }
}
