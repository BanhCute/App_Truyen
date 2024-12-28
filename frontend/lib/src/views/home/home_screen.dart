import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/novel.dart';
import '../auth/login_screen.dart';
import '../../../bloc/session_cubit.dart';
import 'widgets/novel_search_bar.dart';
import 'widgets/recommended_novels.dart';
import 'widgets/recent_novels.dart';
import 'widgets/marquee_text.dart';
import '../../services/reading_history_service.dart';
import '../admin/upload_novel_screen.dart';
import '../admin/select_novel_screen.dart';
import '../follows/followed_novels_screen.dart';
import '../../models/reading_history.dart';
import '../novel_detail/novel_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Novel> novels = [];
  List<Novel> filteredNovels = [];
  bool isLoading = false;
  int _selectedIndex = 0;
  List<ReadingHistory> history = [];

  @override
  void initState() {
    super.initState();
    loadNovels();
    loadHistory();
  }

  Future<void> loadNovels() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response =
          await http.get(Uri.parse('${dotenv.get('API_URL')}/novels'));
      final List data = json.decode(response.body);
      setState(() {
        novels = data.map((json) => Novel.fromJson(json)).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading novels: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadHistory() async {
    try {
      final history = await ReadingHistoryService.getHistory();
      setState(() {
        this.history = history;
      });
    } catch (e) {
      print('Error loading history: $e');
    }
  }

  List<Novel> get recommendedNovels {
    var sorted = List<Novel>.from(novels)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(4).toList();
  }

  List<Novel> get recentNovels {
    var sorted = List<Novel>.from(novels);
    sorted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted;
  }

  void filterNovels(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        filteredNovels = [];
      } else {
        filteredNovels = novels
            .where((novel) =>
                novel.name.toLowerCase().contains(query.toLowerCase()) ||
                novel.author.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B3A57),
        title: const Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  "TRUYỆN FULL",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
              child: MarqueeText(
                text:
                    'Đọc truyện tranh online, truyện tranh hay. Tổng hợp đầy đủ và cập nhật liên tục.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) => IconButton(
              icon: Icon(
                themeProvider.isDarkMode
                    ? Icons.lightbulb
                    : Icons.lightbulb_outline,
                color: themeProvider.isDarkMode ? Colors.yellow : Colors.white,
              ),
              onPressed: () {
                Provider.of<ThemeProvider>(context, listen: false)
                    .toggleTheme();
              },
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedIndex == 0
              ? RefreshIndicator(
                  onRefresh: () async {
                    await loadNovels();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        NovelSearchBar(
                          searchController: _searchController,
                          isSearching: _isSearching,
                          filteredNovels: filteredNovels,
                          onSearch: filterNovels,
                        ),
                        RecommendedNovels(novels: recommendedNovels),
                        RecentNovels(novels: recentNovels),
                      ],
                    ),
                  ),
                )
              : _buildPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1B3A57)
            : Colors.white,
        selectedItemColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : const Color(0xFF1B3A57),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Truyện tranh',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Theo dõi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Lịch sử',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 1:
        return BlocBuilder<SessionCubit, SessionState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return const FollowedNovelsScreen();
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border, size: 100),
                  const SizedBox(height: 16),
                  const Text('Vui lòng đăng nhập để xem truyện đang theo dõi'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(canPop: true),
                        ),
                      );
                    },
                    child: const Text('Đăng nhập'),
                  ),
                ],
              ),
            );
          },
        );
      case 2:
        return isLoading
            ? const Center(child: CircularProgressIndicator())
            : history.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Chưa có lịch sử đọc truyện',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await loadHistory();
                    },
                    child: Stack(
                      children: [
                        ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: history.length,
                          itemBuilder: (context, index) {
                            final item = history[index];
                            return Dismissible(
                              key: Key(item.novel.id),
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (direction) async {
                                return await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Xác nhận'),
                                    content: Text(
                                        'Xóa "${item.novel.name}" khỏi lịch sử?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Hủy'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text(
                                          'Xóa',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (direction) async {
                                await ReadingHistoryService.removeFromHistory(
                                    item.novel.id);
                                setState(() {});

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Đã xóa "${item.novel.name}" khỏi lịch sử'),
                                    duration: const Duration(seconds: 2),
                                    action: SnackBarAction(
                                      label: 'Hoàn tác',
                                      onPressed: () async {
                                        await ReadingHistoryService
                                            .addToHistory(
                                          item.novel,
                                          lastChapter: item.lastChapter,
                                        );
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    item.novel.cover,
                                    width: 50,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.error),
                                  ),
                                ),
                                title: Text(item.novel.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Tác giả: ${item.novel.author}'),
                                    if (item.lastChapter != null)
                                      Text(
                                        'Đọc gần nhất: ${item.lastChapter!.name}',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          NovelDetailScreen(novel: item.novel),
                                    ),
                                  ).then((_) => loadHistory());
                                },
                              ),
                            );
                          },
                        ),
                        if (history.isNotEmpty)
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: FloatingActionButton(
                              backgroundColor: Colors.red,
                              child: const Icon(Icons.delete_sweep),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Xóa lịch sử'),
                                    content: const Text(
                                        'Xóa toàn bộ lịch sử đọc truyện?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Hủy'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          final oldHistory =
                                              List<ReadingHistory>.from(
                                                  history);
                                          await ReadingHistoryService
                                              .clearHistory();
                                          Navigator.pop(context);
                                          setState(() {});

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                  'Đã xóa toàn bộ lịch sử'),
                                              duration:
                                                  const Duration(seconds: 2),
                                              action: SnackBarAction(
                                                label: 'Hoàn tác',
                                                onPressed: () async {
                                                  for (var item
                                                      in oldHistory.reversed) {
                                                    await ReadingHistoryService
                                                        .addToHistory(
                                                      item.novel,
                                                      lastChapter:
                                                          item.lastChapter,
                                                    );
                                                  }
                                                  setState(() {});
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'Xóa',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  );
      case 3:
        return BlocBuilder<SessionCubit, SessionState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: state.session.user?.avatar != null
                          ? NetworkImage(state.session.user!.avatar!)
                          : null,
                      child: state.session.user?.avatar == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.session.user?.name ?? 'Người dùng',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 16),
                    if (state.session.user?.isAdmin == true) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Đăng truyện mới'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider.value(
                                    value: context.read<SessionCubit>(),
                                    child: const UploadNovelScreen(),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add_circle),
                            label: const Text('Thêm chương'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider.value(
                                    value: context.read<SessionCubit>(),
                                    child: const SelectNovelScreen(),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Xác nhận'),
                            content:
                                const Text('Bạn có chắc chắn muốn đăng xuất?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  context.read<SessionCubit>().signOut();
                                },
                                child: const Text(
                                  'Đăng xuất',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('Đăng xuất'),
                    ),
                  ],
                ),
              );
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_outline, size: 100),
                  const SizedBox(height: 16),
                  const Text('Vui lòng đăng nhập để sử dụng các tính năng'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text('Đăng nhập'),
                  ),
                ],
              ),
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
