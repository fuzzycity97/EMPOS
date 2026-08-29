import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../bloc/catalog_bloc.dart';
import '../bloc/catalog_event.dart';
import '../bloc/catalog_state.dart';

class CatalogSearchBar extends StatelessWidget {
  const CatalogSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogBloc, CatalogState>(
      builder: (context, state) {
        final query = (state is CatalogLoaded) ? state.searchQuery : '';

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceElevatedDark,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.space12),
                child: Icon(
                  LucideIcons.scanBarcode,
                  size: 20,
                  color: AppColors.primaryLight,
                ),
              ),
              Expanded(
                child: TextField(
                  key: const ValueKey('catalog_search_input'),
                  decoration: const InputDecoration(
                    hintText: 'Scan Barcode (e.g. 622...) or search item / category...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMutedDark,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: AppDimensions.space12,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimaryDark,
                  ),
                  onChanged: (val) {
                    context.read<CatalogBloc>().add(SearchCatalog(val));
                  },
                ),
              ),
              if (query.isNotEmpty)
                IconButton(
                  icon: const Icon(
                    LucideIcons.x,
                    size: 16,
                    color: AppColors.textMutedDark,
                  ),
                  onPressed: () {
                    context.read<CatalogBloc>().add(const SearchCatalog(''));
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
