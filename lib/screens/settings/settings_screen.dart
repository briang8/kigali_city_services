import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUidProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
          title: const Text('Settings'), automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profile card ───────────────────────────────────────
            ref.watch(userProfileProvider(uid)).when(
                  loading: () => const _ProfileSkeleton(),
                  error: (_, __) => const _ProfileSkeleton(),
                  data: (profile) {
                    final displayName = profile?.displayName ?? '';
                    final email = profile?.email ?? '';
                    // Avatar letter: name initial → email initial → '?'
                    final avatarLetter = displayName.isNotEmpty
                        ? displayName[0].toUpperCase()
                        : (email.isNotEmpty ? email[0].toUpperCase() : '?');
                    // Display name: full name → email prefix → 'User'
                    final nameDisplay = displayName.isNotEmpty
                        ? displayName
                        : (email.isNotEmpty ? email.split('@').first : 'User');
                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.accent.withOpacity(0.15),
                            child: Text(
                              avatarLetter,
                              style: const TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nameDisplay,
                                  style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  email,
                                  style: const TextStyle(
                                      color: AppColors.textMuted, fontSize: 13),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Member since ${_formatDate(profile?.createdAt ?? DateTime.now())}',
                                  style: const TextStyle(
                                      color: AppColors.textMuted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            const SizedBox(height: 28),

            // ── Notifications section ──────────────────────────────
            _SectionLabel('Notifications'),
            const SizedBox(height: 12),

            _ToggleTile(
              icon: Icons.notifications_outlined,
              title: 'Push Notifications',
              subtitle: 'Receive updates about new services in Kigali',
              value: settings.notificationsEnabled,
              onChanged: (v) =>
                  ref.read(settingsProvider.notifier).toggleNotifications(v),
            ),
            const SizedBox(height: 10),
            _ToggleTile(
              icon: Icons.location_on_outlined,
              title: 'Nearby Alerts',
              subtitle: 'Get notified about services near your location',
              value: settings.nearbyAlertsEnabled,
              onChanged: (v) =>
                  ref.read(settingsProvider.notifier).toggleNearbyAlerts(v),
            ),
            const SizedBox(height: 28),

            // ── App info section ───────────────────────────────────
            _SectionLabel('About'),
            const SizedBox(height: 12),

            _InfoTile(
                icon: Icons.info_outline,
                title: 'Version',
                trailing: const Text('1.0.0',
                    style:
                        TextStyle(color: AppColors.textMuted, fontSize: 13))),
            const SizedBox(height: 10),
            _InfoTile(
                icon: Icons.location_city_outlined,
                title: 'Coverage',
                trailing: const Text('Kigali, Rwanda',
                    style:
                        TextStyle(color: AppColors.textMuted, fontSize: 13))),
            const SizedBox(height: 28),

            // ── Sign out ───────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    ref.read(authNotifierProvider.notifier).signOut(),
                icon: const Icon(Icons.logout_outlined),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) => '${_months[d.month - 1]} ${d.year}';

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
}

// ── Helper widgets ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(),
      style: const TextStyle(
          color: AppColors.accent,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2));
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider)),
      child: Row(children: [
        Icon(icon, color: AppColors.accent, size: 22),
        const SizedBox(width: 14),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(subtitle,
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        )),
        Switch(
            value: value, onChanged: onChanged, activeColor: AppColors.accent),
      ]),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;
  const _InfoTile(
      {required this.icon, required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider)),
      child: Row(children: [
        Icon(icon, color: AppColors.textMuted, size: 20),
        const SizedBox(width: 14),
        Expanded(
            child: Text(title,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500))),
        trailing,
      ]),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider)),
      child: const Center(
          child: CircularProgressIndicator(color: AppColors.accent)),
    );
  }
}
