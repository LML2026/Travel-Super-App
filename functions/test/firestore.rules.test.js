const test = require('node:test');
const assert = require('node:assert/strict');
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const {
  doc,
  setDoc,
  getDoc,
  deleteDoc,
  getDocs,
  collection,
} = require('firebase/firestore');

const PROJECT_ID = 'travelsuperapp-f04a0';
const FIRESTORE_HOST =
  process.env.FIRESTORE_EMULATOR_HOST?.split(':')[0] || '127.0.0.1';
const FIRESTORE_PORT = Number(
  process.env.FIRESTORE_EMULATOR_HOST?.split(':')[1] || 8080,
);

let testEnv;

test.before(async () => {
  try {
    testEnv = await initializeTestEnvironment({
      projectId: PROJECT_ID,
      firestore: {
        host: FIRESTORE_HOST,
        port: FIRESTORE_PORT,
      },
    });
  } catch (error) {
    console.error('Failed to initialize Firestore rules test environment:', error);
    throw error;
  }
});

test.after(async () => {
  if (testEnv != null) {
    await testEnv.cleanup();
  }
});

test.afterEach(async () => {
  if (testEnv != null) {
    await testEnv.clearFirestore();
  }
});

async function seedTripsAndActivities() {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();

    await setDoc(doc(db, 'users/userA/trips/tripA'), {
      id: 'tripA',
      destination: 'Rome',
      ownerUid: 'userA',
    });

    await setDoc(doc(db, 'users/userA/trips/tripA/activities/activityA'), {
      id: 'activityA',
      tripId: 'tripA',
      title: 'Colosseum',
      ownerUid: 'userA',
    });

    await setDoc(doc(db, 'users/userB/trips/tripB'), {
      id: 'tripB',
      destination: 'Paris',
      ownerUid: 'userB',
    });

    await setDoc(doc(db, 'users/userB/trips/tripB/activities/activityB'), {
      id: 'activityB',
      tripId: 'tripB',
      title: 'Louvre',
      ownerUid: 'userB',
    });

    await setDoc(doc(db, 'users/userB/sharedTrips/tripA'), {
      tripId: 'tripA',
      ownerUserId: 'userA',
      role: 'editor',
      status: 'active',
    });
    await setDoc(doc(db, 'users/userC/sharedTrips/tripA'), {
      tripId: 'tripA',
      ownerUserId: 'userA',
      role: 'viewer',
      status: 'active',
    });
  });
}

test('unauthenticated users cannot read private trip data', async () => {
  await seedTripsAndActivities();
  const db = testEnv.unauthenticatedContext().firestore();

  await assertFails(getDoc(doc(db, 'users/userA/trips/tripA')));
  await assertFails(
    getDoc(doc(db, 'users/userA/trips/tripA/activities/activityA')),
  );
});

test('User A can read and write only User A trips', async () => {
  await seedTripsAndActivities();
  const db = testEnv.authenticatedContext('userA').firestore();

  await assertSucceeds(getDoc(doc(db, 'users/userA/trips/tripA')));
  await assertSucceeds(
    setDoc(doc(db, 'users/userA/trips/tripA'), {
      id: 'tripA',
      destination: 'Rome Updated',
      ownerUid: 'userA',
    }),
  );

  const ownTrips = await assertSucceeds(getDocs(collection(db, 'users/userA/trips')));
  assert.equal(ownTrips.docs.length, 1);
});

test('User A cannot read User B trip by direct document id access', async () => {
  await seedTripsAndActivities();
  const db = testEnv.authenticatedContext('userA').firestore();

  await assertFails(getDoc(doc(db, 'users/userB/trips/tripB')));
});

test('User A cannot modify or delete User B trip', async () => {
  await seedTripsAndActivities();
  const db = testEnv.authenticatedContext('userA').firestore();

  await assertFails(
    setDoc(doc(db, 'users/userB/trips/tripB'), {
      id: 'tripB',
      destination: 'Hijacked',
      ownerUid: 'userA',
    }),
  );

  await assertFails(deleteDoc(doc(db, 'users/userB/trips/tripB')));
});

test('activities enforce the same ownership boundaries as trips', async () => {
  await seedTripsAndActivities();
  const db = testEnv.authenticatedContext('userA').firestore();

  await assertSucceeds(
    getDoc(doc(db, 'users/userA/trips/tripA/activities/activityA')),
  );

  await assertFails(
    getDoc(doc(db, 'users/userB/trips/tripB/activities/activityB')),
  );

  await assertFails(
    setDoc(doc(db, 'users/userB/trips/tripB/activities/activityB'), {
      id: 'activityB',
      tripId: 'tripB',
      title: 'Tampered',
      ownerUid: 'userA',
    }),
  );
});

test('active editor can access and update shared trip data', async () => {
  await seedTripsAndActivities();
  const db = testEnv.authenticatedContext('userB').firestore();

  await assertSucceeds(getDoc(doc(db, 'users/userA/trips/tripA')));
  await assertSucceeds(
    setDoc(doc(db, 'users/userA/trips/tripA/activities/activityA'), {
      id: 'activityA',
      tripId: 'tripA',
      title: 'Colosseum updated',
    }),
  );
  await assertSucceeds(
    setDoc(doc(db, 'users/userA/trips/tripA/expenses/expenseA'), {
      id: 'expenseA',
      tripId: 'tripA',
      amount: 20,
    }),
  );
  await assertFails(
    setDoc(doc(db, 'users/userA/trips/tripA/collaborators/other'), {
      userId: 'userC',
      role: 'viewer',
    }),
  );
});

test('active viewer can read shared data but cannot write it', async () => {
  await seedTripsAndActivities();
  const db = testEnv.authenticatedContext('userC').firestore();

  await assertSucceeds(
    getDoc(doc(db, 'users/userA/trips/tripA/activities/activityA')),
  );
  await assertFails(
    setDoc(doc(db, 'users/userA/trips/tripA/activities/activityA'), {
      id: 'activityA',
      tripId: 'tripA',
      title: 'Viewer tampered',
    }),
  );
});

test('unrelated users cannot use a shared owner path', async () => {
  await seedTripsAndActivities();
  const db = testEnv.authenticatedContext('userD').firestore();

  await assertFails(getDoc(doc(db, 'users/userA/trips/tripA')));
  await assertFails(
    getDoc(doc(db, 'users/userA/trips/tripA/documents/documentA')),
  );
});
