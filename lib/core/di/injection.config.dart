// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:coloring/core/database/app_database.dart' as _i665;
import 'package:coloring/core/di/register_module.dart' as _i41;
import 'package:coloring/features/coloring/data/coloring_repository_impl.dart'
    as _i681;
import 'package:coloring/features/coloring/data/coloring_storage.dart' as _i659;
import 'package:coloring/features/coloring/data/local_cv_data_source.dart'
    as _i857;
import 'package:coloring/features/coloring/domain/repositories/coloring_repository.dart'
    as _i1010;
import 'package:coloring/features/coloring/domain/repositories/cv_repository.dart'
    as _i864;
import 'package:coloring/features/coloring/presentation/cubit/coloring_cubit.dart'
    as _i678;
import 'package:coloring/features/gallery/presentation/cubit/gallery_cubit.dart'
    as _i708;
import 'package:coloring/features/import/data/import_repository_impl.dart'
    as _i221;
import 'package:coloring/features/import/data/pdf_rasterizer.dart' as _i1043;
import 'package:coloring/features/import/domain/import_repository.dart'
    as _i465;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i665.AppDatabase>(() => _i665.AppDatabase());
    gh.lazySingleton<_i1043.PdfRasterizer>(() => _i1043.PdfRasterizer());
    gh.lazySingleton<_i864.CvRepository>(() => _i857.LocalCvDataSource());
    gh.lazySingleton<_i659.ColoringStorage>(
      () => _i659.ColoringStorage(gh<_i665.AppDatabase>()),
    );
    gh.lazySingleton<_i465.ImportRepository>(
      () => _i221.ImportRepositoryImpl(
        gh<_i1043.PdfRasterizer>(),
        gh<_i864.CvRepository>(),
        gh<_i659.ColoringStorage>(),
      ),
    );
    gh.factory<_i708.GalleryCubit>(
      () => _i708.GalleryCubit(gh<_i659.ColoringStorage>()),
    );
    gh.lazySingleton<_i1010.ColoringRepository>(
      () => _i681.ColoringRepositoryImpl(gh<_i659.ColoringStorage>()),
    );
    gh.factory<_i678.ColoringCubit>(
      () => _i678.ColoringCubit(
        gh<_i1010.ColoringRepository>(),
        gh<_i659.ColoringStorage>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i41.RegisterModule {}
