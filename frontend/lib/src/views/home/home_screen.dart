import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/novel.dart';
import '../../models/category.dart';
import 'widgets/marquee_text.dart';
import 'tabs/home_tab.dart';
import 'tabs/history_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/followed_tab.dart';
import '../auth/login_screen.dart';
import '../../../bloc/session_cubit.dart';

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
  List<NovelCategory> allCategories = [];
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    loadNovels();
    loadCategories();
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

  Future<void> loadNovels() async {
    setState(() {
      isLoading = true;
    });
    try {
      final baseUrl = dotenv.get('API_URL');
      final response = await http.get(Uri.parse('$baseUrl/novels'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            novels = data.map((json) => Novel.fromJson(json)).toList();
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load novels: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading novels: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> refreshData() async {
    await loadNovels();
    await loadCategories();
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
          : _buildCurrentTab(),
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
            label: 'Lịch sử đọc',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_selectedIndex) {
      case 0:
        return HomeTab(
          searchController: _searchController,
          isSearching: _isSearching,
          filteredNovels: filteredNovels,
          recommendedNovels: recommendedNovels,
          recentNovels: recentNovels,
          onSearch: _filterNovels,
          onCategorySelected: _onCategorySelected,
          onRefresh: refreshData,
        );
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
        return const HistoryTab();
      case 3:
        return const ProfileTab();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
