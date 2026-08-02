import '../../shared/enums/app_enums.dart';
import '../../shared/models/models.dart';
import 'fake_database.dart';
import 'repositories.dart';

class FakeDressRepository implements DressRepository {
  FakeDressRepository({FakeDatabase? db}) : _db = db ?? FakeDatabase.instance;

  final FakeDatabase _db;

  List<Dress> get _visible => _db.dresses
      .where(
        (d) =>
            d.status == DressStatus.available ||
            d.status == DressStatus.approved ||
            d.status == DressStatus.rented,
      )
      .toList();

  @override
  Future<List<Dress>> getAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List.from(_visible);
  }

  @override
  Future<Dress?> getById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _db.dresses.cast<Dress?>().firstWhere(
      (d) => d!.id == id,
      orElse: () => null,
    );
  }

  @override
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
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    var results = _visible.where((d) {
      if (query != null && query.trim().isNotEmpty) {
        final q = query.toLowerCase();
        if (!d.name.toLowerCase().contains(q) &&
            !d.description.toLowerCase().contains(q) &&
            !d.color.toLowerCase().contains(q)) {
          return false;
        }
      }
      if (category != null && d.category != category) return false;
      if (occasion != null && d.occasion != occasion) return false;
      if (color != null && color.isNotEmpty && !d.color.contains(color)) {
        return false;
      }
      if (size != null && size.isNotEmpty && !d.sizes.contains(size)) {
        return false;
      }
      if (minPrice != null && d.pricePerDay < minPrice) return false;
      if (maxPrice != null && d.pricePerDay > maxPrice) return false;
      if (storeId != null && d.storeId != storeId) return false;
      if (availableFrom != null && availableTo != null) {
        if (!d.isAvailableForRange(availableFrom, availableTo)) return false;
      }
      return true;
    }).toList();

    switch (sort) {
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
  }

  @override
  Future<List<Dress>> getFeatured() async {
    final all = await getAll();
    all.sort((a, b) => b.rating.compareTo(a.rating));
    return all.take(6).toList();
  }

  @override
  Future<List<Dress>> getTrending() async {
    final all = await getAll();
    all.sort((a, b) => b.rentalCount.compareTo(a.rentalCount));
    return all.take(6).toList();
  }

  @override
  Future<List<Dress>> getRecent() async {
    final all = await getAll();
    all.sort(
      (a, b) => (b.createdAt ?? DateTime(2000)).compareTo(
        a.createdAt ?? DateTime(2000),
      ),
    );
    return all.take(6).toList();
  }

  @override
  Future<List<Dress>> getByOwner(String ownerId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _db.dresses.where((d) => d.ownerId == ownerId).toList();
  }

  @override
  Future<List<Dress>> getByStore(String storeId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _db.dresses.where((d) => d.storeId == storeId).toList();
  }

  @override
  Future<Dress> create(Dress dress) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final isStoreDress = dress.storeId != null && dress.storeId!.isNotEmpty;

    // Store inventory: live immediately. Personal wardrobe: pending platform review.
    final created = dress.copyWith(
      id: dress.id.isEmpty ? _db.newId() : dress.id,
      status: isStoreDress ? DressStatus.available : DressStatus.pending,
      createdAt: DateTime.now(),
    );
    _db.dresses.insert(0, created);

    final owner = _db.users.cast<AppUser?>().firstWhere(
      (u) => u!.id == created.ownerId,
      orElse: () => null,
    );
    if (owner != null && !owner.ownedDressIds.contains(created.id)) {
      owner.ownedDressIds = [...owner.ownedDressIds, created.id];
    }
    if (isStoreDress) {
      final store = _db.stores.cast<Store?>().firstWhere(
        (s) => s!.id == created.storeId,
        orElse: () => null,
      );
      if (store != null && !store.dressIds.contains(created.id)) {
        store.dressIds = [...store.dressIds, created.id];
      }
    }

    _db.notifications.add(
      AppNotification(
        id: _db.newId(),
        userId: created.ownerId,
        title: isStoreDress ? 'تم نشر الفستان' : 'فستانك قيد المراجعة',
        body: isStoreDress
            ? 'تم إضافة ${created.name} إلى مخزون المحل'
            : 'تم استلام ${created.name}. في انتظار موافقة المنصة.',
        type: isStoreDress
            ? NotificationType.dressApproved
            : NotificationType.general,
        createdAt: DateTime.now(),
        relatedId: created.id,
      ),
    );

    _db.notify();
    return created;
  }

  @override
  Future<Dress> approve(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final dress = await getById(id);
    if (dress == null) throw Exception('الفستان غير موجود');
    final approved = dress.copyWith(status: DressStatus.available);
    await update(approved);
    _db.notifications.insert(
      0,
      AppNotification(
        id: _db.newId(),
        userId: approved.ownerId,
        title: 'تمت الموافقة على فستانك',
        body: 'تمت الموافقة على ${approved.name} وهو الآن متاح للإيجار',
        type: NotificationType.dressApproved,
        createdAt: DateTime.now(),
        relatedId: approved.id,
      ),
    );
    _db.notify();
    return approved;
  }

  @override
  Future<Dress> reject(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final dress = await getById(id);
    if (dress == null) throw Exception('الفستان غير موجود');
    final rejected = dress.copyWith(status: DressStatus.rejected);
    await update(rejected);
    _db.notifications.insert(
      0,
      AppNotification(
        id: _db.newId(),
        userId: rejected.ownerId,
        title: 'تم رفض الفستان',
        body: 'للأسف تم رفض ${rejected.name}. يمكنك تعديله وإعادة الإرسال.',
        type: NotificationType.dressRejected,
        createdAt: DateTime.now(),
        relatedId: rejected.id,
      ),
    );
    _db.notify();
    return rejected;
  }

  @override
  Future<Dress> update(Dress dress) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final index = _db.dresses.indexWhere((d) => d.id == dress.id);
    if (index < 0) throw Exception('الفستان غير موجود');
    _db.dresses[index] = dress;
    _db.notify();
    return dress;
  }

  @override
  Future<void> delete(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _db.dresses.removeWhere((d) => d.id == id);
    _db.favorites.removeWhere((f) => f.dressId == id);
    _db.notify();
  }

  @override
  Future<void> archive(String id) async {
    final dress = await getById(id);
    if (dress == null) return;
    await update(dress.copyWith(status: DressStatus.archived));
  }
}

class FakeStoreRepository implements StoreRepository {
  FakeStoreRepository({FakeDatabase? db}) : _db = db ?? FakeDatabase.instance;

  final FakeDatabase _db;

  @override
  Future<List<Store>> getAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List.from(_db.stores);
  }

  @override
  Future<Store?> getById(String id) async {
    return _db.stores.cast<Store?>().firstWhere(
      (s) => s!.id == id,
      orElse: () => null,
    );
  }

  @override
  Future<List<Store>> getNearby() async {
    final all = await getAll();
    return all.take(5).toList();
  }

  @override
  Future<Store> create(Store store) async {
    final created = store.copyWith(
      id: store.id.isEmpty ? _db.newId() : store.id,
    );
    _db.stores.add(created);
    _db.notify();
    return created;
  }

  @override
  Future<Store> update(Store store) async {
    final index = _db.stores.indexWhere((s) => s.id == store.id);
    if (index < 0) throw Exception('المحل غير موجود');
    _db.stores[index] = store;
    _db.notify();
    return store;
  }

  @override
  Future<void> delete(String id) async {
    _db.stores.removeWhere((s) => s.id == id);
    _db.notify();
  }
}
