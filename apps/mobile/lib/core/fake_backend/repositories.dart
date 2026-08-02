import '../../shared/enums/app_enums.dart';
import '../../shared/models/models.dart';

abstract class DressRepository {
  Future<List<Dress>> getAll();
  Future<Dress?> getById(String id);
  Future<List<Dress>> search({
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
    DressSortOption sort = DressSortOption.newest,
  });
  Future<List<Dress>> getFeatured();
  Future<List<Dress>> getTrending();
  Future<List<Dress>> getRecent();
  Future<List<Dress>> getByOwner(String ownerId);
  Future<List<Dress>> getByStore(String storeId);
  Future<Dress> create(Dress dress);
  Future<Dress> update(Dress dress);
  Future<void> delete(String id);
  Future<void> archive(String id);
  /// Mock platform review for individual-owner listings.
  Future<Dress> approve(String id);
  Future<Dress> reject(String id);
}

abstract class StoreRepository {
  Future<List<Store>> getAll();
  Future<Store?> getById(String id);
  Future<List<Store>> getNearby();
  Future<Store> create(Store store);
  Future<Store> update(Store store);
  Future<void> delete(String id);
}

abstract class BookingRepository {
  Future<List<Booking>> getAll();
  Future<Booking?> getById(String id);
  Future<List<Booking>> getByCustomer(String customerId);
  Future<List<Booking>> getByOwner(String ownerId);
  Future<List<Booking>> getByStore(String storeId);
  Future<Booking> create({
    required String dressId,
    required String customerId,
    required DateTime startDate,
    required DateTime endDate,
    required String size,
    required Address deliveryAddress,
    required bool contractAccepted,
    String? notes,
  });
  Future<Booking> updateStatus(String id, BookingStatus status);
  Future<void> delete(String id);
}

abstract class TransactionRepository {
  Future<List<AppTransaction>> getAll();
  Future<List<AppTransaction>> getByUser(String userId);
  Future<AppTransaction?> getById(String id);
  Future<AppTransaction> create(AppTransaction transaction);
  Future<AppTransaction> update(AppTransaction transaction);
  Future<void> delete(String id);
}

abstract class FavoriteRepository {
  Future<List<Favorite>> getByUser(String userId);
  Future<bool> isFavorite(String userId, String dressId);
  Future<Favorite> add(String userId, String dressId);
  Future<void> remove(String userId, String dressId);
}

abstract class NotificationRepository {
  Future<List<AppNotification>> getByUser(String userId);
  Future<int> unreadCount(String userId);
  Future<AppNotification> create(AppNotification notification);
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead(String userId);
  Future<void> delete(String id);
}
