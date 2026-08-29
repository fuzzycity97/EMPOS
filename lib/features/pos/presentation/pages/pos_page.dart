import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/config/presentation/bloc/config_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../orders/presentation/bloc/orders_bloc.dart';
import '../../../orders/presentation/bloc/orders_event.dart';
import '../../../shift/presentation/bloc/shift_bloc.dart';
import '../../../shift/presentation/bloc/shift_state.dart';
import '../../../shift/presentation/widgets/open_shift_dialog.dart';
import '../../../shift/presentation/widgets/z_report_receipt_widget.dart';
import '../bloc/pos_bloc.dart';
import '../bloc/pos_event.dart';
import '../bloc/pos_state.dart';
import '../widgets/checkout_receipt_dialog.dart';
import '../widgets/pos_cart_dock.dart';
import '../widgets/pos_product_tile.dart';
import '../widgets/pos_search_header.dart';

class PosPage extends StatelessWidget {
  final PosBloc? posBloc;
  final ShiftBloc? shiftBloc;
  final ConfigBloc? configBloc;

  const PosPage({
    super.key,
    this.posBloc,
    this.shiftBloc,
    this.configBloc,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = const _PosPageView();

    if (posBloc != null) {
      content = BlocProvider<PosBloc>.value(value: posBloc!, child: content);
    }
    if (shiftBloc != null) {
      content = BlocProvider<ShiftBloc>.value(value: shiftBloc!, child: content);
    }
    if (configBloc != null) {
      content = BlocProvider<ConfigBloc>.value(value: configBloc!, child: content);
    }

    return content;
  }
}

class _PosPageView extends StatelessWidget {
  const _PosPageView();

  void _showReceiptDialog(BuildContext context, PosReady state) {
    if (state.lastCompletedOrder == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => BlocProvider.value(
        value: context.read<PosBloc>(),
        child: CheckoutReceiptDialog(order: state.lastCompletedOrder!),
      ),
    );
  }

  void _showZReportDialog(BuildContext context, ZReportGenerated state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => BlocProvider.value(
        value: context.read<ShiftBloc>(),
        child: ZReportReceiptWidget(zReport: state.zReport),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: BlocListener<ShiftBloc, ShiftState>(
        listener: (context, shiftState) {
          if (shiftState is ActiveShiftReady && shiftState.toastMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(shiftState.toastMessage!),
                backgroundColor: AppColors.surfaceElevatedDark,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }

          if (shiftState is ZReportGenerated) {
            _showZReportDialog(context, shiftState);
          }
        },
        child: BlocConsumer<PosBloc, PosState>(
          listener: (context, posState) {
            if (posState is PosReady) {
              if (posState.toastMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(posState.toastMessage!),
                    backgroundColor: AppColors.surfaceElevatedDark,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }

              if (posState.lastCompletedOrder != null) {
                _showReceiptDialog(context, posState);
                try {
                  context.read<OrdersBloc>().add(const LoadOrdersEvent());
                } catch (_) {}
              }
            }
          },
          builder: (context, posState) {
            if (posState is PosLoading) {
              return Center(
                child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
              );
            }

            if (posState is PosError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.circleAlert, color: AppColors.danger, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to initialize POS Terminal',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      posState.message,
                      style: const TextStyle(color: AppColors.textSecondaryDark),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.read<PosBloc>().add(const InitPosSession()),
                      icon: const Icon(LucideIcons.refreshCw, size: 16),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (posState is PosReady) {
              return BlocBuilder<ShiftBloc, ShiftState>(
                builder: (context, shiftState) {
                  final isLocked = shiftState is NoActiveShift || shiftState is ShiftInitial;

                  return Stack(
                    children: [
                      // Underneath POS UI (Absorbs pointers and greys out when locked)
                      AbsorbPointer(
                        absorbing: isLocked,
                        child: ColorFiltered(
                          colorFilter: isLocked
                              ? const ColorFilter.matrix(<double>[
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0,      0,      0,      0.35, 0,
                                ])
                              : const ColorFilter.mode(
                                  Colors.transparent,
                                  BlendMode.dst,
                                ),
                          child: SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.all(AppDimensions.space12),
                              child: ResponsiveLayout(
                                mobile: _buildMobileLayout(context, posState),
                                tablet: _buildSplitLayout(context, posState, crossAxisCount: 3),
                                desktop: _buildSplitLayout(context, posState, crossAxisCount: 4),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Prominent Shift Lock Overlay
                      if (isLocked)
                        Positioned.fill(
                          child: _buildShiftLockOverlay(context),
                        ),
                    ],
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // Dark overlay locking POS when no active shift is open
  Widget _buildShiftLockOverlay(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.88),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(AppDimensions.space24),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space32),
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(color: AppColors.borderDark),
          boxShadow: const [
            BoxShadow(
              color: Colors.black87,
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.lock,
                size: 40,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: AppDimensions.space16),
            const Text(
              'Cash Drawer Locked',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No active cashier shift detected. Please start your shift and declare opening morning float to unlock POS ordering.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: AppDimensions.space24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => BlocProvider.value(
                      value: context.read<ShiftBloc>(),
                      child: OpenShiftDialog(),
                    ),
                  );
                },
                icon: const Icon(LucideIcons.unlock, size: 18),
                label: const Text(
                  'START SHIFT & DECLARE FLOAT',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Desktop / Tablet Split Screen (Left: Catalog Grid, Right: Cart Dock)
  Widget _buildSplitLayout(
    BuildContext context,
    PosReady state, {
    required int crossAxisCount,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Pane: Catalog & Scanner (65% width)
        Expanded(
          flex: 65,
          child: Column(
            children: [
              PosSearchHeader(
                categories: state.categories,
                selectedCategoryId: state.selectedCategoryId,
              ),
              const SizedBox(height: AppDimensions.space12),
              Expanded(
                child: state.displayedProducts.isEmpty
                    ? Center(
                        child: Text(
                          'No products found matching "${state.searchQuery}"',
                          style: const TextStyle(color: AppColors.textMutedDark),
                        ),
                      )
                    : GridView.builder(
                        itemCount: state.displayedProducts.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: AppDimensions.space8,
                          mainAxisSpacing: AppDimensions.space8,
                          childAspectRatio: 1.15,
                        ),
                        itemBuilder: (context, index) {
                          final product = state.displayedProducts[index];
                          return PosProductTile(
                            product: product,
                            onAddToCart: () {
                              context
                                  .read<PosBloc>()
                                  .add(AddProductToCart(product));
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.space12),

        // Right Pane: Active Cart Dock (35% width)
        Expanded(
          flex: 35,
          child: PosCartDock(
            cart: state.cart,
            heldTabs: state.heldTabs,
          ),
        ),
      ],
    );
  }

  // Mobile Layout: Cart Dock with floating product picker button
  Widget _buildMobileLayout(BuildContext context, PosReady state) {
    return Column(
      children: [
        Expanded(
          child: PosCartDock(
            cart: state.cart,
            heldTabs: state.heldTabs,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
            onPressed: () => _openMobileProductPicker(context, state),
            icon: const Icon(LucideIcons.boxes, size: 18),
            label: const Text(
              'BROWSE & ADD PRODUCTS',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  void _openMobileProductPicker(BuildContext context, PosReady state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<PosBloc>()),
            BlocProvider.value(value: context.read<ShiftBloc>()),
          ],
          child: DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (ctx, scrollController) {
              return Padding(
                padding: const EdgeInsets.all(AppDimensions.space12),
                child: Column(
                  children: [
                    PosSearchHeader(
                      categories: state.categories,
                      selectedCategoryId: state.selectedCategoryId,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: GridView.builder(
                        controller: scrollController,
                        itemCount: state.displayedProducts.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.15,
                        ),
                        itemBuilder: (context, index) {
                          final product = state.displayedProducts[index];
                          return PosProductTile(
                            product: product,
                            onAddToCart: () {
                              context.read<PosBloc>().add(AddProductToCart(product));
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
