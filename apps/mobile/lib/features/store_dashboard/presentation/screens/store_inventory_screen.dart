import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/fake_backend/providers.dart';
import '../../../../core/fake_backend/store_providers.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/diah_theme.dart';
import '../../../../core/widgets/diah_widgets.dart';
import '../../../../core/widgets/dress_image.dart';
import '../../../../shared/enums/app_enums.dart';
import '../../../../shared/models/models.dart';
import '../widgets/store_widgets.dart';
import 'store_shell.dart';

class StoreInventoryScreen extends ConsumerWidget {
  const StoreInventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final dresses = ref.watch(storeDressesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0F5),
      appBar: StoreAppBar(title: s.inventory),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/store/inventory/add'),
        icon: const Icon(Icons.add),
        label: Text(s.addDress),
      ),
      body: dresses.isEmpty
          ? EmptyState(
              message: s.t(
                'المخزون فارغ — أضيفي فستانك الأول',
                'Inventaire vide',
                'Inventory is empty — add your first dress',
              ),
              icon: Icons.inventory_2_outlined,
              actionLabel: s.addDress,
              onAction: () => context.push('/store/inventory/add'),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: dresses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final d = dresses[i];
                return StorePanel(
                  child: Row(
                    children: [
                      DressImage(
                        source: d.images.isNotEmpty ? d.images.first : '',
                        width: 72,
                        height: 72,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            PriceWidget(
                              amount: d.pricePerDay,
                              suffix: s.pricePerDay,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _StatusDot(d.status),
                                const SizedBox(width: 6),
                                Text(
                                  _statusLabel(d.status, s),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${d.rentalCount}×',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: DiahColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (v) async {
                          final n = ref.read(storeNotifierProvider.notifier);
                          switch (v) {
                            case 'edit':
                              context.push('/store/inventory/edit/${d.id}');
                            case 'price':
                              await _editPrice(context, ref, d);
                            case 'toggle':
                              await n.setDressAvailability(
                                d.id,
                                d.status != DressStatus.available,
                              );
                            case 'archive':
                              await n.archiveDress(d.id);
                            case 'delete':
                              await n.deleteDress(d.id);
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(s.t('تعديل', 'Modifier', 'Edit')),
                          ),
                          PopupMenuItem(
                            value: 'price',
                            child: Text(s.t('تحديث السعر', 'Prix', 'Update price')),
                          ),
                          PopupMenuItem(
                            value: 'toggle',
                            child: Text(
                              d.status == DressStatus.available
                                  ? s.t('تعطيل التوفر', 'Indisponible', 'Mark unavailable')
                                  : s.t('تفعيل التوفر', 'Disponible', 'Mark available'),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'archive',
                            child: Text(s.t('أرشفة', 'Archiver', 'Archive')),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(s.delete),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Future<void> _editPrice(
    BuildContext context,
    WidgetRef ref,
    Dress dress,
  ) async {
    final price = TextEditingController(
      text: dress.pricePerDay.toStringAsFixed(0),
    );
    final deposit = TextEditingController(
      text: dress.deposit.toStringAsFixed(0),
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ref.read(stringsProvider).t('تحديث السعر', 'Prix', 'Update price')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: price,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: ref.read(stringsProvider).pricePerDay,
              ),
            ),
            TextField(
              controller: deposit,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: ref.read(stringsProvider).deposit,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ref.read(stringsProvider).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ref.read(stringsProvider).save),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(storeNotifierProvider.notifier).updateDressPrice(
        dress.id,
        pricePerDay: double.tryParse(price.text) ?? dress.pricePerDay,
        deposit: double.tryParse(deposit.text) ?? dress.deposit,
      );
    }
  }

  String _statusLabel(DressStatus st, AppStrings s) {
    switch (st) {
      case DressStatus.available:
        return s.t('متاح', 'Disponible', 'Available');
      case DressStatus.rented:
        return s.t('مؤجر', 'Loué', 'Rented');
      case DressStatus.archived:
        return s.t('مؤرشف', 'Archivé', 'Archived');
      case DressStatus.pending:
        return s.t('قيد المراجعة', 'En revue', 'Pending');
      default:
        return st.name;
    }
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot(this.status);
  final DressStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      DressStatus.available => DiahColors.success,
      DressStatus.rented => DiahColors.warning,
      DressStatus.archived => DiahColors.textMuted,
      _ => DiahColors.accent,
    };
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class StoreAddEditDressScreen extends ConsumerStatefulWidget {
  const StoreAddEditDressScreen({super.key, this.dressId});

  final String? dressId;

  @override
  ConsumerState<StoreAddEditDressScreen> createState() =>
      _StoreAddEditDressScreenState();
}

class _StoreAddEditDressScreenState
    extends ConsumerState<StoreAddEditDressScreen> {
  late final TextEditingController _name;
  late final TextEditingController _desc;
  late final TextEditingController _price;
  late final TextEditingController _deposit;
  late final TextEditingController _color;
  late final TextEditingController _days;
  DressCategory _category = DressCategory.evening;
  DressOccasion _occasion = DressOccasion.soiree;
  final List<String> _sizes = ['M'];
  final List<String> _images = [];
  final _picker = ImagePicker();
  bool _loading = false;

  static const _fallbackImage =
      'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=800';

  @override
  void initState() {
    super.initState();
    final existing = widget.dressId != null
        ? ref.read(dressByIdProvider(widget.dressId!))
        : null;
    _name = TextEditingController(text: existing?.name ?? '');
    _desc = TextEditingController(text: existing?.description ?? '');
    _price = TextEditingController(
      text: existing?.pricePerDay.toStringAsFixed(0) ?? '8000',
    );
    _deposit = TextEditingController(
      text: existing?.deposit.toStringAsFixed(0) ?? '20000',
    );
    _color = TextEditingController(text: existing?.color ?? '');
    _days = TextEditingController(text: '${existing?.minRentalDays ?? 2}');
    if (existing != null) {
      _category = existing.category;
      _occasion = existing.occasion;
      _sizes
        ..clear()
        ..addAll(existing.sizes);
      _images.addAll(existing.images);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _price.dispose();
    _deposit.dispose();
    _color.dispose();
    _days.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    final files = await _picker.pickMultiImage(imageQuality: 85);
    if (files.isEmpty) return;
    setState(() {
      for (final f in files) {
        if (!_images.contains(f.path)) _images.add(f.path);
      }
    });
  }

  Future<void> _pickFromCamera() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (file == null) return;
    setState(() {
      if (!_images.contains(file.path)) _images.add(file.path);
    });
  }

  void _showImageSourceSheet(AppStrings s) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: DiahColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: DiahColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                s.t('إضافة صور', 'Ajouter des photos', 'Add photos'),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined,
                    color: DiahColors.primary),
                title: Text(
                  s.t('من المعرض', 'Galerie', 'From gallery'),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFromGallery();
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.photo_camera_outlined, color: DiahColors.primary),
                title: Text(
                  s.t('التقاط صورة', 'Appareil photo', 'Take a photo'),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFromCamera();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _sizes.isEmpty) return;
    setState(() => _loading = true);
    final notifier = ref.read(storeNotifierProvider.notifier);
    final images = _images.isEmpty ? [_fallbackImage] : List<String>.from(_images);

    final dress = Dress(
      id: widget.dressId ?? '',
      name: _name.text.trim(),
      description: _desc.text.trim(),
      images: images,
      category: _category,
      occasion: _occasion,
      color: _color.text.trim(),
      sizes: List.from(_sizes),
      pricePerDay: double.tryParse(_price.text) ?? 8000,
      deposit: double.tryParse(_deposit.text) ?? 20000,
      ownerId: ref.read(authProvider).user?.id ?? '',
      storeId: ref.read(currentStoreProvider)?.id,
      minRentalDays: int.tryParse(_days.text) ?? 1,
      status: DressStatus.available,
    );

    try {
      if (widget.dressId != null) {
        final existing = ref.read(dressByIdProvider(widget.dressId!))!;
        await notifier.updateDress(
          dress.copyWith(
            id: existing.id,
            rating: existing.rating,
            reviews: existing.reviews,
            rentalCount: existing.rentalCount,
            unavailableDates: existing.unavailableDates,
            createdAt: existing.createdAt,
            status: existing.status,
          ),
        );
      } else {
        await notifier.addDress(dress);
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final isEdit = widget.dressId != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0F5),
      appBar: AppBar(
        title: Text(
          isEdit
              ? s.t('تعديل فستان', 'Modifier la robe', 'Edit dress')
              : s.t('إضافة فستان للمحل', 'Ajouter une robe', 'Add store dress'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              decoration: InputDecoration(
                labelText: s.t('اسم الفستان', 'Nom', 'Dress name'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _desc,
              maxLines: 3,
              decoration: InputDecoration(labelText: s.description),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _color,
              decoration: InputDecoration(labelText: s.color),
            ),
            const SizedBox(height: 16),
            Text(
              s.t('صور الفستان', 'Photos', 'Dress photos'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ..._images.asMap().entries.map((e) {
                    return Padding(
                      padding: const EdgeInsetsDirectional.only(end: 10),
                      child: Stack(
                        children: [
                          DressImage(
                            source: e.value,
                            width: 100,
                            height: 110,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => setState(() => _images.removeAt(e.key)),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  GestureDetector(
                    onTap: () => _showImageSourceSheet(s),
                    child: Container(
                      width: 100,
                      height: 110,
                      decoration: BoxDecoration(
                        color: DiahColors.softLavender,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: DiahColors.primary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_a_photo_outlined,
                            color: DiahColors.primary,
                            size: 28,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            s.t('إضافة', 'Ajouter', 'Add'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: DiahColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.t(
                'اختاري من المعرض أو الكاميرا (يمكن إضافة عدة صور)',
                'Galerie ou appareil photo (plusieurs images)',
                'Pick from gallery or camera (multiple photos supported)',
              ),
              style: const TextStyle(fontSize: 12, color: DiahColors.textMuted),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextField(
                      controller: _price,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(labelText: s.pricePerDay),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextField(
                      controller: _deposit,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(labelText: s.deposit),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Directionality(
              textDirection: TextDirection.ltr,
              child: TextField(
                controller: _days,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                  labelText: s.t(
                    'حد أدنى لأيام الإيجار',
                    'Durée min. (jours)',
                    'Min rental days',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<DressCategory>(
              initialValue: _category,
              decoration: InputDecoration(labelText: s.categories),
              items: DressCategory.values
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(s.categoryLabel(c)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<DressOccasion>(
              initialValue: _occasion,
              decoration: InputDecoration(labelText: s.occasion),
              items: DressOccasion.values
                  .map(
                    (o) => DropdownMenuItem(value: o, child: Text(o.name)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _occasion = v!),
            ),
            const SizedBox(height: 12),
            Text(s.size, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['XS', 'S', 'M', 'L', 'XL', 'One Size'].map((sz) {
                final selected = _sizes.contains(sz);
                return DiahFilterChip(
                  label: sz,
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      if (selected) {
                        _sizes.remove(sz);
                      } else {
                        _sizes.add(sz);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: s.save,
              isLoading: _loading,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
