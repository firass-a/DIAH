import '../enums/app_enums.dart';

class CustomerProfile {
  CustomerProfile({
    required this.id,
    required this.userId,
    this.favoriteCategories = const [],
    this.favoriteOccasions = const [],
    this.preferredSizes = const [],
    this.favoriteColors = const [],
    this.stylePreferences = const [],
  });

  final String id;
  final String userId;
  List<String> favoriteCategories;
  List<String> favoriteOccasions;
  List<String> preferredSizes;
  List<String> favoriteColors;
  List<String> stylePreferences;

  CustomerProfile copyWith({
    List<String>? favoriteCategories,
    List<String>? favoriteOccasions,
    List<String>? preferredSizes,
    List<String>? favoriteColors,
    List<String>? stylePreferences,
  }) {
    return CustomerProfile(
      id: id,
      userId: userId,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
      favoriteOccasions: favoriteOccasions ?? this.favoriteOccasions,
      preferredSizes: preferredSizes ?? this.preferredSizes,
      favoriteColors: favoriteColors ?? this.favoriteColors,
      stylePreferences: stylePreferences ?? this.stylePreferences,
    );
  }
}

class IndividualOwnerProfile {
  IndividualOwnerProfile({
    required this.id,
    required this.userId,
    this.ownedDressIds = const [],
    this.verificationStatus = VerificationStatus.pending,
    this.totalEarnings = 0,
    this.totalRentals = 0,
    this.wardrobeCategories = const [],
    this.dressCountRange,
    this.idCardImage,
  });

  final String id;
  final String userId;
  List<String> ownedDressIds;
  VerificationStatus verificationStatus;
  double totalEarnings;
  int totalRentals;
  List<String> wardrobeCategories;
  String? dressCountRange;
  String? idCardImage;

  IndividualOwnerProfile copyWith({
    List<String>? ownedDressIds,
    VerificationStatus? verificationStatus,
    double? totalEarnings,
    int? totalRentals,
    List<String>? wardrobeCategories,
    String? dressCountRange,
    String? idCardImage,
  }) {
    return IndividualOwnerProfile(
      id: id,
      userId: userId,
      ownedDressIds: ownedDressIds ?? this.ownedDressIds,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalRentals: totalRentals ?? this.totalRentals,
      wardrobeCategories: wardrobeCategories ?? this.wardrobeCategories,
      dressCountRange: dressCountRange ?? this.dressCountRange,
      idCardImage: idCardImage ?? this.idCardImage,
    );
  }
}

class StoreOwnerProfile {
  StoreOwnerProfile({
    required this.id,
    required this.userId,
    required this.storeName,
    this.logo,
    this.coverImage,
    this.bio = '',
    this.description = '',
    this.address = '',
    this.city = '',
    this.businessPhone,
    this.businessType = StoreType.multi,
    this.dressIds = const [],
    this.subscriptionPlan = SubscriptionPlan.none,
    this.verificationStatus = VerificationStatus.pending,
    this.inventoryCategories = const [],
    this.inventorySizeRange,
    this.storePhoto,
    this.addressProofImage,
  });

  final String id;
  final String userId;
  String storeName;
  String? logo;
  String? coverImage;
  String bio;
  String description;
  String address;
  String city;
  String? businessPhone;
  StoreType businessType;
  List<String> dressIds;
  SubscriptionPlan subscriptionPlan;
  VerificationStatus verificationStatus;
  List<String> inventoryCategories;
  String? inventorySizeRange;
  String? storePhoto;
  String? addressProofImage;

  StoreOwnerProfile copyWith({
    String? storeName,
    String? logo,
    String? coverImage,
    String? bio,
    String? description,
    String? address,
    String? city,
    String? businessPhone,
    StoreType? businessType,
    List<String>? dressIds,
    SubscriptionPlan? subscriptionPlan,
    VerificationStatus? verificationStatus,
    List<String>? inventoryCategories,
    String? inventorySizeRange,
    String? storePhoto,
    String? addressProofImage,
  }) {
    return StoreOwnerProfile(
      id: id,
      userId: userId,
      storeName: storeName ?? this.storeName,
      logo: logo ?? this.logo,
      coverImage: coverImage ?? this.coverImage,
      bio: bio ?? this.bio,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      businessPhone: businessPhone ?? this.businessPhone,
      businessType: businessType ?? this.businessType,
      dressIds: dressIds ?? this.dressIds,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      inventoryCategories: inventoryCategories ?? this.inventoryCategories,
      inventorySizeRange: inventorySizeRange ?? this.inventorySizeRange,
      storePhoto: storePhoto ?? this.storePhoto,
      addressProofImage: addressProofImage ?? this.addressProofImage,
    );
  }
}
