import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../shared/enums/app_enums.dart';
import '../../shared/models/models.dart';
import '../../shared/models/profile_models.dart';

/// In-memory mutable database that simulates a real backend.
class FakeDatabase extends ChangeNotifier {
  FakeDatabase._() {
    _seed();
  }

  static final FakeDatabase instance = FakeDatabase._();

  final _uuid = const Uuid();

  final List<AppUser> users = [];
  final List<Dress> dresses = [];
  final List<Store> stores = [];
  final List<Booking> bookings = [];
  final List<AppTransaction> transactions = [];
  final List<Favorite> favorites = [];
  final List<Review> reviews = [];
  final List<AppNotification> notifications = [];
  final List<CustomerProfile> customerProfiles = [];
  final List<IndividualOwnerProfile> ownerProfiles = [];
  final List<StoreOwnerProfile> storeProfiles = [];

  AppUser? currentUser;
  bool isGuest = false;

  String newId() => _uuid.v4();

  void notify() => notifyListeners();

  // ─── Seed ───────────────────────────────────────────────

  void _seed() {
    final now = DateTime.now();

    // Users — clearly distinct names, cities, and portraits
    final customer = AppUser(
      id: 'user-customer-1',
      firstName: 'سارة',
      lastName: 'بن علي',
      phone: '0555123456',
      password: '123456',
      email: 'sara@diah.dz',
      city: 'الجزائر العاصمة',
      profileImage:
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400&h=400&fit=crop',
      role: UserRole.customer,
      accountModes: const [AccountMode.customer],
      verificationStatus: VerificationStatus.verified,
      onboardingCompleted: true,
      addresses: [
        Address(
          id: 'addr-1',
          label: 'المنزل',
          street: '12 شارع ديدوش مراد',
          city: 'الجزائر العاصمة — حيدرة',
          phone: '0555123456',
          isDefault: true,
        ),
        Address(
          id: 'addr-1b',
          label: 'العمل',
          street: 'برج الأعمال، شارع بالقيسم',
          city: 'الجزائر العاصمة',
          phone: '0555123456',
        ),
      ],
      createdAt: now.subtract(const Duration(days: 90)),
    );

    final owner = AppUser(
      id: 'user-owner-1',
      firstName: 'أمينة',
      lastName: 'خالدي',
      phone: '0666789012',
      password: '123456',
      email: 'amina@diah.dz',
      city: 'الجزائر العاصمة',
      profileImage:
          'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=400&h=400&fit=crop',
      role: UserRole.individualOwner,
      accountModes: const [
        AccountMode.customer,
        AccountMode.individualOwner,
      ],
      verificationStatus: VerificationStatus.verified,
      onboardingCompleted: true,
      ownedDressIds: ['dress-3', 'dress-5'],
      addresses: [
        Address(
          id: 'addr-2',
          label: 'المنزل',
          street: '45 حي بن عكنون',
          city: 'الجزائر العاصمة — بن عكنون',
          phone: '0666789012',
          isDefault: true,
        ),
      ],
      createdAt: now.subtract(const Duration(days: 120)),
    );

    final storeOwner = AppUser(
      id: 'user-store-1',
      firstName: 'فاطمة',
      lastName: 'زروال',
      phone: '0777111222',
      password: '123456',
      email: 'fatima@elegance.dz',
      city: 'الجزائر العاصمة',
      profileImage:
          'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&h=400&fit=crop',
      role: UserRole.storeOwner,
      accountModes: const [AccountMode.storeOwner, AccountMode.customer],
      verificationStatus: VerificationStatus.verified,
      onboardingCompleted: true,
      storeId: 'store-1',
      ownedDressIds: ['dress-1', 'dress-2', 'dress-4', 'dress-6'],
      addresses: [
        Address(
          id: 'addr-3',
          label: 'المحل — Maison Élégance',
          street: '8 شارع العربي بن مهيدي',
          city: 'الجزائر العاصمة — وسط المدينة',
          phone: '0777111222',
          isDefault: true,
        ),
      ],
      createdAt: now.subtract(const Duration(days: 200)),
    );

    final storeOwner2 = AppUser(
      id: 'user-store-2',
      firstName: 'ليلى',
      lastName: 'مسعودي',
      phone: '0555987654',
      password: '123456',
      email: 'leila@karakou.dz',
      city: 'الجزائر العاصمة',
      profileImage:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop',
      role: UserRole.storeOwner,
      accountModes: const [AccountMode.storeOwner],
      verificationStatus: VerificationStatus.verified,
      onboardingCompleted: true,
      storeId: 'store-2',
      ownedDressIds: ['dress-7', 'dress-8'],
      addresses: [
        Address(
          id: 'addr-4',
          label: 'المحل — Atelier Karakou',
          street: '22 شارع حسيبة بن بوعلي',
          city: 'الجزائر العاصمة — بلكور',
          phone: '0555987654',
          isDefault: true,
        ),
      ],
      createdAt: now.subtract(const Duration(days: 150)),
    );

    users.addAll([customer, owner, storeOwner, storeOwner2]);

    customerProfiles.add(
      CustomerProfile(
        id: 'cprof-1',
        userId: customer.id,
        favoriteCategories: const ['Wedding Dresses', 'Evening Dresses'],
        favoriteOccasions: const ['Wedding', 'Party'],
        preferredSizes: const ['M', 'L'],
        favoriteColors: const ['White', 'Gold', 'Pink'],
      ),
    );
    ownerProfiles.add(
      IndividualOwnerProfile(
        id: 'oprof-1',
        userId: owner.id,
        ownedDressIds: const ['dress-3', 'dress-5'],
        verificationStatus: VerificationStatus.verified,
        totalEarnings: 18000,
        totalRentals: 20,
        wardrobeCategories: const ['Traditional', 'Karakou'],
        dressCountRange: '1-3',
      ),
    );
    storeProfiles.addAll([
      StoreOwnerProfile(
        id: 'sprof-1',
        userId: storeOwner.id,
        storeName: 'Maison Élégance',
        city: 'الجزائر العاصمة',
        address: '8 شارع العربي بن مهيدي',
        businessType: StoreType.multi,
        verificationStatus: VerificationStatus.verified,
        subscriptionPlan: SubscriptionPlan.monthly,
        dressIds: const ['dress-1', 'dress-2', 'dress-4', 'dress-6'],
      ),
      StoreOwnerProfile(
        id: 'sprof-2',
        userId: storeOwner2.id,
        storeName: 'Atelier Karakou',
        city: 'الجزائر العاصمة',
        address: '22 شارع حسيبة بن بوعلي',
        businessType: StoreType.traditional,
        verificationStatus: VerificationStatus.verified,
        subscriptionPlan: SubscriptionPlan.yearly,
        dressIds: const ['dress-7', 'dress-8'],
      ),
    ]);

    // Stores
    stores.addAll([
      Store(
        id: 'store-1',
        name: 'Maison Élégance',
        ownerId: storeOwner.id,
        address: '8 شارع العربي بن مهيدي',
        city: 'الجزائر العاصمة',
        type: StoreType.wedding,
        description:
            'محل راقٍ متخصص في فساتين الزفاف الفاخرة، بخدمة شخصية وتصاميم حصرية.',
        imageUrl:
            'https://images.unsplash.com/photo-1519741497674-611481863552?w=800',
        logo:
            'https://images.unsplash.com/photo-1519741497674-611481863552?w=200',
        coverImage:
            'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?w=1200',
        phone: '0777111222',
        dressIds: ['dress-1', 'dress-2', 'dress-4', 'dress-6', 'dress-9', 'dress-10'],
        showBrandName: true,
        subscriptionPlan: SubscriptionPlan.yearly,
        subscriptionStatus: SubscriptionStatus.active,
        subscriptionStartedAt: now.subtract(const Duration(days: 165)),
        subscriptionExpiresAt: now.add(const Duration(days: 200)),
        rating: 4.8,
        latitude: 36.7753,
        longitude: 3.0588,
        openingHours: '10:00 – 20:00 · السبت–الخميس',
        createdAt: now.subtract(const Duration(days: 200)),
      ),
      Store(
        id: 'store-2',
        name: 'Atelier Karakou',
        ownerId: storeOwner2.id,
        address: '22 شارع حسيبة بن بوعلي',
        city: 'الجزائر العاصمة',
        type: StoreType.traditional,
        description: 'تصاميم تقليدية جزائرية أصيلة مع لمسة عصرية.',
        imageUrl:
            'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=800',
        logo:
            'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=200',
        coverImage:
            'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=1200',
        phone: '0555987654',
        dressIds: ['dress-7', 'dress-8'],
        showBrandName: false,
        subscriptionPlan: SubscriptionPlan.monthly,
        subscriptionStatus: SubscriptionStatus.active,
        subscriptionStartedAt: now.subtract(const Duration(days: 10)),
        subscriptionExpiresAt: now.add(const Duration(days: 20)),
        rating: 4.6,
        latitude: 36.7525,
        longitude: 3.0419,
        openingHours: '09:30 – 18:30',
        createdAt: now.subtract(const Duration(days: 150)),
      ),
      Store(
        id: 'store-3',
        name: 'Sofia Soirée',
        ownerId: storeOwner.id,
        address: '15 شارع الاستقلال',
        city: 'الجزائر العاصمة',
        type: StoreType.evening,
        description: 'فساتين سهرة أنيقة لكل المناسبات الخاصة.',
        imageUrl:
            'https://images.unsplash.com/photo-1566174053879-31528523f8ae?w=800',
        logo:
            'https://images.unsplash.com/photo-1566174053879-31528523f8ae?w=200',
        coverImage:
            'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?w=1200',
        phone: '0555000111',
        dressIds: [],
        showBrandName: true,
        subscriptionPlan: SubscriptionPlan.monthly,
        subscriptionStatus: SubscriptionStatus.trial,
        subscriptionStartedAt: now.subtract(const Duration(days: 5)),
        subscriptionExpiresAt: now.add(const Duration(days: 45)),
        rating: 4.4,
        latitude: 36.7538,
        longitude: 3.0588,
        openingHours: '11:00 – 21:00',
        createdAt: now.subtract(const Duration(days: 60)),
      ),
    ]);

    // Dresses
    dresses.addAll([
      Dress(
        id: 'dress-1',
        name: 'Royal White Wedding Gown',
        description:
            'فستان زفاف أبيض ملكي بتطريز يدوي فاخر وذيل طويل أنيق. مثالي لحفلات الزفاف الكبرى في قاعات الجزائر الفاخرة.',
        images: const [
          'https://images.unsplash.com/photo-1594552072239-b1f8c8d51e54?w=800',
          'https://images.unsplash.com/photo-1515372039744-b8f0229a06a2?w=800',
          'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?w=800',
        ],
        category: DressCategory.wedding,
        occasion: DressOccasion.wedding,
        color: 'أبيض',
        sizes: const ['S', 'M', 'L'],
        pricePerDay: 15000,
        deposit: 50000,
        ownerId: storeOwner.id,
        storeId: 'store-1',
        rating: 4.9,
        status: DressStatus.available,
        rentalCount: 24,
        createdAt: now.subtract(const Duration(days: 60)),
        condition: 'ممتاز',
      ),
      Dress(
        id: 'dress-2',
        name: 'Luxury Satin Evening Dress',
        description:
            'فستان سهرة ساتان فاخر بلون شمبانيا، قصة انسيابية تبرز الأناقة الطبيعية.',
        images: const [
          'https://images.unsplash.com/photo-1566174053879-31528523f8ae?w=800',
          'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=800',
        ],
        category: DressCategory.evening,
        occasion: DressOccasion.soiree,
        color: 'شمبانيا',
        sizes: const ['XS', 'S', 'M'],
        pricePerDay: 8000,
        deposit: 25000,
        ownerId: storeOwner.id,
        storeId: 'store-1',
        rating: 4.7,
        status: DressStatus.available,
        rentalCount: 18,
        createdAt: now.subtract(const Duration(days: 45)),
      ),
      Dress(
        id: 'dress-3',
        name: 'Emerald Green Caftan',
        description:
            'قفطان زمردي بتطريز ذهبي تقليدي، قطعة فريدة من مجموعة خاصة.',
        images: const [
          'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=800',
          'https://images.unsplash.com/photo-1585487000160-6ebcfceb0d03?w=800',
        ],
        category: DressCategory.traditional,
        occasion: DressOccasion.traditionalCeremony,
        color: 'أخضر زمردي',
        sizes: const ['M', 'L', 'XL'],
        pricePerDay: 8500,
        deposit: 20000,
        ownerId: owner.id,
        rating: 4.8,
        status: DressStatus.available,
        rentalCount: 12,
        createdAt: now.subtract(const Duration(days: 30)),
        purchasePrice: 120000,
      ),
      Dress(
        id: 'dress-4',
        name: 'Burgundy Velvet Dress',
        description:
            'فستان مخملي بلون بورغندي غني، مثالي لحفلات الخطوبة والسهرات الشتوية.',
        images: const [
          'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=800',
          'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?w=800',
        ],
        category: DressCategory.evening,
        occasion: DressOccasion.engagement,
        color: 'بورغندي',
        sizes: const ['S', 'M', 'L'],
        pricePerDay: 7500,
        deposit: 20000,
        ownerId: storeOwner.id,
        storeId: 'store-1',
        rating: 4.6,
        status: DressStatus.available,
        rentalCount: 15,
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      Dress(
        id: 'dress-5',
        name: 'Traditional Algerian Karakou',
        description:
            'كاراكو جزائري أصيل بتطريز فتلة ذهبية وفضية، إرث ثقافي بلمسة معاصرة.',
        images: const [
          'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=800',
          'https://images.unsplash.com/photo-1585487000160-6ebcfceb0d03?w=800',
        ],
        category: DressCategory.traditional,
        occasion: DressOccasion.traditionalCeremony,
        color: 'أسود وذهبي',
        sizes: const ['S', 'M', 'L', 'XL'],
        pricePerDay: 15000,
        deposit: 40000,
        ownerId: owner.id,
        rating: 5.0,
        status: DressStatus.available,
        rentalCount: 8,
        createdAt: now.subtract(const Duration(days: 15)),
        purchasePrice: 250000,
      ),
      Dress(
        id: 'dress-6',
        name: 'Blush Pink Soft Gown',
        description:
            'فستان وردي ناعم بطبقات تول خفيفة، مثالي لحفلات الخطوبة والتصوير.',
        images: const [
          'https://images.unsplash.com/photo-1566174053879-31528523f8ae?w=800',
          'https://images.unsplash.com/photo-1515372039744-b8f0229a06a2?w=800',
        ],
        category: DressCategory.wedding,
        occasion: DressOccasion.engagement,
        color: 'وردي',
        sizes: const ['XS', 'S', 'M'],
        pricePerDay: 10000,
        deposit: 30000,
        ownerId: storeOwner.id,
        storeId: 'store-1',
        rating: 4.5,
        status: DressStatus.available,
        rentalCount: 10,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      Dress(
        id: 'dress-7',
        name: 'Golden Blousa Oranaise',
        description:
            'بلوزة وهرانية ذهبية بتطريز تقليدي من وهران، قطعة تراثية نادرة.',
        images: const [
          'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=800',
          'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=800',
        ],
        category: DressCategory.traditional,
        occasion: DressOccasion.traditionalCeremony,
        color: 'ذهبي',
        sizes: const ['M', 'L'],
        pricePerDay: 12000,
        deposit: 35000,
        ownerId: storeOwner2.id,
        storeId: 'store-2',
        rating: 4.9,
        status: DressStatus.available,
        rentalCount: 6,
        createdAt: now.subtract(const Duration(days: 8)),
      ),
      Dress(
        id: 'dress-8',
        name: 'Midnight Navy Soirée',
        description:
            'فستان سهرة كحلي ليلي مع تفاصيل كريستالية، أناقة لا تقاوم.',
        images: const [
          'https://images.unsplash.com/photo-1612336307429-8a898d10e223?w=800',
          'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=800',
        ],
        category: DressCategory.evening,
        occasion: DressOccasion.soiree,
        color: 'كحلي',
        sizes: const ['S', 'M', 'L'],
        pricePerDay: 6500,
        deposit: 18000,
        ownerId: storeOwner2.id,
        storeId: 'store-2',
        rating: 4.4,
        status: DressStatus.available,
        rentalCount: 9,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Dress(
        id: 'dress-9',
        name: 'Pearl Crystal Clutch',
        description: 'حقيبة يد كريستالية بلؤلؤ صناعي، إكسسوار فاخر للمناسبات.',
        images: const [
          'https://images.unsplash.com/photo-1584917865442-de89df76acc0?w=800',
        ],
        category: DressCategory.accessories,
        occasion: DressOccasion.wedding,
        color: 'فضي',
        sizes: const ['One Size'],
        pricePerDay: 600,
        deposit: 3000,
        ownerId: storeOwner.id,
        storeId: 'store-1',
        rating: 4.3,
        status: DressStatus.available,
        rentalCount: 30,
        createdAt: now.subtract(const Duration(days: 40)),
      ),
      Dress(
        id: 'dress-10',
        name: 'Ivory Lace Veil',
        description: 'طرحة عروس دانتيل عاجي فاخرة بطول كاتدرائية.',
        images: const [
          'https://images.unsplash.com/photo-1519741497674-611481863552?w=800',
        ],
        category: DressCategory.accessories,
        occasion: DressOccasion.wedding,
        color: 'عاجي',
        sizes: const ['One Size'],
        pricePerDay: 700,
        deposit: 4000,
        ownerId: storeOwner.id,
        storeId: 'store-1',
        rating: 4.7,
        status: DressStatus.available,
        rentalCount: 22,
        createdAt: now.subtract(const Duration(days: 35)),
      ),
    ]);

    // Mark some unavailable dates
    for (final dress in dresses.take(3)) {
      dress.unavailableDates = [
        now.add(const Duration(days: 3)),
        now.add(const Duration(days: 4)),
        now.add(const Duration(days: 10)),
        now.add(const Duration(days: 11)),
      ];
    }

    // Reviews
    final sampleReviews = [
      Review(
        id: 'rev-1',
        dressId: 'dress-1',
        userId: customer.id,
        userName: customer.fullName,
        rating: 5,
        comment: 'فستان رائع جداً! شعرت وكأني أميرة في يوم زفافي.',
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      Review(
        id: 'rev-2',
        dressId: 'dress-1',
        userId: 'user-anon',
        userName: 'نادية م.',
        rating: 4.5,
        comment: 'جودة ممتازة وتوصيل في الوقت. أنصح به بشدة.',
        createdAt: now.subtract(const Duration(days: 40)),
      ),
      Review(
        id: 'rev-3',
        dressId: 'dress-3',
        userId: customer.id,
        userName: customer.fullName,
        rating: 5,
        comment: 'القفطان تحفة فنية حقيقية. التطريز مذهل!',
        createdAt: now.subtract(const Duration(days: 12)),
      ),
      Review(
        id: 'rev-4',
        dressId: 'dress-5',
        userId: 'user-anon-2',
        userName: 'ياسمين ب.',
        rating: 5,
        comment: 'أفضل كاراكو استأجرته. أصيل وأنيق.',
        createdAt: now.subtract(const Duration(days: 8)),
      ),
    ];
    reviews.addAll(sampleReviews);
    for (final r in sampleReviews) {
      final dress = dresses.where((d) => d.id == r.dressId).firstOrNull;
      if (dress != null) {
        dress.reviews = [...dress.reviews, r];
      }
    }

    // Sample booking
    final booking = Booking(
      id: 'booking-1',
      dressId: 'dress-2',
      customerId: customer.id,
      startDate: now.add(const Duration(days: 14)),
      endDate: now.add(const Duration(days: 16)),
      totalPrice: 24000,
      deposit: 25000,
      status: BookingStatus.accepted,
      createdAt: now.subtract(const Duration(days: 2)),
      deliveryAddress: customer.addresses.first,
      size: 'M',
      contractAccepted: true,
    );
    bookings.add(booking);

    // Pending request on individual owner wardrobe (personal rental)
    final ownerBooking = Booking(
      id: 'booking-owner-1',
      dressId: 'dress-5',
      customerId: customer.id,
      startDate: now.add(const Duration(days: 21)),
      endDate: now.add(const Duration(days: 23)),
      totalPrice: 18000,
      deposit: 20000,
      status: BookingStatus.pending,
      createdAt: now.subtract(const Duration(hours: 6)),
      deliveryAddress: customer.addresses.first,
      size: 'M',
      contractAccepted: true,
    );
    bookings.add(ownerBooking);
    customer.bookingIds = [booking.id, ownerBooking.id];

    transactions.add(
      AppTransaction(
        id: 'tx-1',
        bookingId: booking.id,
        amount: 25000,
        type: TransactionType.deposit,
        status: TransactionStatus.completed,
        date: now.subtract(const Duration(days: 2)),
        userId: customer.id,
        description: 'عربون حجز - Luxury Satin Evening Dress',
      ),
    );
    transactions.add(
      AppTransaction(
        id: 'tx-owner-1',
        bookingId: ownerBooking.id,
        amount: 20000,
        type: TransactionType.deposit,
        status: TransactionStatus.completed,
        date: now.subtract(const Duration(hours: 6)),
        userId: customer.id,
        description: 'عربون حجز - Traditional Algerian Karakou',
      ),
    );
    transactions.add(
      AppTransaction(
        id: 'tx-owner-2',
        bookingId: ownerBooking.id,
        amount: 18000,
        type: TransactionType.rentalPayment,
        status: TransactionStatus.pending,
        date: now.subtract(const Duration(hours: 6)),
        userId: customer.id,
        description: 'دفعة إيجار - Traditional Algerian Karakou',
      ),
    );

    notifications.addAll([
      AppNotification(
        id: 'notif-1',
        userId: customer.id,
        title: 'تم قبول حجزك',
        body: 'تم قبول حجزك لفستان Luxury Satin Evening Dress',
        type: NotificationType.bookingAccepted,
        createdAt: now.subtract(const Duration(days: 1)),
        relatedId: booking.id,
      ),
      AppNotification(
        id: 'notif-2',
        userId: storeOwner.id,
        title: 'حجز جديد',
        body: 'طلب حجز جديد لفستان Luxury Satin Evening Dress',
        type: NotificationType.newBooking,
        createdAt: now.subtract(const Duration(days: 2)),
        relatedId: booking.id,
      ),
      AppNotification(
        id: 'notif-3',
        userId: owner.id,
        title: 'تمت الموافقة على فستانك',
        body: 'تمت الموافقة على Traditional Algerian Karakou وهو الآن متاح',
        type: NotificationType.dressApproved,
        createdAt: now.subtract(const Duration(days: 14)),
        relatedId: 'dress-5',
      ),
      AppNotification(
        id: 'notif-4',
        userId: owner.id,
        title: 'حجز جديد',
        body: 'طلب حجز جديد لفستان Traditional Algerian Karakou',
        type: NotificationType.newBooking,
        createdAt: now.subtract(const Duration(hours: 6)),
        relatedId: ownerBooking.id,
      ),
    ]);

    favorites.add(
      Favorite(
        id: 'fav-1',
        userId: customer.id,
        dressId: 'dress-1',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    );
    favorites.add(
      Favorite(
        id: 'fav-2',
        userId: customer.id,
        dressId: 'dress-5',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    );
  }

  void reset() {
    users.clear();
    dresses.clear();
    stores.clear();
    bookings.clear();
    transactions.clear();
    favorites.clear();
    reviews.clear();
    notifications.clear();
    customerProfiles.clear();
    ownerProfiles.clear();
    storeProfiles.clear();
    currentUser = null;
    isGuest = false;
    _seed();
    notify();
  }
}
