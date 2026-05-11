import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show AppColors;

const _currentUser = 'Tu';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _sort = 'Recientes';

  final List<_ForumCat> _cats = const [
    _ForumCat('Tendencias', Icons.trending_up_rounded, Color(0xFFD84315)),
    _ForumCat('Estilo personal', Icons.style_outlined, AppColors.primary),
    _ForumCat('Sostenibilidad', Icons.eco_outlined, Color(0xFF2E7D32)),
    _ForumCat('Compras', Icons.shopping_bag_outlined, Color(0xFF6A1B9A)),
    _ForumCat('DIY & Custom', Icons.palette_outlined, Color(0xFFE65100)),
    _ForumCat('Ayuda', Icons.help_outline_rounded, Color(0xFF00838F)),
  ];

  late final List<_Thread> _threads = [
    _Thread(
      id: 't1',
      title: 'Como combinar colores tierra esta temporada',
      body:
          'Estoy probando camel, terracota y oliva para looks de diario. Que prendas usais para que no se vea demasiado plano?',
      cat: _cats[1],
      author: 'sofia.styles',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      views: 1230,
      pinned: true,
      tags: ['Colores', 'Otono'],
      replies: [
        _Reply(
          id: 'r1',
          user: 'marta.fashion',
          text:
              'Camel con blanco roto y un cinturon marron oscuro siempre funciona.',
          createdAt: DateTime.now().subtract(
            const Duration(hours: 1, minutes: 45),
          ),
          likes: 8,
        ),
        _Reply(
          id: 'r2',
          user: 'lucia.v',
          text:
              'Terracota con mostaza queda muy bien si metes una base neutra.',
          createdAt: DateTime.now().subtract(
            const Duration(hours: 1, minutes: 30),
          ),
          likes: 15,
        ),
      ],
    ),
    _Thread(
      id: 't2',
      title: 'Los tonos pastel ya son tendencia: guia rapida',
      body:
          'He visto mucho azul bebe, verde menta y rosa empolvado. Dejo ideas para combinarlos sin caer en look infantil.',
      cat: _cats[0],
      author: 'marta.fashion',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      views: 4560,
      tags: ['Pastel', 'Primavera'],
      replies: [],
    ),
    _Thread(
      id: 't3',
      title: 'Haul Zara: lo que vale y lo que no',
      body:
          'Comparto prendas que he probado esta semana, con tallaje, tejido y alternativas mas sostenibles.',
      cat: _cats[3],
      author: 'lucia.vintage',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      views: 2890,
      tags: ['Zara', 'Haul'],
      replies: [],
    ),
    _Thread(
      id: 't4',
      title: 'Thrift shopping en Madrid: spots favoritos',
      body:
          'Listado de tiendas de segunda mano con buena seleccion de denim, abrigos y accesorios.',
      cat: _cats[2],
      author: 'andrea.glam',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      views: 980,
      tags: ['Thrift', 'Madrid'],
      replies: [],
    ),
    _Thread(
      id: 't5',
      title: 'Tutorial: personaliza tus vaqueros con bordados',
      body:
          'Ideas sencillas para dar una segunda vida a vaqueros basicos sin comprar materiales caros.',
      cat: _cats[4],
      author: 'carmen.b',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      views: 760,
      tags: ['DIY', 'Tutorial'],
      replies: [],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<_Thread> get _visibleThreads {
    final text = _query.trim().toLowerCase();
    final filtered = _threads.where((thread) {
      if (thread.deleted) return false;
      if (text.isEmpty) return true;
      return thread.title.toLowerCase().contains(text) ||
          thread.body.toLowerCase().contains(text) ||
          thread.cat.name.toLowerCase().contains(text) ||
          thread.tags.any((tag) => tag.toLowerCase().contains(text));
    }).toList();

    switch (_sort) {
      case 'Populares':
        filtered.sort((a, b) => b.score.compareTo(a.score));
        break;
      case 'Respondidos':
        filtered.sort((a, b) => b.replies.length.compareTo(a.replies.length));
        break;
      default:
        filtered.sort((a, b) {
          if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
          return b.createdAt.compareTo(a.createdAt);
        });
    }
    return filtered;
  }

  List<_Thread> _threadsForCat(_ForumCat cat) =>
      _visibleThreads.where((thread) => thread.cat.name == cat.name).toList();

  List<_Thread> get _myThreads =>
      _threads
          .where((thread) => !thread.deleted && thread.author == _currentUser)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  void _upsertThread(_Thread thread, {_Thread? editing}) {
    setState(() {
      if (editing == null) {
        _threads.insert(0, thread);
      } else {
        final index = _threads.indexWhere((item) => item.id == editing.id);
        if (index != -1) {
          editing
            ..title = thread.title
            ..body = thread.body
            ..cat = thread.cat
            ..tags = thread.tags
            ..editedAt = thread.editedAt;
        }
      }
    });
  }

  void _deleteThread(_Thread thread) {
    setState(() => thread.deleted = true);
    Navigator.maybePop(context);
    _toast('Hilo eliminado');
  }

  void _toggleSaved(_Thread thread) {
    setState(() => thread.saved = !thread.saved);
    _toast(thread.saved ? 'Hilo guardado' : 'Hilo quitado de guardados');
  }

  void _toggleLocked(_Thread thread) {
    setState(() => thread.locked = !thread.locked);
    _toast(thread.locked ? 'Hilo cerrado' : 'Hilo reabierto');
  }

  void _toggleSolved(_Thread thread) {
    setState(() => thread.solved = !thread.solved);
    _toast(thread.solved ? 'Marcado como resuelto' : 'Marcado como pendiente');
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openComposer({_ForumCat? cat, _Thread? editing}) async {
    final result = await showModalBottomSheet<_Thread>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ThreadComposer(cats: _cats, cat: cat, editing: editing),
    );
    if (result == null) return;
    _upsertThread(result, editing: editing);
    _toast(editing == null ? 'Hilo publicado' : 'Cambios guardados');
  }

  Future<void> _openThread(_Thread thread) async {
    setState(() => thread.views++);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ThreadScreen(
          thread: thread,
          onChanged: () => setState(() {}),
          onEdit: () => _openComposer(editing: thread),
          onDelete: () => _confirmDelete(thread),
          onSave: () => _toggleSaved(thread),
          onLock: () => _toggleLocked(thread),
          onSolve: () => _toggleSolved(thread),
        ),
      ),
    );
    setState(() {});
  }

  Future<void> _confirmDelete(_Thread thread) async {
    final confirmed = await _confirm(
      title: 'Eliminar hilo',
      body:
          'Se ocultara el hilo y sus respuestas de la comunidad. Esta accion no se puede deshacer en esta demo.',
      action: 'Eliminar',
    );
    if (confirmed) _deleteThread(thread);
  }

  Future<bool> _confirm({
    required String title,
    required String body,
    required String action,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(action),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Text(
          'Foro',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Categorias'),
            Tab(text: 'Hilos'),
            Tab(text: 'Mis hilos'),
          ],
        ),
      ),
      body: Column(
        children: [
          _ForumSearchBar(
            controller: _searchCtrl,
            sort: _sort,
            onSortChanged: (value) => setState(() => _sort = value),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _CategoriesTab(
                  cats: _cats,
                  countFor: (cat) => _threadsForCat(cat).length,
                  onTap: (cat) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _CategoryScreen(
                        cat: cat,
                        threads: _threadsForCat(cat),
                        onOpen: _openThread,
                        onNew: () => _openComposer(cat: cat),
                      ),
                    ),
                  ),
                ),
                _ThreadList(
                  threads: _visibleThreads,
                  emptyText: 'No hay hilos con esa busqueda',
                  onTap: _openThread,
                ),
                _ThreadList(
                  threads: _myThreads,
                  emptyText: 'Todavia no has publicado ningun hilo',
                  onTap: _openThread,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openComposer(),
        icon: const Icon(Icons.edit_outlined),
        label: Text(
          'Nuevo hilo',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _ForumCat {
  final String name;
  final IconData icon;
  final Color color;

  const _ForumCat(this.name, this.icon, this.color);
}

class _Thread {
  final String id;
  String title;
  String body;
  _ForumCat cat;
  final String author;
  final DateTime createdAt;
  DateTime? editedAt;
  List<String> tags;
  final List<_Reply> replies;
  int views;
  bool pinned;
  bool saved;
  bool solved;
  bool locked;
  bool deleted;
  int reports;

  _Thread({
    required this.id,
    required this.title,
    required this.body,
    required this.cat,
    required this.author,
    required this.createdAt,
    this.editedAt,
    required this.tags,
    required this.replies,
    this.views = 0,
    this.pinned = false,
    this.saved = false,
    this.solved = false,
    this.locked = false,
    this.deleted = false,
    this.reports = 0,
  });

  bool get isMine => author == _currentUser;
  int get score => views + (replies.length * 25) + (saved ? 80 : 0);

  _Thread copyWith({
    String? title,
    String? body,
    _ForumCat? cat,
    List<String>? tags,
    DateTime? editedAt,
  }) {
    return _Thread(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      cat: cat ?? this.cat,
      author: author,
      createdAt: createdAt,
      editedAt: editedAt ?? this.editedAt,
      tags: tags ?? this.tags,
      replies: replies,
      views: views,
      pinned: pinned,
      saved: saved,
      solved: solved,
      locked: locked,
      deleted: deleted,
      reports: reports,
    );
  }
}

class _Reply {
  final String id;
  final String user;
  String text;
  final DateTime createdAt;
  DateTime? editedAt;
  int likes;
  bool liked;
  bool deleted;
  int reports;

  _Reply({
    required this.id,
    required this.user,
    required this.text,
    required this.createdAt,
    this.editedAt,
    this.likes = 0,
    this.liked = false,
    this.deleted = false,
    this.reports = 0,
  });

  bool get isMine => user == _currentUser;
}

class _ForumSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String sort;
  final ValueChanged<String> onSortChanged;

  const _ForumSearchBar({
    required this.controller,
    required this.sort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgCard,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Buscar hilos, categorias o etiquetas',
                prefixIcon: Icon(Icons.search_rounded),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            initialValue: sort,
            tooltip: 'Ordenar',
            onSelected: onSortChanged,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Recientes', child: Text('Recientes')),
              PopupMenuItem(value: 'Populares', child: Text('Populares')),
              PopupMenuItem(value: 'Respondidos', child: Text('Respondidos')),
            ],
            child: Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: AppColors.bgPage,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.tune_rounded, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  final List<_ForumCat> cats;
  final int Function(_ForumCat cat) countFor;
  final ValueChanged<_ForumCat> onTap;

  const _CategoriesTab({
    required this.cats,
    required this.countFor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: cats.length,
      itemBuilder: (_, i) {
        final cat = cats[i];
        return _ForumPanel(
          onTap: () => onTap(cat),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cat.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(cat.icon, color: cat.color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.name,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${countFor(cat)} hilos activos',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textHint,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ThreadList extends StatelessWidget {
  final List<_Thread> threads;
  final String emptyText;
  final ValueChanged<_Thread> onTap;

  const _ThreadList({
    required this.threads,
    required this.emptyText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (threads.isEmpty) {
      return _EmptyForumState(text: emptyText);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: threads.length,
      itemBuilder: (_, i) => _ThreadCard(thread: threads[i], onTap: onTap),
    );
  }
}

class _ThreadCard extends StatelessWidget {
  final _Thread thread;
  final ValueChanged<_Thread> onTap;

  const _ThreadCard({required this.thread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _ForumPanel(
      onTap: () => onTap(thread),
      highlighted: thread.pinned,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CategoryPill(cat: thread.cat),
              if (thread.pinned) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.push_pin_rounded,
                  size: 13,
                  color: AppColors.primary,
                ),
              ],
              if (thread.solved) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: Color(0xFF2E7D32),
                ),
              ],
              const Spacer(),
              if (thread.saved)
                const Icon(
                  Icons.bookmark_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
              const SizedBox(width: 6),
              Text(
                _relativeTime(thread.createdAt),
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            thread.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            thread.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppColors.textSec,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: thread.tags.map((tag) => _TagPill(tag)).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Avatar(name: thread.author, radius: 10),
              const SizedBox(width: 6),
              Text(
                thread.author,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppColors.textSec,
                ),
              ),
              if (thread.isMine) ...[
                const SizedBox(width: 6),
                Text(
                  'Autor',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const Spacer(),
              _MiniStat(
                icon: Icons.mode_comment_outlined,
                value: thread.replies.length,
              ),
              const SizedBox(width: 10),
              _MiniStat(icon: Icons.visibility_outlined, value: thread.views),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryScreen extends StatelessWidget {
  final _ForumCat cat;
  final List<_Thread> threads;
  final ValueChanged<_Thread> onOpen;
  final VoidCallback onNew;

  const _CategoryScreen({
    required this.cat,
    required this.threads,
    required this.onOpen,
    required this.onNew,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(cat.icon, color: cat.color, size: 18),
            const SizedBox(width: 8),
            Text(cat.name),
          ],
        ),
      ),
      body: _ThreadList(
        threads: threads,
        emptyText: 'Aun no hay hilos en esta categoria',
        onTap: onOpen,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onNew,
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Publicar'),
      ),
    );
  }
}

class _ThreadScreen extends StatefulWidget {
  final _Thread thread;
  final VoidCallback onChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSave;
  final VoidCallback onLock;
  final VoidCallback onSolve;

  const _ThreadScreen({
    required this.thread,
    required this.onChanged,
    required this.onEdit,
    required this.onDelete,
    required this.onSave,
    required this.onLock,
    required this.onSolve,
  });

  @override
  State<_ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<_ThreadScreen> {
  final _replyCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _replyCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendReply() {
    final text = _replyCtrl.text.trim();
    final error = _validateBody(text);
    if (error != null) {
      _toast(error);
      return;
    }
    setState(() {
      widget.thread.replies.add(
        _Reply(
          id: 'r${DateTime.now().microsecondsSinceEpoch}',
          user: _currentUser,
          text: text,
          createdAt: DateTime.now(),
        ),
      );
      _replyCtrl.clear();
    });
    widget.onChanged();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleLike(_Reply reply) {
    setState(() {
      reply.liked = !reply.liked;
      reply.likes += reply.liked ? 1 : -1;
    });
    widget.onChanged();
  }

  Future<void> _editReply(_Reply reply) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _ReplyEditor(initialText: reply.text),
    );
    if (result == null) return;
    final error = _validateBody(result);
    if (error != null) {
      _toast(error);
      return;
    }
    setState(() {
      reply.text = result.trim();
      reply.editedAt = DateTime.now();
    });
    widget.onChanged();
    _toast('Respuesta editada');
  }

  Future<void> _deleteReply(_Reply reply) async {
    final confirmed = await _confirm(
      title: 'Eliminar respuesta',
      body: 'La respuesta dejara de verse en este hilo.',
      action: 'Eliminar',
    );
    if (!confirmed) return;
    setState(() => reply.deleted = true);
    widget.onChanged();
    _toast('Respuesta eliminada');
  }

  void _reportThread() {
    setState(() => widget.thread.reports++);
    widget.onChanged();
    _toast('Gracias. Revisaremos este hilo segun las normas de la comunidad.');
  }

  void _reportReply(_Reply reply) {
    setState(() => reply.reports++);
    widget.onChanged();
    _toast('Respuesta reportada para moderacion');
  }

  Future<void> _showThreadActions() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ForumActionSheet(
        title: 'Opciones del hilo',
        subtitle: widget.thread.isMine
            ? 'Gestiona tu publicacion'
            : 'Acciones disponibles',
        actions: [
          _ForumAction(
            value: 'save',
            icon: widget.thread.saved
                ? Icons.bookmark_remove_outlined
                : Icons.bookmark_add_outlined,
            title: widget.thread.saved ? 'Quitar de guardados' : 'Guardar hilo',
            color: AppColors.primary,
          ),
          if (widget.thread.isMine)
            _ForumAction(
              value: 'solve',
              icon: widget.thread.solved
                  ? Icons.radio_button_unchecked_rounded
                  : Icons.check_circle_outline_rounded,
              title: widget.thread.solved
                  ? 'Marcar como pendiente'
                  : 'Marcar como resuelto',
              color: const Color(0xFF2E7D32),
            ),
          if (widget.thread.isMine)
            _ForumAction(
              value: 'lock',
              icon: widget.thread.locked
                  ? Icons.lock_open_rounded
                  : Icons.lock_outline_rounded,
              title: widget.thread.locked
                  ? 'Reabrir respuestas'
                  : 'Cerrar respuestas',
              color: const Color(0xFF6A1B9A),
            ),
          if (widget.thread.isMine)
            const _ForumAction(
              value: 'edit',
              icon: Icons.edit_outlined,
              title: 'Editar hilo',
              color: AppColors.textSec,
            ),
          if (!widget.thread.isMine)
            const _ForumAction(
              value: 'report',
              icon: Icons.flag_outlined,
              title: 'Reportar',
              color: Color(0xFFD84315),
            ),
          if (widget.thread.isMine)
            const _ForumAction(
              value: 'delete',
              icon: Icons.delete_outline_rounded,
              title: 'Eliminar hilo',
              color: Color(0xFFC62828),
              destructive: true,
            ),
        ],
      ),
    );
    if (action == null) return;
    switch (action) {
      case 'save':
        widget.onSave();
        setState(() {});
        break;
      case 'solve':
        widget.onSolve();
        setState(() {});
        break;
      case 'lock':
        widget.onLock();
        setState(() {});
        break;
      case 'edit':
        widget.onEdit();
        break;
      case 'delete':
        widget.onDelete();
        break;
      case 'report':
        _reportThread();
        break;
    }
  }

  Future<void> _showReplyActions(_Reply reply) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ForumActionSheet(
        title: reply.isMine ? 'Opciones de respuesta' : 'Moderacion',
        subtitle: reply.isMine
            ? 'Puedes editar o retirar tu respuesta'
            : 'Ayuda a mantener el foro cuidado',
        actions: [
          if (reply.isMine)
            const _ForumAction(
              value: 'edit',
              icon: Icons.edit_outlined,
              title: 'Editar respuesta',
              color: AppColors.textSec,
            ),
          if (!reply.isMine)
            const _ForumAction(
              value: 'report',
              icon: Icons.flag_outlined,
              title: 'Reportar respuesta',
              color: Color(0xFFD84315),
            ),
          if (reply.isMine)
            const _ForumAction(
              value: 'delete',
              icon: Icons.delete_outline_rounded,
              title: 'Eliminar respuesta',
              color: Color(0xFFC62828),
              destructive: true,
            ),
        ],
      ),
    );
    if (action == 'edit') _editReply(reply);
    if (action == 'delete') _deleteReply(reply);
    if (action == 'report') _reportReply(reply);
  }

  Future<bool> _confirm({
    required String title,
    required String body,
    required String action,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(action),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final replies = widget.thread.replies
        .where((reply) => !reply.deleted)
        .toList();
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Text(
          widget.thread.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Opciones',
            onPressed: _showThreadActions,
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(14),
              children: [
                _ThreadHeader(thread: widget.thread),
                const SizedBox(height: 12),
                if (replies.isEmpty)
                  const _EmptyForumState(
                    text: 'Se la primera persona en responder',
                  )
                else
                  ...replies.map(
                    (reply) => _ReplyBubble(
                      reply: reply,
                      onLike: () => _toggleLike(reply),
                      onActions: () => _showReplyActions(reply),
                    ),
                  ),
              ],
            ),
          ),
          _ReplyInput(
            controller: _replyCtrl,
            locked: widget.thread.locked,
            onSend: _sendReply,
          ),
        ],
      ),
    );
  }
}

class _ThreadHeader extends StatelessWidget {
  final _Thread thread;

  const _ThreadHeader({required this.thread});

  @override
  Widget build(BuildContext context) {
    return _ForumPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CategoryPill(cat: thread.cat),
              if (thread.solved) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.check_circle_rounded,
                  size: 15,
                  color: Color(0xFF2E7D32),
                ),
                const SizedBox(width: 3),
                Text(
                  'Resuelto',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: const Color(0xFF2E7D32),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const Spacer(),
              Text(
                _relativeTime(thread.createdAt),
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            thread.title,
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: AppColors.textPrimary,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            thread.body,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.45,
            ),
          ),
          if (thread.editedAt != null) ...[
            const SizedBox(height: 6),
            Text(
              'Editado ${_relativeTime(thread.editedAt!)}',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: AppColors.textHint,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: thread.tags.map((tag) => _TagPill(tag)).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Avatar(name: thread.author, radius: 13),
              const SizedBox(width: 8),
              Text(
                thread.author,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppColors.textSec,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _MiniStat(
                icon: Icons.mode_comment_outlined,
                value: thread.replies.where((r) => !r.deleted).length,
              ),
              const SizedBox(width: 12),
              _MiniStat(icon: Icons.visibility_outlined, value: thread.views),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReplyBubble extends StatelessWidget {
  final _Reply reply;
  final VoidCallback onLike;
  final VoidCallback onActions;

  const _ReplyBubble({
    required this.reply,
    required this.onLike,
    required this.onActions,
  });

  @override
  Widget build(BuildContext context) {
    return _ForumPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(name: reply.user, radius: 13),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  reply.user,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.textSec,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                _relativeTime(reply.createdAt),
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: AppColors.textHint,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Opciones',
                onPressed: onActions,
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  size: 20,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reply.text,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: onLike,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        reply.liked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 16,
                        color: reply.liked
                            ? AppColors.primary
                            : AppColors.textHint,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${reply.likes}',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: AppColors.textHint,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (reply.editedAt != null) ...[
                const SizedBox(width: 8),
                Text(
                  'Editado',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ReplyInput extends StatelessWidget {
  final TextEditingController controller;
  final bool locked;
  final VoidCallback onSend;

  const _ReplyInput({
    required this.controller,
    required this.locked,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !locked,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: locked
                      ? 'Este hilo esta cerrado'
                      : 'Escribe una respuesta respetuosa',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: locked ? null : onSend,
              icon: const Icon(Icons.send_rounded),
              tooltip: 'Enviar respuesta',
            ),
          ],
        ),
      ),
    );
  }
}

class _ThreadComposer extends StatefulWidget {
  final List<_ForumCat> cats;
  final _ForumCat? cat;
  final _Thread? editing;

  const _ThreadComposer({required this.cats, this.cat, this.editing});

  @override
  State<_ThreadComposer> createState() => _ThreadComposerState();
}

class _ThreadComposerState extends State<_ThreadComposer> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;
  late final TextEditingController _tagsCtrl;
  late _ForumCat _selectedCat;

  @override
  void initState() {
    super.initState();
    final editing = widget.editing;
    _selectedCat = widget.cat ?? editing?.cat ?? widget.cats.first;
    _titleCtrl = TextEditingController(text: editing?.title ?? '');
    _bodyCtrl = TextEditingController(text: editing?.body ?? '');
    _tagsCtrl = TextEditingController(text: editing?.tags.join(', ') ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    final titleError = _validateTitle(title);
    final bodyError = _validateBody(body);
    if (titleError != null || bodyError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(titleError ?? bodyError!)));
      return;
    }

    final tags = _tagsCtrl.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .take(5)
        .toList();

    final editing = widget.editing;
    final thread = editing == null
        ? _Thread(
            id: 't${DateTime.now().microsecondsSinceEpoch}',
            title: title,
            body: body,
            cat: _selectedCat,
            author: _currentUser,
            createdAt: DateTime.now(),
            tags: tags.isEmpty ? [_selectedCat.name] : tags,
            replies: [],
          )
        : editing.copyWith(
            title: title,
            body: body,
            cat: _selectedCat,
            tags: tags.isEmpty ? [_selectedCat.name] : tags,
            editedAt: DateTime.now(),
          );
    Navigator.pop(context, thread);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.editing == null ? 'Nuevo hilo' : 'Editar hilo',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Categoria',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSec,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.cats.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final cat = widget.cats[i];
                      final selected = cat.name == _selectedCat.name;
                      return ChoiceChip(
                        selected: selected,
                        avatar: Icon(
                          cat.icon,
                          size: 15,
                          color: selected ? Colors.white : cat.color,
                        ),
                        label: Text(cat.name),
                        onSelected: (_) => setState(() => _selectedCat = cat),
                        selectedColor: cat.color,
                        labelStyle: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : cat.color,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _titleCtrl,
                  maxLength: 90,
                  decoration: const InputDecoration(
                    labelText: 'Titulo',
                    hintText: 'Resume la conversacion en una frase',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bodyCtrl,
                  minLines: 5,
                  maxLines: 8,
                  maxLength: 800,
                  decoration: const InputDecoration(
                    labelText: 'Mensaje',
                    hintText: 'Explica el contexto, pregunta o idea de moda',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _tagsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Etiquetas',
                    hintText: 'Capsula, denim, Madrid',
                    prefixIcon: Icon(Icons.tag_rounded),
                  ),
                ),
                const SizedBox(height: 10),
                _GuidelinesBox(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check_rounded),
                    label: Text(
                      widget.editing == null
                          ? 'Publicar hilo'
                          : 'Guardar cambios',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReplyEditor extends StatefulWidget {
  final String initialText;

  const _ReplyEditor({required this.initialText});

  @override
  State<_ReplyEditor> createState() => _ReplyEditorState();
}

class _ReplyEditorState extends State<_ReplyEditor> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar respuesta'),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        minLines: 3,
        maxLines: 6,
        decoration: const InputDecoration(alignLabelWithHint: true),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _ctrl.text),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class _ForumAction {
  final String value;
  final IconData icon;
  final String title;
  final Color color;
  final bool destructive;

  const _ForumAction({
    required this.value,
    required this.icon,
    required this.title,
    required this.color,
    this.destructive = false,
  });
}

class _ForumActionSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<_ForumAction> actions;

  const _ForumActionSheet({
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.82;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.textHint,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: actions
                      .map((action) => _ForumActionTile(action: action))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSec,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForumActionTile extends StatelessWidget {
  final _ForumAction action;

  const _ForumActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final bgColor = action.destructive
        ? action.color.withValues(alpha: 0.08)
        : action.color.withValues(alpha: 0.1);
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.pop(context, action.value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: action.destructive
                ? const Color(0xFFFFF6F6)
                : AppColors.bgPage,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: action.destructive
                  ? action.color.withValues(alpha: 0.18)
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(action.icon, color: action.color, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  action.title,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: action.destructive
                        ? action.color
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: action.destructive
                    ? action.color.withValues(alpha: 0.7)
                    : AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuidelinesBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accentBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Publica contenido propio, evita datos personales y manten un tono respetuoso. Puedes editar o borrar lo que publiques.',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppColors.textSec,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForumPanel extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool highlighted;

  const _ForumPanel({
    required this.child,
    this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlighted
              ? AppColors.primary.withOpacity(0.35)
              : AppColors.border,
          width: highlighted ? 1.4 : 1,
        ),
      ),
      child: child,
    );
    if (onTap == null) return panel;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: panel,
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final _ForumCat cat;

  const _CategoryPill({required this.cat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cat.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        cat.name,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          color: cat.color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String tag;

  const _TagPill(this.tag);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accentBg,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        '#$tag',
        style: GoogleFonts.dmSans(
          fontSize: 10,
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final double radius;

  const _Avatar({required this.name, required this.radius});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.accentBg,
      child: Text(
        name.isEmpty ? '?' : name[0].toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: radius - 2,
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final int value;

  const _MiniStat({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textHint),
        const SizedBox(width: 3),
        Text(
          '$value',
          style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textHint),
        ),
      ],
    );
  }
}

class _EmptyForumState extends StatelessWidget {
  final String text;

  const _EmptyForumState({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.forum_outlined,
              size: 34,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textSec,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String? _validateTitle(String value) {
  final text = value.trim();
  if (text.length < 8) return 'El titulo necesita al menos 8 caracteres';
  if (text.length > 90) return 'El titulo es demasiado largo';
  return null;
}

String? _validateBody(String value) {
  final text = value.trim();
  if (text.length < 3) return 'Escribe un poco mas antes de publicar';
  if (text.length > 800) return 'El mensaje supera los 800 caracteres';
  final blocked = ['telefono', 'direccion exacta', 'password', 'contrasena'];
  if (blocked.any((word) => text.toLowerCase().contains(word))) {
    return 'Evita compartir datos personales o sensibles';
  }
  return null;
}

String _relativeTime(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'Ahora';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min';
  if (diff.inHours < 24) return '${diff.inHours} h';
  if (diff.inDays < 7) return '${diff.inDays} d';
  return '${date.day}/${date.month}/${date.year}';
}
