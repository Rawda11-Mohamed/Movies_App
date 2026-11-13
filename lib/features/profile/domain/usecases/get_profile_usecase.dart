import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase extends UseCase<ProfileEntity, GetProfileParams> {
  final ProfileRepository repository;
  GetProfileUseCase(this.repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(GetProfileParams params) {
    return repository.getProfile(params.uid);
  }
}

class GetProfileParams extends Equatable {
  final String uid;
  const GetProfileParams({required this.uid});

  @override
  List<Object> get props => [uid];
}
