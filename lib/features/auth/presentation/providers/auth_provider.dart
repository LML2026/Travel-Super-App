import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/firebase_auth_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/send_password_reset.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_in_with_apple.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/watch_auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final watchAuthStateProvider = Provider<WatchAuthState>((ref) {
  return WatchAuthState(ref.watch(authRepositoryProvider));
});

final getCurrentUserProvider = Provider<GetCurrentUser>((ref) {
  return GetCurrentUser(ref.watch(authRepositoryProvider));
});

final signInUseCaseProvider = Provider<SignIn>((ref) {
  return SignIn(ref.watch(authRepositoryProvider));
});

final registerUserUseCaseProvider = Provider<RegisterUser>((ref) {
  return RegisterUser(ref.watch(authRepositoryProvider));
});

final sendPasswordResetUseCaseProvider = Provider<SendPasswordReset>((ref) {
  return SendPasswordReset(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOut>((ref) {
  return SignOut(ref.watch(authRepositoryProvider));
});

final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogle>((ref) {
  return SignInWithGoogle(ref.watch(authRepositoryProvider));
});

final signInWithAppleUseCaseProvider = Provider<SignInWithApple>((ref) {
  return SignInWithApple(ref.watch(authRepositoryProvider));
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(watchAuthStateProvider).call();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider)?.uid;
});

final immediateCurrentUserProvider = Provider<User?>((ref) {
  return ref.watch(authRepositoryProvider).currentUser;
});

class AuthMutationNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref
          .read(signInUseCaseProvider)
          .call(email: email, password: password);
    });
    state = result;
    if (result.hasError) {
      throw result.error!;
    }
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(registerUserUseCaseProvider).call(
            email: email,
            password: password,
          );
    });
    state = result;
    if (result.hasError) {
      throw result.error!;
    }
  }

  Future<void> sendPasswordReset({required String email}) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(sendPasswordResetUseCaseProvider).call(email: email);
    });
    state = result;
    if (result.hasError) {
      throw result.error!;
    }
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

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(signInWithGoogleUseCaseProvider).call();
    });
    state = result;
    if (result.hasError) {
      throw result.error!;
    }
  }

  Future<void> signInWithApple() async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(signInWithAppleUseCaseProvider).call();
    });
    state = result;
    if (result.hasError) {
      throw result.error!;
    }
  }
}

final authMutationProvider =
    AutoDisposeAsyncNotifierProvider<AuthMutationNotifier, void>(
  AuthMutationNotifier.new,
);
