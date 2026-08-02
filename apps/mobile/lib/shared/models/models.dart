import '../enums/app_enums.dart';

class Address {
  Address({
    required this.id,
    required this.label,
    required this.street,
    required this.city,
    required this.phone,
    this.isDefault = false,
  });

  final String id;
  String label;
  String street;
  String city;
  String phone;
  bool isDefault;

  Address copyWith({
    String? id,
    String? label,
    String? street,
    String? city,
    String? phone,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      street: street ?? this.street,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class AppUser {
  AppUser({
    required this.id,
    required this.phone,
    required this.password,
    String? fullName,
    String? firstName,
    String? lastName,
    this.profileImage,
    this.email,
    this.city,
    this.role = UserRole.customer,
    this.accountModes = const [],
    this.verificationStatus = VerificationStatus.none,
    this.onboardingCompleted = false,
    this.addresses = const [],
    this.ownedDressIds = const [],
    this.bookingIds = const [],
    this.storeId,
    this.createdAt,
  })  : firstName = firstName ?? _splitName(fullName).$1,
        lastName = lastName ?? _splitName(fullName).$2,
        fullName = (fullName != null && fullName.trim().isNotEmpty)
            ? fullName.trim()
            : [
                firstName ?? _splitName(fullName).$1,
                lastName ?? _splitName(fullName).$2,
              ].where((p) => p.trim().isNotEmpty).join(' ');

  final String id;
  String firstName;
  String lastName;

  /// Display name — kept in sync with [firstName] / [lastName] for existing UI.
  String fullName;
  String phone;
  String password;
  String? profileImage;
  String? email;
  String? city;

  /// Active experience used for routing (one at a time).
  UserRole role;

  /// All activated usage modes on this single account.
  List<AccountMode> accountModes;

  VerificationStatus verificationStatus;
  bool onboardingCompleted;
  List<Address> addresses;
  List<String> ownedDressIds;
  List<String> bookingIds;
  String? storeId;
  DateTime? createdAt;

  String get phoneNumber => phone;

  /// Personal wardrobe owner (individual) or store owner (active or activated).
  bool get isOwner =>
      hasMode(AccountMode.individualOwner) ||
      hasMode(AccountMode.storeOwner) ||
      role == UserRole.individualOwner ||
      role == UserRole.storeOwner;

  bool get isIndividualOwner =>
      role == UserRole.individualOwner ||
      hasMode(AccountMode.individualOwner);

  bool get isGuest => role == UserRole.guest;

  bool hasMode(AccountMode mode) => accountModes.contains(mode);

  void syncFullName() {
    fullName = [firstName, lastName]
        .where((p) => p.trim().isNotEmpty)
        .join(' ')
        .trim();
  }

  static (String, String) _splitName(String? full) {
    final parts = (full ?? '').trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return ('', '');
    if (parts.length == 1) return (parts.first, '');
    return (parts.first, parts.sublist(1).join(' '));
  }

  AppUser copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? fullName,
    String? phone,
    String? password,
    String? profileImage,
    String? email,
    String? city,
    UserRole? role,
    List<AccountMode>? accountModes,
    VerificationStatus? verificationStatus,
    bool? onboardingCompleted,
    List<Address>? addresses,
    List<String>? ownedDressIds,
    List<String>? bookingIds,
    String? storeId,
    DateTime? createdAt,
  }) {
    final nextFirst = firstName ?? this.firstName;
    final nextLast = lastName ?? this.lastName;
    final nextFull = fullName ??
        [nextFirst, nextLast].where((p) => p.trim().isNotEmpty).join(' ');
    return AppUser(
      id: id ?? this.id,
      firstName: nextFirst,
      lastName: nextLast,
      fullName: nextFull,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      profileImage: profileImage ?? this.profileImage,
      email: email ?? this.email,
      city: city ?? this.city,
      role: role ?? this.role,
      accountModes: accountModes ?? this.accountModes,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      addresses: addresses ?? this.addresses,
      ownedDressIds: ownedDressIds ?? this.ownedDressIds,
      bookingIds: bookingIds ?? this.bookingIds,
      storeId: storeId ?? this.storeId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Review {
  Review({
    required this.id,
    required this.dressId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String dressId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;
}

class Dress {
  Dress({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.category,
    required this.occasion,
    required this.color,
    required this.sizes,
    required this.pricePerDay,
    required this.deposit,
    required this.ownerId,
    this.storeId,
    this.rating = 0,
    this.reviews = const [],
    this.unavailableDates = const [],
    this.status = DressStatus.available,
    this.rentalCount = 0,
    this.createdAt,
    this.condition = 'Excellent',
    this.purchasePrice,
    this.minRentalDays = 1,
  });

  final String id;
  String name;
  String description;
  List<String> images;
  DressCategory category;
  DressOccasion occasion;
  String color;
  List<String> sizes;
  double pricePerDay;
  double deposit;
  String ownerId;
  String? storeId;
  double rating;
  List<Review> reviews;
  List<DateTime> unavailableDates;
  DressStatus status;
  int rentalCount;
  DateTime? createdAt;
  String condition;
  double? purchasePrice;
  int minRentalDays;

  bool isAvailableOn(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return !unavailableDates.any(
      (u) => u.year == d.year && u.month == d.month && u.day == d.day,
    );
  }

  bool isAvailableForRange(DateTime start, DateTime end) {
    var cursor = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    while (!cursor.isAfter(last)) {
      if (!isAvailableOn(cursor)) return false;
      cursor = cursor.add(const Duration(days: 1));
    }
    return true;
  }

  Dress copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? images,
    DressCategory? category,
    DressOccasion? occasion,
    String? color,
    List<String>? sizes,
    double? pricePerDay,
    double? deposit,
    String? ownerId,
    String? storeId,
    double? rating,
    List<Review>? reviews,
    List<DateTime>? unavailableDates,
    DressStatus? status,
    int? rentalCount,
    DateTime? createdAt,
    String? condition,
    double? purchasePrice,
    int? minRentalDays,
  }) {
    return Dress(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      images: images ?? this.images,
      category: category ?? this.category,
      occasion: occasion ?? this.occasion,
      color: color ?? this.color,
      sizes: sizes ?? this.sizes,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      deposit: deposit ?? this.deposit,
      ownerId: ownerId ?? this.ownerId,
      storeId: storeId ?? this.storeId,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      unavailableDates: unavailableDates ?? this.unavailableDates,
      status: status ?? this.status,
      rentalCount: rentalCount ?? this.rentalCount,
      createdAt: createdAt ?? this.createdAt,
      condition: condition ?? this.condition,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      minRentalDays: minRentalDays ?? this.minRentalDays,
    );
  }
}

class Store {
  Store({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.address,
    required this.city,
    required this.type,
    this.description = '',
    this.imageUrl,
    this.logo,
    this.coverImage,
    this.phone,
    this.dressIds = const [],
    this.showBrandName = true,
    this.subscriptionPlan = SubscriptionPlan.none,
    this.subscriptionStatus = SubscriptionStatus.none,
    this.subscriptionStartedAt,
    this.subscriptionExpiresAt,
    this.rating = 4.5,
    this.latitude,
    this.longitude,
    this.openingHours = '09:00 – 19:00',
    this.createdAt,
  });

  final String id;
  String name;
  String ownerId;
  String address;
  String city;
  StoreType type;
  String description;
  String? imageUrl;
  String? logo;
  String? coverImage;
  String? phone;
  List<String> dressIds;
  bool showBrandName;
  SubscriptionPlan subscriptionPlan;
  SubscriptionStatus subscriptionStatus;
  DateTime? subscriptionStartedAt;
  DateTime? subscriptionExpiresAt;
  double rating;
  double? latitude;
  double? longitude;
  String openingHours;
  DateTime? createdAt;

  /// Spec alias for [name].
  String get storeName => name;
  set storeName(String v) => name = v;

  /// Spec alias for [type].
  StoreType get businessType => type;

  Store copyWith({
    String? id,
    String? name,
    String? ownerId,
    String? address,
    String? city,
    StoreType? type,
    String? description,
    String? imageUrl,
    String? logo,
    String? coverImage,
    String? phone,
    List<String>? dressIds,
    bool? showBrandName,
    SubscriptionPlan? subscriptionPlan,
    SubscriptionStatus? subscriptionStatus,
    DateTime? subscriptionStartedAt,
    DateTime? subscriptionExpiresAt,
    double? rating,
    double? latitude,
    double? longitude,
    String? openingHours,
    DateTime? createdAt,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      address: address ?? this.address,
      city: city ?? this.city,
      type: type ?? this.type,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      logo: logo ?? this.logo,
      coverImage: coverImage ?? this.coverImage,
      phone: phone ?? this.phone,
      dressIds: dressIds ?? this.dressIds,
      showBrandName: showBrandName ?? this.showBrandName,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionStartedAt: subscriptionStartedAt ?? this.subscriptionStartedAt,
      subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      rating: rating ?? this.rating,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      openingHours: openingHours ?? this.openingHours,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Booking {
  Booking({
    required this.id,
    required this.dressId,
    required this.customerId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.deposit,
    required this.status,
    required this.createdAt,
    this.deliveryAddress,
    this.size,
    this.contractAccepted = false,
    this.notes,
  });

  final String id;
  String dressId;
  String customerId;
  DateTime startDate;
  DateTime endDate;
  double totalPrice;
  double deposit;
  BookingStatus status;
  DateTime createdAt;
  Address? deliveryAddress;
  String? size;
  bool contractAccepted;
  String? notes;

  int get rentalDays {
    final days = endDate.difference(startDate).inDays + 1;
    return days < 1 ? 1 : days;
  }

  Booking copyWith({
    String? id,
    String? dressId,
    String? customerId,
    DateTime? startDate,
    DateTime? endDate,
    double? totalPrice,
    double? deposit,
    BookingStatus? status,
    DateTime? createdAt,
    Address? deliveryAddress,
    String? size,
    bool? contractAccepted,
    String? notes,
  }) {
    return Booking(
      id: id ?? this.id,
      dressId: dressId ?? this.dressId,
      customerId: customerId ?? this.customerId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalPrice: totalPrice ?? this.totalPrice,
      deposit: deposit ?? this.deposit,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      size: size ?? this.size,
      contractAccepted: contractAccepted ?? this.contractAccepted,
      notes: notes ?? this.notes,
    );
  }
}

class AppTransaction {
  AppTransaction({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.type,
    required this.status,
    required this.date,
    this.userId,
    this.description,
  });

  final String id;
  String bookingId;
  double amount;
  TransactionType type;
  TransactionStatus status;
  DateTime date;
  String? userId;
  String? description;

  AppTransaction copyWith({
    String? id,
    String? bookingId,
    double? amount,
    TransactionType? type,
    TransactionStatus? status,
    DateTime? date,
    String? userId,
    String? description,
  }) {
    return AppTransaction(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      status: status ?? this.status,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      description: description ?? this.description,
    );
  }
}

class AppNotification {
  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.relatedId,
  });

  final String id;
  String userId;
  String title;
  String body;
  NotificationType type;
  DateTime createdAt;
  bool isRead;
  String? relatedId;

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    String? relatedId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId ?? this.relatedId,
    );
  }
}

class Favorite {
  Favorite({
    required this.id,
    required this.userId,
    required this.dressId,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String dressId;
  final DateTime createdAt;
}
