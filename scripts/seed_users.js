/**
 * Provision Test User Profiles in Firestore — BooksBound
 * Run: node scripts/seed_users.js
 *
 * Provisons profiles for:
 * 1. admin@booksbound.demo    (Role: admin)
 * 2. customer@booksbound.demo (Role: user)
 * 3. reset@booksbound.demo    (Role: user)
 */

let cert = null;
try {
  ({ cert } = require('firebase-admin/app'));
} catch (_) {}
const path = require('path');
const os = require('os');
const fs = require('fs');

const PROJECT = 'booksbound-app-boka18';
const BASE = `https://firestore.googleapis.com/v1/projects/${PROJECT}/databases/(default)/documents`;
const API_KEY = 'AIzaSyAN2EgOD5NDBQr4quFbfJrytgSCkUi4y1A';

const testUsers = [
  {
    email: 'admin@booksbound.demo',
    password: 'Admin@123',
    role: 'admin',
    displayName: 'Admin User',
    knownUid: 'lmaEt1xyhHg9QURAMdCZAVvURii1',
  },
  {
    email: 'customer@booksbound.demo',
    password: 'Customer@123',
    role: 'user',
    displayName: 'Customer User',
    knownUid: 'yQnd2wEcyhNFImpSDcw3kXzim0t2',
  },
  {
    email: 'reset@booksbound.demo',
    password: 'Reset@123',
    role: 'user',
    displayName: 'Reset Test User',
    knownUid: 'x6GBv02M3lZTrP0pn7hmfivER1K2',
  },
];

async function getAuthTokenAndUid(user) {
  // Method 1: Sign in with Firebase Auth API key to get user's live ID token & localId (uid)
  try {
    const res = await fetch(
      `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${API_KEY}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email: user.email,
          password: user.password,
          returnSecureToken: true,
        }),
      }
    );
    const data = await res.json();
    if (res.ok && data.localId) {
      return { uid: data.localId, idToken: data.idToken };
    }
  } catch (_) {}

  return { uid: user.knownUid, idToken: null };
}

function toFirestoreValue(val) {
  if (typeof val === 'string') return { stringValue: val };
  if (typeof val === 'number' && Number.isInteger(val)) return { integerValue: String(val) };
  if (typeof val === 'number') return { doubleValue: val };
  if (typeof val === 'boolean') return { booleanValue: val };
  if (Array.isArray(val)) return { arrayValue: { values: val.map(toFirestoreValue) } };
  if (val && typeof val === 'object') {
    const fields = {};
    for (const [k, v] of Object.entries(val)) fields[k] = toFirestoreValue(v);
    return { mapValue: { fields } };
  }
  return { nullValue: null };
}

function toDoc(obj) {
  const fields = {};
  for (const [k, v] of Object.entries(obj)) fields[k] = toFirestoreValue(v);
  return { fields };
}

async function getAdminToken() {
  const keyCandidates = [
    process.env.GOOGLE_APPLICATION_CREDENTIALS,
    path.join(__dirname, '..', 'serviceAccountKey.json'),
    path.join(__dirname, 'serviceAccountKey.json'),
  ];
  for (const candidate of keyCandidates) {
    if (candidate && fs.existsSync(candidate) && cert) {
      try {
        const keyData = JSON.parse(fs.readFileSync(candidate, 'utf8'));
        const credential = cert(keyData);
        const token = await credential.getAccessToken();
        if (token && token.access_token) return token.access_token;
      } catch (_) {}
    }
  }

  const configPath = path.join(os.homedir(), '.config', 'configstore', 'firebase-tools.json');
  try {
    const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
    if (config?.tokens?.access_token) return config.tokens.access_token;
  } catch (_) {}

  return null;
}

async function seedUsers() {
  console.log('👤 Provisioning user profiles in Firestore for BooksBound...\n');
  const adminToken = await getAdminToken();

  for (const user of testUsers) {
    const { uid, idToken } = await getAuthTokenAndUid(user);
    const token = idToken || adminToken;

    if (!uid) {
      console.warn(`⚠️ Could not resolve UID for ${user.email}`);
      continue;
    }

    const userData = {
      uid: uid,
      name: user.displayName,
      displayName: user.displayName,
      email: user.email,
      role: user.role,
      photoUrl: '',
      createdAt: new Date().toISOString(),
      wishlist: [],
      ratings: {},
      isBlocked: false,
    };

    const collections = ['user', 'users'];
    for (const col of collections) {
      const url = `${BASE}/${col}/${uid}`;
      const headers = { 'Content-Type': 'application/json' };
      if (token) headers['Authorization'] = `Bearer ${token}`;

      try {
        const res = await fetch(url, {
          method: 'PATCH',
          headers,
          body: JSON.stringify(toDoc(userData)),
        });
        if (res.ok) {
          console.log(`✅ Saved ${user.email} (${user.role}) -> ${col}/${uid}`);
        } else {
          console.warn(`⚠️ Failed writing to ${col}/${uid}: HTTP ${res.status}`);
        }
      } catch (err) {
        console.error(`❌ Error writing to ${col}/${uid}:`, err.message);
      }
    }
  }

  console.log('\n🎉 User profiles provisioning complete!');
}

seedUsers().catch(err => {
  console.error('\n❌ Seeding users failed:', err.message);
  process.exit(1);
});
