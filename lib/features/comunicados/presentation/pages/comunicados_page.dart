import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../cubit/comunicados_cubit.dart';
import 'criar_comunicado_page.dart';

class ComunicadosPage extends StatelessWidget {
  const ComunicadosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final cooperativeId = auth is AuthAuthenticated ? auth.user.cooperativeId ?? '' : '';
    final cooperadoId = auth is AuthAuthenticated ? auth.user.cooperadoId : null;
    final isAdmin = auth is AuthAuthenticated && auth.user.isAdmin;

    return BlocProvider(
      create: (_) => getIt<ComunicadosCubit>()
        ..load(cooperativeId, cooperadoId: cooperadoId),
      child: _ComunicadosView(isAdmin: isAdmin),
    );
  }
}

class _ComunicadosView extends StatelessWidget {
  final bool isAdmin;
  const _ComunicadosView({required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComunicadosCubit, ComunicadosState>(
      listener: (context, state) {
        if (state is ComunicadosMutated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.primary),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Comunicados')),
          floatingActionButton: isAdmin
              ? FloatingActionButton.extended(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<ComunicadosCubit>(),
                        child: const CriarComunicadoPage(),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Novo'),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                )
              : null,
          body: Builder(builder: (context) {
            if (state is ComunicadosLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ComunicadosError) {
              return Center(child: Text(state.message));
            }
            if (state is ComunicadosLoaded) {
              if (state.items.isEmpty) {
                return const EmptyState(
                  icon: Icons.campaign_outlined,
                  title: 'Nenhum comunicado',
                  subtitle: 'Novidades serão exibidas aqui.',
                );
              }
              return ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (context, i) {
                  final c = state.items[i];
                  return Card(
                    child: ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: c.pinned
                                ? AppColors.accent.withOpacity(0.15)
                                : AppColors.surface,
                            child: Icon(
                              c.pinned ? Icons.push_pin_outlined : Icons.campaign_outlined,
                              color: c.pinned ? AppColors.accent : AppColors.primary,
                            ),
                          ),
                          if (!c.lido)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                    // CA-11-4: ponto azul (não vermelho)
                                    color: Color(0xFF3B82F6),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        c.titulo,
                        style: TextStyle(
                          fontWeight: c.lido ? FontWeight.w400 : FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(AppDateUtils.timeAgo(c.createdAt)),
                      onTap: () {
                        final auth = context.read<AuthBloc>().state;
                        if (auth is AuthAuthenticated && auth.user.cooperadoId != null) {
                          context.read<ComunicadosCubit>().marcarLido(
                            c.id,
                            auth.user.cooperadoId!,
                          );
                        }
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (_) => DraggableScrollableSheet(
                            expand: false,
                            builder: (_, ctrl) => SingleChildScrollView(
                              controller: ctrl,
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.titulo, style: Theme.of(context).textTheme.headlineSmall),
                                  const SizedBox(height: 8),
                                  Text(AppDateUtils.formatDateTime(c.createdAt),
                                      style: const TextStyle(color: AppColors.textSecondary)),
                                  const Divider(height: 24),
                                  Text(c.conteudo, style: Theme.of(context).textTheme.bodyLarge),
                                  // CA-11-1: link do anexo (imagem ou PDF)
                                  if (c.anexoUrl != null && c.anexoUrl!.isNotEmpty) ...[  
                                    const SizedBox(height: 16),
                                    const Divider(),
                                    const SizedBox(height: 4),
                                    InkWell(
                                      onTap: () => launchUrl(
                                        Uri.parse(c.anexoUrl!),
                                        mode: LaunchMode.externalApplication,
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.attach_file_outlined, size: 16, color: Color(0xFF3B82F6)),
                                          SizedBox(width: 6),
                                          Text(
                                            'Abrir anexo',
                                            style: TextStyle(
                                              color: Color(0xFF3B82F6),
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          }),
        );
      },
    );
  }
}
