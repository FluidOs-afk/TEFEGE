importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyDQRoDby4OQBrEG-JwP348sDxjEM3HHdNw',
  authDomain: 'outfy-81a2c.firebaseapp.com',
  projectId: 'outfy-81a2c',
  storageBucket: 'outfy-81a2c.firebasestorage.app',
  messagingSenderId: '275606187408',
  appId: '1:275606187408:web:972dd50943cf8154a69715',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const { title, body } = payload.notification ?? {};
  self.registration.showNotification(title ?? 'OUTFY', {
    body: body ?? '',
    icon: '/icons/Icon-192.png',
  });
});
