import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ak_api_test/services/api_service.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ApiService apiService;

  ProfileBloc({required this.apiService}) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<UploadAvatar>(_onUploadAvatar);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final response = await apiService.get('/profile');
      final profile = response['data'] as Map<String, dynamic>;
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    final currentProfile = _getCurrentProfile();
    emit(ProfileUpdating(currentProfile));
    try {
      final response = await apiService.put('/profile', body: event.data);
      final profile = response['data'] as Map<String, dynamic>;
      emit(ProfileUpdated(profile));
    } catch (e) {
      emit(ProfileError(e.toString(), profile: currentProfile));
    }
  }

  Future<void> _onUploadAvatar(
    UploadAvatar event,
    Emitter<ProfileState> emit,
  ) async {
    final currentProfile = _getCurrentProfile();
    emit(AvatarUploading(currentProfile));
    try {
      final response = await apiService.uploadMultipart(
        '/profile/avatar',
        filePath: event.filePath,
        fieldName: 'avatar',
      );
      final avatarUrl = response['data']['avatar_url'] as String;
      final updatedProfile = Map<String, dynamic>.from(currentProfile);
      updatedProfile['avatar_url'] = avatarUrl;
      emit(AvatarUploaded(updatedProfile, avatarUrl));
    } catch (e) {
      emit(ProfileError(e.toString(), profile: currentProfile));
    }
  }

  Map<String, dynamic> _getCurrentProfile() {
    final currentState = state;
    if (currentState is ProfileLoaded) return currentState.profile;
    if (currentState is ProfileUpdating) return currentState.profile;
    if (currentState is ProfileUpdated) return currentState.profile;
    if (currentState is AvatarUploading) return currentState.profile;
    if (currentState is AvatarUploaded) return currentState.profile;
    if (currentState is ProfileError) return currentState.profile ?? {};
    return {};
  }
}
