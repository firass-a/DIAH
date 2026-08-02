import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/enums/app_enums.dart';

enum AppLocale { ar, fr, en }

class LocaleNotifier extends Notifier<AppLocale> {
  @override
  /// Default English so first launch is readable without choosing Arabic first.
  AppLocale build() => AppLocale.en;

  void setLocale(AppLocale locale) => state = locale;
}

final localeProvider = NotifierProvider<LocaleNotifier, AppLocale>(
  LocaleNotifier.new,
);

class AppStrings {
  AppStrings(this.locale);

  final AppLocale locale;

  bool get isAr => locale == AppLocale.ar;
  bool get isFr => locale == AppLocale.fr;
  bool get isEn => locale == AppLocale.en;

  String t(String ar, String fr, String en) {
    switch (locale) {
      case AppLocale.ar:
        return ar;
      case AppLocale.fr:
        return fr;
      case AppLocale.en:
        return en;
    }
  }

  String get appName => 'Diah';
  String get tagline =>
      t('أناقتك تبدأ من هنا', 'Votre élégance commence ici', 'Your elegance starts here');
  String get login => t('تسجيل الدخول', 'Connexion', 'Log in');
  String get register => t('إنشاء حساب', 'Créer un compte', 'Create account');
  String get guest => t('تصفح كزائر', 'Continuer en invité', 'Browse as guest');
  String get phone => t('رقم الهاتف', 'Téléphone', 'Phone');
  String get password => t('كلمة المرور', 'Mot de passe', 'Password');
  String get fullName => t('الاسم الكامل', 'Nom complet', 'Full name');
  String get forgotPassword =>
      t('نسيت كلمة المرور؟', 'Mot de passe oublié ?', 'Forgot password?');
  String get home => t('الرئيسية', 'Accueil', 'Home');
  String get search => t('بحث', 'Recherche', 'Search');
  String get favorites => t('المفضلة', 'Favoris', 'Favorites');
  String get profile => t('حسابي', 'Profil', 'Profile');
  String get notifications => t('الإشعارات', 'Notifications', 'Notifications');
  String get settings => t('الإعدادات', 'Paramètres', 'Settings');
  String get bookNow => t('احجزي الآن', 'Réserver', 'Book now');
  String get featured => t('مميز', 'Sélection', 'Featured');
  String get trending => t('الأكثر طلباً', 'Tendances', 'Trending');
  String get recent => t('أضيف حديثاً', 'Nouveautés', 'Just added');
  String get nearbyStores => t('محلات قريبة', 'Boutiques proches', 'Nearby stores');
  String get categories => t('التصنيفات', 'Catégories', 'Categories');
  String get wedding => t('فساتين أعراس', 'Mariage', 'Wedding');
  String get evening => t('فساتين سهرات', 'Soirée', 'Evening');
  String get traditional => t('تقليدية', 'Traditionnel', 'Traditional');
  String get accessories => t('إكسسوارات', 'Accessoires', 'Accessories');
  String get pricePerDay => t('لليوم', '/jour', '/day');
  String get deposit => t('العربون', 'Caution', 'Deposit');
  String get reviews => t('التقييمات', 'Avis', 'Reviews');
  String get availability => t('التوفر', 'Disponibilité', 'Availability');
  String get filters => t('فلاتر', 'Filtres', 'Filters');
  String get apply => t('تطبيق', 'Appliquer', 'Apply');
  String get reset => t('إعادة تعيين', 'Réinitialiser', 'Reset');
  String get logout => t('تسجيل الخروج', 'Déconnexion', 'Log out');
  String get editProfile => t('تعديل الملف', 'Modifier le profil', 'Edit profile');
  String get myBookings => t('حجوزاتي', 'Mes réservations', 'My bookings');
  String get myTransactions => t('معاملاتي', 'Transactions', 'Transactions');
  String get addresses => t('العناوين', 'Adresses', 'Addresses');
  String get becomeOwner => t('أريد تأجير فساتيني', 'Louer mes robes', 'Rent out my dresses');
  String get createStore => t(
        'أريد إنشاء محل كراء',
        'Créer ma boutique de location',
        'I want to create my rental store',
      );
  String get ownerDashboard => t('لوحة المؤجرة', 'Espace loueuse', 'Owner dashboard');
  String get storeDashboard => t('لوحة المحل', 'Espace boutique', 'Store dashboard');
  String get myDresses => t('فساتيني', 'Mes robes', 'My dresses');
  String get addDress => t('أضف فستاني', 'Ajouter une robe', 'Add a dress');
  String get rentalRequests => t('طلبات الإيجار', 'Demandes', 'Rental requests');
  String get revenue => t('الأرباح', 'Revenus', 'Revenue');
  String get statistics => t('الإحصائيات', 'Statistiques', 'Statistics');
  String get emptyFavorites =>
      t('لا توجد فساتين في المفضلة', 'Aucun favori', 'No favorites yet');
  String get emptyBookings =>
      t('لا توجد حجوزات', 'Aucune réservation', 'No bookings yet');
  String get emptyNotifications =>
      t('لا توجد إشعارات', 'Aucune notification', 'No notifications');
  String get continueText => t('متابعة', 'Continuer', 'Continue');
  String get confirm => t('تأكيد', 'Confirmer', 'Confirm');
  String get cancel => t('إلغاء', 'Annuler', 'Cancel');
  String get save => t('حفظ', 'Enregistrer', 'Save');
  String get delete => t('حذف', 'Supprimer', 'Delete');
  String get seeAll => t('عرض الكل', 'Voir tout', 'See all');
  String get searchHint =>
      t('ابحثي عن فستان...', 'Rechercher une robe...', 'Search for a dress...');
  String get currency => t('دج', 'DA', 'DZD');
  String get days => t('أيام', 'jours', 'days');
  String get size => t('المقاس', 'Taille', 'Size');
  String get color => t('اللون', 'Couleur', 'Color');
  String get description => t('الوصف', 'Description', 'Description');
  String get owner => t('المؤجرة', 'Loueuse', 'Owner');
  String get store => t('المحل', 'Boutique', 'Store');
  String get contract =>
      t('عقد الإيجار الإلكتروني', 'Contrat de location', 'Rental contract');
  String get acceptContract => t(
        'أوافق على شروط عقد الإيجار',
        "J'accepte le contrat",
        'I accept the rental contract',
      );
  String get payment => t('الدفع', 'Paiement', 'Payment');
  String get mockPayment => t(
        'دفع وهمي (نموذج أولي)',
        'Paiement fictif (prototype)',
        'Mock payment (prototype)',
      );
  String get bookingConfirmed =>
      t('تم تأكيد الحجز!', 'Réservation confirmée !', 'Booking confirmed!');
  String get deliveryAddress =>
      t('عنوان التوصيل', 'Adresse de livraison', 'Delivery address');
  String get bookingSummary => t('ملخص الحجز', 'Récapitulatif', 'Booking summary');
  String get total => t('المجموع', 'Total', 'Total');
  String get next => t('التالي', 'Suivant', 'Next');
  String get skip => t('تخطي', 'Passer', 'Skip');
  String get getStarted => t('ابدئي الآن', 'Commencer', 'Get started');
  String get language => t('اللغة', 'Langue', 'Language');
  String get arabic => t('العربية', 'Arabe', 'Arabic');
  String get french => t('الفرنسية', 'Français', 'French');
  String get english => t('الإنجليزية', 'Anglais', 'English');
  String get inventory => t('المخزون', 'Inventaire', 'Inventory');
  String get calendar => t('التقويم', 'Calendrier', 'Calendar');
  String get subscription => t('الاشتراك', 'Abonnement', 'Subscription');
  String get personalWardrobe =>
      t('من خزانتي الشخصية', 'Ma garde-robe', 'From my wardrobe');
  String get rentalStore =>
      t('من محل كراء', 'Boutique de location', 'From a rental store');
  String get whereRentFrom => t(
        'من أين ستؤجرين الفساتين؟',
        "D'où louerez-vous ?",
        'Where will you rent from?',
      );
  String get demoAccounts =>
      t('حسابات تجريبية', 'Comptes de démo', 'Demo accounts');
  String get loading => t('جاري التحميل...', 'Chargement...', 'Loading...');
  String get error =>
      t('حدث خطأ', 'Une erreur est survenue', 'Something went wrong');
  String get retry => t('إعادة المحاولة', 'Réessayer', 'Retry');
  String get noResults => t('لا توجد نتائج', 'Aucun résultat', 'No results');
  String get sortBy => t('ترتيب حسب', 'Trier par', 'Sort by');
  String get occasion => t('المناسبة', 'Occasion', 'Occasion');
  String get priceRange =>
      t('نطاق السعر', 'Fourchette de prix', 'Price range');
  String get otpTitle => t('رمز التحقق', 'Code OTP', 'Verification code');
  String get otpHint =>
      t('أدخلي الرمز 1234', 'Entrez le code 1234', 'Enter code 1234');
  String get verify => t('تحقق', 'Vérifier', 'Verify');
  String get loginRequired =>
      t('سجّلي الدخول للمتابعة', 'Connectez-vous pour continuer', 'Log in to continue');
  String get aboutApp => t('عن التطبيق', 'À propos', 'About');
  String get aboutBody => t(
        'منصة تأجير الأزياء في الجزائر',
        'Plateforme de location de robes en Algérie',
        'Dress rental marketplace in Algeria',
      );
  String get roleCustomer => t('زبونة', 'Cliente', 'Customer');
  String get roleOwner => t('مالكة فردية', 'Loueuse', 'Individual owner');
  String get roleStore => t('صاحبة محل', 'Gérante', 'Store owner');
  String get roleGuest => t('زائرة', 'Invitée', 'Guest');
  String get memberSince => t('عضوة منذ', 'Membre depuis', 'Member since');
  String get quickStats => t('نظرة سريعة', 'Aperçu rapide', 'Quick look');
  String get onboarding1Title =>
      t('اكتشفي أناقتك', 'Découvrez votre élégance', 'Discover your elegance');
  String get onboarding1Body => t(
        'آلاف الفساتين الفاخرة للإيجار من أفضل المحلات والمالكات',
        'Des milliers de robes de luxe à louer',
        'Thousands of luxury dresses from top stores and owners',
      );
  String get onboarding2Title =>
      t('احجزي بسهولة', 'Réservez facilement', 'Book with ease');
  String get onboarding2Body => t(
        'اختاري التاريخ، وافقي على العقد، وادفعي بأمان',
        'Choisissez la date, acceptez le contrat et payez',
        'Pick dates, accept the contract, and pay securely',
      );
  String get onboarding3Title => t(
        'حوّلي خزانتك إلى دخل',
        'Monétisez votre garde-robe',
        'Turn your wardrobe into income',
      );
  String get onboarding3Body => t(
        'أجّري فساتينك غير المستغلة واكسبي دخلاً إضافياً',
        'Louez vos robes et gagnez un revenu supplémentaire',
        'Rent unused dresses and earn extra income',
      );

  String categoryLabel(DressCategory c) {
    switch (c) {
      case DressCategory.wedding:
        return wedding;
      case DressCategory.evening:
        return evening;
      case DressCategory.traditional:
        return traditional;
      case DressCategory.accessories:
        return accessories;
    }
  }

  String formatPrice(double amount) {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
    return '$formatted $currency';
  }
}

final stringsProvider = Provider<AppStrings>((ref) {
  return AppStrings(ref.watch(localeProvider));
});

Locale localeFromApp(AppLocale app) {
  switch (app) {
    case AppLocale.ar:
      return const Locale('ar');
    case AppLocale.fr:
      return const Locale('fr');
    case AppLocale.en:
      return const Locale('en');
  }
}

TextDirection textDirectionOf(AppLocale app) {
  return app == AppLocale.ar ? TextDirection.rtl : TextDirection.ltr;
}
