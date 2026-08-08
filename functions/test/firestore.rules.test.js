'use strict';

const { initializeTestEnvironment, assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');
const { readFileSync } = require('fs');
const { resolve } = require('path');
const { describe, it, before, after, afterEach } = require('node:test');

const PROJECT_ID = 'travelsuperapp-f04a0';
const FIRESTORE_HOST = process.env.FIRESTORE_EMULATOR_HOST || 'localhost:8080';

let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: readFileSync(resolve(__dirname, '../../firestore.rules'), 'utf8'),
      host: FIRESTORE_HOST.split(':')[0],
      port: parseInt(FIRESTORE_HOST.split(':')[1], 10),
    },
  });
});

afterEach(async () => {
  await testEnv.clearFirestore();
});

after(async () => {
  await testEnv.cleanup();
});

describe('Firestore security rules', () => {
  describe('/users/{userId}', () => {
    it('allows an authenticated user to read their own profile', async () => {
      const uid = 'user-1';
      await testEnv.withSecurityRulesDisabled(async (ctx) => {
        await ctx.firestore().collection('users').doc(uid).set({ name: 'Alice' });
      });

      const userCtx = testEnv.authenticatedContext(uid);
      await assertSucceeds(userCtx.firestore().collection('users').doc(uid).get());
    });

    it('denies an authenticated user from reading another user\'s profile', async () => {
      await testEnv.withSecurityRulesDisabled(async (ctx) => {
        await ctx.firestore().collection('users').doc('other-user').set({ name: 'Bob' });
      });

      const userCtx = testEnv.authenticatedContext('user-1');
      await assertFails(userCtx.firestore().collection('users').doc('other-user').get());
    });

    it('denies unauthenticated access to user profiles', async () => {
      await testEnv.withSecurityRulesDisabled(async (ctx) => {
        await ctx.firestore().collection('users').doc('user-1').set({ name: 'Alice' });
      });

      const anonCtx = testEnv.unauthenticatedContext();
      await assertFails(anonCtx.firestore().collection('users').doc('user-1').get());
    });

    it('allows an authenticated user to write their own profile', async () => {
      const uid = 'user-1';
      const userCtx = testEnv.authenticatedContext(uid);
      await assertSucceeds(
        userCtx.firestore().collection('users').doc(uid).set({ name: 'Alice' })
      );
    });

    it('denies an authenticated user from writing another user\'s profile', async () => {
      const userCtx = testEnv.authenticatedContext('user-1');
      await assertFails(
        userCtx.firestore().collection('users').doc('other-user').set({ name: 'Hacker' })
      );
    });
  });

  describe('/trips/{tripId}', () => {
    it('allows owner to read their own trip', async () => {
      const uid = 'user-1';
      await testEnv.withSecurityRulesDisabled(async (ctx) => {
        await ctx.firestore().collection('trips').doc('trip-1').set({ ownerId: uid, destination: 'Paris' });
      });

      const userCtx = testEnv.authenticatedContext(uid);
      await assertSucceeds(userCtx.firestore().collection('trips').doc('trip-1').get());
    });

    it('denies non-owner from reading a trip', async () => {
      await testEnv.withSecurityRulesDisabled(async (ctx) => {
        await ctx.firestore().collection('trips').doc('trip-1').set({ ownerId: 'user-1', destination: 'Paris' });
      });

      const userCtx = testEnv.authenticatedContext('user-2');
      await assertFails(userCtx.firestore().collection('trips').doc('trip-1').get());
    });

    it('allows owner to create a trip', async () => {
      const uid = 'user-1';
      const userCtx = testEnv.authenticatedContext(uid);
      await assertSucceeds(
        userCtx.firestore().collection('trips').doc('trip-new').set({ ownerId: uid, destination: 'Rome' })
      );
    });

    it('denies creating a trip with a different ownerId', async () => {
      const userCtx = testEnv.authenticatedContext('user-1');
      await assertFails(
        userCtx.firestore().collection('trips').doc('trip-bad').set({ ownerId: 'user-2', destination: 'Rome' })
      );
    });

    it('denies unauthenticated access to trips', async () => {
      await testEnv.withSecurityRulesDisabled(async (ctx) => {
        await ctx.firestore().collection('trips').doc('trip-1').set({ ownerId: 'user-1', destination: 'Paris' });
      });

      const anonCtx = testEnv.unauthenticatedContext();
      await assertFails(anonCtx.firestore().collection('trips').doc('trip-1').get());
    });
  });

  describe('default deny', () => {
    it('denies access to uncovered collections', async () => {
      const userCtx = testEnv.authenticatedContext('user-1');
      await assertFails(userCtx.firestore().collection('secret').doc('doc-1').get());
    });
  });
});
