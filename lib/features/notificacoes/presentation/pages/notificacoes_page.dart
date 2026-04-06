import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_display.dart';
import '../cubit/notificacoes_cubit.dart';

class NotificacoesPage extends StatelessWidget {
  const NotificacoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : '';

    return BlocProvider(
      create: (_) => getIt<NotificacoesCubit>()..load(userId),
      child: const _NotificacoesView(),
    );
  }
}

class _NotificacoesView extends StatelessWidget {
  const _NotificacoesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () {
              final authState = context.read<AuthBloc>().state;
              final userId =
                  authState is AuthAuthenticated ? authState.user.id : '';
              context.read<NotificacoesCubit>().load(userId);
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificacoesCubit, NotificacoesState>(
        builder: (context, state) {
          if (state is NotificacoesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NotificacoesError) {
            return ErrorDisplay(
              message: state.message,
              onRetry: () {
                final authState = context.read<AuthBloc>().state;
                final userId =
                    authState is AuthAuthenticated ? authState.user.id : '';
                context.read<NotificacoesCubit>().load(userId);
              },
            );
          }
          if (state is! NotificacoesLoaded || state.items.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_off_outlined,
              title: 'Nenhuma notificação',
              subtitle: 'Você será notificado sobre oportunidades e comunicados.',
            );
          }

          return ListView.separated(
            itemCount: state.items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final n = state.items[i];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.notifications_outlined,
                      color: AppColors.primary),
                ),
                title: Text(
                  n.title.isNotEmpty ? n.title : 'Notificação',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (n.body.isNotEmpty)
                      Text(n.body,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text(
                      AppDateUtils.timeAgo(n.createdAt),
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
                isThreeLine: n.body.isNotEmpty,
              );
            },
          );
        },
      ),
    );
  }
}
