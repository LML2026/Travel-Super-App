'use strict';

const { readFileSync } = require('fs');
const { resolve } = require('path');

const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');

const RULES_PATH = resolve(__dirname, '../../firestore.rules');

let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'demo-test',
    firestore: {
      rules: readFileSync(RULES_PATH, 'utf8'),
    },
  });
});

afterEach(async () => {
  await testEnv.clearFirestore();
});

after(async () => {
  await testEnv.cleanup();
});

describe('Firestore Security Rules – /users/{userId}', () => {
  it('allows an authenticated user to read their own document', async () => {
    const db = testEnv.authenticatedContext('alice').firestore();
    await assertSucceeds(db.collection('users').doc('alice').get());
  });

  it('denies an authenticated user from reading another user\'s document', async () => {
    const db = testEnv.authenticatedContext('alice').firestore();
    await assertFails(db.collection('users').doc('bob').get());
  });

  it('denies unauthenticated access to user documents', async () => {
    const db = testEnv.unauthenticatedContext().firestore();
    await assertFails(db.collection('users').doc('alice').get());
  });

  it('allows an authenticated user to write their own document', async () => {
    const db = testEnv.authenticatedContext('alice').firestore();
    await assertSucceeds(db.collection('users').doc('alice').set({ name: 'Alice' }));
  });

  it('denies writing to another user\'s document', async () => {
    const db = testEnv.authenticatedContext('alice').firestore();
    await assertFails(db.collection('users').doc('bob').set({ name: 'Bob' }));
  });
});

describe('Firestore Security Rules – /trips/{tripId}', () => {
  it('allows an authenticated user to create a trip', async () => {
    const db = testEnv.authenticatedContext('alice').firestore();
    await assertSucceeds(
      db.collection('trips').add({ ownerId: 'alice', destination: 'Paris' })
    );
  });

  it('denies unauthenticated user from creating a trip', async () => {
    const db = testEnv.unauthenticatedContext().firestore();
    await assertFails(
      db.collection('trips').add({ ownerId: 'anon', destination: 'Paris' })
    );
  });

  it('allows the owner to read their trip', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('trips').doc('trip1').set({ ownerId: 'alice', destination: 'Tokyo' });
    });
    const db = testEnv.authenticatedContext('alice').firestore();
    await assertSucceeds(db.collection('trips').doc('trip1').get());
  });

  it('denies a non-owner from reading a trip', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('trips').doc('trip2').set({ ownerId: 'alice', destination: 'Tokyo' });
    });
    const db = testEnv.authenticatedContext('bob').firestore();
    await assertFails(db.collection('trips').doc('trip2').get());
  });

  it('denies unauthenticated user from reading trips', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('trips').doc('trip3').set({ ownerId: 'alice', destination: 'Tokyo' });
    });
    const db = testEnv.unauthenticatedContext().firestore();
    await assertFails(db.collection('trips').doc('trip3').get());
  });
});

describe('Firestore Security Rules – default deny', () => {
  it('denies reads on arbitrary collections', async () => {
    const db = testEnv.authenticatedContext('alice').firestore();
    await assertFails(db.collection('secrets').doc('key').get());
  });
});
