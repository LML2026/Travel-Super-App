import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_super_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:travel_super_app/features/auth/presentation/providers/auth_provider.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockUserCredential extends Mock implements UserCredential {}

void main() {
  late _MockAuthRepository repository;

  setUp(() {
    repository = _MockAuthRepository();
    when(
      () => repository.authStateChanges(),
    ).thenAnswer((_) => const Stream<User?>.empty());
    when(() => repository.currentUser).thenReturn(null);
  });

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
  }

  test('authStateProvider emits values from repository stream', () async {
    when(
      () => repository.authStateChanges(),
    ).thenAnswer((_) => Stream<User?>.value(null));

    final container = makeContainer();
    addTearDown(container.dispose);

    final state = await container.read(authStateProvider.future);

    expect(state, isNull);
  });

  test('signIn delegates to repository and sets success state', () async {
    when(
      () => repository.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => _MockUserCredential());

    final container = makeContainer();
    addTearDown(container.dispose);

    final notifier = container.read(authMutationProvider.notifier);
    await notifier.signIn(email: 'user@example.com', password: 'abc123');

    verify(
      () => repository.signIn(email: 'user@example.com', password: 'abc123'),
    ).called(1);
    final state = container.read(authMutationProvider);
    expect(state.hasValue, isTrue);
    expect(state.hasError, isFalse);
  });

  test('register rethrows repository error and sets error state', () async {
    final exception = FirebaseAuthException(
      code: 'email-already-in-use',
      message: 'Email already in use',
    );
    when(
      () => repository.register(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(exception);

    final container = makeContainer();
    addTearDown(container.dispose);

    final notifier = container.read(authMutationProvider.notifier);

    await expectLater(
      () => notifier.register(email: 'taken@example.com', password: 'abc123'),
      throwsA(isA<FirebaseAuthException>()),
    );

    final state = container.read(authMutationProvider);
    expect(state.hasError, isTrue);
  });

  test('sendPasswordReset delegates to repository', () async {
    when(
      () => repository.sendPasswordReset(email: any(named: 'email')),
    ).thenAnswer((_) async {});

    final container = makeContainer();
    addTearDown(container.dispose);

    final notifier = container.read(authMutationProvider.notifier);
    await notifier.sendPasswordReset(email: 'user@example.com');

    verify(
      () => repository.sendPasswordReset(email: 'user@example.com'),
    ).called(1);
  });

  test('signOut delegates to repository', () async {
    when(() => repository.signOut()).thenAnswer((_) async {});

    final container = makeContainer();
    addTearDown(container.dispose);

    final notifier = container.read(authMutationProvider.notifier);
    await notifier.signOut();

    verify(() => repository.signOut()).called(1);
  });
}
