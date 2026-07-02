import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final Map<String, dynamic> data;

  const UpdateProfile(this.data);

  @override
  List<Object?> get props => [data];
}

class UploadAvatar extends ProfileEvent {
  final String filePath;

  const UploadAvatar(this.filePath);

  @override
  List<Object?> get props => [filePath];
}
