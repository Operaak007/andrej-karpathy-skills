import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdating extends ProfileState {
  final Map<String, dynamic> profile;

  const ProfileUpdating(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdated extends ProfileState {
  final Map<String, dynamic> profile;

  const ProfileUpdated(this.profile);

  @override
  List<Object?> get props => [profile];
}

class AvatarUploading extends ProfileState {
  final Map<String, dynamic> profile;

  const AvatarUploading(this.profile);

  @override
  List<Object?> get props => [profile];
}

class AvatarUploaded extends ProfileState {
  final Map<String, dynamic> profile;
  final String avatarUrl;

  const AvatarUploaded(this.profile, this.avatarUrl);

  @override
  List<Object?> get props => [profile, avatarUrl];
}

class ProfileError extends ProfileState {
  final String message;
  final Map<String, dynamic>? profile;

  const ProfileError(this.message, {this.profile});

  @override
  List<Object?> get props => [message, profile];
}
