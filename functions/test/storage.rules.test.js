const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const { ref, uploadBytes, getBytes, deleteObject } = require('firebase/storage');

const PROJECT_ID = 'travelsuperapp-f04a0';
const FIRESTORE_HOST = process.env.FIRESTORE_EMULATOR_HOST?.split(':')[0] || '127.0.0.1';
const FIRESTORE_PORT = Number(process.env.FIRESTORE_EMULATOR_HOST?.split(':')[1] || 8080);
const STORAGE_HOST = process.env.FIREBASE_STORAGE_EMULATOR_HOST?.split(':')[0] || '127.0.0.1';
const STORAGE_PORT = Number(process.env.FIREBASE_STORAGE_EMULATOR_HOST?.split(':')[1] || 9199);

let testEnv;

test.before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: { host: FIRESTORE_HOST, port: FIRESTORE_PORT },
    storage: {
      host: STORAGE_HOST,
      port: STORAGE_PORT,
      rules: fs.readFileSync('storage.rules', 'utf8'),
    },
  });
});

test.after(async () => {
  await testEnv?.cleanup();
});

test.beforeEach(async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await db.doc('users/userB/sharedTrips/tripA').set({
      ownerUserId: 'userA',
      role: 'editor',
      status: 'active',
    });
    await db.doc('users/userC/sharedTrips/tripA').set({
      ownerUserId: 'userA',
      role: 'viewer',
      status: 'active',
    });
  });
});

function documentRef(userId, documentId = 'documentA') {
  return `users/${userId}/trips/tripA/documents/${documentId}/ticket.pdf`;
}

test('owner can upload, read and delete a trip document', async () => {
  const storage = testEnv.authenticatedContext('userA').storage();
  const file = ref(storage, documentRef('userA'));
  const bytes = new Uint8Array([1, 2, 3]);

  await assertSucceeds(uploadBytes(file, bytes));
  await assertSucceeds(getBytes(file));
  await assertSucceeds(deleteObject(file));
});

test('editor can write shared documents and viewer is read-only', async () => {
  const editorStorage = testEnv.authenticatedContext('userB').storage();
  const viewerStorage = testEnv.authenticatedContext('userC').storage();
  const editorFile = ref(editorStorage, documentRef('userA', 'editorDoc'));
  const viewerFile = ref(viewerStorage, documentRef('userA', 'viewerDoc'));
  const bytes = new Uint8Array([4, 5, 6]);

  await assertSucceeds(uploadBytes(editorFile, bytes));
  await assertSucceeds(getBytes(ref(viewerStorage, documentRef('userA', 'editorDoc'))));
  await assertFails(uploadBytes(viewerFile, bytes));
  await assertFails(deleteObject(ref(viewerStorage, documentRef('userA', 'editorDoc'))));
});

test('unrelated users cannot access shared trip documents', async () => {
  const storage = testEnv.authenticatedContext('userD').storage();
  const file = ref(storage, documentRef('userA', 'privateDoc'));

  await assertFails(uploadBytes(file, new Uint8Array([7])));
  await assertFails(getBytes(file));
  await assertFails(deleteObject(file));
});
