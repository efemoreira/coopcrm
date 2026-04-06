// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:coopcrm/core/di/injection.dart' as _i877;
import 'package:coopcrm/core/router/app_router.dart' as _i19;
import 'package:coopcrm/features/auth/data/datasources/supabase_auth_datasource.dart'
    as _i244;
import 'package:coopcrm/features/auth/data/repositories/auth_repository_impl.dart'
    as _i958;
import 'package:coopcrm/features/auth/domain/repositories/auth_repository.dart'
    as _i27;
import 'package:coopcrm/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i556;
import 'package:coopcrm/features/auth/domain/usecases/sign_out_usecase.dart'
    as _i656;
import 'package:coopcrm/features/auth/presentation/bloc/auth_bloc.dart'
    as _i540;
import 'package:coopcrm/features/comunicados/data/datasources/supabase_comunicados_datasource.dart'
    as _i699;
import 'package:coopcrm/features/comunicados/data/repositories/comunicados_repository_impl.dart'
    as _i232;
import 'package:coopcrm/features/comunicados/domain/repositories/comunicados_repository.dart'
    as _i23;
import 'package:coopcrm/features/comunicados/presentation/cubit/comunicados_cubit.dart'
    as _i994;
import 'package:coopcrm/features/cooperados/data/datasources/supabase_cooperados_datasource.dart'
    as _i161;
import 'package:coopcrm/features/cooperados/data/repositories/cooperados_repository_impl.dart'
    as _i953;
import 'package:coopcrm/features/cooperados/domain/repositories/cooperados_repository.dart'
    as _i1042;
import 'package:coopcrm/features/cooperados/presentation/cubit/cooperados_cubit.dart'
    as _i94;
import 'package:coopcrm/features/cotas/data/datasources/supabase_cotas_datasource.dart'
    as _i624;
import 'package:coopcrm/features/cotas/data/repositories/cotas_repository_impl.dart'
    as _i417;
import 'package:coopcrm/features/cotas/domain/repositories/cotas_repository.dart'
    as _i1004;
import 'package:coopcrm/features/cotas/presentation/cubit/cotas_cubit.dart'
    as _i126;
import 'package:coopcrm/features/notificacoes/data/datasources/supabase_notificacoes_datasource.dart'
    as _i622;
import 'package:coopcrm/features/notificacoes/data/repositories/notificacoes_repository_impl.dart'
    as _i1054;
import 'package:coopcrm/features/notificacoes/domain/repositories/notificacoes_repository.dart'
    as _i391;
import 'package:coopcrm/features/notificacoes/presentation/cubit/notificacoes_cubit.dart'
    as _i72;
import 'package:coopcrm/features/oportunidades/data/datasources/supabase_oportunidades_datasource.dart'
    as _i378;
import 'package:coopcrm/features/oportunidades/data/repositories/oportunidades_repository_impl.dart'
    as _i37;
import 'package:coopcrm/features/oportunidades/domain/repositories/oportunidades_repository.dart'
    as _i68;
import 'package:coopcrm/features/oportunidades/presentation/bloc/feed_bloc.dart'
    as _i1056;
import 'package:coopcrm/features/oportunidades/presentation/bloc/oportunidade_detail_cubit.dart'
    as _i9;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.singleton<_i454.SupabaseClient>(
      () => appModule.supabaseClient,
      instanceName: 'supabase',
    );
    gh.factory<_i244.SupabaseAuthDatasource>(
      () => _i244.SupabaseAuthDatasource(
        gh<_i454.SupabaseClient>(instanceName: 'supabase'),
      ),
    );
    gh.factory<_i699.SupabaseComunicadosDatasource>(
      () => _i699.SupabaseComunicadosDatasource(
        gh<_i454.SupabaseClient>(instanceName: 'supabase'),
      ),
    );
    gh.factory<_i161.SupabaseCooperadosDatasource>(
      () => _i161.SupabaseCooperadosDatasource(
        gh<_i454.SupabaseClient>(instanceName: 'supabase'),
      ),
    );
    gh.factory<_i624.SupabaseCotasDatasource>(
      () => _i624.SupabaseCotasDatasource(
        gh<_i454.SupabaseClient>(instanceName: 'supabase'),
      ),
    );
    gh.factory<_i622.SupabaseNotificacoesDatasource>(
      () => _i622.SupabaseNotificacoesDatasource(
        gh<_i454.SupabaseClient>(instanceName: 'supabase'),
      ),
    );
    gh.factory<_i378.SupabaseOportunidadesDatasource>(
      () => _i378.SupabaseOportunidadesDatasource(
        gh<_i454.SupabaseClient>(instanceName: 'supabase'),
      ),
    );
    gh.factory<_i391.NotificacoesRepository>(
      () => _i1054.NotificacoesRepositoryImpl(
        gh<_i622.SupabaseNotificacoesDatasource>(),
      ),
    );
    gh.factory<_i1042.CooperadosRepository>(
      () => _i953.CooperadosRepositoryImpl(
        gh<_i161.SupabaseCooperadosDatasource>(),
      ),
    );
    gh.factory<_i72.NotificacoesCubit>(
      () => _i72.NotificacoesCubit(gh<_i391.NotificacoesRepository>()),
    );
    gh.factory<_i27.AuthRepository>(
      () => _i958.AuthRepositoryImpl(gh<_i244.SupabaseAuthDatasource>()),
    );
    gh.factory<_i556.SignInUseCase>(
      () => _i556.SignInUseCase(gh<_i27.AuthRepository>()),
    );
    gh.factory<_i656.SignOutUseCase>(
      () => _i656.SignOutUseCase(gh<_i27.AuthRepository>()),
    );
    gh.factory<_i68.OportunidadesRepository>(
      () => _i37.OportunidadesRepositoryImpl(
        gh<_i378.SupabaseOportunidadesDatasource>(),
      ),
    );
    gh.factory<_i1004.CotasRepository>(
      () => _i417.CotasRepositoryImpl(gh<_i624.SupabaseCotasDatasource>()),
    );
    gh.singleton<_i540.AuthBloc>(
      () => _i540.AuthBloc(
        gh<_i556.SignInUseCase>(),
        gh<_i656.SignOutUseCase>(),
        gh<_i27.AuthRepository>(),
      ),
    );
    gh.factory<_i23.ComunicadosRepository>(
      () => _i232.ComunicadosRepositoryImpl(
        gh<_i699.SupabaseComunicadosDatasource>(),
      ),
    );
    gh.factory<_i1056.FeedBloc>(
      () => _i1056.FeedBloc(gh<_i68.OportunidadesRepository>()),
    );
    gh.factory<_i94.CooperadosCubit>(
      () => _i94.CooperadosCubit(gh<_i1042.CooperadosRepository>()),
    );
    gh.singleton<_i19.AppRouter>(() => _i19.AppRouter(gh<_i540.AuthBloc>()));
    gh.factory<_i126.CotasCubit>(
      () => _i126.CotasCubit(gh<_i1004.CotasRepository>()),
    );
    gh.factory<_i9.OportunidadeDetailCubit>(
      () => _i9.OportunidadeDetailCubit(gh<_i68.OportunidadesRepository>()),
    );
    gh.factory<_i994.ComunicadosCubit>(
      () => _i994.ComunicadosCubit(gh<_i23.ComunicadosRepository>()),
    );
    return this;
  }
}

class _$AppModule extends _i877.AppModule {}
