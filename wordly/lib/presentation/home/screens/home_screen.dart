import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../domain/entities/dictionary.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadDictionaries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading || state is HomeInitial) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            );
          }

          if (state is HomeError) {
            return Center(
              child: Text(
                state.message,
                style: AppTextStyles.caption,
              ),
            );
          }

          if (state is HomeLoaded) {
            if (state.dictionaries.isEmpty) {
              return const EmptyStateWidget(
                title: AppStrings.noDictionaries,
                subtitle: AppStrings.noDictionariesHint,
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.dictionaries.length,
              separatorBuilder: (_, __) =>
                  const Divider(indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final dict = state.dictionaries[index];
                return _DictionaryTile(dictionary: dict);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/dictionary/new'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DictionaryTile extends StatelessWidget {
  final Dictionary dictionary;

  const _DictionaryTile({required this.dictionary});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.push(
        '/dictionary/${dictionary.id}',
        extra: dictionary,
      ),
      title: Text(
        dictionary.name,
        style: AppTextStyles.bodyMedium,
      ),
      subtitle: dictionary.description.isNotEmpty
          ? Text(
              dictionary.description,
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${dictionary.wordCount}',
            style: AppTextStyles.heading3,
          ),
          const Text(
            AppStrings.words,
            style: AppTextStyles.small,
          ),
        ],
      ),
    );
  }
}
