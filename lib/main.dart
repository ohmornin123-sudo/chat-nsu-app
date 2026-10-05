import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';
import 'campus_life_screen.dart';

void main() {
  runApp(const UniversityApp());
}

class UniversityApp extends StatelessWidget {
  const UniversityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '남서울대 스마트 캠퍼스',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF003B70)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final List<String> _titles = ['학사 공지', '학사 Q&A 챗봇', '학점 계산기 & 로드맵', '캠퍼스 편의 & 시설'];

  @override
  void initState() {
    super.initState();
    ApiService.checkHealth();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const NoticeListScreen(),
      const ChatBotScreen(),
      const GraduationCheckScreen(),
      const CampusLifeScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF003B70),
        centerTitle: true,
        elevation: 0,
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF003B70),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined),
            activeIcon: Icon(Icons.campaign),
            label: '공지',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: '챗봇',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: '학점진단',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_city_outlined),
            activeIcon: Icon(Icons.location_city_rounded),
            label: '캠퍼스편의',
          ),
        ],
      ),
    );
  }
}

// [1] 공지사항 화면 (실시간 78개 남서울대 공식 공지 연동)
class NoticeListScreen extends StatefulWidget {
  const NoticeListScreen({super.key});

  @override
  State<NoticeListScreen> createState() => _NoticeListScreenState();
}

class _NoticeListScreenState extends State<NoticeListScreen> {
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = '전체';
  List<Map<String, dynamic>> _allNotices = [];

  // 로컬 예비 공지 (오프라인 시 표시)
  final List<Map<String, dynamic>> _fallbackNotices = const [
    {
      'category': '학사공지',
      'title': '2026학년도 2학기 수강신청 정정 및 취소 기간 안내',
      'date': '2026-09-18',
      'author': '교무처',
      'is_top': true,
      'content':
          '2026학년도 2학기 수강신청 정정 및 취소 기간을 다음과 같이 안내하오니 기간 내에 신청하시기 바랍니다.\n\n1. 정정 기간: 2026.09.21(월) ~ 09.25(금)\n2. 대상: 재학생 및 복학생\n3. 신청 방법: 포털 시스템 로그인 후 수강신청 메뉴 이용',
      'url': 'https://nsu.ac.kr',
    },
    {
      'category': '장학공지',
      'title': '2026-2학기 교내 맞춤형 복지 장학금 추가 신청 안내',
      'date': '2026-09-15',
      'author': '학생지원팀',
      'is_top': false,
      'content':
          '교내 맞춤형 복지 장학금 추가 선발 안내입니다.\n\n- 신청 자격: 직전 학기 12학점 이상 이수 및 성적 기준 충족자\n- 서류 제출: 학과 사무실 또는 온라인 포털 업로드',
      'url': 'https://nsu.ac.kr',
    },
    {
      'category': '일반공지',
      'title': '지능정보통신공학과 IT 대기업 멘토링 프로그램 참가자 모집',
      'date': '2026-09-12',
      'author': '취창업지원센터',
      'is_top': false,
      'content':
          '현업 개발자 선배와 함께하는 포트폴리오 첨삭 및 모의 면접 멘토링 프로그램 참가자를 모집합니다.',
      'url': 'https://nsu.ac.kr',
    },
    {
      'category': '행사공지',
      'title': '2026 캡스톤디자인 성과전시회 일정 공고',
      'date': '2026-09-10',
      'author': '공학교육혁신센터',
      'is_top': false,
      'content':
          '캡스톤디자인 작품 시연 및 성과 전시회가 진행될 예정입니다. 팀별 포스터 제출 일정을 확인하세요.',
      'url': 'https://nsu.ac.kr',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchNotices();
  }

  Future<void> _fetchNotices() async {
    setState(() => _isLoading = true);
    final fetched = await ApiService.getNotices();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (fetched.isNotEmpty) {
          _allNotices = fetched;
        } else {
          _allNotices = List.from(_fallbackNotices);
        }
      });
    }
  }

  List<Map<String, dynamic>> get _filteredNotices {
    return _allNotices.where((item) {
      final title = (item['title'] ?? '').toString().toLowerCase();
      final category = (item['category'] ?? '').toString();
      final matchesSearch = title.contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == '전체' || category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<String> get _categories {
    final set = <String>{'전체'};
    for (final n in _allNotices) {
      final cat = (n['category'] ?? '').toString().trim();
      if (cat.isNotEmpty) set.add(cat);
    }
    return set.toList();
  }

  Future<void> _openNoticeUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    try {
      final Uri uri = Uri.parse(urlString);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _showNoticeDetail(BuildContext context, Map<String, dynamic> item) {
    final title = item['title'] ?? '제목 없음';
    final category = item['category'] ?? '공지';
    final date = item['date'] ?? '';
    final url = item['url']?.toString() ?? '';
    final isTop = item['is_top'] == true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          maxChildSize: 0.92,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: controller,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF003B70).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003B70),
                          ),
                        ),
                      ),
                      if (isTop) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '📌 중요 공지',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.3),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(date,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey)),
                      const Spacer(),
                      const Text('남서울대학교 공식 포털',
                          style: TextStyle(
                              fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                  const Divider(height: 28, thickness: 1),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_outline,
                                size: 18, color: Color(0xFF003B70)),
                            SizedBox(width: 6),
                            Text('공지 상세 및 첨부파일 안내',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF003B70))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '본 공지사항의 상세 본문 및 제출 서식/첨부파일은 남서울대학교 공식 포털 홈페이지 원문에서 직접 확인 및 다운로드가 가능합니다.',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (url.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () => _openNoticeUrl(url),
                      icon: const Icon(Icons.open_in_browser, color: Colors.white),
                      label: const Text(
                        '남서울대 공식 홈페이지에서 원문 보기',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003B70),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF003B70)),
            SizedBox(height: 16),
            Text('남서울대 공식 공지사항(78건) 로딩 중...',
                style: TextStyle(color: Colors.black54, fontSize: 14)),
          ],
        ),
      );
    }

    final notices = _filteredNotices;

    return RefreshIndicator(
      color: const Color(0xFF003B70),
      onRefresh: _fetchNotices,
      child: Column(
        children: [
          // 1. 상단 검색창 & 카테고리 필터
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: '공지사항 제목 검색 (예: 등록금, 장학, 수강)...',
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF003B70)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () =>
                                setState(() => _searchQuery = ''),
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF5F6FA),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      final count = cat == '전체'
                          ? _allNotices.length
                          : _allNotices
                              .where((n) => n['category'] == cat)
                              .length;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text('$cat ($count)'),
                          selected: isSelected,
                          onSelected: (_) =>
                              setState(() => _selectedCategory = cat),
                          selectedColor: const Color(0xFF003B70),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          backgroundColor: const Color(0xFFF0F2F5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // 2. 공지사항 건수 알림 바
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            width: double.infinity,
            color: const Color(0xFFEBF3FB),
            child: Row(
              children: [
                const Icon(Icons.campaign,
                    size: 18, color: Color(0xFF003B70)),
                const SizedBox(width: 6),
                Text(
                  '남서울대 공식 포털 실시간 연동 (총 ${notices.length}건)',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003B70)),
                ),
                const Spacer(),
                const Text('당겨서 새로고침 ↻',
                    style: TextStyle(fontSize: 11, color: Colors.black45)),
              ],
            ),
          ),

          // 3. 공지 목록
          Expanded(
            child: notices.isEmpty
                ? const Center(
                    child: Text('검색 결과가 없습니다.',
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: notices.length,
                    itemBuilder: (context, index) {
                      final item = notices[index];
                      final isTop = item['is_top'] == true;
                      final category = item['category'] ?? '공지';
                      final title = item['title'] ?? '';
                      final date = item['date'] ?? '';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: isTop ? 2.5 : 1.2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: isTop
                              ? const BorderSide(
                                  color: Color(0xFF003B70), width: 1.2)
                              : BorderSide.none,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => _showNoticeDetail(context, item),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isTop
                                            ? Colors.amber.shade100
                                            : const Color(0xFF003B70)
                                                .withOpacity(0.08),
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        isTop ? '📌 중요' : category,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isTop
                                              ? Colors.brown
                                              : const Color(0xFF003B70),
                                        ),
                                      ),
                                    ),
                                    if (isTop) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        category,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black54),
                                      ),
                                    ],
                                    const Spacer(),
                                    Text(
                                      date,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontWeight: isTop
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    fontSize: 14.5,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// [2] 챗봇 화면
class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isWaiting = false;

  final List<String> _quickQuestions = [
    '졸업하려면 몇 학점 필요해?',
    '수강신청 정정 기간',
    '장학금 신청 자격',
    '채플 Pass 기준 및 결석 한도',
    '재수강 기준 및 최고 성적',
    '일반휴학 및 군휴학 신청 방법',
    '복학 신청 기간 및 절차',
    '수강 과목 철회(드랍) 기간',
    '오늘 학생식당 학식 메뉴',
  ];

  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text': '안녕하세요! 남서울대학교 학사 Q&A 챗봇입니다.\n궁금한 학사 규정을 물어보세요!',
      'docType': '확정형',
      'sources': [],
    }
  ];

  void _sendMessage([String? presetText]) {
    final text = presetText ?? _controller.text.trim();
    if (text.isEmpty || _isWaiting) return;

    setState(() {
      _messages.add({'isUser': true, 'text': text, 'docType': '', 'sources': []});
      _messages.add({'isUser': false, 'text': '', 'docType': '', 'sources': []});
      _isWaiting = true;
    });

    if (presetText == null) _controller.clear();
    _scrollToBottom();

    final botMessageIndex = _messages.length - 1;

    ApiService.sendChatMessage(text).listen(
      (data) {
        if (!mounted) return;
        setState(() {
          if (data['type'] == 'token') {
            _messages[botMessageIndex]['text'] =
                (_messages[botMessageIndex]['text'] as String) + (data['text'] as String);
          } else if (data['type'] == 'final') {
            _messages[botMessageIndex]['text'] = data['answer'];
            _messages[botMessageIndex]['docType'] = data['docType'] ?? '확정형';
            _messages[botMessageIndex]['sources'] = data['sources'] ?? [];
            _isWaiting = false;
          }
        });
        _scrollToBottom();
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _isWaiting = false);
      },
      onDone: () {
        if (!mounted) return;
        setState(() => _isWaiting = false);
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 48,
          color: Colors.white,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            scrollDirection: Axis.horizontal,
            itemCount: _quickQuestions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final query = _quickQuestions[index];
              return ActionChip(
                label: Text(query, style: const TextStyle(fontSize: 12, color: Color(0xFF003B70))),
                backgroundColor: const Color(0xFF003B70).withOpacity(0.08),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                side: BorderSide.none,
                onPressed: () => _sendMessage(query),
              );
            },
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final bool isUser = msg['isUser'];
              final String text = msg['text'] ?? '';
              final String docType = msg['docType'] ?? '확정형';
              final List sources = msg['sources'] ?? [];

              if (!isUser && text.isEmpty && _isWaiting) {
                return const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('챗봇이 학칙을 검색하고 있습니다...',
                        style: TextStyle(fontSize: 13, color: Colors.grey)),
                  ),
                );
              }

              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFF003B70) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      if (docType == '확정형' && sources.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: sources.map<Widget>((s) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.blueGrey.shade200),
                              ),
                              child: Text(
                                '📄 ${s['doc_name'] ?? '학칙'} ${s['article'] ?? ''}',
                                style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade800),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.white,
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: '궁금한 학사 일정을 입력하세요...',
                      hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF5F6FA),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: Color(0xFF003B70)),
                  onPressed: () => _sendMessage(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// [3] 학과 공식 교과목 모델
// ==========================================
class CourseInfo {
  final String code;
  final String name;
  final int credits;
  final String type; // '전공기초', '전공필수', '전공선택'
  final int grade;   // 1, 2, 3, 4
  final int semester; // 1, 2

  const CourseInfo({
    required this.code,
    required this.name,
    required this.credits,
    required this.type,
    required this.grade,
    required this.semester,
  });
}

// 남서울대 지능정보통신공학과 공식 요람 데이터베이스
final List<CourseInfo> nsuIctCurriculum = [
  // 1학년 1학기
  const CourseInfo(code: '13091', name: '정보통신공학개론', credits: 3, type: '전공기초', grade: 1, semester: 1),
  const CourseInfo(code: '14689', name: '지능정보통신수학', credits: 3, type: '전공기초', grade: 1, semester: 1),
  const CourseInfo(code: '14692', name: 'C/C++프로그래밍', credits: 2, type: '전공선택', grade: 1, semester: 1),
  // 1학년 2학기
  const CourseInfo(code: '14700', name: '자료구조·알고리즘', credits: 3, type: '전공선택', grade: 1, semester: 2),
  const CourseInfo(code: '14702', name: '컴퓨터구조', credits: 3, type: '전공선택', grade: 1, semester: 2),
  const CourseInfo(code: '14703', name: 'IoT센서·디바이스실습', credits: 2, type: '전공선택', grade: 1, semester: 2),
  const CourseInfo(code: '14707', name: 'Python프로그래밍', credits: 2, type: '전공선택', grade: 1, semester: 2),

  // 2학년 1학기 (전필 집중)
  const CourseInfo(code: '14684', name: '데이터사이언스', credits: 3, type: '전공필수', grade: 2, semester: 1),
  const CourseInfo(code: '14690', name: '통신회로', credits: 3, type: '전공필수', grade: 2, semester: 1),
  const CourseInfo(code: '14691', name: '회로이론', credits: 3, type: '전공필수', grade: 2, semester: 1),
  const CourseInfo(code: '14694', name: 'RF무선통신기초', credits: 3, type: '전공필수', grade: 2, semester: 1),
  const CourseInfo(code: '13021', name: '디지털신호처리', credits: 3, type: '전공선택', grade: 2, semester: 1),
  const CourseInfo(code: '13704', name: 'JAVA프로그래밍', credits: 3, type: '전공선택', grade: 2, semester: 1),

  // 2학년 2학기
  const CourseInfo(code: '13029', name: '데이터통신', credits: 3, type: '전공필수', grade: 2, semester: 2),
  const CourseInfo(code: '14869', name: '머신러닝이론및실습', credits: 3, type: '전공선택', grade: 2, semester: 2),
  const CourseInfo(code: '14696', name: '빅데이터', credits: 3, type: '전공선택', grade: 2, semester: 2),
  const CourseInfo(code: '13206', name: '모바일프로그래밍', credits: 3, type: '전공선택', grade: 2, semester: 2),
  const CourseInfo(code: '14704', name: 'IoT센서공학', credits: 3, type: '전공선택', grade: 2, semester: 2),
  const CourseInfo(code: '14699', name: '임베디드프로세서실습', credits: 3, type: '전공선택', grade: 2, semester: 2),

  // 3학년 1학기
  const CourseInfo(code: '13053', name: '디지털통신', credits: 3, type: '전공필수', grade: 3, semester: 1),
  const CourseInfo(code: '14683', name: '네트워크프로토콜실습', credits: 3, type: '전공선택', grade: 3, semester: 1),
  const CourseInfo(code: '14685', name: '딥러닝', credits: 3, type: '전공선택', grade: 3, semester: 1),
  const CourseInfo(code: '14698', name: '운영체제이론및실습', credits: 3, type: '전공선택', grade: 3, semester: 1),
  const CourseInfo(code: '14687', name: '웹서버및DB', credits: 3, type: '전공선택', grade: 3, semester: 1),
  const CourseInfo(code: '14688', name: '임베디드프로그래밍', credits: 3, type: '전공선택', grade: 3, semester: 1),

  // 3학년 2학기
  const CourseInfo(code: '14695', name: '5G이동통신', credits: 3, type: '전공선택', grade: 3, semester: 2),
  const CourseInfo(code: '14635', name: '지능형네트워크', credits: 3, type: '전공선택', grade: 3, semester: 2),
  const CourseInfo(code: '14701', name: '정보보호개론', credits: 3, type: '전공선택', grade: 3, semester: 2),
  const CourseInfo(code: '14705', name: 'IoT통신', credits: 3, type: '전공선택', grade: 3, semester: 2),
  const CourseInfo(code: '14706', name: 'IoT플랫폼', credits: 3, type: '전공선택', grade: 3, semester: 2),
  const CourseInfo(code: '14697', name: '영상/오디오신호처리', credits: 3, type: '전공선택', grade: 3, semester: 2),
  const CourseInfo(code: '14910', name: 'ICT융합설계기초', credits: 2, type: '전공선택', grade: 3, semester: 2),

  // 4학년 1학기
  const CourseInfo(code: '14908', name: 'ICT융합설계1(캡스톤)', credits: 2, type: '전공선택', grade: 4, semester: 1),
  const CourseInfo(code: '14693', name: 'IoT정보보안', credits: 3, type: '전공선택', grade: 4, semester: 1),

  // 4학년 2학기
  const CourseInfo(code: '14909', name: 'ICT융합설계2(캡스톤)', credits: 2, type: '전공선택', grade: 4, semester: 2),

  // 남서울대 공통 교양필수 (채플 4회, 아가페인문학 등)
  const CourseInfo(code: 'GE101', name: '채플 1', credits: 0, type: '교양필수', grade: 1, semester: 1),
  const CourseInfo(code: 'GE102', name: '아가페인문학', credits: 2, type: '교양필수', grade: 1, semester: 1),
  const CourseInfo(code: 'GE103', name: '말하기와글쓰기', credits: 2, type: '교양필수', grade: 1, semester: 1),
  const CourseInfo(code: 'GE104', name: '채플 2', credits: 0, type: '교양필수', grade: 1, semester: 2),
  const CourseInfo(code: 'GE105', name: '현대인과 사회적 영성', credits: 2, type: '교양필수', grade: 1, semester: 2),
  const CourseInfo(code: 'GE106', name: '대학영어', credits: 2, type: '교양필수', grade: 1, semester: 2),
  const CourseInfo(code: 'GE201', name: '채플 3', credits: 0, type: '교양필수', grade: 2, semester: 1),
  const CourseInfo(code: 'GE202', name: '채플 4', credits: 0, type: '교양필수', grade: 2, semester: 2),
];

// [4] 학점 자가진단 & 졸업 로드맵 플래너 (학년별 과목 필터 및 추천 탑재)
class GraduationCheckScreen extends StatefulWidget {
  const GraduationCheckScreen({super.key});

  @override
  State<GraduationCheckScreen> createState() => _GraduationCheckScreenState();
}

class _GraduationCheckScreenState extends State<GraduationCheckScreen> {
  String _studentId = '202112345';
  String _department = '지능정보통신공학과';
  int _currentGrade = 3;      // 현재 학년 (1~4)
  int _currentSemester = 1;   // 현재 학기 (1~2)
  int _remainingSemesters = 2; // 남은 정규 학기

  int _majorReqCompleted = 12;
  int _majorSelCompleted = 45;
  int _generalCompleted = 30;

  // 현재 필터링된 학년 탭 (0: 전체, 1: 1학년, 2: 2학년, 3: 3학년, 4: 4학년)
  int _selectedGradeTab = 0;

  // 사용자가 이수한 과목 코드 목록
  List<String> _completedCourseCodes = [
    '13091', '14689', '14692', // 1학년 기초/C++
    '14684', '14690', '14691', '14694', // 2학년 전필
  ];

  Map<String, dynamic>? _data;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFromLocalStorage();
  }

  // 폰 데이터 로컬 저장소에서 불러오기
  Future<void> _loadFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _department = prefs.getString('saved_dept') ?? _department;
      _studentId = prefs.getString('saved_student_id') ?? _studentId;
      _currentGrade = prefs.getInt('saved_curr_grade') ?? _currentGrade;
      _currentSemester = prefs.getInt('saved_curr_sem') ?? _currentSemester;
      _remainingSemesters = prefs.getInt('saved_semesters') ?? _remainingSemesters;
      _majorReqCompleted = prefs.getInt('saved_major_req') ?? _majorReqCompleted;
      _majorSelCompleted = prefs.getInt('saved_major_sel') ?? _majorSelCompleted;
      _generalCompleted = prefs.getInt('saved_general') ?? _generalCompleted;
      _completedCourseCodes =
          prefs.getStringList('saved_course_codes') ?? _completedCourseCodes;
    });
    _loadCreditData();
  }

  // 폰 데이터에 영구 저장하기
  Future<void> _saveToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_dept', _department);
    await prefs.setString('saved_student_id', _studentId);
    await prefs.setInt('saved_curr_grade', _currentGrade);
    await prefs.setInt('saved_curr_sem', _currentSemester);
    await prefs.setInt('saved_semesters', _remainingSemesters);
    await prefs.setInt('saved_major_req', _majorReqCompleted);
    await prefs.setInt('saved_major_sel', _majorSelCompleted);
    await prefs.setInt('saved_general', _generalCompleted);
    await prefs.setStringList('saved_course_codes', _completedCourseCodes);
  }

  int get _totalCompleted =>
      _majorReqCompleted + _majorSelCompleted + _generalCompleted;

  void _loadCreditData() async {
    setState(() => _isLoading = true);

    // 이수한 과목 이름 목록
    final completedNames = nsuIctCurriculum
        .where((c) => _completedCourseCodes.contains(c.code))
        .map((c) => c.name)
        .toList();

    final result = await ApiService.checkGraduationCredits(
      studentId: _studentId,
      department: _department,
      totalCompleted: _totalCompleted,
      majorReqCompleted: _majorReqCompleted,
      majorSelCompleted: _majorSelCompleted,
      generalCompleted: _generalCompleted,
      remainingSemesters: _remainingSemesters,
      completedCourseCodes: completedNames,
    );

    if (!mounted) return;
    setState(() {
      _data = result;
      _isLoading = false;
    });
  }

  // 과목 이수 토글
  void _toggleCourse(CourseInfo course) {
    setState(() {
      if (_completedCourseCodes.contains(course.code)) {
        _completedCourseCodes.remove(course.code);
        if (course.type == '전공필수') {
          _majorReqCompleted = (_majorReqCompleted - course.credits).clamp(0, 18);
        } else if (course.type == '교양필수') {
          _generalCompleted = (_generalCompleted - course.credits).clamp(0, 50);
        } else {
          _majorSelCompleted = (_majorSelCompleted - course.credits).clamp(0, 75);
        }
      } else {
        _completedCourseCodes.add(course.code);
        if (course.type == '전공필수') {
          _majorReqCompleted = (_majorReqCompleted + course.credits).clamp(0, 18);
        } else if (course.type == '교양필수') {
          _generalCompleted = (_generalCompleted + course.credits).clamp(0, 50);
        } else {
          _majorSelCompleted = (_majorSelCompleted + course.credits).clamp(0, 75);
        }
      }
    });
    _saveToLocalStorage();
    _loadCreditData();
  }

  // 학점 및 학년 설정 모달
  void _openCalculatorModal() {
    final majorReqCtrl = TextEditingController(text: _majorReqCompleted.toString());
    final majorSelCtrl = TextEditingController(text: _majorSelCompleted.toString());
    final generalCtrl = TextEditingController(text: _generalCompleted.toString());
    int tempGrade = _currentGrade;
    int tempSem = _currentSemester;
    int tempSemesters = _remainingSemesters;
    String tempDept = _department;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Icon(Icons.edit_note_rounded, color: Color(0xFF003B70)),
                        SizedBox(width: 8),
                        Text(
                          '내 학적 & 이수 학점 설정',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 학과 선택
                    DropdownButtonFormField<String>(
                      value: tempDept,
                      decoration: const InputDecoration(
                        labelText: '소속 학과',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: '지능정보통신공학과', child: Text('지능정보통신공학과')),
                        DropdownMenuItem(
                            value: '컴퓨터소프트웨어학과', child: Text('컴퓨터소프트웨어학과')),
                        DropdownMenuItem(
                            value: '전자공학과', child: Text('전자공학과')),
                        DropdownMenuItem(
                            value: '가상현실학과', child: Text('가상현실학과')),
                        DropdownMenuItem(
                            value: '간호학과', child: Text('간호학과')),
                        DropdownMenuItem(
                            value: '물리치료학과', child: Text('물리치료학과')),
                        DropdownMenuItem(
                            value: '치위생학과', child: Text('치위생학과')),
                        DropdownMenuItem(
                            value: '임상병리학과', child: Text('임상병리학과')),
                        DropdownMenuItem(
                            value: '경영학과', child: Text('경영학과')),
                        DropdownMenuItem(
                            value: '시각미디어디자인학과', child: Text('시각미디어디자인학과')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => tempDept = val);
                      },
                    ),
                    const SizedBox(height: 14),
                    // 현재 학년 및 학기 선택
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: tempGrade,
                            decoration: const InputDecoration(
                              labelText: '현재 학년',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: [1, 2, 3, 4]
                                .map((g) => DropdownMenuItem(value: g, child: Text('$g학년')))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() {
                                  tempGrade = val;
                                  tempSemesters = (8 - ((tempGrade - 1) * 2 + tempSem)).clamp(1, 8);
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: tempSem,
                            decoration: const InputDecoration(
                              labelText: '현재 학기',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: [1, 2]
                                .map((s) => DropdownMenuItem(value: s, child: Text('$s학기')))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() {
                                  tempSem = val;
                                  tempSemesters = (8 - ((tempGrade - 1) * 2 + tempSem)).clamp(1, 8);
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // 잔여 학기 자동 계산 및 안내
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF003B70).withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 18, color: Color(0xFF003B70)),
                          const SizedBox(width: 8),
                          Text(
                            '정규 잔여 학기: $tempSemesters학기 남음',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF003B70),
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 24),
                    const Text('영역별 취득 학점 입력',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: majorReqCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: '전공필수',
                              suffixText: '학점',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: majorSelCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: '전공선택',
                              suffixText: '학점',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: generalCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: '교양/기타',
                              suffixText: '학점',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003B70),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _department = tempDept;
                            _currentGrade = tempGrade;
                            _currentSemester = tempSem;
                            _remainingSemesters = tempSemesters;
                            _majorReqCompleted =
                                int.tryParse(majorReqCtrl.text) ?? _majorReqCompleted;
                            _majorSelCompleted =
                                int.tryParse(majorSelCtrl.text) ?? _majorSelCompleted;
                            _generalCompleted =
                                int.tryParse(generalCtrl.text) ?? _generalCompleted;
                          });
                          _saveToLocalStorage();
                          Navigator.pop(ctx);
                          _loadCreditData();
                        },
                        child: const Text(
                          '저장 및 로드맵 계산',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalReq = _data?['total_credits_required'] ?? 130;
    final totalComp = _totalCompleted;
    final double progress = (totalComp / totalReq).clamp(0.0, 1.0);
    final int remainingCredits = (totalReq - totalComp).clamp(0, 130);
    final double recommendedPerSemester =
        (_data?['recommended_per_semester'] as num?)?.toDouble() ??
            (_remainingSemesters > 0
                ? double.parse((remainingCredits / _remainingSemesters).toStringAsFixed(1))
                : 0.0);

    // 필터링된 학년별 교과목 목록
    final displayedCourses = nsuIctCurriculum.where((c) {
      if (_selectedGradeTab == 0) return true;
      if (_selectedGradeTab == 5) return c.type == '교양필수';
      return c.grade == _selectedGradeTab;
    }).toList();

    // 다음 학기 우선 추천 과목 추출:
    // 사용자의 현재 학년/학기 다음 학기에 개설된 과목 중 미이수한 과목 우선 추출
    int nextGrade = _currentGrade;
    int nextSemester = _currentSemester + 1;
    if (nextSemester > 2) {
      nextGrade = (_currentGrade + 1).clamp(1, 4);
      nextSemester = 1;
    }

    final recommendedNextList = nsuIctCurriculum
        .where((c) =>
            !_completedCourseCodes.contains(c.code) &&
            ((c.grade == nextGrade && c.semester == nextSemester) || c.type == '전공필수'))
        .take(3)
        .toList();

    Color roadmapColor;
    String roadmapMsg;
    IconData roadmapIcon;

    if (remainingCredits <= 0) {
      roadmapColor = Colors.green;
      roadmapMsg = '🎉 축하합니다! 졸업에 필요한 최저 이수학점을 모두 달성했습니다.';
      roadmapIcon = Icons.celebration;
    } else if (recommendedPerSemester <= 19) {
      roadmapColor = const Color(0xFF003B70);
      roadmapMsg =
          '남은 $_remainingSemesters학기 동안 학기당 약 ${recommendedPerSemester}학점씩 수강하면 정규 학기 내 무리 없이 졸업 가능합니다.';
      roadmapIcon = Icons.check_circle_outline;
    } else if (recommendedPerSemester <= 21) {
      roadmapColor = Colors.orange.shade800;
      roadmapMsg =
          '학기당 수강 제한 학점(최대 19~21학점)에 가깝습니다. 과목 철회 없이 정규 학기를 꽉 채워 수강해야 합니다.';
      roadmapIcon = Icons.warning_amber_rounded;
    } else {
      roadmapColor = Colors.red.shade700;
      roadmapMsg =
          '정규 학기만으로는 학기당 ${recommendedPerSemester}학점이 필요하여 초과됩니다! 계절학기 수강 또는 1학기 추가 등록을 권장합니다.';
      roadmapIcon = Icons.error_outline;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. 학적 프로필 및 버튼
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFF003B70),
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _department,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$_studentId · $_currentGrade학년 $_currentSemester학기 (잔여 $_remainingSemesters학기)',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF003B70)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                onPressed: _openCalculatorModal,
                icon: const Icon(Icons.tune_rounded, size: 18, color: Color(0xFF003B70)),
                label: const Text('학적 설정',
                    style: TextStyle(fontSize: 12, color: Color(0xFF003B70))),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 2. 졸업 학점 달성도 카드
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 1.5,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('졸업 총 학점 달성도',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    Text('${(progress * 100).toInt()}% 완료',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003B70))),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF003B70)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$totalComp / $totalReq 학점',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003B70))),
                    Text('남은 학점: $remainingCredits 학점',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                  ],
                ),
                const Divider(height: 24),
                _buildSubProgressBar('전공 필수', _majorReqCompleted, 18),
                const SizedBox(height: 8),
                _buildSubProgressBar('전공 선택', _majorSelCompleted, 54),
                const SizedBox(height: 8),
                _buildSubProgressBar('교양 및 기타', _generalCompleted, 36),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // 3. 스마트 로드맵 플래너 카드
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 1.5,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(roadmapIcon, color: roadmapColor),
                    const SizedBox(width: 8),
                    const Text('스마트 졸업 로드맵 플래너',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: roadmapColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: roadmapColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildPlannerStat('남은 학점', '$remainingCredits 학점'),
                          Container(width: 1, height: 32, color: Colors.grey.shade300),
                          _buildPlannerStat('잔여 학기', '$_remainingSemesters 학기'),
                          Container(width: 1, height: 32, color: Colors.grey.shade300),
                          _buildPlannerStat('학기당 권장', '$recommendedPerSemester 학점'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        roadmapMsg,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                          color: roadmapColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // 4. [신규] 다음 학기 맞춤 추천 과목 (학년/학기 기반)
        Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
            const SizedBox(width: 6),
            Text(
              '${nextGrade}학년 ${nextSemester}학기 우선 추천 과목',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 1,
          color: Colors.white,
          child: Column(
            children: recommendedNextList.isEmpty
                ? [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('해당 학기에 수강할 모든 필수/권장 과목을 이수했습니다!',
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                    )
                  ]
                : recommendedNextList.map((c) {
                    final bool isReq = c.type == '전공필수';
                    return ListTile(
                      leading: Icon(
                        isReq ? Icons.stars_rounded : Icons.check_circle_outline,
                        color: isReq ? Colors.redAccent : Colors.green,
                      ),
                      title: Text(
                        c.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${c.grade}학년 ${c.semester}학기 · ${c.type} (${c.credits}학점)',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isReq ? Colors.red.shade50 : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isReq ? '필수 이수' : '수강 권장',
                          style: TextStyle(
                            color: isReq ? Colors.redAccent : const Color(0xFF003B70),
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // 5. [핵심] 실제 교육과정 학년별 과목 목록 및 이수 체크리스트
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 1.5,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.list_alt_rounded, color: Color(0xFF003B70), size: 20),
                    SizedBox(width: 8),
                    Text('남서울대 지능정보통신공학과 교육과정',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                // 학년별 탭 필터
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [0, 1, 2, 3, 4, 5].map((grade) {
                      final isSelected = _selectedGradeTab == grade;
                      final label = grade == 0
                          ? '전체'
                          : (grade == 5 ? '교양필수' : '$grade학년');
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          selectedColor: grade == 5
                              ? Colors.teal.shade700
                              : const Color(0xFF003B70),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (_) => setState(() => _selectedGradeTab = grade),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '💡 들은 과목을 터치(V)하면 졸업 학점에 즉시 반영됩니다.',
                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                ),
                const Divider(height: 18),
                ...displayedCourses.map((c) {
                  final isDone = _completedCourseCodes.contains(c.code);
                  final isReq = c.type == '전공필수';
                  return CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFF003B70),
                    title: Row(
                      children: [
                        Text(
                          c.name,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                            color: isDone ? Colors.grey : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: isReq
                                ? Colors.red.shade50
                                : (c.type == '교양필수'
                                    ? Colors.teal.shade50
                                    : (c.type == '전공기초'
                                        ? Colors.purple.shade50
                                        : Colors.blue.shade50)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            c.type,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isReq
                                  ? Colors.redAccent
                                  : (c.type == '교양필수'
                                      ? Colors.teal.shade800
                                      : (c.type == '전공기초'
                                          ? Colors.purple
                                          : const Color(0xFF003B70))),
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      '${c.grade}학년 ${c.semester}학기 · ${c.credits}학점 ${isDone ? "✓ 이수 완료" : "· 미이수"}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDone ? Colors.green : Colors.grey.shade600,
                      ),
                    ),
                    value: isDone,
                    onChanged: (_) => _toggleCourse(c),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSubProgressBar(String title, int current, int required) {
    final double ratio = (current / required).clamp(0.0, 1.0);
    final bool isCompleted = current >= required;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 12.5, color: Colors.black87)),
            Text(
              '$current / $required 학점 ${isCompleted ? "(충족)" : ""}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isCompleted ? Colors.green : Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? Colors.green : const Color(0xFF003B70).withOpacity(0.7)),
          ),
        ),
      ],
    );
  }

  Widget _buildPlannerStat(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF003B70))),
      ],
    );
  }
}