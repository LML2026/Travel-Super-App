import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_super_app/features/authentication/domain/entities/auth_user.dart';
import 'package:travel_super_app/features/authentication/domain/entities/user_profile.dart';
import 'package:travel_super_app/features/authentication/domain/repositories/authentication_repository.dart';
import 'package:travel_super_app/features/authentication/domain/repositories/user_profile_repository.dart';
import 'package:travel_super_app/features/authentication/presentation/providers/auth_providers.dart';

class _MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

class _MockUserProfileRepository extends Mock
    implements UserProfileRepository {}

void main() {
  late _MockAuthenticationRepository authRepository;
  late _MockUserProfileRepository profileRepository;

  setUpAll(() {
    registerFallbackValue(
      const UserProfile(
        displayName: 'Name',
        email: 'user@example.com',
        photoUrl: null,
        homeCountry: '',
        homeCurrency: 'GBP',
        preferredLanguage: 'en',
      ),
    );
  });

  setUp(() {
    authRepository = _MockAuthenticationRepository();
    profileRepository = _MockUserProfileRepository();

    when(() => authRepository.authStateChanges())
        .thenAnswer((_) => const Stream<AuthUser?>.empty());
    when(() => authRepository.currentUser).thenReturn(null);
    when(() => profileRepository.ensureProfile(
          uid: any(named: 'uid'),
          profile: any(named: 'profile'),
        )).thenAnswer((_) async {});
  });

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [
        authenticationRepositoryProvider.overrideWithValue(authRepository),
        userProfileRepositoryProvider.overrideWithValue(profileRepository),
      ],
    );
  }

  test('registerWithEmail returns email verification destination', () async {
    const user = AuthUser(
      uid: 'uid-1',
      email: 'new@example.com',
      emailVerified: false,
    );

    when(() => authRepository.register(
          email: any(named: 'email'),
          password: any(named: 'password'),
          displayName: any(named: 'displayName'),
        )).thenAnswer((_) async => user);
    when(() => authRepository.sendEmailVerification()).thenAnswer((_) async {});

    final container = makeContainer();
    addTearDown(container.dispose);

    final destination = await container
        .read(authActionControllerProvider.notifier)
        .registerWithEmail(
          displayName: 'New User',
          email: 'new@example.com',
          password: 'secret123',
        );

    expect(destination, AuthDestination.emailVerification);
    verify(() => authRepository.sendEmailVerification()).called(1);
  });

  test('signInWithEmail returns home for verified users', () async {
    const user = AuthUser(
      uid: 'uid-2',
      email: 'verified@example.com',
      emailVerified: true,
    );

    when(() => authRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => user);

    final container = makeContainer();
    addTearDown(container.dispose);

    final destination = await container
        .read(authActionControllerProvider.notifier)
        .signInWithEmail(
          email: 'verified@example.com',
          password: 'secret123',
        );

    expect(destination, AuthDestination.home);
  });
}
