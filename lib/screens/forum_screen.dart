import 'package:flutter/material.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});
  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_ForumCat> _cats = [
    _ForumCat('Tendencias', '🔥', Color(0xFFFF5722), 142),
    _ForumCat('Estilo Personal', '✨', Color(0xFFE8537A), 89),
    _ForumCat('Sostenibilidad', '♻️', Color(0xFF4CAF50), 56),
    _ForumCat('Compras', '🛍️', Color(0xFF9C27B0), 203),
    _ForumCat('DIY & Custom', '🎨', Color(0xFFFF9800), 34),
    _ForumCat('Ayuda', '💬', Color(0xFF00BCD4), 178),
  ];

  final List<_Thread> _threads = [
    _Thread(title: '¿Cómo combinar colores tierra esta temporada?', cat: 'Estilo Personal',
        catColor: Color(0xFFE8537A), author: 'sofia.styles', replies: 48, views: 1230,
        time: '2h', pinned: true, tags: ['Colores', 'Otoño']),
    _Thread(title: 'Los tonos pastel ya son TENDENCIA — mi guía completa 🌸', cat: 'Tendencias',
        catColor: Color(0xFFFF5722), author: 'marta.fashion', replies: 112, views: 4560,
        time: '5h', pinned: false, tags: ['Pastel', 'Primavera']),
    _Thread(title: 'Haul Zara marzo — lo que vale y lo que no 🛍️', cat: 'Compras',
        catColor: Color(0xFF9C27B0), author: 'lucia.vintage', replies: 67, views: 2890,
        time: '1d', pinned: false, tags: ['Zara', 'Haul']),
    _Thread(title: 'Thrift shopping en Madrid: mis spots favoritos ♻️', cat: 'Sostenibilidad',
        catColor: Color(0xFF4CAF50), author: 'andrea.glam', replies: 29, views: 980,
        time: '1d', pinned: false, tags: ['Thrift', 'Madrid']),
    _Thread(title: 'Tutorial: personaliza tus vaqueros con bordados 🎨', cat: 'DIY & Custom',
        catColor: Color(0xFFFF9800), author: 'carmen.b', replies: 21, views: 760,
        time: '2d', pinned: false, tags: ['DIY', 'Tutorial']),
  ];

  @override
  void initState() { super.initState(); _tabController = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Foros'),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () => _showSearch(context)),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFE8537A),
          unselectedLabelColor: const Color(0xFF9E9E9E),
          indicatorColor: const Color(0xFFE8537A),
          indicatorWeight: 2,
          tabs: const [Tab(text: 'Categorías'), Tab(text: 'Popular')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Categories
          ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: _cats.length,
            itemBuilder: (_, i) => _CatCard(cat: _cats[i],
                onTap: () => _openCat(context, _cats[i])),
          ),
          // Threads
          ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: _threads.length,
            itemBuilder: (_, i) => _ThreadCard(thread: _threads[i],
                onTap: () => _openThread(context, _threads[i])),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _newThread(context),
        backgroundColor: const Color(0xFFE8537A),
        icon: const Icon(Icons.edit_outlined, color: Colors.white),
        label: const Text('Nuevo hilo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _openCat(BuildContext context, _ForumCat cat) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _CatScreen(cat: cat, threads: _threads)));
  }

  void _openThread(BuildContext context, _Thread thread) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _ThreadScreen(thread: thread)));
  }

  void _showSearch(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Buscar en foros'),
        content: const TextField(autofocus: true,
            decoration: InputDecoration(hintText: 'Buscar hilos, temas...', prefixIcon: Icon(Icons.search))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Buscar')),
        ],
      ),
    );
  }

  void _newThread(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _NewThreadSheet(cats: _cats),
    );
  }
}

// ─── Models ─────────────────────────────────────────────────────────────────
class _ForumCat {
  final String name, icon;
  final Color color;
  final int threads;
  const _ForumCat(this.name, this.icon, this.color, this.threads);
}

class _Thread {
  final String title, cat, author, time;
  final Color catColor;
  final int replies, views;
  final bool pinned;
  final List<String> tags;
  const _Thread({required this.title, required this.cat, required this.catColor,
      required this.author, required this.replies, required this.views,
      required this.time, required this.pinned, required this.tags});
}

// ─── Category Card ────────────────────────────────────────────────────────────
class _CatCard extends StatelessWidget {
  final _ForumCat cat;
  final VoidCallback onTap;
  const _CatCard({required this.cat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Container(width: 50, height: 50,
              decoration: BoxDecoration(color: cat.color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(cat.icon, style: const TextStyle(fontSize: 24)))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2D2D2D))),
            const SizedBox(height: 2),
            Text('${cat.threads} hilos activos', style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
          ])),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF9E9E9E)),
        ]),
      ),
    );
  }
}

// ─── Thread Card ─────────────────────────────────────────────────────────────
class _ThreadCard extends StatelessWidget {
  final _Thread thread;
  final VoidCallback onTap;
  const _ThreadCard({required this.thread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: thread.pinned ? Border.all(color: const Color(0xFFE8537A).withOpacity(0.3), width: 1.5) : null,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: thread.catColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(thread.cat, style: TextStyle(fontSize: 10, color: thread.catColor, fontWeight: FontWeight.w600))),
            if (thread.pinned) ...[
              const SizedBox(width: 6),
              const Icon(Icons.push_pin_rounded, size: 12, color: Color(0xFFE8537A)),
              const Text(' Destacado', style: TextStyle(fontSize: 10, color: Color(0xFFE8537A), fontWeight: FontWeight.w600)),
            ],
            const Spacer(),
            Text(thread.time, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
          ]),
          const SizedBox(height: 8),
          Text(thread.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14,
              color: Color(0xFF2D2D2D), height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 7),
          Wrap(spacing: 5, children: thread.tags.map((t) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(color: const Color(0xFFFCE4EC), borderRadius: BorderRadius.circular(6)),
            child: Text('#$t', style: const TextStyle(fontSize: 10, color: Color(0xFFE8537A))),
          )).toList()),
          const SizedBox(height: 8),
          Row(children: [
            CircleAvatar(radius: 10, backgroundColor: const Color(0xFFE8537A).withOpacity(0.12),
                child: Text(thread.author[0].toUpperCase(),
                    style: const TextStyle(fontSize: 9, color: Color(0xFFE8537A), fontWeight: FontWeight.bold))),
            const SizedBox(width: 5),
            Text(thread.author, style: const TextStyle(fontSize: 11, color: Color(0xFF666666))),
            const Spacer(),
            const Icon(Icons.mode_comment_outlined, size: 13, color: Color(0xFF9E9E9E)),
            const SizedBox(width: 3),
            Text('${thread.replies}', style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
            const SizedBox(width: 10),
            const Icon(Icons.visibility_outlined, size: 13, color: Color(0xFF9E9E9E)),
            const SizedBox(width: 3),
            Text('${thread.views}', style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
          ]),
        ]),
      ),
    );
  }
}

// ─── Category Screen ──────────────────────────────────────────────────────────
class _CatScreen extends StatelessWidget {
  final _ForumCat cat;
  final List<_Thread> threads;
  const _CatScreen({required this.cat, required this.threads});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(title: Text('${cat.icon} ${cat.name}')),
      body: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: threads.length,
        itemBuilder: (_, i) => _ThreadCard(thread: threads[i],
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => _ThreadScreen(thread: threads[i])))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFE8537A),
        child: const Icon(Icons.edit_outlined, color: Colors.white),
      ),
    );
  }
}

// ─── Thread Screen ────────────────────────────────────────────────────────────
class _ThreadScreen extends StatefulWidget {
  final _Thread thread;
  const _ThreadScreen({required this.thread});
  @override
  State<_ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<_ThreadScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  final List<Map<String, dynamic>> _msgs = [
    {'user': 'sofia.styles', 'text': '¡Hola a todos! He estado probando paletas tierra y os traigo mis conclusiones 🍂', 'time': '10:00', 'mine': false, 'likes': 12},
    {'user': 'marta.fashion', 'text': 'Yo siempre combino camel con blanco roto y queda increíble', 'time': '10:05', 'mine': false, 'likes': 8},
    {'user': 'lucia.v', 'text': 'El terracota con mostaza es mi combinación favorita del otoño', 'time': '10:12', 'mine': false, 'likes': 15},
  ];

  @override
  void dispose() { _ctrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  void _send() {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() {
      _msgs.add({'user': 'Tú', 'text': _ctrl.text.trim(), 'time': 'Ahora', 'mine': true, 'likes': 0});
      _ctrl.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.thread.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis),
          Text('${widget.thread.replies} respuestas',
              style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
        ]),
      ),
      body: Column(children: [
        // Banner
        Container(color: widget.thread.catColor.withOpacity(0.08),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: widget.thread.catColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(widget.thread.cat, style: TextStyle(fontSize: 11,
                      color: widget.thread.catColor, fontWeight: FontWeight.w600))),
              const SizedBox(width: 10),
              const Icon(Icons.visibility_outlined, size: 13, color: Color(0xFF9E9E9E)),
              const SizedBox(width: 3),
              Text('${widget.thread.views} vistas',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
            ])),
        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(14),
            itemCount: _msgs.length,
            itemBuilder: (_, i) => _MsgBubble(msg: _msgs[i],
                onLike: () => setState(() => _msgs[i]['likes']++)),
          ),
        ),
        // Input
        Container(
          padding: EdgeInsets.only(left: 12, right: 12, top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 10),
          decoration: BoxDecoration(color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!))),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'Escribe tu respuesta...',
                  hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                  filled: true, fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _send,
              child: Container(width: 40, height: 40,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFE8537A), Color(0xFFFF8FAB)]),
                    shape: BoxShape.circle),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 19)),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _MsgBubble extends StatelessWidget {
  final Map<String, dynamic> msg;
  final VoidCallback onLike;
  const _MsgBubble({required this.msg, required this.onLike});

  @override
  Widget build(BuildContext context) {
    final mine = msg['mine'] as bool;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!mine) ...[
            CircleAvatar(radius: 16, backgroundColor: const Color(0xFFE8537A).withOpacity(0.12),
                child: Text((msg['user'] as String)[0].toUpperCase(),
                    style: const TextStyle(color: Color(0xFFE8537A), fontWeight: FontWeight.bold, fontSize: 12))),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
              if (!mine) Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(msg['user'] as String,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF666666)))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                decoration: BoxDecoration(
                  color: mine ? const Color(0xFFE8537A) : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                    bottomLeft: mine ? const Radius.circular(16) : const Radius.circular(4),
                    bottomRight: mine ? const Radius.circular(4) : const Radius.circular(16),
                  ),
                ),
                child: Text(msg['text'] as String,
                    style: TextStyle(fontSize: 13, color: mine ? Colors.white : const Color(0xFF2D2D2D), height: 1.4)),
              ),
              const SizedBox(height: 3),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text(msg['time'] as String, style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
                if (!mine) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onLike,
                    child: Row(children: [
                      const Icon(Icons.favorite_border_rounded, size: 12, color: Color(0xFF9E9E9E)),
                      const SizedBox(width: 2),
                      Text('${msg['likes']}', style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
                    ]),
                  ),
                ],
              ]),
            ]),
          ),
        ],
      ),
    );
  }
}

// ─── New Thread Sheet ─────────────────────────────────────────────────────────
class _NewThreadSheet extends StatefulWidget {
  final List<_ForumCat> cats;
  const _NewThreadSheet({required this.cats});
  @override
  State<_NewThreadSheet> createState() => _NewThreadSheetState();
}

class _NewThreadSheetState extends State<_NewThreadSheet> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String? _selectedCat;

  @override
  void dispose() { _titleCtrl.dispose(); _bodyCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 36, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Nuevo hilo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          const Text('Categoría', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.cats.length,
              itemBuilder: (_, i) {
                final c = widget.cats[i];
                final sel = _selectedCat == c.name;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCat = c.name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: sel ? c.color : c.color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('${c.icon} ${c.name}', style: TextStyle(fontSize: 12,
                        color: sel ? Colors.white : c.color, fontWeight: FontWeight.w600)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          TextField(controller: _titleCtrl,
              decoration: const InputDecoration(hintText: 'Título del hilo', labelText: 'Título')),
          const SizedBox(height: 12),
          TextField(controller: _bodyCtrl, maxLines: 4,
              decoration: const InputDecoration(hintText: 'Escribe tu mensaje...', labelText: 'Mensaje', alignLabelWithHint: true)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_titleCtrl.text.isNotEmpty && _selectedCat != null) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('✅ Hilo publicado correctamente'),
                      backgroundColor: Color(0xFFE8537A), behavior: SnackBarBehavior.floating));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Completa el título y selecciona una categoría')));
                }
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 13),
                  backgroundColor: const Color(0xFFE8537A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Publicar hilo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}
