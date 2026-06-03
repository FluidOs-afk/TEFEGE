const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { initializeApp }     = require('firebase-admin/app');
const { getFirestore }      = require('firebase-admin/firestore');
const { getMessaging }      = require('firebase-admin/messaging');
const https = require('https');

initializeApp();

// ─── 1. Webhook Discord al crear una denuncia ─────────────────────────────────
exports.onReportCreated = onDocumentCreated('reports/{reportId}', async (event) => {
  const data = event.data.data();
  const webhookUrl = process.env.WEBHOOK_URL;
  if (!webhookUrl) return;

  const tipos = {
    post: 'Publicación', comment: 'Comentario', message: 'Mensaje',
    user: 'Usuario', story: 'Historia',
  };
  const motivos = {
    spam: 'Spam', hateSpeech: 'Lenguaje de odio',
    inappropriate: 'Contenido inapropiado', harassment: 'Acoso', other: 'Otro',
  };

  const payload = {
    embeds: [{
      title: '🚨 Nueva denuncia — OUTFY',
      color: 0xE53935,
      fields: [
        { name: 'Tipo',             value: tipos[data.targetType]   || data.targetType, inline: true  },
        { name: 'Motivo',           value: motivos[data.reason]     || data.reason,     inline: true  },
        { name: 'ID del contenido', value: data.targetId,                               inline: false },
        { name: 'Denunciante (UID)',value: data.reporterId,                              inline: false },
        { name: 'Descripción',      value: data.description || '—',                    inline: false },
      ],
      timestamp: new Date().toISOString(),
    }],
  };

  await _httpsPost(webhookUrl, payload);
});

// ─── 2. Push FCM al crear una notificación in-app ─────────────────────────────
exports.onNotificationCreated = onDocumentCreated('notifications/{notifId}', async (event) => {
  const data       = event.data.data();
  const toUid      = data.toUid;
  const fromUser   = data.fromUsername || 'Alguien';

  if (!toUid) return;

  const userSnap = await getFirestore().collection('users').doc(toUid).get();
  if (!userSnap.exists) return;

  const token = userSnap.data()?.fcmToken;
  if (!token) return;

  const { title, body } = _buildText(data.type, fromUser, data);

  try {
    await getMessaging().send({
      token,
      notification: { title, body },
      data: {
        type:    data.type    || '',
        postId:  data.postId  || '',
        fromUid: data.fromUid || '',
      },
      android: { priority: 'high' },
      apns:    { payload: { aps: { sound: 'default', badge: 1 } } },
    });
  } catch (err) {
    // Token caducado o inválido: lo eliminamos para no intentarlo de nuevo
    const invalid = [
      'messaging/invalid-registration-token',
      'messaging/registration-token-not-registered',
    ];
    if (invalid.includes(err.code)) {
      await getFirestore().collection('users').doc(toUid).update({ fcmToken: null });
    }
  }
});

// ─── Helpers ──────────────────────────────────────────────────────────────────
function _buildText(type, from, data) {
  switch (type) {
    case 'like':
      return { title: '❤️ Nuevo like',       body: `${from} le dio like a tu publicación` };
    case 'comment':
      return { title: '💬 Nuevo comentario', body: `${from} comentó: "${data.text || ''}"` };
    case 'follow':
      return { title: '👤 Nuevo seguidor',   body: `${from} ha empezado a seguirte` };
    case 'follow_accept':
      return { title: '✅ Solicitud aceptada', body: `${from} aceptó tu solicitud de seguimiento` };
    case 'message':
      return { title: `✉️ ${from}`,           body: data.text || 'Nuevo mensaje' };
    default:
      return { title: 'OUTFY',               body: `${from} interactuó contigo` };
  }
}

function _httpsPost(webhookUrl, payload) {
  return new Promise((resolve, reject) => {
    const parsed  = new URL(webhookUrl);
    const body    = JSON.stringify(payload);
    const options = {
      hostname: parsed.hostname,
      path:     parsed.pathname + parsed.search,
      method:   'POST',
      headers:  { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(body) },
    };
    const req = https.request(options, (res) => { res.resume(); res.on('end', resolve); });
    req.on('error', reject);
    req.write(body);
    req.end();
  });
}
