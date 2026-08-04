import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/firebase_auth_repository.dart';
import '../../data/repositories/firestore_user_profile_repository.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/usecases/ensure_user_profile.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/register_with_email.dart';
import '../../domain/usecases/reload_current_user.dart';
import '../../domain/usecases/send_email_verification.dart';
import '../../domain/usecases/send_password_reset.dart';
import '../../domain/usecases/sign_in_with_apple.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/watch_auth_state.dart';

enum AuthDestination { home, emailVerification }

const bool kEnforceEmailVerification = true;

final authenticationRepositoryProvider = Provider<AuthenticationRepository>((
  ref,
) {
  return FirebaseAuthenticationRepository();
});

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return FirestoreUserProfileRepository();
});

final watchAuthStateProvider = Provider<WatchAuthState>((ref) {
  return WatchAuthState(ref.watch(authenticationRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUser>((ref) {
  return GetCurrentUser(ref.watch(authenticationRepositoryProvider));
});

final signInWithEmailUseCaseProvider = Provider<SignInWithEmail>((ref) {
  return SignInWithEmail(ref.watch(authenticationRepositoryProvider));
});

final registerWithEmailUseCaseProvider = Provider<RegisterWithEmail>((ref) {
  return RegisterWithEmail(ref.watch(authenticationRepositoryProvider));
});

final sendPasswordResetUseCaseProvider = Provider<SendPasswordReset>((ref) {
  return SendPasswordReset(ref.watch(authenticationRepositoryProvider));
});

final sendEmailVerificationUseCaseProvider = Provider<SendEmailVerification>((
  ref,
) {
  return SendEmailVerification(ref.watch(authenticationRepositoryProvider));
});

final reloadCurrentUserUseCaseProvider = Provider<ReloadCurrentUser>((ref) {
  return ReloadCurrentUser(ref.watch(authenticationRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOut>((ref) {
  return SignOut(ref.watch(authenticationRepositoryProvider));
});

final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogle>((ref) {
  return SignInWithGoogle(ref.watch(authenticationRepositoryProvider));
});

final signInWithAppleUseCaseProvider = Provider<SignInWithApple>((ref) {
  return SignInWithApple(ref.watch(authenticationRepositoryProvider));
});

final ensureUserProfileUseCaseProvider = Provider<EnsureUserProfile>((ref) {
  return EnsureUserProfile(ref.watch(userProfileRepositoryProvider));
});

final authStateProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(watchAuthStateProvider).call();
});

final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

final immediateCurrentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authenticationRepositoryProvider).currentUser;
});

bool requiresEmailVerification(AuthUser user) {
  if (!kEnforceEmailVerification) {
    return false;
  }

  return !user.emailVerified;
}

class AuthActionController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> _ensureProfile(AuthUser user, {String? displayName}) async {
    final email = user.email;
    if (email == null) {
      return;
    }

    await ref
        .read(ensureUserProfileUseCaseProvider)
        .call(
          uid: user.uid,
          profile: UserProfile(
            displayName: displayName ?? '',
            email: email,
            photoUrl: null,
            homeCountry: '',
            homeCurrency: 'GBP',
            preferredLanguage: 'en',
          ),
        );
  }

  Future<AuthDestination> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final user = await ref
          .read(signInWithEmailUseCaseProvider)
          .call(email: email, password: password);

      if (user != null) {
        await _ensureProfile(user);
        if (requiresEmailVerification(user)) {
          return AuthDestination.emailVerification;
        }
      }

      return AuthDestination.home;
    });

    state = result;
    if (result.hasError) {
      throw result.error!;
    }

    return result.requireValue;
  }

  Future<AuthDestination> registerWithEmail({
    required String displayName,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final user = await ref
          .read(registerWithEmailUseCaseProvider)
          .call(email: email, password: password, displayName: displayName);

      await _ensureProfile(user, displayName: displayName.trim());
      await ref.read(sendEmailVerificationUseCaseProvider).call();

      if (requiresEmailVerification(user)) {
        return AuthDestination.emailVerification;
      }

      return AuthDestination.home;
    });

    state = result;
    if (result.hasError) {
      throw result.error!;
    }

    return result.requireValue;
  }

  Future<AuthDestination> signInWithGoogle() async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final user = await ref.read(signInWithGoogleUseCaseProvider).call();
      if (user != null) {
        await _ensureProfile(user);
        if (requiresEmailVerification(user)) {
          return AuthDestination.emailVerification;
        }
      }
      return AuthDestination.home;
    });

    state = result;
    if (result.hasError) {
      throw result.error!;
    }

    return result.requireValue;
  }

  Future<AuthDestination> signInWithApple() async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final user = await ref.read(signInWithAppleUseCaseProvider).call();
      if (user != null) {
        await _ensureProfile(user);
        if (requiresEmailVerification(user)) {
          return AuthDestination.emailVerification;
        }
      }
      return AuthDestination.home;
    });

    state = result;
    if (result.hasError) {
      throw result.error!;
    }

    return result.requireValue;
  }

  Future<void> sendPasswordReset({required String email}) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(sendPasswordResetUseCaseProvider).call(email);
    });
    state = result;
    if (result.hasError) {
      throw result.error!;
    }
  }

  Future<void> resendEmailVerification() async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(sendEmailVerificationUseCaseProvider).call();
    });
    state = result;
    if (result.hasError) {
      throw result.error!;
    }
  }

  Future<bool> refreshEmailVerificationStatus() async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(reloadCurrentUserUseCaseProvider).call();
      final refreshedUser = ref.read(getCurrentUserUseCaseProvider).call();
      return refreshedUser?.emailVerified ?? false;
    });
    state = const AsyncData(null);
    if (result.hasError) {
      throw result.error!;
    }

    return result.requireValue;
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(signOutUseCaseProvider).call();
    });
    state = result;
    if (result.hasError) {
      throw result.error!;
    }
  }
}

final authActionControllerProvider =
    AutoDisposeAsyncNotifierProvider<AuthActionController, void>(
      AuthActionController.new,
    );
