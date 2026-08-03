import '../../shared/enums/app_enums.dart';
import '../../shared/models/models.dart';
import 'auth_repository.dart';
import 'fake_database.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({FakeDatabase? db}) : _db = db ?? FakeDatabase.instance;

  final FakeDatabase _db;

  @override
  AppUser? get currentUser => _db.currentUser;

  @override
  bool get isAuthenticated => _db.currentUser != null && !_db.isGuest;

  @override
  bool get isGuest => _db.isGuest;

  @override
  Future<AppUser> login(String phone, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final user = _db.users.cast<AppUser?>().firstWhere(
      (u) => u!.phone == phone && u.password == password,
      orElse: () => null,
    );
    if (user == null) {
      throw Exception('رقم الهاتف أو كلمة المرور غير صحيحة');
    }
    _db.currentUser = user;
    _db.isGuest = false;
    _db.notify();
    return user;
  }

  @override
  Future<AppUser> register({
    required String fullName,
    required String phone,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (_db.users.any((u) => u.phone == phone)) {
      throw Exception('رقم الهاتف مسجل مسبقاً');
    }
    final parts = fullName.trim().split(RegExp(r'\s+'));
    final first = parts.isNotEmpty ? parts.first : '';
    final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    final user = AppUser(
      id: _db.newId(),
      firstName: first,
      lastName: last,
      phone: phone,
      password: password,
      role: UserRole.customer,
      accountModes: const [],
      verificationStatus: VerificationStatus.none,
      onboardingCompleted: false,
      createdAt: DateTime.now(),
      profileImage:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
    );
    _db.users.add(user);
    _db.currentUser = user;
    _db.isGuest = false;
    _db.notify();
    return user;
  }

  @override
  Future<void> loginAsGuest() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _db.currentUser = AppUser(
      id: 'guest',
      firstName: 'Guest',
      lastName: '',
      phone: '',
      password: '',
      role: UserRole.guest,
      accountModes: const [],
      onboardingCompleted: true,
    );
    _db.isGuest = true;
    _db.notify();
  }

  @override
  Future<void> logout() async {
    _db.currentUser = null;
    _db.isGuest = false;
    _db.notify();
  }

  @override
  Future<void> updateProfile(AppUser user) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final index = _db.users.indexWhere((u) => u.id == user.id);
    if (index >= 0) {
      _db.users[index] = user;
      _db.currentUser = user;
      _db.notify();
    }
  }

  List<AccountMode> _withMode(AppUser user, AccountMode mode) {
    final set = {...user.accountModes, mode};
    return set.toList();
  }

  @override
  Future<void> becomeIndividualOwner() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final user = _db.currentUser;
    if (user == null || _db.isGuest) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }
    final updated = user.copyWith(
      role: UserRole.individualOwner,
      accountModes: _withMode(user, AccountMode.individualOwner),
      onboardingCompleted: true,
    );
    await updateProfile(updated);
  }

  @override
  Future<Store> becomeStoreOwner({
    required String storeName,
    required String address,
    required String city,
    required StoreType type,
    String? description,
    String? phone,
    bool showBrandName = true,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final user = _db.currentUser;
    if (user == null || _db.isGuest) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }
    final now = DateTime.now();
    final store = Store(
      id: _db.newId(),
      name: storeName,
      ownerId: user.id,
      address: address,
      city: city,
      type: type,
      description: description ?? '',
      phone: phone ?? user.phone,
      showBrandName: showBrandName,
      subscriptionPlan: SubscriptionPlan.monthly,
      subscriptionStatus: SubscriptionStatus.trial,
      subscriptionStartedAt: now,
      subscriptionExpiresAt: now.add(const Duration(days: 30)),
      imageUrl:
          'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800',
      logo:
          'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=200',
      coverImage: 'assets/images/wedding_dress.png',
      openingHours: '09:00 – 19:00',
      createdAt: now,
    );
    _db.stores.add(store);
    final updated = user.copyWith(
      role: UserRole.storeOwner,
      storeId: store.id,
      accountModes: _withMode(user, AccountMode.storeOwner),
      onboardingCompleted: true,
    );
    await updateProfile(updated);
    return store;
  }

  @override
  Future<bool> requestPasswordReset(String phone) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return _db.users.any((u) => u.phone == phone);
  }

  @override
  Future<bool> verifyOtp(String phone, String otp) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return otp == '1234' || otp == '0000';
  }
}
