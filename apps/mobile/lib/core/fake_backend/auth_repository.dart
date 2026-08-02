import '../../shared/enums/app_enums.dart';
import '../../shared/models/models.dart';

/// Auth repository contract — swap FakeAuthRepository for API later.
abstract class AuthRepository {
  AppUser? get currentUser;
  bool get isAuthenticated;
  bool get isGuest;

  Future<AppUser> login(String phone, String password);
  Future<AppUser> register({
    required String fullName,
    required String phone,
    required String password,
  });
  Future<void> loginAsGuest();
  Future<void> logout();
  Future<void> updateProfile(AppUser user);
  Future<void> becomeIndividualOwner();
  Future<Store> becomeStoreOwner({
    required String storeName,
    required String address,
    required String city,
    required StoreType type,
    String? description,
    String? phone,
    bool showBrandName = true,
  });
  Future<bool> requestPasswordReset(String phone);
  Future<bool> verifyOtp(String phone, String otp);
}
