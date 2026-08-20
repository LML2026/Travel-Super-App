import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_super_app/features/authentication/data/services/account_deletion_service.dart';
import 'package:travel_super_app/features/authentication/presentation/providers/auth_providers.dart';

class _FakeAccountDeletionService implements AccountDeletionService {
  String? password;
  Object? failure;

  @override
  Future<void> deleteAccount({String? password}) async {
    this.password = password;
    if (failure != null) throw failure!;
  }
}

void main() {
  test('account deletion forwards confirmation credential to the service',
      () async {
    final service = _FakeAccountDeletionService();
    final container = ProviderContainer(
      overrides: [accountDeletionServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);

    await container
        .read(authActionControllerProvider.notifier)
        .deleteAccount(password: 'confirmed-password');

    expect(service.password, 'confirmed-password');
    expect(
      container.read(authActionControllerProvider).hasError,
      isFalse,
    );
  });

  test('account deletion preserves a friendly requires-login error', () async {
    final service = _FakeAccountDeletionService()
      ..failure = const AccountDeletionException(
        'requires-recent-login',
        'For your security, sign in again before deleting your account.',
      );
    final container = ProviderContainer(
      overrides: [accountDeletionServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(authActionControllerProvider.notifier).deleteAccount(),
      throwsA(
        isA<AccountDeletionException>().having(
          (error) => error.message,
          'message',
          'For your security, sign in again before deleting your account.',
        ),
      ),
    );
  });
}
