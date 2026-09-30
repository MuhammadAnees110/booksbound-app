/**
 * Firestore Seed Script — BooksBound
 * Run: node scripts/seed_firestore.js
 *
 * Seeds: categories (8) + books (24, 3 per category)
 * Uses firebase-admin with the token from firebase-tools.json (no gcloud needed).
 */

let cert = null;
try {
  ({ cert } = require('firebase-admin/app'));
} catch (_) {}
const path = require('path');
const os = require('os');
const fs = require('fs');

async function getAccessToken() {
  // Option 1: serviceAccountKey.json (root or scripts directory, or via env)
  const keyCandidates = [
    process.env.GOOGLE_APPLICATION_CREDENTIALS,
    path.join(__dirname, '..', 'serviceAccountKey.json'),
    path.join(__dirname, 'serviceAccountKey.json'),
  ];

  for (const candidate of keyCandidates) {
    if (candidate && fs.existsSync(candidate) && cert) {
      try {
        const keyData = JSON.parse(fs.readFileSync(candidate, 'utf8'));
        console.log(`🔑 Using service account key from: ${candidate}`);
        const credential = cert(keyData);
        const token = await credential.getAccessToken();
        if (token && token.access_token) {
          return token.access_token;
        }
      } catch (err) {
        console.warn(`⚠️  Failed reading service account from ${candidate}:`, err.message);
      }
    }
  }

  // Option 2: Fall back to firebase login stored credentials
  const configPath = path.join(os.homedir(), '.config', 'configstore', 'firebase-tools.json');
  try {
    const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
    const token = config?.tokens?.access_token;
    if (token) {
      console.log('🔑 Using access token from firebase-tools CLI session.');
      return token;
    }
  } catch (_) {}

  console.error('❌ Authentication failed. Please provide credentials via either:');
  console.error('   1) Place your Firebase serviceAccountKey.json in the project root');
  console.error('      (or export GOOGLE_APPLICATION_CREDENTIALS="path/to/serviceAccountKey.json")');
  console.error('   2) Run: firebase login (to authenticate via Firebase CLI)\n');
  process.exit(1);
}

// ─── Categories ────────────────────────────────────────────────────────────
const categories = [
  { name: 'Fiction',      icon: 'menu_book',      color: 0xFF6200EE, imageUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/categories/fiction.jpg' },
  { name: 'Mystery',      icon: 'search',         color: 0xFF03DAC6, imageUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/categories/mystery.jpg' },
  { name: 'Science',      icon: 'science',        color: 0xFF018786, imageUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/categories/science.jpg' },
  { name: 'History',      icon: 'history_edu',    color: 0xFFB00020, imageUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/categories/history.jpg' },
  { name: 'Fantasy',      icon: 'auto_fix_high',  color: 0xFF3700B3, imageUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/categories/fantasy.jpg' },
  { name: 'Romance',      icon: 'favorite',       color: 0xFFE91E63, imageUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/categories/romance.jpg' },
  { name: 'Biography',    icon: 'person',         color: 0xFF795548, imageUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/categories/biography.jpg' },
  { name: 'Technology',   icon: 'computer',       color: 0xFF607D8B, imageUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/categories/technology.jpg' },
];

// ─── Books (3 per category) ─────────────────────────────────────────────────
const books = [
  // Fiction
  { title: 'The Great Gatsby',        author: 'F. Scott Fitzgerald', genre: 'Fiction',    price: 12.99, rating: 4.5, isBestseller: true,  isbn: '9780743273565', description: 'A story of the fabulously wealthy Jay Gatsby and his love for the beautiful Daisy Buchanan.',                    coverUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/covers/the-great-gatsby.jpg', releaseDate: '1925-04-10' },
  { title: 'To Kill a Mockingbird',   author: 'Harper Lee',          genre: 'Fiction',    price: 10.99, rating: 4.8, isBestseller: true,  isbn: '9780061935466', description: 'The unforgettable novel of a childhood in a sleepy Southern town and the crisis of conscience that rocked it.',  coverUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/covers/to-kill-a-mockingbird.jpg', releaseDate: '1960-07-11' },
  { title: '1984',                    author: 'George Orwell',        genre: 'Fiction',    price: 9.99,  rating: 4.7, isBestseller: true,  isbn: '9780451524935', description: 'A dystopian novel set in Airstrip One, a province of the superstate Oceania in a world of perpetual war.',      coverUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/covers/1984.jpg', releaseDate: '1949-06-08' },
  // Mystery
  { title: 'Gone Girl',               author: 'Gillian Flynn',        genre: 'Mystery',    price: 13.99, rating: 4.3, isBestseller: true,  isbn: '9780307588371', description: 'On the morning of his fifth wedding anniversary, Nick Dunne reports that his wife has gone missing.',            coverUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/covers/gone-girl.jpg', releaseDate: '2012-06-05' },
  { title: 'The Girl with the Dragon Tattoo', author: 'Stieg Larsson', genre: 'Mystery',  price: 14.99, rating: 4.4, isBestseller: true,  isbn: '9780307949486', description: 'A gripping mystery about a journalist and a hacker investigating a decades-old disappearance.',                    coverUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/covers/the-girl-with-the-dragon-tattoo.jpg', releaseDate: '2005-08-01' },
  { title: 'Big Little Lies',         author: 'Liane Moriarty',       genre: 'Mystery',    price: 11.99, rating: 4.2, isBestseller: false, isbn: '9780399167065', description: 'A brilliant take on ex-husbands and second wives, schoolyard scandal, and the dangerous little lies we tell.',   coverUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/covers/big-little-lies.jpg', releaseDate: '2014-07-29' },
  // Science
  { title: 'A Brief History of Time', author: 'Stephen Hawking',      genre: 'Science',    price: 14.99, rating: 4.6, isBestseller: true,  isbn: '9780553380163', description: 'A landmark volume in science writing that makes the most challenging cosmic questions accessible.',               coverUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/covers/a-brief-history-of-time.jpg', releaseDate: '1988-04-01' },
  { title: 'The Selfish Gene',        author: 'Richard Dawkins',       genre: 'Science',    price: 12.99, rating: 4.4, isBestseller: false, isbn: '9780198788607', description: 'Richard Dawkins presents a gene-centred view of evolution and coins the term "meme".',                            coverUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/covers/the-selfish-gene.jpg', releaseDate: '1976-11-01' },
  { title: 'Sapiens',                 author: 'Yuval Noah Harari',     genre: 'Science',    price: 15.99, rating: 4.7, isBestseller: true,  isbn: '9780062316097', description: 'A brief history of humankind, from the Stone Age to the present day.',                                             coverUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/covers/sapiens.jpg', releaseDate: '2011-01-01' },
  // History
  { title: 'The Diary of a Young Girl', author: 'Anne Frank',         genre: 'History',    price: 8.99,  rating: 4.9, isBestseller: true,  isbn: '9780553577129', description: 'The diary Anne Frank kept during the two years she and her family hid from the Nazis in occupied Holland.',     coverUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/covers/the-diary-of-a-young-girl.jpg', releaseDate: '1947-06-25' },
  { title: 'Guns, Germs and Steel',   author: 'Jared Diamond',        genre: 'History',    price: 13.99, rating: 4.5, isBestseller: false, isbn: '9780393354324', description: 'Why did history unfold differently on different continents? Diamond examines the roots of power.',              coverUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/covers/guns-germs-and-steel.jpg', releaseDate: '1997-03-01' },
  { title: 'The Silk Roads',          author: 'Peter Frankopan',      genre: 'History',    price: 16.99, rating: 4.3, isBestseller: false, isbn: '9781101912379', description: 'A revelatory history of the world that places Asia at its center.',                                                coverUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/covers/the-silk-roads.jpg', releaseDate: '2015-09-03' },
  // Fantasy
  { title: 'The Hobbit',              author: 'J.R.R. Tolkien',       genre: 'Fantasy',    price: 11.99, rating: 4.8, isBestseller: true,  isbn: '9780547928227', description: 'A great modern classic and the prelude to The Lord of the Rings.',                                                 coverUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/covers/the-hobbit.jpg', releaseDate: '1937-09-21' },
  { title: 'Harry Potter and the Sorcerers Stone', author: 'J.K. Rowling', genre: 'Fantasy', price: 10.99, rating: 4.9, isBestseller: true, isbn: '9780439708180', description: 'Harry Potter has no idea how famous he is until he arrives at Hogwarts School of Witchcraft and Wizardry.', coverUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/covers/harry-potter-and-the-sorcerers-stone.jpg', releaseDate: '1997-06-26' },
  { title: 'The Name of the Wind',    author: 'Patrick Rothfuss',     genre: 'Fantasy',    price: 14.99, rating: 4.6, isBestseller: false, isbn: '9780756404741', description: 'A heroic story of a young man who grows to be the most notorious magician his world has ever seen.',             coverUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/covers/the-name-of-the-wind.jpg', releaseDate: '2007-03-27' },
  // Romance
  { title: 'Pride and Prejudice',     author: 'Jane Austen',          genre: 'Romance',    price: 7.99,  rating: 4.7, isBestseller: true,  isbn: '9780141439518', description: 'The story of Elizabeth Bennet and the proud Mr. Darcy in Regency-era England.',                                  coverUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/covers/pride-and-prejudice.jpg', releaseDate: '1813-01-28' },
  { title: 'The Notebook',            author: 'Nicholas Sparks',      genre: 'Romance',    price: 9.99,  rating: 4.3, isBestseller: true,  isbn: '9780446605236', description: 'A classic love story about two people who fall deeply in love despite their different worlds.',                  coverUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/covers/the-notebook.jpg', releaseDate: '1996-10-01' },
  { title: 'Outlander',               author: 'Diana Gabaldon',       genre: 'Romance',    price: 15.99, rating: 4.5, isBestseller: false, isbn: '9780440212560', description: 'A lush, epic romance set in 18th century Scotland.',                                                              coverUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/covers/outlander.jpg', releaseDate: '1991-06-01' },
  // Biography
  { title: 'Steve Jobs',              author: 'Walter Isaacson',      genre: 'Biography',  price: 17.99, rating: 4.5, isBestseller: true,  isbn: '9781451648539', description: 'The exclusive biography based on more than forty interviews with Steve Jobs.',                                   coverUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/covers/steve-jobs.jpg', releaseDate: '2011-10-24' },
  { title: 'Becoming',                author: 'Michelle Obama',       genre: 'Biography',  price: 16.99, rating: 4.8, isBestseller: true,  isbn: '9781524763138', description: 'An intimate and powerful memoir by the former First Lady of the United States.',                                  coverUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/covers/becoming.jpg', releaseDate: '2018-11-13' },
  { title: 'Long Walk to Freedom',    author: 'Nelson Mandela',       genre: 'Biography',  price: 14.99, rating: 4.7, isBestseller: false, isbn: '9780316548182', description: 'The autobiography of Nelson Mandela, one of the great moral and political leaders of our time.',               coverUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/covers/long-walk-to-freedom.jpg', releaseDate: '1994-11-01' },
  // Technology
  { title: 'Clean Code',              author: 'Robert C. Martin',     genre: 'Technology', price: 34.99, rating: 4.6, isBestseller: true,  isbn: '9780132350884', description: 'A handbook of agile software craftsmanship. Every programmer should read this book.',                            coverUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/covers/clean-code.jpg', releaseDate: '2008-08-01' },
  { title: 'The Pragmatic Programmer', author: 'David Thomas',        genre: 'Technology', price: 39.99, rating: 4.7, isBestseller: true,  isbn: '9780135957059', description: 'A guide to programming best practices that will help you become a better developer.',                            coverUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/covers/the-pragmatic-programmer.jpg', releaseDate: '1999-10-20' },
  { title: 'Zero to One',             author: 'Peter Thiel',          genre: 'Technology', price: 18.99, rating: 4.4, isBestseller: true,  isbn: '9780804139021', description: 'Notes on startups, or how to build the future by PayPal co-founder Peter Thiel.',                               coverUrl: 'https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/covers/zero-to-one.jpg', releaseDate: '2014-09-16' },
];

const PROJECT = 'booksbound-app-boka18';
const BASE = `https://firestore.googleapis.com/v1/projects/${PROJECT}/databases/(default)/documents`;

function toFirestoreValue(val) {
  if (typeof val === 'string')  return { stringValue: val };
  if (typeof val === 'number' && Number.isInteger(val)) return { integerValue: String(val) };
  if (typeof val === 'number')  return { doubleValue: val };
  if (typeof val === 'boolean') return { booleanValue: val };
  if (val && val._type === 'timestamp') return { timestampValue: val.value };
  if (Array.isArray(val))       return { arrayValue: { values: val.map(toFirestoreValue) } };
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

async function restSet(accessToken, collection, docId, data) {
  const url = `${BASE}/${collection}/${docId}`;
  const body = toDoc(data);
  const res = await fetch(url, {
    method: 'PATCH',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(body),
  });
  if (!res.ok) {
    const err = await res.text();
    throw new Error(`Failed to write ${collection}/${docId}: ${err}`);
  }
}

async function restAdd(accessToken, collection, data) {
  const url = `${BASE}/${collection}`;
  const res = await fetch(url, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(toDoc(data)),
  });
  if (!res.ok) {
    const err = await res.text();
    throw new Error(`Failed to add to ${collection}: ${err}`);
  }
}

async function seed() {
  console.log('🌱 Seeding Firestore for BooksBound...\n');

  const accessToken = await getAccessToken();
  console.log('🔑 Got access token.\n');

  // ── Categories ─────────────────────────────────────────────────────────
  console.log('📂 Writing categories...');
  for (const cat of categories) {
    await restSet(accessToken, 'categories', cat.name.toLowerCase(), {
      name: cat.name,
      icon: cat.icon,
      color: cat.color,
      imageUrl: cat.imageUrl,
    });
    process.stdout.write('.');
  }
  console.log(`\n   ✅ ${categories.length} categories written.\n`);

  // ── Books ───────────────────────────────────────────────────────────────
  console.log('📚 Writing books...');
  for (const book of books) {
    await restAdd(accessToken, 'books', {
      title:              book.title,
      author:             book.author,
      genre:              book.genre,
      category:           book.genre,
      category_lowercase: book.genre.toLowerCase().trim(),
      description:        book.description,
      coverUrl:           book.coverUrl,
      price:              book.price,
      stock:              20,
      rating:             book.rating,
      isBestseller:       book.isBestseller,
      isbn:               book.isbn,
      releaseDate:        { _type: 'timestamp', value: new Date(book.releaseDate).toISOString() },
      reviews:            [],
    });
    process.stdout.write('.');
  }
  console.log(`\n   ✅ ${books.length} books written.\n`);

  // ── Users ───────────────────────────────────────────────────────────────
  console.log('👤 Writing user profiles...');
  const testUsers = [
    {
      email: 'admin@booksbound.demo',
      role: 'admin',
      displayName: 'Admin User',
      uid: 'lmaEt1xyhHg9QURAMdCZAVvURii1',
    },
    {
      email: 'customer@booksbound.demo',
      role: 'user',
      displayName: 'Customer User',
      uid: 'yQnd2wEcyhNFImpSDcw3kXzim0t2',
    },
    {
      email: 'reset@booksbound.demo',
      role: 'user',
      displayName: 'Reset Test User',
      uid: 'x6GBv02M3lZTrP0pn7hmfivER1K2',
    },
  ];

  for (const user of testUsers) {
    const userData = {
      uid: user.uid,
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
    for (const col of ['user', 'users']) {
      try {
        await restSet(accessToken, col, user.uid, userData);
      } catch (_) {}
    }
    process.stdout.write('.');
  }
  console.log(`\n   ✅ ${testUsers.length} test user profiles written.\n`);

  console.log('🎉 Done! Open your app — categories, books, and test users are ready.');
}

seed().catch(err => {
  console.error('\n❌ Seed failed:', err.message);
  process.exit(1);
});
