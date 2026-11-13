import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase extends UseCase<void, ProfileEntity> {
  final ProfileRepository repository;
  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ProfileEntity params) {
    return repository.updateProfile(params);
  }
}
