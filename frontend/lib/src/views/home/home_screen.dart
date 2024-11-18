import 'package:flutter/material.dart';
import '../../models/truyen.dart';
import '../../widgets/truyen_card.dart';
import '../auth/login_screen.dart';
import '../admin/user_management_screen.dart';
import '../admin/story_management_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import 'package:card_swiper/card_swiper.dart';
import '../hot_stories/hot_stories_screen.dart';
import '../search/advanced_search_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Truyen> truyenHot = const [
    Truyen(
        title: "Doraemon",
        imageUrl:
            "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiUBftbgOZfAhnKmdPGAnmMlUAFZpvzBE0yQQ5L-XnOV_vcVVVRbPFG4b6o5UZYMg4Qe0HQQqesqP6cU91xnbgzQbqrlqdr6qbwPdPuXsKAw-Mucxp3N8xJZu3Rq_53HxRKHbMn4mF2kOlzZkc-IAdWBizIrEsPI4eR54twId_PGkBaIq-Tlxz5IR9K/s1536/DORAEMON%20Vol.2%20-%20FUJIKO%20F%20FUJIO_Page_01_Image_0001.jpg",
        isHot: true,
        chapter: 15,
        updatedAt: "1 Phút Trước"),
    Truyen(
        title: "Hunter X Hunter",
        imageUrl:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRSVFQx-jWl8oHOluT8-PXxCL_BzmDedSsa6JPfzBwFGiK8zJCF&s",
        isHot: true,
        chapter: 167,
        updatedAt: "2 Phút Trước"),
    Truyen(
        title: "Cậu Út Nhà Công Tước Là Sát Thủ Hồi Quy",
        imageUrl:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQMxILuwJIS96JtWH9A9G-oaKy3qgs0GndHo8hv1CyfKyPlgjnk",
        isHot: true,
        chapter: 256,
        updatedAt: "5 Phút Trước"),
  ];

  final String selectedValue = 'Xám nhạt';

  // Thêm list đề xuất
  final List<Map<String, String>> deXuatItems = [
    {
      'image':
          "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiUBftbgOZfAhnKmdPGAnmMlUAFZpvzBE0yQQ5L-XnOV_vcVVVRbPFG4b6o5UZYMg4Qe0HQQqesqP6cU91xnbgzQbqrlqdr6qbwPdPuXsKAw-Mucxp3N8xJZu3Rq_53HxRKHbMn4mF2kOlzZkc-IAdWBizIrEsPI4eR54twId_PGkBaIq-Tlxz5IR9K/s1536/DORAEMON%20Vol.2%20-%20FUJIKO%20F%20FUJIO_Page_01_Image_0001.jpg",
      'title': 'Truyện Nhiều Người Đọc'
    },
    {
      'image':
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQMxILuwJIS96JtWH9A9G-oaKy3qgs0GndHo8hv1CyfKyPlgjnk",
      'title': 'Truyện Hot Tháng'
    },
    {
      'image':
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRSVFQx-jWl8oHOluT8-PXxCL_BzmDedSsa6JPfzBwFGiK8zJCF&s",
      'title': 'Truyện Mới Cập Nhật'
    },
    {
      'image':
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSflnlwf839LTInQGfR3LOohUjWGA-F-c36fqPMDNyX7HfeLC74",
      'title': 'Truyện Đề Cử'
    },
  ];

  // Thêm biến để lưu thể loại đã chọn
  String selectedGenre = 'Tất cả'; // Giá trị mặc định

  // Danh sách thể loại
  final List<String> genres = [
    'Tất cả',
    'Tiên Hiệp',
    'Kiếm Hiệp',
    'Ngôn Tình',
    'Đam Mỹ',
    'Trinh Thám',
    // Thêm các thể loại khác
  ];

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).currentUser;

    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: buildAppBar(),
      endDrawer: buildEndDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Thanh tìm kiếm
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1B3A57),
                borderRadius: BorderRadius.circular(4),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  suffixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1B3A57),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (value) {
                  // Xử lý tìm kiếm
                },
              ),
            ),

            // Thay thế phần thể loại cũ bằng Tìm Kiếm Nâng Cao
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdvancedSearchScreen(),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.filter_list, color: Colors.lightBlue),
                    const SizedBox(width: 8),
                    Text(
                      'Tìm Kiếm Nâng Cao',
                      style: TextStyle(
                        color: Colors.lightBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios,
                        color: Colors.lightBlue, size: 16),
                  ],
                ),
              ),
            ),

            // Truyện Hot
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HotStoriesScreen(),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department,
                        color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      'Truyện Hot',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios,
                        color: Colors.orange, size: 16),
                  ],
                ),
              ),
            ),

            // Phần đề xuất
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Đề Xuất',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: Swiper(
                      itemCount: deXuatItems.length,
                      autoplay: true,
                      autoplayDelay: 3000,
                      viewportFraction: 0.85,
                      scale: 0.95,
                      pagination: const SwiperPagination(
                        alignment: Alignment.bottomCenter,
                        margin: EdgeInsets.only(bottom: 5),
                        builder: DotSwiperPaginationBuilder(
                          activeColor: Colors.blue,
                          color: Colors.white,
                          size: 5.0,
                          activeSize: 6.0,
                          space: 4.0,
                        ),
                      ),
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  deXuatItems[index]['image']!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.error),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.8),
                                        Colors.black.withOpacity(0.4),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Text(
                                    deXuatItems[index]['title']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(1, 1),
                                          blurRadius: 2,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
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
            ),

            // Tiêu đề Truyện Mới Cập Nhật
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.cloud_download, color: Colors.lightBlue),
                  const SizedBox(width: 8),
                  Text(
                    'Truyện Mới Cập Nhật',
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // GridView truyện (không còn Expanded)
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.7,
              ),
              padding: const EdgeInsets.all(8.0),
              itemCount: truyenHot.length,
              itemBuilder: (context, index) {
                return TruyenCard(truyen: truyenHot[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1B3A57),
      title: Column(
        children: [
          // Logo TRUYENFULL với icon sách
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.book, color: Colors.white),
              SizedBox(width: 8),
              Text(
                "TRUYENFULL",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Dòng text chạy
          SizedBox(
            height: 20,
            child: MarqueeText(
              text:
                  'Đọc truyện online, đọc truyện chữ, truyện full, truyện hay. Tổng hợp đầy đủ và cập nhật liên tục.',
              style: const TextStyle(
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
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ),
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 30),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ),
      ],
    );
  }

  // Drawer bên phải
  Drawer buildEndDrawer(BuildContext context) {
    // Lấy currentUser từ provider
    final currentUser = Provider.of<UserProvider>(context).currentUser;
    final bool isAdmin = currentUser?.role == 'admin';

    return Drawer(
      child: Container(
        color: const Color(0xFF1B3A57),
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.list, color: Colors.white),
              title: const Text(
                'Danh sách',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                // Xử lý khi chọn Danh sách
              },
            ),
            ListTile(
              leading: const Icon(Icons.category, color: Colors.white),
              title: const Text(
                'Thể loại',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                // Xử lý khi chọn Thể loại
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort, color: Colors.white),
              title: const Text(
                'Phân loại theo Chương',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                // Xử lý khi chọn Phân loại
              },
            ),
            ListTile(
              leading: const Icon(Icons.book, color: Colors.white),
              title: const Text(
                'Truyện Tranh',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                // Xử lý khi chọn Truyện Tranh
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text('Tùy chỉnh',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) => AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      contentPadding: EdgeInsets.zero,
                      content: Container(
                        width: 280,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              child: const Text(
                                'Tùy chỉnh',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: const Text(
                                'Màu nền',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<bool>(
                                  value: themeProvider.isDarkMode,
                                  isExpanded: true,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 30,
                                    color: Colors.black,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  items: [
                                    DropdownMenuItem(
                                      value: false,
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        color: Colors.grey[200],
                                        child: const Text(
                                          'Xám nhạt',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: true,
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        color: Color(0xFF1B3A57),
                                        child: const Text(
                                          'Màu tối',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  onChanged: (bool? value) {
                                    if (value != null) {
                                      themeProvider.toggleTheme();
                                      Navigator.pop(context);
                                    }
                                  },
                                  selectedItemBuilder: (BuildContext context) {
                                    return [
                                      Container(
                                        alignment: Alignment.center,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          color: Colors.grey[200],
                                          child: const Text(
                                            'Xám nhạt',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          color: Color(0xFF1B3A57),
                                          child: const Text(
                                            'Màu tối',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ];
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Menu items chỉ dành cho admin
            if (isAdmin) ...[
              const Divider(color: Colors.white54),
              ListTile(
                leading:
                    const Icon(Icons.admin_panel_settings, color: Colors.white),
                title: const Text(
                  'Quản lý tài khoản',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserManagementScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.book_online, color: Colors.white),
                title: const Text(
                  'Quản lý truyện',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const StoryManagementScreen()),
                  );
                },
              ),
            ],
            const Divider(color: Colors.white54),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                // Hiển thị dialog xác nhận
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Xác nhận'),
                    content: const Text('Bạn có chắc muốn đăng xuất?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('HỦY'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Xử lý đăng xuất
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'ĐĂNG XUẤT',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const MarqueeText({
    Key? key,
    required this.text,
    required this.style,
  }) : super(key: key);

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    // Đợi widget được build xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        startAnimation();
      }
    });
  }

  void startAnimation() {
    if (!mounted) return;

    try {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0) {
        _animationController.repeat();

        _animationController.addListener(() {
          if (_scrollController.hasClients) {
            try {
              _scrollController.jumpTo(
                _animationController.value *
                    _scrollController.position.maxScrollExtent,
              );
            } catch (e) {
              // Xử lý lỗi nếu có
              print('Error during scroll: $e');
            }
          }
        });
      }
    } catch (e) {
      print('Error starting animation: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          widget.text,
          style: widget.style,
        ),
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Xử lý kết quả tìm kiếm
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Xử lý các gợi ý tìm kiếm
    return Container();
  }
}

class BlinkingText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const BlinkingText({
    Key? key,
    required this.text,
    required this.style,
  }) : super(key: key);

  @override
  State<BlinkingText> createState() => _BlinkingTextState();
}

class _BlinkingTextState extends State<BlinkingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Text(
        widget.text,
        style: widget.style,
      ),
    );
  }
}
