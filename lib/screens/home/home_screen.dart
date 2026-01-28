import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/mock_providers.dart';
import '../../widgets/laundry_card.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  // Tirana, Albania
  final LatLng _userLocation = const LatLng(41.3275, 19.8187);
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Setup animation for user location marker
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final laundries = ref.watch(laundriesProvider);
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: AppBar(
          title: Text(context.l10n.t('Nearby Laundries')),
          centerTitle: true,
          toolbarHeight: 64,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: const Color(0xFF1F2A37),
          ),
          actions: [
            _HeaderActionButton(
              icon: Icons.discount_outlined,
              onPressed: () => context.push('/coupons'),
              color: primaryColor,
            ),
            _HeaderActionButton(
              icon: Icons.chat_outlined,
              onPressed: () => context.push('/conversations'),
              color: primaryColor,
            ),
            _HeaderActionButton(
              icon: Icons.receipt_long,
              onPressed: () => context.push('/orders'),
              color: primaryColor,
            ),
            _HeaderActionButton(
              icon: Icons.person_outline,
              onPressed: () => context.push('/profile'),
              color: primaryColor,
            ),
            const SizedBox(width: 6),
          ],
          flexibleSpace: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.95),
                      Colors.white.withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.7),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Map with custom styling
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userLocation,
              initialZoom: 13,
              minZoom: 4,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.aspro_app',
                tileBuilder: (context, tileWidget, tile) {
                  return ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      0.9, 0.0, 0.0, 0.0, 10.0,
                      0.0, 0.9, 0.0, 0.0, 10.0,
                      0.0, 0.0, 0.95, 0.0, 5.0,
                      0.0, 0.0, 0.0, 1.0, 0.0,
                    ]),
                    child: tileWidget,
                  );
                },
              ),
              MarkerLayer(
                markers: [
                  // User location marker with pulse animation
                  Marker(
                    point: _userLocation,
                    width: 60,
                    height: 60,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Animated pulse effect
                            Container(
                              width: 60 - _pulseAnimation.value,
                              height: 60 - _pulseAnimation.value,
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                            ),
                            // Inner circle
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_pin_circle,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  // Laundry location markers
                  ...laundries.map(
                    (laundry) => Marker(
                      point: LatLng(laundry.latitude, laundry.longitude),
                      width: 48,
                      height: 48,
                      child: GestureDetector(
                        onTap: () => context.push('/laundry?id=${laundry.id}'),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.secondary,
                                theme.colorScheme.secondary.withBlue(
                                  (theme.colorScheme.secondary.blue + 40).clamp(0, 255),
                                ),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.secondary.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.local_laundry_service,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Bottom sheet with laundry listings
          DraggableScrollableSheet(
            initialChildSize: 0.32,
            minChildSize: 0.2,
            maxChildSize: 0.65,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.8),
                    width: 1,
                  ),
                ),
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          // Handle bar
                          Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 8),
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryColor.withOpacity(0.3),
                                    primaryColor.withOpacity(0.5),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),

                          // Title with gradient underline
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.t('Top picks near you'),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 2,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Laundry listings
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final laundry = laundries[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: LaundryCard(
                                laundry: laundry,
                                onTap: () => context.push('/laundry?id=${laundry.id}'),
                              ),
                            );
                          },
                          childCount: laundries.length,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push('/booking'),
            borderRadius: BorderRadius.circular(28),
            child: Ink(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(28),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_location_alt_outlined,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.t('Book Pickup'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4, right: 4, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.7),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: color, size: 22),
          ),
        ),
      ),
    );
  }
}
