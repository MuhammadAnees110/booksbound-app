/**
 * scripts/audit_cover_urls.mjs
 *
 * Scans the Firestore `books` collection for documents whose `coverUrl`
 * field is missing, empty, or contains raw Base64 data instead of an HTTPS
 * Storage URL.  Run this after the books_service.dart Base64 fallback removal
 * to identify any legacy documents that will now show a grey placeholder.
 *
 * Usage:
 *   GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccountKey.json \
 *     node scripts/audit_cover_urls.mjs
 *
 *   -- or, if you have already run `gcloud auth application-default login`:
 *   node scripts/audit_cover_urls.mjs
 *
 * Exit codes:
 *   0  No issues found.
 *   1  One or more documents need remediation.
 */

import { readFileSync } from 'fs';
import { initializeApp, cert, applicationDefault } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

// ---------------------------------------------------------------------------
// Initialise Firebase Admin (service-account file OR ADC)
// ---------------------------------------------------------------------------
const credentialEnv = process.env.GOOGLE_APPLICATION_CREDENTIALS;
let credential;
if (credentialEnv) {
  try {
    credential = cert(JSON.parse(readFileSync(credentialEnv, 'utf8')));
  } catch (err) {
    console.error(`\n❌  Failed to read service account key at: ${credentialEnv}`);
    console.error(`   ${err.message}\n`);
    process.exit(1);
  }
} else {
  credential = applicationDefault();
}
initializeApp({ credential });

const db = getFirestore();
const COLLECTION = 'books';
const PAGE_SIZE  = 200;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
function classifyUrl(coverUrl) {
  if (!coverUrl || coverUrl.trim() === '') return 'MISSING';
  const trimmed = coverUrl.trim();
  if (trimmed.startsWith('https://')) return 'OK';
  if (trimmed.startsWith('http://'))  return 'INSECURE_HTTP';
  // Base64 data URI or raw Base64 blob
  if (trimmed.startsWith('data:'))    return 'BASE64_DATA_URI';
  return 'LEGACY_BASE64';          // raw Base64 string (old fallback path)
}

// ---------------------------------------------------------------------------
// Scan
// ---------------------------------------------------------------------------
const issues   = [];
const counts   = { OK: 0, MISSING: 0, INSECURE_HTTP: 0, BASE64_DATA_URI: 0, LEGACY_BASE64: 0 };
let   cursor   = null;
let   total    = 0;

console.log(`\nScanning Firestore collection: "${COLLECTION}" …\n`);

while (true) {
  let query = db.collection(COLLECTION).orderBy('__name__').limit(PAGE_SIZE);
  if (cursor) query = query.startAfter(cursor);

  const snapshot = await query.get();
  if (snapshot.empty) break;

  for (const doc of snapshot.docs) {
    total++;
    const data     = doc.data();
    const coverUrl = data.coverUrl ?? '';
    const kind     = classifyUrl(coverUrl);
    counts[kind]++;

    if (kind !== 'OK') {
      issues.push({
        id:    doc.id,
        title: data.title ?? '(no title)',
        kind,
        // Show only the first 80 chars of the value so Base64 blobs don't flood stdout
        preview: coverUrl.length > 80 ? coverUrl.slice(0, 80) + '…' : coverUrl,
      });
    }
  }

  cursor = snapshot.docs[snapshot.docs.length - 1];
  if (snapshot.docs.length < PAGE_SIZE) break;
}

// ---------------------------------------------------------------------------
// Report
// ---------------------------------------------------------------------------
console.log(`Total documents scanned : ${total}`);
console.log(`  ✅  HTTPS URLs (OK)   : ${counts.OK}`);
console.log(`  ⚠️   Missing / empty   : ${counts.MISSING}`);
console.log(`  ⚠️   Insecure HTTP     : ${counts.INSECURE_HTTP}`);
console.log(`  🔴  Base64 data URI   : ${counts.BASE64_DATA_URI}`);
console.log(`  🔴  Legacy raw Base64 : ${counts.LEGACY_BASE64}`);

if (issues.length === 0) {
  console.log('\n✅  No issues found. All book cover URLs are valid HTTPS links.\n');
  process.exit(0);
}

console.log(`\n🔴  ${issues.length} document(s) need remediation:\n`);
console.log('  ID'.padEnd(28) + 'Title'.padEnd(35) + 'Kind'.padEnd(22) + 'Preview');
console.log('  ' + '─'.repeat(110));
for (const issue of issues) {
  console.log(
    `  ${issue.id.padEnd(26)} ${issue.title.slice(0, 33).padEnd(35)} ${issue.kind.padEnd(22)} ${issue.preview}`,
  );
}

console.log(`
Remediation options:
  • Re-upload the book cover via the admin panel (book edit form).
  • Or run a one-off migration script that reads the Base64 value,
    uploads it to Firebase Storage, and writes the resulting HTTPS URL
    back to the document's \`coverUrl\` field.
`);

process.exit(1);
