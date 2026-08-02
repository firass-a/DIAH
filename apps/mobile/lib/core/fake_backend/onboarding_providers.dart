import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/enums/app_enums.dart';
import '../../shared/models/profile_models.dart';
import 'fake_database.dart';
import 'providers.dart';

// ─── Draft form held during the wizard ────────────────────

class OnboardingDraft {
  const OnboardingDraft({
    this.selectedMode,
    this.step = 0,
    this.firstName = '',
    this.lastName = '',
    this.profileImage,
    this.phone = '',
    this.city = '',
    this.email = '',
    this.categories = const [],
    this.occasions = const [],
    this.sizes = const [],
    this.colors = const [],
    this.dressCountRange,
    this.addFirstDressNow = false,
    this.idCardImage,
    this.legalFullName = '',
    this.storeName = '',
    this.storeLogo,
    this.storeCover,
    this.storeBio = '',
    this.storeDescription = '',
    this.storeAddress = '',
    this.storeCity = '',
    this.businessPhone = '',
    this.businessType = StoreType.multi,
    this.inventorySizeRange,
    this.storePhoto,
    this.addressProofImage,
    this.otpSent = false,
    this.otpVerified = false,
    this.completed = false,
  });

  final AccountMode? selectedMode;
  final int step;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final String phone;
  final String city;
  final String email;
  final List<String> categories;
  final List<String> occasions;
  final List<String> sizes;
  final List<String> colors;
  final String? dressCountRange;
  final bool addFirstDressNow;
  final String? idCardImage;
  final String legalFullName;
  final String storeName;
  final String? storeLogo;
  final String? storeCover;
  final String storeBio;
  final String storeDescription;
  final String storeAddress;
  final String storeCity;
  final String businessPhone;
  final StoreType businessType;
  final String? inventorySizeRange;
  final String? storePhoto;
  final String? addressProofImage;
  final bool otpSent;
  final bool otpVerified;
  final bool completed;

  int get totalSteps {
    switch (selectedMode) {
      case AccountMode.customer:
        return 3;
      case AccountMode.individualOwner:
        return 4;
      case AccountMode.storeOwner:
        return 5;
      case null:
        return 0;
    }
  }

  OnboardingDraft copyWith({
    AccountMode? selectedMode,
    int? step,
    String? firstName,
    String? lastName,
    String? profileImage,
    String? phone,
    String? city,
    String? email,
    List<String>? categories,
    List<String>? occasions,
    List<String>? sizes,
    List<String>? colors,
    String? dressCountRange,
    bool? addFirstDressNow,
    String? idCardImage,
    String? legalFullName,
    String? storeName,
    String? storeLogo,
    String? storeCover,
    String? storeBio,
    String? storeDescription,
    String? storeAddress,
    String? storeCity,
    String? businessPhone,
    StoreType? businessType,
    String? inventorySizeRange,
    String? storePhoto,
    String? addressProofImage,
    bool? otpSent,
    bool? otpVerified,
    bool? completed,
    bool clearMode = false,
  }) {
    return OnboardingDraft(
      selectedMode: clearMode ? null : (selectedMode ?? this.selectedMode),
      step: step ?? this.step,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImage: profileImage ?? this.profileImage,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      email: email ?? this.email,
      categories: categories ?? this.categories,
      occasions: occasions ?? this.occasions,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      dressCountRange: dressCountRange ?? this.dressCountRange,
      addFirstDressNow: addFirstDressNow ?? this.addFirstDressNow,
      idCardImage: idCardImage ?? this.idCardImage,
      legalFullName: legalFullName ?? this.legalFullName,
      storeName: storeName ?? this.storeName,
      storeLogo: storeLogo ?? this.storeLogo,
      storeCover: storeCover ?? this.storeCover,
      storeBio: storeBio ?? this.storeBio,
      storeDescription: storeDescription ?? this.storeDescription,
      storeAddress: storeAddress ?? this.storeAddress,
      storeCity: storeCity ?? this.storeCity,
      businessPhone: businessPhone ?? this.businessPhone,
      businessType: businessType ?? this.businessType,
      inventorySizeRange: inventorySizeRange ?? this.inventorySizeRange,
      storePhoto: storePhoto ?? this.storePhoto,
      addressProofImage: addressProofImage ?? this.addressProofImage,
      otpSent: otpSent ?? this.otpSent,
      otpVerified: otpVerified ?? this.otpVerified,
      completed: completed ?? this.completed,
    );
  }
}

class OnboardingNotifier extends Notifier<OnboardingDraft> {
  @override
  OnboardingDraft build() {
    final user = ref.watch(authProvider).user;
    return OnboardingDraft(
      phone: user?.phone ?? '',
      firstName: user?.firstName ?? '',
      lastName: user?.lastName ?? '',
      profileImage: user?.profileImage,
      city: user?.city ?? '',
      email: user?.email ?? '',
    );
  }

  void selectMode(AccountMode mode) {
    state = state.copyWith(selectedMode: mode, step: 0);
  }

  void setStep(int step) => state = state.copyWith(step: step);

  void nextStep() {
    final max = state.totalSteps - 1;
    if (state.step < max) state = state.copyWith(step: state.step + 1);
  }

  void previousStep() {
    if (state.step > 0) state = state.copyWith(step: state.step - 1);
  }

  void updatePersonal({
    String? firstName,
    String? lastName,
    String? profileImage,
    String? phone,
    String? city,
    String? email,
  }) {
    state = state.copyWith(
      firstName: firstName,
      lastName: lastName,
      profileImage: profileImage,
      phone: phone,
      city: city,
      email: email,
    );
  }

  void toggleInList(String field, String value) {
    List<String> current;
    switch (field) {
      case 'categories':
        current = [...state.categories];
      case 'occasions':
        current = [...state.occasions];
      case 'sizes':
        current = [...state.sizes];
      case 'colors':
        current = [...state.colors];
      default:
        return;
    }
    if (current.contains(value)) {
      current.remove(value);
    } else {
      current.add(value);
    }
    switch (field) {
      case 'categories':
        state = state.copyWith(categories: current);
      case 'occasions':
        state = state.copyWith(occasions: current);
      case 'sizes':
        state = state.copyWith(sizes: current);
      case 'colors':
        state = state.copyWith(colors: current);
    }
  }

  void setDressCountRange(String range) =>
      state = state.copyWith(dressCountRange: range);

  void setAddFirstDress(bool value) =>
      state = state.copyWith(addFirstDressNow: value);

  void setIdCard(String? path) => state = state.copyWith(idCardImage: path);

  void setLegalName(String name) => state = state.copyWith(legalFullName: name);

  void updateStore({
    String? storeName,
    String? storeLogo,
    String? storeCover,
    String? storeBio,
    String? storeDescription,
    String? storeAddress,
    String? storeCity,
    String? businessPhone,
    StoreType? businessType,
    String? inventorySizeRange,
    String? storePhoto,
    String? addressProofImage,
  }) {
    state = state.copyWith(
      storeName: storeName,
      storeLogo: storeLogo,
      storeCover: storeCover,
      storeBio: storeBio,
      storeDescription: storeDescription,
      storeAddress: storeAddress,
      storeCity: storeCity,
      businessPhone: businessPhone,
      businessType: businessType,
      inventorySizeRange: inventorySizeRange,
      storePhoto: storePhoto,
      addressProofImage: addressProofImage,
    );
  }

  Future<void> sendOtp() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    state = state.copyWith(otpSent: true);
  }

  Future<bool> verifyOtp(String code) async {
    final ok = await ref.read(authRepositoryProvider).verifyOtp(
          state.phone,
          code,
        );
    if (ok) state = state.copyWith(otpVerified: true);
    return ok;
  }

  /// Persist wizard data, activate mode, create role profile.
  Future<String> completeOnboarding() async {
    final user = ref.read(authProvider).user;
    if (user == null || user.isGuest) {
      throw Exception('Account required');
    }
    final mode = state.selectedMode;
    if (mode == null) throw Exception('Select a mode');

    final db = FakeDatabase.instance;
    final role = switch (mode) {
      AccountMode.customer => UserRole.customer,
      AccountMode.individualOwner => UserRole.individualOwner,
      AccountMode.storeOwner => UserRole.storeOwner,
    };

    final modes = {...user.accountModes, mode}.toList();

    var updated = user.copyWith(
      firstName: state.firstName.trim(),
      lastName: state.lastName.trim(),
      phone: state.phone.trim().isEmpty ? user.phone : state.phone.trim(),
      profileImage: state.profileImage ?? user.profileImage,
      email: state.email.trim().isEmpty ? user.email : state.email.trim(),
      city: state.city.trim().isEmpty ? user.city : state.city.trim(),
      role: role,
      accountModes: modes,
      verificationStatus: VerificationStatus.pending,
      onboardingCompleted: true,
    );
    updated.syncFullName();

    // Mode-specific profiles + store entity
    switch (mode) {
      case AccountMode.customer:
        db.customerProfiles.removeWhere((p) => p.userId == user.id);
        db.customerProfiles.add(
          CustomerProfile(
            id: db.newId(),
            userId: user.id,
            favoriteCategories: state.categories,
            favoriteOccasions: state.occasions,
            preferredSizes: state.sizes,
            favoriteColors: state.colors,
          ),
        );
        updated = updated.copyWith(
          verificationStatus: VerificationStatus.verified,
        );
      case AccountMode.individualOwner:
        db.ownerProfiles.removeWhere((p) => p.userId == user.id);
        db.ownerProfiles.add(
          IndividualOwnerProfile(
            id: db.newId(),
            userId: user.id,
            ownedDressIds: user.ownedDressIds,
            verificationStatus: VerificationStatus.pending,
            wardrobeCategories: state.categories,
            dressCountRange: state.dressCountRange,
            idCardImage: state.idCardImage,
          ),
        );
        // Also ensure customer mode exists for dual use
        if (!modes.contains(AccountMode.customer)) {
          updated = updated.copyWith(
            accountModes: [...modes, AccountMode.customer],
          );
        }
      case AccountMode.storeOwner:
        // Persist personal fields first so becomeStoreOwner keeps them
        await ref.read(authProvider.notifier).updateProfile(updated);
        final store = await ref.read(authProvider.notifier).becomeStoreOwner(
              storeName: state.storeName.trim().isEmpty
                  ? '${state.firstName}\'s Store'
                  : state.storeName.trim(),
              address: state.storeAddress.trim(),
              city: state.storeCity.trim().isEmpty
                  ? state.city.trim()
                  : state.storeCity.trim(),
              type: state.businessType,
              description: state.storeDescription.trim(),
              phone: state.businessPhone.trim().isEmpty
                  ? updated.phone
                  : state.businessPhone.trim(),
            );
        final after = ref.read(authProvider).user!;
        updated = after.copyWith(
          verificationStatus: VerificationStatus.pending,
          onboardingCompleted: true,
          role: UserRole.storeOwner,
          accountModes: {
            ...after.accountModes,
            AccountMode.storeOwner,
            ...user.accountModes,
          }.toList(),
        );
        db.storeProfiles.removeWhere((p) => p.userId == user.id);
        db.storeProfiles.add(
          StoreOwnerProfile(
            id: db.newId(),
            userId: user.id,
            storeName: store.name,
            logo: state.storeLogo ?? store.logo,
            coverImage: state.storeCover ?? store.coverImage,
            bio: state.storeBio,
            description: state.storeDescription,
            address: store.address,
            city: store.city,
            businessPhone: store.phone,
            businessType: state.businessType,
            verificationStatus: VerificationStatus.pending,
            inventoryCategories: state.categories,
            inventorySizeRange: state.inventorySizeRange,
            storePhoto: state.storePhoto,
            addressProofImage: state.addressProofImage,
            subscriptionPlan: store.subscriptionPlan,
            dressIds: store.dressIds,
          ),
        );
        final idx = db.stores.indexWhere((s) => s.id == store.id);
        if (idx >= 0) {
          db.stores[idx] = db.stores[idx].copyWith(
            logo: state.storeLogo ?? db.stores[idx].logo,
            coverImage: state.storeCover ?? db.stores[idx].coverImage,
            description: state.storeDescription.isEmpty
                ? db.stores[idx].description
                : state.storeDescription,
          );
        }
    }

    await ref.read(authProvider.notifier).updateProfile(updated);
    state = state.copyWith(completed: true);
    db.notify();

    return switch (mode) {
      AccountMode.customer => '/home',
      AccountMode.individualOwner =>
        state.addFirstDressNow ? '/owner/add-dress' : '/owner',
      AccountMode.storeOwner => '/store',
    };
  }

  void reset() => state = const OnboardingDraft();
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingDraft>(
      OnboardingNotifier.new,
    );

// ─── Profile aggregate ────────────────────────────────────

class UserProfiles {
  const UserProfiles({
    this.customer,
    this.owner,
    this.store,
  });

  final CustomerProfile? customer;
  final IndividualOwnerProfile? owner;
  final StoreOwnerProfile? store;
}

class ProfileNotifier extends Notifier<UserProfiles> {
  @override
  UserProfiles build() {
    ref.watch(databaseProvider);
    final user = ref.watch(authProvider).user;
    if (user == null) return const UserProfiles();
    final db = FakeDatabase.instance;
    return UserProfiles(
      customer: db.customerProfiles.cast<CustomerProfile?>().firstWhere(
            (p) => p!.userId == user.id,
            orElse: () => null,
          ),
      owner: db.ownerProfiles.cast<IndividualOwnerProfile?>().firstWhere(
            (p) => p!.userId == user.id,
            orElse: () => null,
          ),
      store: db.storeProfiles.cast<StoreOwnerProfile?>().firstWhere(
            (p) => p!.userId == user.id,
            orElse: () => null,
          ),
    );
  }

  Future<void> switchActiveMode(AccountMode mode) async {
    final user = ref.read(authProvider).user;
    if (user == null || !user.hasMode(mode)) return;
    final role = switch (mode) {
      AccountMode.customer => UserRole.customer,
      AccountMode.individualOwner => UserRole.individualOwner,
      AccountMode.storeOwner => UserRole.storeOwner,
    };
    await ref.read(authProvider.notifier).updateProfile(
          user.copyWith(role: role),
        );
  }

  Future<void> activateMode(AccountMode mode) async {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    if (user.hasMode(mode)) {
      await switchActiveMode(mode);
      return;
    }
    // Start onboarding for new mode
    ref.read(onboardingProvider.notifier).selectMode(mode);
  }
}

final profileNotifierProvider =
    NotifierProvider<ProfileNotifier, UserProfiles>(ProfileNotifier.new);

String routeForAccountMode(AccountMode mode) {
  switch (mode) {
    case AccountMode.customer:
      return '/home';
    case AccountMode.individualOwner:
      return '/owner';
    case AccountMode.storeOwner:
      return '/store';
  }
}
