import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/novel.dart';
import '../../models/chapter.dart';
import '../auth/login_screen.dart';
import '../../../bloc/session_cubit.dart';
import 'widgets/novel_search_bar.dart';
import 'widgets/recommended_novels.dart';
import 'widgets/recent_novels.dart';
import 'widgets/marquee_text.dart';
import '../../services/reading_history_service.dart';
import '../admin/upload_novel_screen.dart';
import '../follows/followed_novels_screen.dart';
import '../../models/reading_history.dart';
import '../novel_detail/novel_detail_screen.dart';
import '../admin/manage_categories_screen.dart';
import '../admin/manage_novels_screen.dart';
import '../details/chapter_detail_screen.dart';
import '../../models/category.dart';

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
  List<NovelCategory> allCategories = [];
  List<NovelCategory> selectedCategories = [];
  Map<String, int> chapterCounts = {};
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    loadNovels();
    loadHistory();
    loadCategories();
  }

  Future<void> loadChapters() async {
    try {
      final chaptersResponse = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/chapters'),
      );

      if (chaptersResponse.statusCode == 200) {
        final List<dynamic> chaptersData = json.decode(chaptersResponse.body);

        // Đếm số chương cho mỗi novel trong history
        for (var item in history) {
          final count = chaptersData
              .where((chapter) =>
                  chapter['novelId'].toString() == item.novel.id.toString())
              .length;
          chapterCounts[item.novel.id.toString()] = count;
        }
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      print('Error loading chapters: $e');
    }
  }

  Future<void> loadCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/categories'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          allCategories =
              data.map((json) => NovelCategory.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> loadHistory() async {
    try {
      final history = await ReadingHistoryService.getHistory();
      setState(() {
        this.history = history;
      });
      loadChapters(); // Load số chương sau khi có history
    } catch (e) {
      print('Error loading history: $e');
    }
  }

  Future<void> loadNovels() async {
    setState(() {
      isLoading = true;
    });
    try {
      final baseUrl = dotenv.get('API_URL');
      print('Base URL: $baseUrl'); // Log để kiểm tra URL cơ sở

      final response = await http.get(Uri.parse('$baseUrl/novels'));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          novels = data.map((json) => Novel.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load novels: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading novels: $e');
      setState(() {
        isLoading = false;
      });
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

  void _filterNovels(String query) {
    setState(() {
      _isSearching = query.isNotEmpty || _selectedCategory != null;
      if (_isSearching) {
        filteredNovels = novels.where((novel) {
          bool matchesQuery = query.isEmpty ||
              novel.name.toLowerCase().contains(query.toLowerCase()) ||
              novel.author.toLowerCase().contains(query.toLowerCase());

          bool matchesCategories = _selectedCategory == null ||
              novel.categories
                  .any((novelCat) => _selectedCategory!.id == novelCat.id);

          return matchesQuery && matchesCategories;
        }).toList();
      } else {
        filteredNovels = [];
      }
    });
  }

  void _onCategorySelected(Category? category) {
    setState(() {
      _selectedCategory = category;
      _filterNovels(_searchController.text);
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
                          onSearch: _filterNovels,
                          onCategorySelected: _onCategorySelected,
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
                        Padding(
                          padding: const EdgeInsets.only(bottom: 80),
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.39,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: history.length,
                            itemBuilder: (context, index) {
                              final item = history[index];
                              return Card(
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => NovelDetailScreen(
                                            novel: item.novel),
                                      ),
                                    ).then((_) => loadHistory());
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 0.7,
                                        child: Image.network(
                                          item.novel.cover,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.novel.name,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Tác giả: ${item.novel.author}',
                                                style: const TextStyle(
                                                    fontSize: 12),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              if (item.lastChapter != null) ...[
                                                Text(
                                                  'Đang đọc: ${item.lastChapter!.name}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                              const Spacer(),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  if (item.lastChapter != null)
                                                    TextButton.icon(
                                                      icon: const Icon(
                                                        Icons.play_arrow,
                                                        size: 18,
                                                        color: Colors.blue,
                                                      ),
                                                      label: const Text(
                                                        'Đọc tiếp',
                                                        style: TextStyle(
                                                          color: Colors.blue,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      style:
                                                          TextButton.styleFrom(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 4),
                                                      ),
                                                      onPressed: () async {
                                                        try {
                                                          final response =
                                                              await http.get(
                                                            Uri.parse(
                                                                '${dotenv.get('API_URL')}/chapters'),
                                                            headers: {
                                                              'Accept':
                                                                  'application/json',
                                                              'Content-Type':
                                                                  'application/json',
                                                            },
                                                          );

                                                          if (!mounted) return;

                                                          if (response
                                                                  .statusCode ==
                                                              200) {
                                                            print(
                                                                'Response body: ${response.body}');
                                                            final List<dynamic>
                                                                chaptersData =
                                                                json.decode(
                                                                    response
                                                                        .body);

                                                            // Lọc chapters của novel hiện tại
                                                            final novelChapters = chaptersData
                                                                .where((chapter) =>
                                                                    chapter['novelId']
                                                                        .toString() ==
                                                                    item.novel
                                                                        .id)
                                                                .map((json) =>
                                                                    Chapter
                                                                        .fromJson(
                                                                            json))
                                                                .toList();

                                                            if (novelChapters
                                                                .isEmpty) {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                const SnackBar(
                                                                  content: Text(
                                                                      'Không có chương nào'),
                                                                  duration:
                                                                      Duration(
                                                                          seconds:
                                                                              2),
                                                                ),
                                                              );
                                                              return;
                                                            }

                                                            // Sắp xếp chapters
                                                            novelChapters
                                                                .sort((a, b) {
                                                              try {
                                                                final aNum = int.parse(a
                                                                    .name
                                                                    .replaceAll(
                                                                        RegExp(
                                                                            r'[^0-9]'),
                                                                        ''));
                                                                final bNum = int.parse(b
                                                                    .name
                                                                    .replaceAll(
                                                                        RegExp(
                                                                            r'[^0-9]'),
                                                                        ''));
                                                                return aNum
                                                                    .compareTo(
                                                                        bNum);
                                                              } catch (e) {
                                                                return a.name
                                                                    .compareTo(
                                                                        b.name);
                                                              }
                                                            });

                                                            final currentIndex =
                                                                novelChapters
                                                                    .indexWhere((ch) =>
                                                                        ch.id ==
                                                                        item.lastChapter!
                                                                            .id);

                                                            if (currentIndex !=
                                                                -1) {
                                                              if (!mounted)
                                                                return;
                                                              await Navigator
                                                                  .push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          ChapterDetailScreen(
                                                                    novel: item
                                                                        .novel,
                                                                    chapter:
                                                                        novelChapters[
                                                                            currentIndex],
                                                                    currentIndex:
                                                                        currentIndex,
                                                                    allChapters:
                                                                        novelChapters,
                                                                  ),
                                                                ),
                                                              );
                                                              if (mounted) {
                                                                loadHistory();
                                                              }
                                                            } else {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                const SnackBar(
                                                                  content: Text(
                                                                      'Không tìm thấy chương đang đọc'),
                                                                  duration:
                                                                      Duration(
                                                                          seconds:
                                                                              2),
                                                                ),
                                                              );
                                                            }
                                                          } else {
                                                            print(
                                                                'Error response: ${response.statusCode} - ${response.body}');
                                                            throw Exception(
                                                                'Không thể tải danh sách chương: ${response.statusCode}');
                                                          }
                                                        } catch (e) {
                                                          print(
                                                              'Error loading chapters: $e');
                                                          if (mounted) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                    'Có lỗi xảy ra khi tải chương'),
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            2),
                                                              ),
                                                            );
                                                          }
                                                        }
                                                      },
                                                    ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete_outline,
                                                      size: 20,
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(),
                                                    tooltip: 'Xóa khỏi lịch sử',
                                                    onPressed: () async {
                                                      final confirm =
                                                          await showDialog<
                                                              bool>(
                                                        context: context,
                                                        builder: (context) =>
                                                            AlertDialog(
                                                          title: const Text(
                                                              'Xác nhận xóa'),
                                                          content: Text(
                                                              'Xóa truyện "${item.novel.name}" khỏi lịch sử đọc?'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context,
                                                                      false),
                                                              child: const Text(
                                                                  'Hủy'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context,
                                                                      true),
                                                              child: const Text(
                                                                'Xóa',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );

                                                      if (confirm == true) {
                                                        await ReadingHistoryService
                                                            .removeFromHistory(
                                                                item.novel.id);
                                                        setState(() {});

                                                        if (!mounted) return;
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                                'Đã xóa "${item.novel.name}" khỏi lịch sử'),
                                                            duration:
                                                                const Duration(
                                                                    seconds: 2),
                                                            action:
                                                                SnackBarAction(
                                                              label: 'Hoàn tác',
                                                              onPressed:
                                                                  () async {
                                                                await ReadingHistoryService
                                                                    .addToHistory(
                                                                  item.novel,
                                                                  lastChapter: item
                                                                      .lastChapter,
                                                                );
                                                                setState(() {});
                                                              },
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                              Wrap(
                                                spacing: 8,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                          Icons.menu_book,
                                                          size: 14,
                                                          color: Colors.grey),
                                                      Text(
                                                        ' ${chapterCounts[item.novel.id.toString()] ?? 0} ch.',
                                                        style: const TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                          Icons.remove_red_eye,
                                                          size: 14,
                                                          color: Colors.grey),
                                                      Text(
                                                        ' ${item.novel.view}',
                                                        style: const TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Icon(Icons.favorite,
                                                          size: 14,
                                                          color: Colors.grey),
                                                      Text(
                                                        ' ${item.novel.followerCount}',
                                                        style: const TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
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
                      backgroundImage: state.session.user.avatar != null
                          ? NetworkImage(state.session.user.avatar!)
                          : null,
                      child: state.session.user.avatar == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.session.user.name,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 16),
                    if (state.session.user.isAdmin == true) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Đăng truyện mới'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const UploadNovelScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.category),
                            label: const Text('Quản lý thể loại'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ManageCategoriesScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.book),
                        label: const Text('Quản lý tất cả truyện'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider.value(
                                value: context.read<SessionCubit>(),
                                child: const ManageNovelsScreen(),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
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
