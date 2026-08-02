import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../fake_backend/auth_repository.dart';
import '../fake_backend/fake_auth_repository.dart';
import '../fake_backend/fake_booking_repository.dart';
import '../fake_backend/fake_database.dart';
import '../fake_backend/fake_dress_repository.dart';
import '../fake_backend/repositories.dart';
import '../../shared/enums/app_enums.dart';
import '../../shared/models/models.dart';

// ─── Database tick (forces rebuilds on mutations) ─────────

final databaseProvider = ChangeNotifierProvider<FakeDatabase>((ref) {
  return FakeDatabase.instance;
});

// ─── Repositories ─────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FakeAuthRepository();
});

final dressRepositoryProvider = Provider<DressRepository>((ref) {
  return FakeDressRepository();
});

final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  return FakeStoreRepository();
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return FakeBookingRepository();
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return FakeTransactionRepository();
});

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FakeFavoriteRepository();
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return FakeNotificationRepository();
});

// ─── Auth ─────────────────────────────────────────────────

class AuthState {
  const AuthState({
    this.user,
    this.isGuest = false,
    this.isLoading = false,
    this.error,
  });

  final AppUser? user;
  final bool isGuest;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => user != null && !isGuest;
  bool get hasSession => user != null;

  AuthState copyWith({
    AppUser? user,
    bool? isGuest,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isGuest: isGuest ?? this.isGuest,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    ref.watch(databaseProvider);
    final repo = ref.read(authRepositoryProvider);
    return AuthState(user: repo.currentUser, isGuest: repo.isGuest);
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<bool> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repo.login(phone, password);
      state = AuthState(user: user, isGuest: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repo.register(
        fullName: fullName,
        phone: phone,
        password: password,
      );
      state = AuthState(user: user, isGuest: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> loginAsGuest() async {
    await _repo.loginAsGuest();
    state = AuthState(user: _repo.currentUser, isGuest: true);
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }

  Future<void> updateProfile(AppUser user) async {
    await _repo.updateProfile(user);
    state = state.copyWith(user: user);
  }

  Future<void> becomeIndividualOwner() async {
    await _repo.becomeIndividualOwner();
    state = state.copyWith(user: _repo.currentUser);
  }

  Future<Store> becomeStoreOwner({
    required String storeName,
    required String address,
    required String city,
    required StoreType type,
    String? description,
    String? phone,
    bool showBrandName = true,
  }) async {
    final store = await _repo.becomeStoreOwner(
      storeName: storeName,
      address: address,
      city: city,
      type: type,
      description: description,
      phone: phone,
      showBrandName: showBrandName,
    );
    state = state.copyWith(user: _repo.currentUser);
    return store;
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

// ─── Dresses ──────────────────────────────────────────────

final dressesProvider = Provider<List<Dress>>((ref) {
  ref.watch(databaseProvider);
  return FakeDatabase.instance.dresses
      .where(
        (d) =>
            d.status == DressStatus.available ||
            d.status == DressStatus.approved ||
            d.status == DressStatus.rented,
      )
      .toList();
});

final dressByIdProvider = Provider.family<Dress?, String>((ref, id) {
  ref.watch(databaseProvider);
  return FakeDatabase.instance.dresses.cast<Dress?>().firstWhere(
    (d) => d!.id == id,
    orElse: () => null,
  );
});

final featuredDressesProvider = Provider<List<Dress>>((ref) {
  final dresses = ref.watch(dressesProvider);
  final sorted = [...dresses]..sort((a, b) => b.rating.compareTo(a.rating));
  return sorted.take(6).toList();
});

final trendingDressesProvider = Provider<List<Dress>>((ref) {
  final dresses = ref.watch(dressesProvider);
  final sorted = [...dresses]
    ..sort((a, b) => b.rentalCount.compareTo(a.rentalCount));
  return sorted.take(6).toList();
});

final recentDressesProvider = Provider<List<Dress>>((ref) {
  final dresses = ref.watch(dressesProvider);
  final sorted = [...dresses]
    ..sort(
      (a, b) => (b.createdAt ?? DateTime(2000)).compareTo(
        a.createdAt ?? DateTime(2000),
      ),
    );
  return sorted.take(6).toList();
});

final ownerDressesProvider = Provider<List<Dress>>((ref) {
  ref.watch(databaseProvider);
  final user = ref.watch(authProvider).user;
  if (user == null) return [];
  return FakeDatabase.instance.dresses
      .where((d) => d.ownerId == user.id)
      .toList();
});

// ─── Stores ───────────────────────────────────────────────

final storesProvider = Provider<List<Store>>((ref) {
  ref.watch(databaseProvider);
  return List.from(FakeDatabase.instance.stores);
});

final storeByIdProvider = Provider.family<Store?, String>((ref, id) {
  ref.watch(databaseProvider);
  return FakeDatabase.instance.stores.cast<Store?>().firstWhere(
    (s) => s!.id == id,
    orElse: () => null,
  );
});

final nearbyStoresProvider = Provider<List<Store>>((ref) {
  return ref.watch(storesProvider).take(5).toList();
});

// ─── Search ───────────────────────────────────────────────

class SearchFilters {
  const SearchFilters({
    this.query = '',
    this.category,
    this.occasion,
    this.color,
    this.size,
    this.minPrice,
    this.maxPrice,
    this.availableFrom,
    this.availableTo,
    this.storeId,
    this.sort = DressSortOption.newest,
  });

  final String query;
  final DressCategory? category;
  final DressOccasion? occasion;
  final String? color;
  final String? size;
  final double? minPrice;
  final double? maxPrice;
  final DateTime? availableFrom;
  final DateTime? availableTo;
  final String? storeId;
  final DressSortOption sort;

  SearchFilters copyWith({
    String? query,
    DressCategory? category,
    DressOccasion? occasion,
    String? color,
    String? size,
    double? minPrice,
    double? maxPrice,
    DateTime? availableFrom,
    DateTime? availableTo,
    String? storeId,
    DressSortOption? sort,
    bool clearCategory = false,
    bool clearOccasion = false,
    bool clearColor = false,
    bool clearSize = false,
    bool clearStore = false,
    bool clearDates = false,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      category: clearCategory ? null : (category ?? this.category),
      occasion: clearOccasion ? null : (occasion ?? this.occasion),
      color: clearColor ? null : (color ?? this.color),
      size: clearSize ? null : (size ?? this.size),
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      availableFrom: clearDates ? null : (availableFrom ?? this.availableFrom),
      availableTo: clearDates ? null : (availableTo ?? this.availableTo),
      storeId: clearStore ? null : (storeId ?? this.storeId),
      sort: sort ?? this.sort,
    );
  }

  SearchFilters reset() => const SearchFilters();
}

class SearchNotifier extends Notifier<SearchFilters> {
  @override
  SearchFilters build() => const SearchFilters();

  void setQuery(String q) => state = state.copyWith(query: q);
  void setCategory(DressCategory? c) =>
      state = state.copyWith(category: c, clearCategory: c == null);
  void setOccasion(DressOccasion? o) =>
      state = state.copyWith(occasion: o, clearOccasion: o == null);
  void setColor(String? c) =>
      state = state.copyWith(color: c, clearColor: c == null);
  void setSize(String? s) =>
      state = state.copyWith(size: s, clearSize: s == null);
  void setPriceRange(double? min, double? max) =>
      state = state.copyWith(minPrice: min, maxPrice: max);
  void setDates(DateTime? from, DateTime? to) =>
      state = state.copyWith(availableFrom: from, availableTo: to);
  void setStore(String? id) =>
      state = state.copyWith(storeId: id, clearStore: id == null);
  void setSort(DressSortOption sort) => state = state.copyWith(sort: sort);
  void reset() => state = const SearchFilters();
}

final searchFiltersProvider =
    NotifierProvider<SearchNotifier, SearchFilters>(SearchNotifier.new);

final searchResultsProvider = Provider<List<Dress>>((ref) {
  final filters = ref.watch(searchFiltersProvider);
  final dresses = ref.watch(dressesProvider);

  var results = dresses.where((d) {
    if (filters.query.trim().isNotEmpty) {
      final q = filters.query.toLowerCase();
      if (!d.name.toLowerCase().contains(q) &&
          !d.description.toLowerCase().contains(q) &&
          !d.color.toLowerCase().contains(q)) {
        return false;
      }
    }
    if (filters.category != null && d.category != filters.category) {
      return false;
    }
    if (filters.occasion != null && d.occasion != filters.occasion) {
      return false;
    }
    if (filters.color != null &&
        filters.color!.isNotEmpty &&
        !d.color.contains(filters.color!)) {
      return false;
    }
    if (filters.size != null &&
        filters.size!.isNotEmpty &&
        !d.sizes.contains(filters.size!)) {
      return false;
    }
    if (filters.minPrice != null && d.pricePerDay < filters.minPrice!) {
      return false;
    }
    if (filters.maxPrice != null && d.pricePerDay > filters.maxPrice!) {
      return false;
    }
    if (filters.storeId != null && d.storeId != filters.storeId) return false;
    if (filters.availableFrom != null && filters.availableTo != null) {
      if (!d.isAvailableForRange(
        filters.availableFrom!,
        filters.availableTo!,
      )) {
        return false;
      }
    }
    return true;
  }).toList();

  switch (filters.sort) {
    case DressSortOption.newest:
      results.sort(
        (a, b) => (b.createdAt ?? DateTime(2000)).compareTo(
          a.createdAt ?? DateTime(2000),
        ),
      );
    case DressSortOption.priceLowToHigh:
      results.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
    case DressSortOption.priceHighToLow:
      results.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
    case DressSortOption.rating:
      results.sort((a, b) => b.rating.compareTo(a.rating));
    case DressSortOption.popular:
      results.sort((a, b) => b.rentalCount.compareTo(a.rentalCount));
  }
  return results;
});

// ─── Favorites ────────────────────────────────────────────

final favoritesProvider = Provider<List<Favorite>>((ref) {
  ref.watch(databaseProvider);
  final user = ref.watch(authProvider).user;
  if (user == null || user.isGuest) return [];
  return FakeDatabase.instance.favorites
      .where((f) => f.userId == user.id)
      .toList();
});

final favoriteDressesProvider = Provider<List<Dress>>((ref) {
  final favs = ref.watch(favoritesProvider);
  final dresses = ref.watch(dressesProvider);
  final ids = favs.map((f) => f.dressId).toSet();
  return dresses.where((d) => ids.contains(d.id)).toList();
});

final isFavoriteProvider = Provider.family<bool, String>((ref, dressId) {
  final favs = ref.watch(favoritesProvider);
  return favs.any((f) => f.dressId == dressId);
});

class FavoritesNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> toggle(String dressId) async {
    final user = ref.read(authProvider).user;
    if (user == null || user.isGuest) return;
    final repo = ref.read(favoriteRepositoryProvider);
    final isFav = await repo.isFavorite(user.id, dressId);
    if (isFav) {
      await repo.remove(user.id, dressId);
    } else {
      await repo.add(user.id, dressId);
    }
  }
}

final favoritesNotifierProvider =
    NotifierProvider<FavoritesNotifier, void>(FavoritesNotifier.new);

// ─── Bookings ─────────────────────────────────────────────

final customerBookingsProvider = Provider<List<Booking>>((ref) {
  ref.watch(databaseProvider);
  final user = ref.watch(authProvider).user;
  if (user == null) return [];
  return FakeDatabase.instance.bookings
      .where((b) => b.customerId == user.id)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

final ownerBookingsProvider = Provider<List<Booking>>((ref) {
  ref.watch(databaseProvider);
  final user = ref.watch(authProvider).user;
  if (user == null) return [];
  final dressIds = FakeDatabase.instance.dresses
      .where((d) => d.ownerId == user.id)
      .map((d) => d.id)
      .toSet();
  return FakeDatabase.instance.bookings
      .where((b) => dressIds.contains(b.dressId))
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

class BookingDraft {
  const BookingDraft({
    this.dressId,
    this.startDate,
    this.endDate,
    this.size,
    this.address,
    this.contractAccepted = false,
    this.notes,
  });

  final String? dressId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? size;
  final Address? address;
  final bool contractAccepted;
  final String? notes;

  BookingDraft copyWith({
    String? dressId,
    DateTime? startDate,
    DateTime? endDate,
    String? size,
    Address? address,
    bool? contractAccepted,
    String? notes,
  }) {
    return BookingDraft(
      dressId: dressId ?? this.dressId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      size: size ?? this.size,
      address: address ?? this.address,
      contractAccepted: contractAccepted ?? this.contractAccepted,
      notes: notes ?? this.notes,
    );
  }
}

class BookingDraftNotifier extends Notifier<BookingDraft> {
  @override
  BookingDraft build() => const BookingDraft();

  void start(String dressId) =>
      state = BookingDraft(dressId: dressId);

  void setDates(DateTime start, DateTime end) =>
      state = state.copyWith(startDate: start, endDate: end);

  void setSize(String size) => state = state.copyWith(size: size);

  void setAddress(Address address) =>
      state = state.copyWith(address: address);

  void setContract(bool accepted) =>
      state = state.copyWith(contractAccepted: accepted);

  void reset() => state = const BookingDraft();

  Future<Booking> submit() async {
    final user = ref.read(authProvider).user;
    if (user == null || user.isGuest) {
      throw Exception('يجب تسجيل الدخول للحجز');
    }
    final d = state;
    if (d.dressId == null ||
        d.startDate == null ||
        d.endDate == null ||
        d.size == null ||
        d.address == null) {
      throw Exception('يرجى إكمال جميع بيانات الحجز');
    }
    final booking = await ref.read(bookingRepositoryProvider).create(
      dressId: d.dressId!,
      customerId: user.id,
      startDate: d.startDate!,
      endDate: d.endDate!,
      size: d.size!,
      deliveryAddress: d.address!,
      contractAccepted: d.contractAccepted,
      notes: d.notes,
    );
    state = const BookingDraft();
    return booking;
  }
}

final bookingDraftProvider =
    NotifierProvider<BookingDraftNotifier, BookingDraft>(
      BookingDraftNotifier.new,
    );

// ─── Transactions & Notifications ─────────────────────────

final userTransactionsProvider = Provider<List<AppTransaction>>((ref) {
  ref.watch(databaseProvider);
  final user = ref.watch(authProvider).user;
  if (user == null) return [];
  return FakeDatabase.instance.transactions
      .where((t) => t.userId == user.id)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));
});

final notificationsProvider = Provider<List<AppNotification>>((ref) {
  ref.watch(databaseProvider);
  final user = ref.watch(authProvider).user;
  if (user == null) return [];
  return FakeDatabase.instance.notifications
      .where((n) => n.userId == user.id)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

final unreadNotificationsProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.isRead).length;
});

// ─── Owner / Store stats ──────────────────────────────────

class DashboardStats {
  const DashboardStats({
    this.totalDresses = 0,
    this.totalRentals = 0,
    this.revenue = 0,
    this.activeRentals = 0,
    this.pendingRequests = 0,
  });

  final int totalDresses;
  final int totalRentals;
  final double revenue;
  final int activeRentals;
  final int pendingRequests;
}

final ownerStatsProvider = Provider<DashboardStats>((ref) {
  final dresses = ref.watch(ownerDressesProvider);
  final bookings = ref.watch(ownerBookingsProvider);
  final revenue = bookings
      .where(
        (b) =>
            b.status == BookingStatus.accepted ||
            b.status == BookingStatus.completed ||
            b.status == BookingStatus.returned ||
            b.status == BookingStatus.delivered,
      )
      .fold<double>(0, (sum, b) => sum + b.totalPrice);
  final active = bookings
      .where(
        (b) =>
            b.status == BookingStatus.accepted ||
            b.status == BookingStatus.preparing ||
            b.status == BookingStatus.delivered,
      )
      .length;
  final pending = bookings
      .where((b) => b.status == BookingStatus.pending)
      .length;
  return DashboardStats(
    totalDresses: dresses.length,
    totalRentals: dresses.fold(0, (s, d) => s + d.rentalCount),
    revenue: revenue,
    activeRentals: active,
    pendingRequests: pending,
  );
});
