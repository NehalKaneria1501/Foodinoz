import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/brutalist_button.dart';
import '../../../../core/widgets/brutalist_card.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/utils/invoice_download_helper.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/services/razorpay_payment_service.dart';
import '../../auth/views/sign_in_screen.dart';
import '../view_models/profile_view_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Preset avatars for gallery picker
  final List<String> _galleryAvatars = [
    'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?w=150',
    'https://images.unsplash.com/photo-1583394293214-28ded15ee548?w=150',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
  ];

  final ImagePicker _imagePicker = ImagePicker();

  // Accessibility, Security, and Notification Preferences
  bool _highContrast = false;
  bool _screenReader = true;
  bool _hapticClicks = true;
  bool _reducedMotion = false;
  String _fontScale = 'Standard (100%)';

  bool _twoFactorAuth = true;
  bool _biometricUnlock = true;

  bool _orderTrackingNotif = true;
  bool _whatsAppAlerts = true;
  bool _cookingTimersNotif = true;
  bool _dealsNotif = false;

  Future<void> _pickImageFromCamera(ProfileViewModel profileVm) async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (photo != null) {
        profileVm.updatePhoto(photo.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo captured from Camera!'),
              backgroundColor: AppColors.sproutGreen,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera permission error or cancelled: $e'),
            backgroundColor: AppColors.terracotta,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery(ProfileViewModel profileVm) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        profileVm.updatePhoto(image.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo chosen from Gallery!'),
              backgroundColor: AppColors.sproutGreen,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gallery permission error or cancelled: $e'),
            backgroundColor: AppColors.terracotta,
          ),
        );
      }
    }
  }

  ImageProvider? _getProfileImageProvider(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return null;
    if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
      return NetworkImage(photoUrl);
    }
    return FileImage(File(photoUrl));
  }

  void _showAvatarOptionsSheet(ProfileViewModel profileVm) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(
          color: isDark ? AppColors.gridLine : AppColors.lightBorder,
          width: 1.5,
        ),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Material(
              color: isDark ? AppColors.surfaceContainer : Colors.white,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PROFILE PHOTO',
                          style: AppTypography.headlineSm.copyWith(
                            fontSize: 14,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 20,
                            color: AppColors.outline,
                          ),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(
                        'Click from Camera',
                        style: AppTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Capture a live picture from your device camera',
                        style: AppTypography.bodySm,
                      ),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _pickImageFromCamera(profileVm);
                      },
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.sproutGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.photo_library,
                          color: AppColors.sproutGreen,
                        ),
                      ),
                      title: Text(
                        'Choose from Gallery',
                        style: AppTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Select a photo from your device gallery',
                        style: AppTypography.bodySm,
                      ),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _pickImageFromGallery(profileVm);
                      },
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.face_retouching_natural,
                          color: Colors.amber,
                        ),
                      ),
                      title: Text(
                        'Preset Gourmet Avatars',
                        style: AppTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Choose from gourmet chef avatars',
                        style: AppTypography.bodySm,
                      ),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _showGalleryPickerSheet(profileVm);
                      },
                    ),
                    if (profileVm.user?.photoUrl != null) ...[
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.terracotta.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: AppColors.terracotta,
                          ),
                        ),
                        title: Text(
                          'Delete Photo',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.terracotta,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Remove current picture and reset to monogram',
                          style: AppTypography.bodySm,
                        ),
                        onTap: () {
                          profileVm.deletePhoto();
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile photo removed'),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showGalleryPickerSheet(ProfileViewModel profileVm) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(
          color: isDark ? AppColors.gridLine : AppColors.lightBorder,
          width: 1.5,
        ),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CHOOSE FROM GALLERY',
                    style: AppTypography.headlineSm.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select an avatar to update your profile photo',
                    style: AppTypography.bodySm,
                  ),
                  const SizedBox(height: 14),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: _galleryAvatars.length,
                    itemBuilder: (context, index) {
                      final url = _galleryAvatars[index];
                      return InkWell(
                        onTap: () {
                          profileVm.updatePhoto(url);
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Profile photo updated from gallery!',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            image: DecorationImage(
                              image: NetworkImage(url),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditProfileFormModal(ProfileViewModel profileVm) {
    final user = profileVm.user;
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final phoneCtrl = TextEditingController(text: user?.phoneNumber ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');
    final addressCtrl = TextEditingController(text: user?.address ?? '');
    String selectedDob = user?.dob ?? '15 Nov 2001';
    String selectedAnniversary = user?.anniversaryDate ?? '30 Oct 2025';
    String selectedGender = user?.gender ?? 'Male';
    VegModeOption selectedVegMode = user?.vegMode ?? VegModeOption.regular;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(
          color: isDark ? AppColors.gridLine : AppColors.lightBorder,
          width: 1.5,
        ),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.85,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isDark ? AppColors.gridLine : AppColors.lightBorder,
                          ),
                        ),
                        color: isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'EDIT PERSONAL DETAILS',
                            style: AppTypography.headlineSm.copyWith(
                              fontSize: 14,
                              color: isDark ? Colors.white : AppColors.lightTextPrimary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.outline,
                            ),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Text('FULL NAME', style: AppTypography.metadata),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: nameCtrl,
                            style: AppTypography.bodyMd,
                            decoration: const InputDecoration(
                              hintText: 'Enter your name',
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          Text(
                            'CONTACT DETAILS',
                            style: AppTypography.metadata,
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: phoneCtrl,
                            keyboardType: TextInputType.phone,
                            style: AppTypography.bodyMd,
                            decoration: const InputDecoration(
                              hintText: 'Phone number (+91)',
                              prefixIcon: Icon(
                                Icons.phone_outlined,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: AppTypography.bodyMd,
                            decoration: const InputDecoration(
                              hintText: 'Email address',
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          Text(
                            'PRIMARY ADDRESS',
                            style: AppTypography.metadata,
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: addressCtrl,
                            maxLines: 2,
                            style: AppTypography.bodyMd,
                            decoration: const InputDecoration(
                              hintText:
                                  'Flat / House No, Street, Landmark, Pincode',
                              prefixIcon: Icon(
                                Icons.location_on_outlined,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('DOB', style: AppTypography.metadata),
                                    const SizedBox(height: 6),
                                    InkWell(
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime(1995, 8, 15),
                                          firstDate: DateTime(1940),
                                          lastDate: DateTime.now(),
                                        );
                                        if (picked != null) {
                                          setModalState(() {
                                            selectedDob = DateFormat(
                                              'dd MMM yyyy',
                                            ).format(picked);
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppColors.surfaceContainerLow
                                              : AppColors.lightSurfaceWarm,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: isDark
                                                ? AppColors.gridLine
                                                : AppColors.lightBorder,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.cake_outlined,
                                              size: 14,
                                              color: AppColors.primary,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                selectedDob,
                                                style: AppTypography.bodySm,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ANNIVERSARY',
                                      style: AppTypography.metadata,
                                    ),
                                    const SizedBox(height: 6),
                                    InkWell(
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime(2021, 11, 24),
                                          firstDate: DateTime(1960),
                                          lastDate: DateTime.now(),
                                        );
                                        if (picked != null) {
                                          setModalState(() {
                                            selectedAnniversary = DateFormat(
                                              'dd MMM yyyy',
                                            ).format(picked);
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppColors.surfaceContainerLow
                                              : AppColors.lightSurfaceWarm,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: isDark
                                                ? AppColors.gridLine
                                                : AppColors.lightBorder,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.favorite_outline,
                                              size: 14,
                                              color: AppColors.terracotta,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                selectedAnniversary,
                                                style: AppTypography.bodySm,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          Text('GENDER', style: AppTypography.metadata),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            children:
                                [
                                  'Male',
                                  'Female',
                                  'Other',
                                  'Prefer not to say',
                                ].map((g) {
                                  final isSelected = selectedGender == g;
                                  return ChoiceChip(
                                    label: Text(g),
                                    selected: isSelected,
                                    selectedColor: AppColors.primary,
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark
                                              ? AppColors.onSurface
                                              : AppColors.lightTextPrimary),
                                      fontSize: 11,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    onSelected: (val) {
                                      if (val) {
                                        setModalState(() => selectedGender = g);
                                      }
                                    },
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 16),

                          Text(
                            'YOUR VEG MODE PREFERENCE (5 OPTIONS)',
                            style: AppTypography.metadata.copyWith(
                              color: AppColors.sproutGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...VegModeOption.values.map((v) {
                            final isSel = selectedVegMode == v;
                            return InkWell(
                              onTap: () =>
                                  setModalState(() => selectedVegMode = v),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? AppColors.sproutGreen.withValues(
                                          alpha: 0.12,
                                        )
                                      : (isDark
                                          ? AppColors.surfaceContainerLow
                                          : AppColors.lightSurfaceWarm),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSel
                                        ? AppColors.sproutGreen
                                        : (isDark
                                            ? AppColors.gridLine
                                            : AppColors.lightBorder),
                                    width: isSel ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSel
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_off,
                                      color: isSel
                                          ? AppColors.sproutGreen
                                          : AppColors.outline,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            v.label,
                                            style: AppTypography.bodyMd
                                                .copyWith(
                                                  fontWeight: isSel
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                          ),
                                          Text(
                                            v == VegModeOption.regular
                                                ? 'Includes all standard fresh vegetables & spices'
                                                : v == VegModeOption.jain
                                                ? 'Strictly no potatoes, onions, garlic or underground roots'
                                                : v ==
                                                      VegModeOption.swaminarayan
                                                ? 'Pure satvik culinary protocol, no garlic or onions'
                                                : v ==
                                                      VegModeOption
                                                          .withAsafoetida
                                                ? 'Cooked with premium organic compounded Hing'
                                                : 'Guaranteed 100% Hing-free preparation',
                                            style: AppTypography.metadata
                                                .copyWith(
                                                  fontSize: 10,
                                                  color: AppColors.outline,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 20),

                          BrutalistButton(
                            text: 'SAVE PROFILE DETAILS',
                            variant: BrutalistButtonVariant.primary,
                            isFullWidth: true,
                            onPressed: () {
                              profileVm.updatePersonalDetails(
                                name: nameCtrl.text.trim().isEmpty
                                    ? 'Nehal Patel'
                                    : nameCtrl.text.trim(),
                                phoneNumber: phoneCtrl.text.trim().isEmpty
                                    ? '+91 9265754161'
                                    : phoneCtrl.text.trim(),
                                email: emailCtrl.text.trim().isEmpty
                                    ? 'nehalkaneria12345@gmail.com'
                                    : emailCtrl.text.trim(),
                                address: addressCtrl.text.trim().isEmpty
                                    ? 'Flat 202, Yogibhuvan Appartment, Yagnapurush ni Pol, Shahpur, Amdavad, 380001'
                                    : addressCtrl.text.trim(),
                                dob: selectedDob,
                                anniversaryDate: selectedAnniversary,
                                gender: selectedGender,
                                vegMode: selectedVegMode,
                              );
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Profile details updated successfully!',
                                  ),
                                  backgroundColor: AppColors.sproutGreen,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddressBookSheet(ProfileViewModel profileVm) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(
          color: isDark ? AppColors.gridLine : AppColors.lightBorder,
          width: 1.5,
        ),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final addresses = profileVm.savedAddresses;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ADDRESS BOOK',
                            style: AppTypography.headlineSm.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          TextButton.icon(
                            icon: const Icon(
                              Icons.add_location_alt,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            label: const Text(
                              'ADD NEW',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                            onPressed: () {
                              profileVm.addAddress(
                                SavedAddress(
                                  id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
                                  title: 'New Location',
                                  addressLine: '12th Cross, HSR Layout Sector 4, Bengaluru - 560102',
                                  landmark: 'Opposite BDA Complex',
                                ),
                              );
                              setSheetState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'New delivery address added to Address Book',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...addresses.map((a) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: a.isDefault
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : (isDark
                                    ? AppColors.surfaceContainerLow
                                    : AppColors.lightSurfaceWarm),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: a.isDefault
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.gridLine
                                      : AppColors.lightBorder),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                a.title == 'Home'
                                    ? Icons.home_outlined
                                    : a.title == 'Office'
                                    ? Icons.business_outlined
                                    : Icons.location_on_outlined,
                                color: a.isDefault
                                    ? AppColors.primary
                                    : AppColors.outline,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          a.title,
                                          style: AppTypography.bodyMd.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (a.isDefault) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                              vertical: 1,
                                            ),
                                            color: AppColors.primary,
                                            child: const Text(
                                              'DEFAULT',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      a.addressLine,
                                      style: AppTypography.bodySm,
                                    ),
                                    if (a.landmark.isNotEmpty)
                                      Text(
                                        'Landmark: ${a.landmark}',
                                        style: AppTypography.metadata.copyWith(
                                          color: AppColors.outline,
                                          fontSize: 10,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert,
                                  size: 18,
                                  color: AppColors.outline,
                                ),
                                onSelected: (val) {
                                  if (val == 'default') {
                                    profileVm.setDefaultAddress(a.id);
                                    setSheetState(() {});
                                  } else if (val == 'delete') {
                                    profileVm.deleteAddress(a.id);
                                    setSheetState(() {});
                                  }
                                },
                                itemBuilder: (c) => [
                                  const PopupMenuItem(
                                    value: 'default',
                                    child: Text('Set as Default'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text(
                                      'Delete Address',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showOrderInTrainDialog() {
    final pnrCtrl = TextEditingController(text: '8491024810');
    final trainCtrl = TextEditingController(text: '12658 - KSR Bengaluru Mail');
    final coachCtrl = TextEditingController(text: 'B4');
    final berthCtrl = TextEditingController(text: '32');
    String selectedStation = 'Katpadi Jn (KPD)';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? AppColors.gridLine : AppColors.lightBorder,
          ),
        ),
        title: Row(
          children: [
            const Icon(Icons.train_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'ORDER IN TRAIN (IRCTC)',
              style: AppTypography.headlineSm.copyWith(fontSize: 14),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deliver sealed hot meals & dry spice kits directly to your train berth.',
                style: AppTypography.bodySm,
              ),
              const SizedBox(height: 12),
              Text('10-DIGIT PNR NUMBER', style: AppTypography.metadata),
              const SizedBox(height: 4),
              TextField(
                controller: pnrCtrl,
                keyboardType: TextInputType.number,
                style: AppTypography.bodyMd,
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'Enter PNR',
                ),
              ),
              const SizedBox(height: 10),
              Text('TRAIN NAME / NUMBER', style: AppTypography.metadata),
              const SizedBox(height: 4),
              TextField(
                controller: trainCtrl,
                style: AppTypography.bodyMd,
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'Train Details',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('COACH', style: AppTypography.metadata),
                        const SizedBox(height: 4),
                        TextField(
                          controller: coachCtrl,
                          style: AppTypography.bodyMd,
                          decoration: const InputDecoration(
                            isDense: true,
                            hintText: 'e.g. B2',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BERTH / SEAT', style: AppTypography.metadata),
                        const SizedBox(height: 4),
                        TextField(
                          controller: berthCtrl,
                          style: AppTypography.bodyMd,
                          decoration: const InputDecoration(
                            isDense: true,
                            hintText: 'e.g. 45',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text('DELIVERY STATION HALT', style: AppTypography.metadata),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                initialValue: selectedStation,
                isExpanded: true,
                items:
                    [
                          'Katpadi Jn (KPD)',
                          'Jolarpettai Jn (JTJ)',
                          'Bengaluru Cantt (BNC)',
                          'Krantivira Sangolli Rayanna (SBC)',
                        ]
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(
                              s,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (val) {
                  if (val != null) selectedStation = val;
                },
                decoration: const InputDecoration(isDense: true),
              ),
            ],
          ),
        ),
        actionsOverflowButtonSpacing: 8,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: AppColors.outline),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Train Delivery scheduled for PNR: ${pnrCtrl.text} at $selectedStation!',
                  ),
                  backgroundColor: AppColors.sproutGreen,
                ),
              );
            },
            child: const Text(
              'CONFIRM TRAIN DROP',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewAndEarnDialog(ProfileViewModel profileVm) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? AppColors.gridLine : AppColors.lightBorder,
          ),
        ),
        title: Row(
          children: [
            const Icon(Icons.stars, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'REVIEW & EARN J-COINS',
              style: AppTypography.headlineSm.copyWith(fontSize: 14),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text('Your J-Coins Balance:', style: AppTypography.bodySm),
                    Text(
                      '${profileVm.jCoinsBalance} J-Coins',
                      style: AppTypography.numericData.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '4 STEPS TO EARN J-COINS:',
                style: AppTypography.metadata.copyWith(letterSpacing: 1.1),
              ),
              const SizedBox(height: 10),
              _buildReviewStepItem(
                '1',
                'Step 1: Write a review following our culinary guide',
              ),
              _buildReviewStepItem('2', 'Step 2: Submit it for verification'),
              _buildReviewStepItem(
                '3',
                "Step 3: We verify it's helpful for other shoppers",
              ),
              _buildReviewStepItem(
                '4',
                'Step 4: Earn J coins to spend on future orders',
              ),
            ],
          ),
        ),
        actionsOverflowButtonSpacing: 8,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'LATER',
              style: TextStyle(color: AppColors.outline),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              profileVm.completeReviewAndEarnCoins(50);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Review verified! +50 J-Coins credited to your wallet.',
                  ),
                  backgroundColor: AppColors.sproutGreen,
                ),
              );
            },
            child: const Text(
              'WRITE REVIEW (+50 J-COINS)',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStepItem(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                num,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySm.copyWith(height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    int rating = 5;
    final feedbackCtrl = TextEditingController();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          return AlertDialog(
            backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark ? AppColors.gridLine : AppColors.lightBorder,
              ),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.rate_review_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'SEND FEEDBACK',
                  style: AppTypography.headlineSm.copyWith(fontSize: 14),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Rate your experience with Jeerola food, delivery & kitchen masalas:',
                    style: AppTypography.bodySm,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starNum = index + 1;
                      return IconButton(
                        icon: Icon(
                          starNum <= rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 28,
                        ),
                        onPressed: () => setDlgState(() => rating = starNum),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: feedbackCtrl,
                    maxLines: 3,
                    style: AppTypography.bodySm,
                    decoration: const InputDecoration(
                      hintText: 'Share what you loved or how we can improve...',
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
            actionsOverflowButtonSpacing: 8,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(color: AppColors.outline),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Thank you! Your feedback has been sent to our chef & tech team.',
                      ),
                      backgroundColor: AppColors.sproutGreen,
                    ),
                  );
                },
                child: const Text(
                  'SUBMIT FEEDBACK',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLogoutDialog(ProfileViewModel profileVm) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? AppColors.gridLine : AppColors.lightBorder,
          ),
        ),
        title: Row(
          children: [
            const Icon(Icons.logout, color: AppColors.terracotta),
            const SizedBox(width: 8),
            Text(
              'LOG OUT',
              style: AppTypography.headlineSm.copyWith(fontSize: 14),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to log out of Jeerola Kitchen OS?',
          style: AppTypography.bodySm,
        ),
        actionsOverflowButtonSpacing: 8,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: AppColors.outline),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracotta,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              profileVm.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SignInScreen()),
                (route) => false,
              );
            },
            child: const Text(
              'LOG OUT',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileVm = context.watch<ProfileViewModel>();
    final user = profileVm.user;
    final isDark = profileVm.themeMode == 'dark';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('MY PROFILE & ACCOUNT'),
        actions: [
          IconButton(
            icon: profileVm.isSyncingWithServer
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(
                    Icons.sync,
                    color: AppColors.sproutGreen,
                    size: 22,
                  ),
            tooltip: 'Sync with Live Server',
            onPressed: profileVm.isSyncingWithServer
                ? null
                : () async {
                    final success = await profileVm.fetchLatestFromServer();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Synced with live server successfully! ⚡'
                                : 'Loaded latest from local storage cache.',
                          ),
                          backgroundColor: success
                              ? AppColors.sproutGreen
                              : AppColors.secondary,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_note,
              color: AppColors.primary,
              size: 26,
            ),
            tooltip: 'Edit Personal Details',
            onPressed: () => _showEditProfileFormModal(profileVm),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => profileVm.refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. Circle Avatar & User Identity Card
            BrutalistCard(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          InkWell(
                            onTap: () => _showAvatarOptionsSheet(profileVm),
                            child: CircleAvatar(
                              radius: 36,
                              backgroundColor: AppColors.primary,
                              backgroundImage: _getProfileImageProvider(
                                user?.photoUrl,
                              ),
                              child:
                                  (user?.photoUrl == null ||
                                      user!.photoUrl!.isEmpty)
                                  ? Text(
                                      user?.name.isNotEmpty == true
                                          ? user!.name.substring(0, 1)
                                          : 'C',
                                      style: AppTypography.displayXl.copyWith(
                                        fontSize: 32,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: InkWell(
                              onTap: () => _showAvatarOptionsSheet(profileVm),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    user?.name ?? 'Nehal Patel',
                                    style: AppTypography.headlineSm.copyWith(
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  onPressed: () =>
                                      _showEditProfileFormModal(profileVm),
                                ),
                              ],
                            ),
                            Text(
                              user?.phoneNumber ?? '+91 9265754161',
                              style: AppTypography.bodySm,
                            ),
                            Text(
                              user?.email ?? 'nehalkaneria12345@gmail.com',
                              style: AppTypography.metadata.copyWith(
                                color: AppColors.outline,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.sproutGreen.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: AppColors.sproutGreen,
                                    ),
                                  ),
                                  child: Text(
                                    user?.vegMode.shortBadge ?? 'REGULAR',
                                    style: AppTypography.metadata.copyWith(
                                      color: AppColors.sproutGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.surfaceContainerHigh
                                        : AppColors.lightSurfaceWarm,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: isDark
                                          ? AppColors.gridLine
                                          : AppColors.lightBorder,
                                    ),
                                  ),
                                  child: Text(
                                    user?.gender.toUpperCase() ?? 'MALE',
                                    style: AppTypography.metadata.copyWith(
                                      color: AppColors.outline,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // Metadata Columns
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildMetaColumn(
                          Icons.cake_outlined,
                          'DOB',
                          user?.dob ?? '15 Aug 1995',
                        ),
                      ),
                      Expanded(
                        child: _buildMetaColumn(
                          Icons.favorite_outline,
                          'ANNIVERSARY',
                          user?.anniversaryDate ?? '24 Nov 2021',
                        ),
                      ),
                      Expanded(
                        child: _buildMetaColumn(
                          Icons.stars,
                          'J-COINS',
                          '${profileVm.jCoinsBalance} Coins',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          user?.address ?? 'Indiranagar, Bengaluru',
                          style: AppTypography.metadata.copyWith(
                            color: isDark
                                ? AppColors.onSurfaceVariant
                                : AppColors.lightTextSecondary,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. Foodie Attraction & Taste Palate Profile
            InkWell(
              onTap: () {
                AppToast.info(
                  '🌟 Gold Foodie Elite: Level 4/5 Spice Palate & 10% Masala Perks Active!',
                  isDark: isDark,
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: BrutalistCard(
                borderColor: isDark
                    ? const Color(0xFFFFB300)
                    : const Color(0xFFE08D3C),
                backgroundColor: isDark
                    ? AppColors.surfaceContainer
                    : Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.stars_rounded,
                          color: isDark
                              ? AppColors.saffronYellow
                              : const Color(0xFFD97706),
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'FOODIE ATTRACTION & PALATE',
                            style: AppTypography.metadata.copyWith(
                              color: isDark
                                  ? AppColors.saffronYellow
                                  : const Color(0xFFB45309),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      const Color(0xFFFFB300),
                                      const Color(0xFFFF8F00),
                                    ]
                                  : [
                                      const Color(0xFFF59E0B),
                                      const Color(0xFFD97706),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withValues(alpha: 0.35),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.military_tech,
                                color: Colors.white,
                                size: 12,
                              ),
                              SizedBox(width: 3),
                              Text(
                                'GOLD FOODIE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.amber.withValues(alpha: 0.16)
                                : const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? Colors.amber.withValues(alpha: 0.4)
                                  : const Color(0xFFFCD34D),
                              width: 1.5,
                            ),
                          ),
                          child: const Column(
                            children: [
                              Text(
                                '4.9',
                                style: TextStyle(
                                  color: Color(0xFFD97706),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                '★ TOP TASTER',
                                style: TextStyle(
                                  color: Color(0xFFB45309),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.local_fire_department_rounded,
                                    color: AppColors.primary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Spice Tolerance: Medium-High (Level 4/5)',
                                      style: AppTypography.bodySm.copyWith(
                                        color: isDark
                                            ? AppColors.onSurface
                                            : AppColors.lightTextPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '128 verified dish reviews • 94% helpful upvotes across Bengaluru.',
                                style: AppTypography.metadata.copyWith(
                                  color: isDark
                                      ? AppColors.outline
                                      : AppColors.lightTextSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Foodie Attraction Perks & Badges
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildFoodiePerkChip(
                          icon: Icons.whatshot,
                          label: 'Level 4 Heat',
                          color: AppColors.primary,
                          isDark: isDark,
                          onTap: () => AppToast.info(
                            '🌶️ Palate Profile: Calibrated for spicy coastal & south Indian curries',
                            isDark: isDark,
                          ),
                        ),
                        _buildFoodiePerkChip(
                          icon: Icons.verified_rounded,
                          label: 'Top 5% Taster',
                          color: const Color(0xFFD97706),
                          isDark: isDark,
                          onTap: () => AppToast.info(
                            '👑 Gold Foodie: Ranked among top 5% taste evaluators this season!',
                            isDark: isDark,
                          ),
                        ),
                        _buildFoodiePerkChip(
                          icon: Icons.savings_outlined,
                          label: '10% Masala Perk',
                          color: AppColors.sproutGreen,
                          isDark: isDark,
                          onTap: () => AppToast.success(
                            '🎁 Foodie Attraction: 10% auto-cashback on all fresh masala blends!',
                            isDark: isDark,
                          ),
                        ),
                        _buildFoodiePerkChip(
                          icon: Icons.restaurant_menu_rounded,
                          label: 'VIP Tasting Access',
                          color: const Color(0xFF8B5CF6),
                          isDark: isDark,
                          onTap: () => AppToast.info(
                            '🍽️ Exclusive invite to secret menu tastings by Jeerola Partner Chefs',
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 3. Appearance (2 Modes of Themes: Dark & Light Mode)
            BrutalistCard(
              backgroundColor: isDark
                  ? AppColors.surfaceContainer
                  : Colors.white,
              borderColor: isDark ? AppColors.gridLine : AppColors.lightBorder,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'APPEARANCE & THEMES (2 MODES)',
                          style: AppTypography.headlineSm.copyWith(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.onSurface
                                : AppColors.lightTextPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isDark ? 'DARK MODE' : 'LIGHT MODE',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            if (!isDark) {
                              profileVm.setThemeMode('dark');
                              AppToast.info(
                                'Switched to Dark Gourmet Kitchen Mode 🌙',
                                isDark: false,
                              );
                            } else {
                              AppToast.show(
                                'Already in Dark Gourmet Kitchen Mode 🌙',
                                isDark: true,
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.primary
                                  : (isDark
                                        ? AppColors.surfaceContainerLow
                                        : Colors.white),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.primary
                                    : AppColors.lightBorder,
                                width: isDark ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isDark
                                      ? Icons.dark_mode_rounded
                                      : Icons.dark_mode_outlined,
                                  size: 16,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.lightTextSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Dark Mode',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.lightTextSecondary,
                                    fontSize: 12,
                                    fontWeight: isDark
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                  ),
                                ),
                                if (isDark) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.check_circle,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            if (isDark) {
                              profileVm.setThemeMode('light');
                              AppToast.success(
                                'Switched to Crisp Light Mode ☀️',
                                isDark: true,
                              );
                            } else {
                              AppToast.show(
                                'Already in Crisp Light Mode ☀️',
                                isDark: false,
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: !isDark
                                  ? AppColors.primary
                                  : AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: !isDark
                                    ? AppColors.primary
                                    : (isDark
                                          ? AppColors.gridLine
                                          : AppColors.lightBorder),
                                width: !isDark ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  !isDark
                                      ? Icons.light_mode_rounded
                                      : Icons.light_mode_outlined,
                                  size: 16,
                                  color: !isDark
                                      ? Colors.white
                                      : AppColors.outline,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Light Mode',
                                  style: TextStyle(
                                    color: !isDark
                                        ? Colors.white
                                        : AppColors.onSurface,
                                    fontSize: 12,
                                    fontWeight: !isDark
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                  ),
                                ),
                                if (!isDark) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.check_circle,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 4. Food Delivery Section Header
            Text(
              'FOOD DELIVERY & ORDERS',
              style: AppTypography.metadata.copyWith(
                letterSpacing: 1.1,
                color: isDark ? AppColors.secondary : AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),

            // Your Collections Preference
            BrutalistCard(
              backgroundColor: isDark
                  ? AppColors.surfaceContainer
                  : Colors.white,
              borderColor: isDark ? AppColors.gridLine : AppColors.lightBorder,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'YOUR COLLECTIONS PREFERENCE',
                        style: AppTypography.metadata.copyWith(
                          color: isDark
                              ? AppColors.secondary
                              : AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(
                        Icons.swap_horiz,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => profileVm.setCollectionPreference(
                            'deliver_to_address',
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  profileVm.collectionPreference ==
                                      'deliver_to_address'
                                  ? AppColors.primary.withValues(
                                      alpha: isDark ? 0.2 : 0.1,
                                    )
                                  : (isDark
                                        ? AppColors.surfaceContainerLow
                                        : AppColors.lightSurfaceWarm),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    profileVm.collectionPreference ==
                                        'deliver_to_address'
                                    ? AppColors.primary
                                    : (isDark
                                          ? AppColors.gridLine
                                          : AppColors.lightBorder),
                                width:
                                    profileVm.collectionPreference ==
                                        'deliver_to_address'
                                    ? 1.5
                                    : 1.0,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.delivery_dining,
                                  size: 18,
                                  color:
                                      profileVm.collectionPreference ==
                                          'deliver_to_address'
                                      ? AppColors.primary
                                      : (isDark
                                            ? AppColors.outline
                                            : AppColors.lightTextTertiary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Deliver to Address',
                                  style: AppTypography.bodySm.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.lightTextPrimary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () =>
                              profileVm.setCollectionPreference('take_away'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  profileVm.collectionPreference == 'take_away'
                                  ? AppColors.primary.withValues(
                                      alpha: isDark ? 0.2 : 0.1,
                                    )
                                  : (isDark
                                        ? AppColors.surfaceContainerLow
                                        : AppColors.lightSurfaceWarm),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    profileVm.collectionPreference ==
                                        'take_away'
                                    ? AppColors.primary
                                    : (isDark
                                          ? AppColors.gridLine
                                          : AppColors.lightBorder),
                                width:
                                    profileVm.collectionPreference ==
                                        'take_away'
                                    ? 1.5
                                    : 1.0,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.storefront,
                                  size: 18,
                                  color:
                                      profileVm.collectionPreference ==
                                          'take_away'
                                      ? AppColors.primary
                                      : (isDark
                                            ? AppColors.outline
                                            : AppColors.lightTextTertiary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Take Away from Store',
                                  style: AppTypography.bodySm.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.lightTextPrimary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            _buildActionTile(
              icon: Icons.receipt_long,
              color: AppColors.primary,
              title: 'Previous Orders',
              subtitle:
                  '${profileVm.pastOrders.length} recent orders • Re-order & track invoices',
              onTap: () => _showPreviousOrdersModal(profileVm),
            ),
            _buildActionTile(
              icon: Icons.menu_book,
              color: AppColors.sproutGreen,
              title: 'Address Book',
              subtitle:
                  '${profileVm.savedAddresses.length} saved addresses (Home, Office, Parents)',
              onTap: () => _showAddressBookSheet(profileVm),
            ),
            _buildActionTile(
              icon: Icons.train,
              color: AppColors.secondaryOrange,
              title: 'Order in Train (IRCTC Berth Delivery)',
              subtitle: 'Direct drop at your scheduled platform & coach halt',
              onTap: _showOrderInTrainDialog,
            ),
            _buildActionTile(
              icon: Icons.reviews,
              color: AppColors.sproutGreen,
              title: 'Review and Earn J-Coins',
              subtitle: '4 steps to earn up to 100 J-Coins per helpful review',
              trailingBadge: '${profileVm.jCoinsBalance} Coins',
              onTap: () => _showReviewAndEarnDialog(profileVm),
            ),
            _buildActionTile(
              icon: Icons.currency_rupee,
              color: AppColors.terracotta,
              title: 'Your Refund History',
              subtitle:
                  '${profileVm.refundHistory.length} refunds tracked • 100% instant refund guarantee',
              onTap: () => _showRefundHistoryModal(profileVm),
            ),
            _buildActionTile(
              icon: Icons.favorite_border,
              color: Colors.redAccent,
              title: 'Your Wishlist',
              subtitle:
                  '${profileVm.wishlistItems.length} saved spices and kitchen dishes',
              onTap: () => _showWishlistModal(profileVm),
            ),
            _buildActionTile(
              icon: Icons.card_giftcard,
              color: AppColors.primary,
              title: 'E-Gift Cards',
              subtitle: 'Active balance: ₹1,000 • Buy or redeem gift vouchers',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: isDark
                        ? AppColors.surfaceContainerHigh
                        : AppColors.lightSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isDark ? AppColors.gridLine : AppColors.lightBorder,
                        width: 1,
                      ),
                    ),
                    content: Row(
                      children: [
                        const Icon(
                          Icons.card_giftcard,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'E-Gift Card balance: ₹1,000 available for food checkout!',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : AppColors.lightTextPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            _buildActionTile(
              icon: Icons.card_membership,
              color: Colors.amber,
              title: 'Rewards & Scratch Cards',
              subtitle: '3 active discount coupons unlocked',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: isDark
                        ? AppColors.surfaceContainerHigh
                        : AppColors.lightSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isDark ? AppColors.gridLine : AppColors.lightBorder,
                        width: 1,
                      ),
                    ),
                    content: Row(
                      children: [
                        const Icon(
                          Icons.stars,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Vouchers active: FLAT ₹150 OFF + Free Simmer Delivery',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : AppColors.lightTextPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            // 5. Hear from Restaurants Permission Toggle
            BrutalistCard(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.primary,
                title: Text(
                  'Hear from Restaurants',
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Permission to share your contact details with partner restaurants for custom cooking instructions & allergen alerts.',
                  style: AppTypography.bodySm,
                ),
                value: profileVm.hearFromRestaurants,
                onChanged: (val) {
                  profileVm.setHearFromRestaurants(val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        val
                            ? 'Restaurant contact permission granted'
                            : 'Restaurant contact permission revoked',
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // 6. Manage Recommendations
            BrutalistCard(
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                iconColor: AppColors.primary,
                collapsedIconColor: AppColors.outline,
                title: Text(
                  'MANAGE RECOMMENDATIONS',
                  style: AppTypography.headlineSm.copyWith(fontSize: 13),
                ),
                subtitle: Text(
                  'Personalize recipe alerts, masala restocks & cuisine deals',
                  style: AppTypography.bodySm,
                ),
                children: [
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Recipe Suggestions based on Taste Palate',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: profileVm.recRecipeMatches,
                    onChanged: (val) =>
                        profileVm.updateRecommendation(recipeMatches: val),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Masala Pouch Refill Alerts (Below 3 pouches)',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: profileVm.recMasalaAlerts,
                    onChanged: (val) =>
                        profileVm.updateRecommendation(masalaAlerts: val),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Local Supermarket Dark Store Flash Discounts',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: profileVm.recCuisineDeals,
                    onChanged: (val) =>
                        profileVm.updateRecommendation(cuisineDeals: val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 7. Preferences & System
            Text(
              'PREFERENCES & SYSTEM',
              style: AppTypography.metadata.copyWith(letterSpacing: 1.1),
            ),
            const SizedBox(height: 8),

            // Theme & Appearance Switcher
            BrutalistCard(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.primary,
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: isDark ? AppColors.primary : Colors.amber[800],
                    size: 22,
                  ),
                ),
                title: Text(
                  'Appearance: ${isDark ? "Dark Gourmet Kitchen" : "Crisp Light Mode"}',
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  isDark
                      ? 'Tap to switch to crisp light theme'
                      : 'Tap to switch to dark kitchen theme',
                  style: AppTypography.bodySm,
                ),
                value: !isDark,
                onChanged: (val) {
                  final newMode = val ? 'light' : 'dark';
                  profileVm.setThemeMode(newMode);
                  if (val) {
                    AppToast.success(
                      'Switched to Crisp Light Mode ☀️',
                      isDark: true,
                    );
                  } else {
                    AppToast.info(
                      'Switched to Dark Gourmet Kitchen Mode 🌙',
                      isDark: false,
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
            _buildActionTile(
              icon: Icons.feedback_outlined,
              color: AppColors.sproutGreen,
              title: 'Your Feedback & Send Feedback',
              subtitle: 'Share comments and rate store service',
              onTap: _showFeedbackDialog,
            ),
            _buildActionTile(
              icon: Icons.accessibility_new,
              color: AppColors.primary,
              title: 'Accessibility',
              subtitle: 'Screen reader hints, high contrast, haptic clicks & font scale',
              onTap: _showAccessibilityModal,
            ),
            _buildActionTile(
              icon: Icons.security,
              color: AppColors.secondaryOrange,
              title: 'Account Settings & Security',
              subtitle: 'Manage active devices, password & 2FA protection',
              onTap: _showAccountSecurityModal,
            ),
            _buildActionTile(
              icon: Icons.notifications_none,
              color: AppColors.sproutGreen,
              title: 'Notification Settings',
              subtitle: 'Order tracking SMS, WhatsApp alerts & kitchen timers',
              onTap: _showNotificationSettingsModal,
            ),
            _buildActionTile(
              icon: Icons.payment,
              color: const Color(0xFF0288D1),
              title: 'Razorpay Payment Gateway & Methods',
              subtitle: 'UPI, saved cards, netbanking & live test gateway',
              trailingBadge: 'RZP SECURE',
              onTap: _showRazorpaySettingsModal,
            ),
            _buildActionTile(
              icon: Icons.info_outline,
              color: AppColors.outline,
              title: 'General Information',
              subtitle:
                  'About Jeerola v2.4.0 • Terms of Service • Privacy Policy',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Jeerola - Restaurant & Quick Commerce',
                  applicationVersion: 'v2.4.0 (Enterprise)',
                  applicationLegalese: '© 2026 Jeerola Technologies Pvt. Ltd.\nAll spices FSSAI certified.',
                );
              },
            ),

            const SizedBox(height: 20),

            // 8. Logout Button
            BrutalistButton(
              text: 'LOG OUT OF JEEROLA',
              variant: BrutalistButtonVariant.outline,
              isFullWidth: true,
              onPressed: () => _showLogoutDialog(profileVm),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaColumn(IconData icon, String title, String val) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(height: 2),
        Text(
          title,
          style: AppTypography.metadata.copyWith(
            fontSize: 8,
            color: AppColors.outline,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 1),
        Text(
          val,
          style: AppTypography.bodySm.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFoodiePerkChip({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.35 : 0.25),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    String? trailingBadge,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isDark ? AppColors.surfaceContainer : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isDark ? AppColors.gridLine : AppColors.lightBorder,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          dense: true,
          leading: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          title: Text(
            title,
            style: AppTypography.bodyMd.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            subtitle,
            style: AppTypography.metadata.copyWith(
              color: AppColors.outline,
              fontSize: 9.5,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailingBadge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    trailingBadge,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: AppColors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPreviousOrdersModal(ProfileViewModel profileVm) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(
          color: isDark ? AppColors.gridLine : AppColors.lightBorder,
          width: 1.5,
        ),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PREVIOUS ORDERS',
                        style: AppTypography.headlineSm.copyWith(
                          fontSize: 14,
                          color: isDark
                              ? Colors.white
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.outline),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...profileVm.pastOrders.map((ord) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceContainerLow
                            : AppColors.lightSurfaceWarm,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? AppColors.gridLine
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                ord.id,
                                style: AppTypography.metadata.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '₹${ord.totalAmount.toStringAsFixed(2)}',
                                style: AppTypography.numericData.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            ord.storeName,
                            style: AppTypography.bodySm.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            ord.dateStr,
                            style: AppTypography.metadata.copyWith(
                              color: AppColors.outline,
                              fontSize: 9,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...ord.items.map(
                            (item) => Text(
                              '• $item',
                              style: AppTypography.bodySm.copyWith(
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  InvoiceDownloadHelper.downloadInvoice(
                                    context: context,
                                    orderId: ord.id,
                                    items: ord.items
                                        .map(
                                          (item) => {
                                            'name': item,
                                            'qty': 1,
                                            'price':
                                                ord.totalAmount /
                                                (ord.items.isEmpty
                                                    ? 1
                                                    : ord.items.length),
                                          },
                                        )
                                        .toList(),
                                    totalAmount: ord.totalAmount,
                                    storeName: ord.storeName,
                                    isDark: isDark,
                                  );
                                },
                                icon: const Icon(
                                  Icons.picture_as_pdf_outlined,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                                label: const Text(
                                  'DOWNLOAD INVOICE',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Items from ${ord.id} added to cart!',
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'RE-ORDER',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRefundHistoryModal(ProfileViewModel profileVm) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(
          color: isDark ? AppColors.gridLine : AppColors.lightBorder,
          width: 1.5,
        ),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'REFUND HISTORY',
                        style: AppTypography.headlineSm.copyWith(
                          fontSize: 14,
                          color: isDark
                              ? Colors.white
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.outline),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...profileVm.refundHistory.map((ref) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceContainerLow
                            : AppColors.lightSurfaceWarm,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.sproutGreen.withValues(
                            alpha: isDark ? 0.6 : 0.4,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                ref['id'] ?? '',
                                style: AppTypography.metadata.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.onSurfaceVariant
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                              Text(
                                ref['amount'] ?? '',
                                style: AppTypography.numericData.copyWith(
                                  color: AppColors.sproutGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            ref['item'] ?? '',
                            style: AppTypography.bodySm.copyWith(
                              color: isDark
                                  ? Colors.white
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                ref['status'] ?? '',
                                style: AppTypography.metadata.copyWith(
                                  color: AppColors.sproutGreen,
                                  fontSize: 9,
                                ),
                              ),
                              Text(
                                ref['date'] ?? '',
                                style: AppTypography.metadata.copyWith(
                                  color: AppColors.outline,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showWishlistModal(ProfileViewModel profileVm) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(
          color: isDark ? AppColors.gridLine : AppColors.lightBorder,
          width: 1.5,
        ),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setWState) {
            final items = profileVm.wishlistItems;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'YOUR WISHLIST',
                            style: AppTypography.headlineSm.copyWith(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.outline,
                            ),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Your wishlist is empty.',
                            style: AppTypography.bodySm.copyWith(
                              color: isDark
                                  ? AppColors.onSurfaceVariant
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        )
                      else
                        ...items.map((item) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surfaceContainerLow
                                  : AppColors.lightSurfaceWarm,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.gridLine
                                    : AppColors.lightBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.favorite,
                                  color: Colors.redAccent,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: AppTypography.bodySm.copyWith(
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: AppColors.outline,
                                  ),
                                  onPressed: () {
                                    profileVm.removeWishlistItem(item);
                                    setWState(() {});
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAccessibilityModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(
          color: isDark ? AppColors.gridLine : AppColors.lightBorder,
          width: 1.5,
        ),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setAccState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.accessibility_new,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'ACCESSIBILITY & DISPLAY',
                                style: AppTypography.headlineSm.copyWith(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.outline,
                            ),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildSettingsSwitchTile(
                        icon: Icons.contrast,
                        title: 'High Contrast Mode',
                        subtitle: 'Enhance text contrast and border definitions across the app',
                        value: _highContrast,
                        isDark: isDark,
                        onChanged: (val) {
                          setAccState(() => _highContrast = val);
                          AppToast.info(
                            val
                                ? 'High Contrast Mode enabled'
                                : 'High Contrast Mode disabled',
                            isDark: isDark,
                          );
                        },
                      ),
                      _buildSettingsSwitchTile(
                        icon: Icons.record_voice_over,
                        title: 'Screen Reader Optimizations',
                        subtitle: 'Enhanced semantics, audio badges, and descriptive aria labels',
                        value: _screenReader,
                        isDark: isDark,
                        onChanged: (val) {
                          setAccState(() => _screenReader = val);
                          AppToast.info(
                            val
                                ? 'Screen reader hints enabled'
                                : 'Screen reader hints disabled',
                            isDark: isDark,
                          );
                        },
                      ),
                      _buildSettingsSwitchTile(
                        icon: Icons.vibration,
                        title: 'Haptic Clicks & Tactile Feedback',
                        subtitle: 'Gentle vibration response when adjusting timers or quantity',
                        value: _hapticClicks,
                        isDark: isDark,
                        onChanged: (val) {
                          setAccState(() => _hapticClicks = val);
                          AppToast.info(
                            val ? 'Haptic feedback on' : 'Haptic feedback off',
                            isDark: isDark,
                          );
                        },
                      ),
                      _buildSettingsSwitchTile(
                        icon: Icons.slow_motion_video,
                        title: 'Reduced Motion Animations',
                        subtitle:
                            'Disables pulsing banners and rapid transitions',
                        value: _reducedMotion,
                        isDark: isDark,
                        onChanged: (val) {
                          setAccState(() => _reducedMotion = val);
                          AppToast.info(
                            val
                                ? 'Animations minimized'
                                : 'Standard motion restored',
                            isDark: isDark,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'FONT SIZE SCALE',
                        style: AppTypography.metadata.copyWith(
                          color: AppColors.secondary,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children:
                            [
                              'Standard (100%)',
                              'Large (115%)',
                              'Extra (130%)',
                            ].map((scale) {
                              final isSelected = _fontScale == scale;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      setAccState(() => _fontScale = scale);
                                      AppToast.success(
                                        'Text scaled to $scale',
                                        isDark: isDark,
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primary
                                            : (isDark
                                                  ? AppColors
                                                        .surfaceContainerLow
                                                  : AppColors.lightSurfaceWarm),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primary
                                              : (isDark
                                                    ? AppColors.gridLine
                                                    : AppColors.lightBorder),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          scale.split(' ').first,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : (isDark
                                                      ? Colors.white
                                                      : AppColors
                                                            .lightTextPrimary),
                                            fontSize: 11,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAccountSecurityModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(
          color: isDark ? AppColors.gridLine : AppColors.lightBorder,
          width: 1.5,
        ),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSecState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryOrange.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.security,
                                  color: AppColors.secondaryOrange,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'SECURITY & ACTIVE DEVICES',
                                style: AppTypography.headlineSm.copyWith(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.outline,
                            ),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildSettingsSwitchTile(
                        icon: Icons.verified_user,
                        title: 'Two-Factor Authentication (2FA)',
                        subtitle: 'SMS OTP or Authenticator prompt when signing in on new device',
                        value: _twoFactorAuth,
                        isDark: isDark,
                        onChanged: (val) {
                          setSecState(() => _twoFactorAuth = val);
                          AppToast.info(
                            val ? '2FA Enabled' : '2FA Disabled',
                            isDark: isDark,
                          );
                        },
                      ),
                      _buildSettingsSwitchTile(
                        icon: Icons.fingerprint,
                        title: 'Biometric Order Authorization',
                        subtitle: 'Fingerprint or Face ID required before checkout confirmation',
                        value: _biometricUnlock,
                        isDark: isDark,
                        onChanged: (val) {
                          setSecState(() => _biometricUnlock = val);
                          AppToast.info(
                            val
                                ? 'Biometric authorization active'
                                : 'Biometric authorization disabled',
                            isDark: isDark,
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'ACTIVE LOGGED-IN SESSIONS',
                        style: AppTypography.metadata.copyWith(
                          color: AppColors.secondary,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceContainerLow
                              : AppColors.lightSurfaceWarm,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark
                                ? AppColors.gridLine
                                : AppColors.lightBorder,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone_android,
                                  color: AppColors.sproutGreen,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Samsung Galaxy S24 Ultra (This Phone)',
                                        style: AppTypography.bodySm.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : AppColors.lightTextPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Amdavad, Gujarat • Active now',
                                        style: AppTypography.metadata.copyWith(
                                          color: isDark
                                              ? AppColors.outline
                                              : AppColors.lightTextTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.sproutGreen.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'THIS DEVICE',
                                    style: TextStyle(
                                      color: AppColors.sproutGreen,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            Row(
                              children: [
                                const Icon(
                                  Icons.laptop,
                                  color: AppColors.outline,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Chrome on macOS (Kitchen Studio)',
                                        style: AppTypography.bodySm.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : AppColors.lightTextPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Bengaluru, Karnataka • 2 days ago',
                                        style: AppTypography.metadata.copyWith(
                                          color: isDark
                                              ? AppColors.outline
                                              : AppColors.lightTextTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                AppToast.success(
                                  'Password reset link sent to your registered email ✉️',
                                  isDark: isDark,
                                );
                              },
                              icon: const Icon(
                                Icons.lock_reset,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              label: const Text(
                                'Change Password',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                AppToast.info(
                                  'Logged out from 1 other active device 🔒',
                                  isDark: isDark,
                                );
                              },
                              icon: const Icon(
                                Icons.logout,
                                size: 16,
                                color: AppColors.terracotta,
                              ),
                              label: const Text(
                                'Log Out Others',
                                style: TextStyle(
                                  color: AppColors.terracotta,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.terracotta,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showNotificationSettingsModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(
          color: isDark ? AppColors.gridLine : AppColors.lightBorder,
          width: 1.5,
        ),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setNotifState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.sproutGreen.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.notifications_active,
                                  color: AppColors.sproutGreen,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'NOTIFICATION PREFERENCES',
                                style: AppTypography.headlineSm.copyWith(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.outline,
                            ),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildSettingsSwitchTile(
                        icon: Icons.local_shipping,
                        title: 'Order Status & Live Tracking',
                        subtitle: 'Instant SMS & Push alert when rider leaves kitchen and arrives at door',
                        value: _orderTrackingNotif,
                        isDark: isDark,
                        onChanged: (val) {
                          setNotifState(() => _orderTrackingNotif = val);
                          AppToast.info(
                            val ? 'Order alerts on' : 'Order alerts off',
                            isDark: isDark,
                          );
                        },
                      ),
                      _buildSettingsSwitchTile(
                        icon: Icons.chat,
                        title: 'WhatsApp Alerts & Receipts',
                        subtitle: 'Receive PDF tax invoices, delivery updates, and rider phone numbers via WhatsApp',
                        value: _whatsAppAlerts,
                        isDark: isDark,
                        onChanged: (val) {
                          setNotifState(() => _whatsAppAlerts = val);
                          AppToast.info(
                            val
                                ? 'WhatsApp updates on'
                                : 'WhatsApp updates off',
                            isDark: isDark,
                          );
                        },
                      ),
                      _buildSettingsSwitchTile(
                        icon: Icons.timer,
                        title: 'Cooking Alarms & Step Reminders',
                        subtitle: 'Sound alarms when simmering timers and flame reduction periods elapse',
                        value: _cookingTimersNotif,
                        isDark: isDark,
                        onChanged: (val) {
                          setNotifState(() => _cookingTimersNotif = val);
                          AppToast.info(
                            val
                                ? 'Cooking timers active'
                                : 'Cooking timers muted',
                            isDark: isDark,
                          );
                        },
                      ),
                      _buildSettingsSwitchTile(
                        icon: Icons.local_offer,
                        title: 'Fresh Deals & Masala Restock Alerts',
                        subtitle: 'Get notified when your favorite masala blends go on dark store flash sale',
                        value: _dealsNotif,
                        isDark: isDark,
                        onChanged: (val) {
                          setNotifState(() => _dealsNotif = val);
                          AppToast.info(
                            val ? 'Deals alerts on' : 'Deals alerts off',
                            isDark: isDark,
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showRazorpaySettingsModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileVm = context.read<ProfileViewModel>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(
          color: isDark ? AppColors.gridLine : AppColors.lightBorder,
          width: 1.5,
        ),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0C2340),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF0288D1),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.payment,
                              color: Color(0xFF0288D1),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'RAZORPAY PAYMENT GATEWAY',
                            style: AppTypography.headlineSm.copyWith(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.outline),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Merchant badge
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceContainerLow
                          : AppColors.lightSurfaceWarm,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF0288D1).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified,
                          color: Color(0xFF0288D1),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Merchant ID: rzp_test_xeVAJ5Jg2C932Q',
                                style: AppTypography.bodySm.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              Text(
                                'Certified PCI-DSS Level 1 & 256-bit SSL Gateway',
                                style: AppTypography.metadata.copyWith(
                                  color: isDark
                                      ? AppColors.outline
                                      : AppColors.lightTextTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    'SUPPORTED PAYMENT MODES',
                    style: AppTypography.metadata.copyWith(
                      color: AppColors.secondary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),

                  _buildPaymentRailItem(
                    icon: Icons.account_balance_wallet,
                    title: 'UPI (Zero Surcharge)',
                    subtitle: 'Google Pay, PhonePe, Paytm, BHIM, Cred UPI',
                    isDark: isDark,
                  ),
                  _buildPaymentRailItem(
                    icon: Icons.credit_card,
                    title: 'Credit & Debit Cards',
                    subtitle:
                        'Visa, MasterCard, RuPay, Maestro with auto-detect',
                    isDark: isDark,
                  ),
                  _buildPaymentRailItem(
                    icon: Icons.account_balance,
                    title: 'Netbanking (58+ Banks)',
                    subtitle: 'HDFC, ICICI, SBI, Axis, Kotak instant payment',
                    isDark: isDark,
                  ),

                  const SizedBox(height: 20),

                  BrutalistButton(
                    text: 'TEST RAZORPAY GATEWAY CHECKOUT',
                    variant: BrutalistButtonVariant.primary,
                    isFullWidth: true,
                    icon: const Icon(Icons.bolt, size: 18, color: Colors.white),
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      final testOrderId = 'TEST-RZP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                      final result =
                          await RazorpayPaymentService.openRazorpayCheckout(
                            context: context,
                            amountInRupees: 199.0,
                            orderId: testOrderId,
                            customerName: profileVm.user?.name ?? 'Gourmet Patron',
                            customerEmail:
                                profileVm.user?.email ??
                                'nehalkaneria12345@gmail.com',
                            customerContact:
                                profileVm.user?.phoneNumber ?? '+91 9265754161',
                            note: 'Test Gateway - Royal Shahi Paneer Masala Kit',
                          );
                      if (result != null && result.isSuccess) {
                        AppToast.success(
                          'Payment Successful via Razorpay (${result.paymentId})! 💳',
                          isDark: isDark,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceContainerLow
            : AppColors.lightSurfaceWarm,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.gridLine : AppColors.lightBorder,
        ),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        activeThumbColor: AppColors.primary,
        secondary: Icon(icon, color: AppColors.primary, size: 20),
        title: Text(
          title,
          style: AppTypography.bodySm.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.metadata.copyWith(
            color: isDark ? AppColors.outline : AppColors.lightTextSecondary,
            fontSize: 9.5,
          ),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildPaymentRailItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceContainerLow
            : AppColors.lightSurfaceWarm,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.gridLine : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.metadata.copyWith(
                    color: isDark
                        ? AppColors.outline
                        : AppColors.lightTextTertiary,
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
