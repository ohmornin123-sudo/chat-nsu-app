import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';

// [캠퍼스 건물 데이터 모델]
class CampusBuilding {
  final String id; // 호관 번호 (예: '01', '08', '16')
  final String name; // 건물명
  final String category; // '공학관', '학관', '복지시설', '도서관/체육', '기숙사', '행정', '정문/교통'
  final String description;
  final List<String> floors;
  final List<String> amenities;
  final IconData icon;
  final double mapX;
  final double mapY;

  const CampusBuilding({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.floors,
    required this.amenities,
    required this.icon,
    this.mapX = 260,
    this.mapY = 250,
  });
}

class CampusLifeScreen extends StatefulWidget {
  const CampusLifeScreen({super.key});

  @override
  State<CampusLifeScreen> createState() => _CampusLifeScreenState();
}

class _CampusLifeScreenState extends State<CampusLifeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '전체';
  String _selectedDeptCollege = '전체';
  String _searchQuery = '';
  bool _isDeptExpanded = false;
  bool _isBuildingExpanded = false;

  // 실시간 도서관 좌석 데이터 상태
  Map<String, dynamic>? _librarySeatData;
  bool _isLoadingSeats = false;

  // 주간 식단표 및 코너 선택 상태
  Map<String, dynamic>? _weeklyMealData;
  String _selectedCafeteriaFloor = '1층'; // '1층', '2층', '3층', '멀베리'
  String _selectedMealDay = '월';

  @override
  void initState() {
    super.initState();
    _loadLibrarySeats();
    _loadWeeklyMeals();
  }

  Future<void> _loadLibrarySeats() async {
    if (!mounted) return;
    setState(() => _isLoadingSeats = true);
    final data = await ApiService.getLibrarySeats();
    if (mounted) {
      setState(() {
        _librarySeatData = data;
        _isLoadingSeats = false;
      });
    }
  }

  Future<void> _loadWeeklyMeals() async {
    final data = await ApiService.getCafeteriaWeekly();
    if (mounted) {
      setState(() {
        _weeklyMealData = data;
      });
    }
  }

  // 1층 실제 푸드코트 공식 메뉴 데이터 (4개 코너, 총 63종)
  final Map<String, List<Map<String, dynamic>>> _floor1OfficialMenus = const {
    '버거운베어(수제버거)': [
      {'name': '버거운치킨버거', 'price': 4900, 'desc': '단품 4,900원 / 세트 7,200원', 'is_best': true},
      {'name': '버거운치킨버거 세트', 'price': 7200, 'desc': '버거 + 감자튀김 + 음료', 'is_best': false},
      {'name': '핫치킨버거', 'price': 5300, 'desc': '단품 5,300원 / 세트 7,600원', 'is_best': false},
      {'name': '핫치킨버거 세트', 'price': 7600, 'desc': '버거 + 감자튀김 + 음료', 'is_best': false},
      {'name': '딥치즈치킨버거', 'price': 5400, 'desc': '단품 5,400원 / 세트 7,700원', 'is_best': true},
      {'name': '딥치즈치킨버거 세트', 'price': 7700, 'desc': '버거 + 감자튀김 + 음료', 'is_best': false},
      {'name': '화이트어니언치킨버거', 'price': 5600, 'desc': '단품 5,600원 / 세트 7,900원', 'is_best': false},
      {'name': '화이트어니언치킨버거 세트', 'price': 7900, 'desc': '버거 + 감자튀김 + 음료', 'is_best': false},
      {'name': '불새버거', 'price': 6400, 'desc': '단품 6,400원 / 세트 8,700원', 'is_best': true},
      {'name': '불새버거 세트', 'price': 8700, 'desc': '버거 + 감자튀김 + 음료', 'is_best': false},
      {'name': '투움바 더블새우버거', 'price': 6900, 'desc': '단품 6,900원 / 세트 9,300원', 'is_best': false},
      {'name': '투움바 더블새우버거 세트', 'price': 9300, 'desc': '버거 + 감자튀김 + 음료', 'is_best': false},
      {'name': '더블통새우버거', 'price': 7000, 'desc': '단품 7,000원 / 세트 9,400원', 'is_best': true},
      {'name': '더블통새우버거 세트', 'price': 9400, 'desc': '버거 + 감자튀김 + 음료', 'is_best': false},
      {'name': '불닭통모짜버거', 'price': 8400, 'desc': '단품 8,400원 / 세트 10,900원', 'is_best': true},
      {'name': '불닭통모짜버거 세트', 'price': 10900, 'desc': '버거 + 감자튀김 + 음료', 'is_best': false},
    ],
    '청년한끼(덮밥·라면)': [
      {'name': '치킨 데리 마요 덮밥', 'price': 6900, 'desc': '바삭 치킨 + 데리마요 소스', 'is_best': false},
      {'name': '치킨 불닭 마요 덮밥', 'price': 7400, 'desc': '매콤 불닭 소스와 고소한 마요', 'is_best': false},
      {'name': '치킨 치폴레 마요 덮밥', 'price': 7400, 'desc': '스모키 치폴레 소스', 'is_best': false},
      {'name': '치킨 김치 마요 덮밥', 'price': 7400, 'desc': '볶음김치와 치킨마요', 'is_best': false},
      {'name': '참치 데리 마요 덮밥', 'price': 6400, 'desc': '고소한 참치마요', 'is_best': false},
      {'name': '함박 치폴레 마요 덮밥', 'price': 6400, 'desc': '함박스테이크 토핑', 'is_best': false},
      {'name': '스팸 데리 마요 덮밥', 'price': 6900, 'desc': '구운 스팸 듬뿍', 'is_best': false},
      {'name': '불맛폭발 직화제육덮밥', 'price': 8900, 'desc': '불향 가득 매콤 제육', 'is_best': false},
      {'name': '춘천 닭갈비 덮밥', 'price': 8400, 'desc': '매콤달콤 닭갈비', 'is_best': false},
      {'name': '김치대패삼겹덮밥', 'price': 9400, 'desc': '대패삼겹과 묵은지', 'is_best': false},
      {'name': '용두동 불쭈꾸미덮밥', 'price': 9900, 'desc': '화끈한 불맛 쭈꾸미', 'is_best': false},
      {'name': '우삼겹 마라샹궈덮밥', 'price': 9900, 'desc': '알싸한 마라샹궈와 우삼겹', 'is_best': false},
      {'name': '갈비양념구이덮밥', 'price': 8900, 'desc': '단짠 갈비양념구이', 'is_best': false},
      {'name': '안동찜닭덮밥', 'price': 7900, 'desc': '단짠 찜닭과 당면', 'is_best': false},
      {'name': '야채 비빔밥', 'price': 6400, 'desc': '신선한 야채 비빔밥', 'is_best': false},
      {'name': '참치 야채 비빔밥', 'price': 7400, 'desc': '참치 듬뿍 비빔밥', 'is_best': false},
      {'name': '치킨김치볶음밥', 'price': 6000, 'desc': '치킨과 김치 볶음밥', 'is_best': false},
      {'name': '골든 카레 덮밥', 'price': 6000, 'desc': '풍미 가득 일본식 카레', 'is_best': false},
      {'name': '골든 치킨 카레 덮밥', 'price': 7500, 'desc': '치킨 토핑 카레', 'is_best': false},
      {'name': '골든 소시지 카레 덮밥', 'price': 8500, 'desc': '소시지 토핑 카레', 'is_best': false},
      {'name': '한끼 라면', 'price': 4000, 'desc': '얼큰한 분식 라면', 'is_best': true},
      {'name': '한끼 치즈라면', 'price': 4500, 'desc': '체다치즈 라면', 'is_best': false},
      {'name': '한끼 짜장라면', 'price': 4500, 'desc': '고소한 짜장라면', 'is_best': false},
    ],
    '쑝쑝돈까스': [
      {'name': '싱글돈까스', 'price': 6500, 'desc': '바삭한 수제 등심 돈까스', 'is_best': true},
      {'name': '쑝쑝돈까스', 'price': 8400, 'desc': '대표 시그니처 수제 돈까스', 'is_best': true},
      {'name': '경양식 왕돈까스', 'price': 9900, 'desc': '푸짐한 옛날 경양식 왕돈까스', 'is_best': true},
      {'name': '슈프림돈까스', 'price': 8900, 'desc': '특제 슈프림 소스 돈까스', 'is_best': false},
      {'name': '큐브치즈돈까스', 'price': 9400, 'desc': '통 치즈가 들어간 카츠', 'is_best': true},
      {'name': '큐브치즈카츠(감자)', 'price': 10400, 'desc': '치즈카츠 + 감자튀김', 'is_best': false},
      {'name': '모짜렐라치즈돈까스', 'price': 10400, 'desc': '100% 자연산 모짜렐라 치즈', 'is_best': true},
      {'name': '눈꽃치즈돈까스', 'price': 10400, 'desc': '눈꽃처럼 소복한 치즈 토핑', 'is_best': false},
      {'name': '양파듬뿍돈까스', 'price': 9900, 'desc': '신선한 양파 샐러드 토핑', 'is_best': false},
      {'name': '프리미엄카츠', 'price': 9900, 'desc': '두툼한 특등심 프리미엄 카츠', 'is_best': false},
      {'name': '가라아게 커리', 'price': 6900, 'desc': '치킨 가라아게 커리', 'is_best': false},
      {'name': '소시지 커리', 'price': 6900, 'desc': '그릴 소시지 커리', 'is_best': false},
      {'name': '에비덴 커리', 'price': 7900, 'desc': '새우튀김 커리', 'is_best': false},
      {'name': '돈까스 커리', 'price': 8500, 'desc': '등심 돈까스 커리', 'is_best': true},
      {'name': '냉우동', 'price': 6900, 'desc': '시원한 살얼음 냉우동', 'is_best': false},
      {'name': '냉모밀', 'price': 7500, 'desc': '시원한 메밀소바', 'is_best': true},
    ],
    '태산김치찜(백반)': [
      {'name': '태산 돼지김치찜 백반', 'price': 7500, 'desc': '푹 익은 묵은지와 돼지고기 백반 (정식 7,900원)', 'is_best': true},
      {'name': '태산 돼지김치찜 정식', 'price': 7900, 'desc': '김치찜 + 밥 + 계란후라이/사이드', 'is_best': false},
      {'name': '태산 참치김치찜 백반', 'price': 7500, 'desc': '고소한 참치 김치찜 백반 (정식 7,900원)', 'is_best': false},
      {'name': '태산 참치김치찜 정식', 'price': 7900, 'desc': '참치김치찜 정식 세트', 'is_best': false},
      {'name': '태산 부대김치찜 백반', 'price': 7500, 'desc': '햄/소시지 부대김치찜 (정식 7,900원)', 'is_best': false},
      {'name': '태산 부대김치찜 정식', 'price': 7900, 'desc': '부대김치찜 정식 세트', 'is_best': false},
      {'name': '우삼겹김치찜 백반', 'price': 8200, 'desc': '고소한 우삼겹 김치찜 (정식 8,900원)', 'is_best': true},
      {'name': '우삼겹김치찜 정식', 'price': 8900, 'desc': '우삼겹김치찜 정식 세트', 'is_best': false},
      {'name': '대패김치찜 백반', 'price': 7900, 'desc': '대패삼겹 김치찜 (정식 8,500원)', 'is_best': false},
      {'name': '대패김치찜 정식', 'price': 8500, 'desc': '대패김치찜 정식 세트', 'is_best': false},
      {'name': '돼지구이백반', 'price': 8000, 'desc': '달콤 짭조름한 돼지구이 (정식 8,500원)', 'is_best': true},
      {'name': '돼지구이정식', 'price': 8500, 'desc': '돼지구이 정식 세트', 'is_best': false},
      {'name': '간장불고기 백반', 'price': 6000, 'desc': '든든한 간장불고기 백반', 'is_best': true},
      {'name': '계란말이', 'price': 6000, 'desc': '푸짐한 수제 왕계란말이', 'is_best': false},
      {'name': '냉칼국수', 'price': 6000, 'desc': '시원한 냉칼국수', 'is_best': false},
      {'name': '스팸구이', 'price': 4000, 'desc': '노릇하게 구운 스팸 4조각', 'is_best': false},
    ],
  };

  // 2층 실제 학생식당 공식 메뉴 데이터 (4개 코너, 총 64종)
  final Map<String, List<Map<String, dynamic>>> _floor2OfficialMenus = const {
    '언덕뜰소반(한식·국밥)': [
      {'name': '소고기된장찌개', 'price': 6900, 'desc': '구수한 소고기 된장찌개', 'is_best': true},
      {'name': '돼지김치찌개', 'price': 6800, 'desc': '칼칼한 돼지고기 김치찌개', 'is_best': true},
      {'name': '스팸순두부찌개', 'price': 7000, 'desc': '부드러운 순두부와 짭조름한 스팸', 'is_best': true},
      {'name': '얼큰소고기무국', 'price': 7000, 'desc': '얼큰하고 시원한 소고기무국', 'is_best': false},
      {'name': '섞어찌개', 'price': 7300, 'desc': '다양한 재료가 어우러진 찌개', 'is_best': false},
      {'name': '콩나물국밥', 'price': 6900, 'desc': '시원하고 개운한 콩나물국밥', 'is_best': false},
      {'name': '밀양순대국밥', 'price': 6900, 'desc': '진한 사골 국물의 순대국밥', 'is_best': true},
      {'name': '밀양돼지국밥', 'price': 7000, 'desc': '구수한 부산·밀양식 돼지국밥', 'is_best': true},
      {'name': '매운돼지국밥', 'price': 7000, 'desc': '얼큰 칼칼한 매운 돼지국밥', 'is_best': false},
      {'name': '뚝배기 불고기', 'price': 8900, 'desc': '달콤한 소불고기 뚝배기', 'is_best': true},
      {'name': '뚝배기돈갈비', 'price': 8500, 'desc': '부드러운 돼지갈비 뚝배기', 'is_best': false},
      {'name': '돌솥비빔밥', 'price': 8500, 'desc': '지글지글 고소한 돌솥비빔밥', 'is_best': true},
      {'name': '알밥', 'price': 7000, 'desc': '날치알 듬뿍 뚝배기 알밥', 'is_best': false},
      {'name': '닭다리 간장찜닭', 'price': 7900, 'desc': '통 닭다리와 단짠 간장양념', 'is_best': false},
      {'name': '닭다리 볶음탕', 'price': 7900, 'desc': '통 닭다리와 매콤 양념', 'is_best': false},
      {'name': '김치말이국수', 'price': 7500, 'desc': '시원 새콤한 김치말이국수', 'is_best': false},
    ],
    '부대통령(부대찌개·직화)': [
      {'name': '부대찌개', 'price': 7000, 'desc': '햄·소시지 듬뿍 부대찌개 (치즈/사리 추가가능)', 'is_best': true},
      {'name': '부대찌개 치즈', 'price': 7500, 'desc': '고소한 치즈 토핑 부대찌개', 'is_best': false},
      {'name': '부대찌개 사리', 'price': 7500, 'desc': '라면사리 포함 부대찌개', 'is_best': false},
      {'name': '부대찌개 치즈사리', 'price': 8000, 'desc': '치즈 + 라면사리 풀토핑', 'is_best': true},
      {'name': '제육볶음', 'price': 7000, 'desc': '불맛 가득 매콤 제육볶음 (곱 8,000원)', 'is_best': true},
      {'name': '제육볶음(곱)', 'price': 8000, 'desc': '고기 양 1.5배 곱빼기 제육', 'is_best': false},
      {'name': '오삼불고기', 'price': 8000, 'desc': '오징어와 삼겹살의 환상 조합', 'is_best': true},
      {'name': '낙지볶음', 'price': 8500, 'desc': '쫄깃 매콤한 낙지볶음', 'is_best': false},
      {'name': '제육 & 낙지볶음', 'price': 8000, 'desc': '제육과 낙지의 푸짐한 만남', 'is_best': true},
      {'name': '고추장콩나물불고기', 'price': 7000, 'desc': '아삭한 콩나물과 고추장불고기', 'is_best': false},
      {'name': '곰탕', 'price': 7500, 'desc': '진하고 뽀얀 사골 곰탕', 'is_best': false},
      {'name': '떡만두국', 'price': 7500, 'desc': '왕만두와 쫄깃한 떡', 'is_best': false},
      {'name': '냉만두국', 'price': 7500, 'desc': '시원한 냉 육수 만두국', 'is_best': false},
      {'name': '묵 국수/밥', 'price': 7500, 'desc': '시원 상큼한 도토리묵 사발', 'is_best': false},
      {'name': '만두 (사이드)', 'price': 3500, 'desc': '따끈따끈 찐만두', 'is_best': false},
      {'name': '음료', 'price': 1500, 'desc': '탄산음료', 'is_best': false},
    ],
    '포한끼(베트남쌀국수)': [
      {'name': '양지쌀국수', 'price': 6900, 'desc': '진한 소고기 육수 오리지널 쌀국수', 'is_best': true},
      {'name': '초계냉쌀국수', 'price': 7500, 'desc': '시원 새콤한 닭가슴살 냉쌀국수', 'is_best': false},
      {'name': '돼지불백비빔쌀국수', 'price': 8500, 'desc': '숯불돼지불백 비빔 쌀국수 (분짜스타일)', 'is_best': true},
      {'name': '매운우삼겹쌀국수', 'price': 8900, 'desc': '얼큰 칼칼한 우삼겹 쌀국수', 'is_best': true},
      {'name': '우삼겹덮밥 미니쌀국수SET', 'price': 8900, 'desc': '우삼겹덮밥 + 미니 양지쌀국수', 'is_best': true},
      {'name': '숯불돼지불고기SET', 'price': 10000, 'desc': '숯불불고기 + 미니쌀국수 세트', 'is_best': false},
      {'name': '쌀국주먹밥 2ps SET', 'price': 8900, 'desc': '양지쌀국수 + 참치주먹밥 2개', 'is_best': true},
      {'name': '수제고추장불고기덮밥SET', 'price': 8900, 'desc': '고추장불고기덮밥 + 미니쌀국수', 'is_best': false},
      {'name': '소고기볶음밥', 'price': 7500, 'desc': '고소한 소고기 야채 볶음밥', 'is_best': false},
      {'name': '우삼겹김치볶음밥', 'price': 7500, 'desc': '우삼겹 묵은지 볶음밥', 'is_best': false},
      {'name': '파인애플 볶음밥', 'price': 7500, 'desc': '달콤 상큼한 동남아식 볶음밥', 'is_best': false},
      {'name': '베트남돼지불고기덮밥', 'price': 8500, 'desc': '피시소스 양념 돼지불고기덮밥', 'is_best': false},
      {'name': '우삼겹덮밥', 'price': 8500, 'desc': '단짠 우삼겹 듬뿍 덮밥', 'is_best': false},
      {'name': '수제고추장불고기덮밥', 'price': 8500, 'desc': '매콤한 수제 불고기덮밥', 'is_best': false},
      {'name': '해산물팟타이', 'price': 8500, 'desc': '오징어·새우 볶음 쌀국수', 'is_best': true},
      {'name': '사천볶음쌀국수', 'price': 8500, 'desc': '매콤한 사천식 해물 볶음면', 'is_best': false},
    ],
    '한우사골마라탕': [
      {'name': '마라탕', 'price': 6900, 'desc': '진한 한우사골 육수의 얼큰 마라탕', 'is_best': true},
      {'name': '마라샹궈(+밥)', 'price': 8900, 'desc': '알싸한 불맛 마라볶음 + 공기밥', 'is_best': true},
      {'name': '상하이소고기볶음(+밥)', 'price': 8500, 'desc': '상하이 특제 소스 소고기볶음', 'is_best': false},
      {'name': '중화제육볶음(+밥)', 'price': 8000, 'desc': '중화풍 불맛 제육볶음 + 밥', 'is_best': true},
      {'name': '중화짜장 새우볶음밥', 'price': 7500, 'desc': '통새우 볶음밥과 짜장소스', 'is_best': false},
      {'name': '중화짜장 게살볶음밥', 'price': 7500, 'desc': '게살 볶음밥과 짜장소스', 'is_best': false},
      {'name': '짜장면', 'price': 7000, 'desc': '달콤 고소한 중화 짜장면', 'is_best': true},
      {'name': '짜장밥', 'price': 6900, 'desc': '든든한 짜장밥 + 계란', 'is_best': false},
      {'name': '중화냉면 + 꿔바로우(2개)', 'price': 8000, 'desc': '시원한 중화냉면 세트', 'is_best': true},
      {'name': '꿔바로우 소 (5~6p)', 'price': 5000, 'desc': '바삭 쫄깃한 찹쌀 탕수육', 'is_best': true},
      {'name': '꿔바로우 대 (10p)', 'price': 10000, 'desc': '푸짐한 찹쌀 꿔바로우', 'is_best': false},
      {'name': '멘보샤 (5p)', 'price': 6900, 'desc': '바삭한 식빵 속 새우살 튀김', 'is_best': true},
      {'name': '새우튀김 (3p)', 'price': 3000, 'desc': '바삭 왕새우튀김', 'is_best': false},
      {'name': '빙홍차', 'price': 2700, 'desc': '달콤 시원한 중국 명품 아이스티', 'is_best': false},
      {'name': '콜라', 'price': 1500, 'desc': '시원한 캔콜라', 'is_best': false},
      {'name': '밥추가', 'price': 800, 'desc': '공기밥 추가', 'is_best': false},
    ],
  };

  // 엘림2관 멀베리 상시 인기 메뉴 6종
  final List<Map<String, dynamic>> _mulberryPopularMenus = const [
    {'name': '뚝배기 소불고기', 'price': 6000, 'desc': '달콤 짭조름한 소불고기 뚝배기 (밥+반찬)'},
    {'name': '치즈 닭갈비 덮밥', 'price': 5800, 'desc': '매콤한 닭갈비에 고소한 모짜렐라 치즈'},
    {'name': '뚝배기 날치알밥', 'price': 5500, 'desc': '톡톡 터지는 날치알과 김가루, 단무지'},
    {'name': '추억의 옛날도시락', 'price': 4800, 'desc': '분홍소시지 + 볶음김치 + 계란후라이'},
    {'name': '등심 돈까스마요', 'price': 5200, 'desc': '바삭 돈까스 조각과 특제 마요소스'},
    {'name': '김치 치즈 볶음밥', 'price': 5200, 'desc': '매콤한 김치볶음밥에 눈꽃 치즈 토핑'},
  ];

  // 남서울대학교 주요 건물 데이터베이스 (캠퍼스 맵 좌표 포함)
  final List<CampusBuilding> _buildings = const [
    CampusBuilding(
      id: '01',
      name: '공학1관 (1호관)',
      category: '공학관',
      description: '지능정보통신공학과, 전자공학과, 컴퓨터소프트웨어학과 실습실 및 교수 연구실',
      floors: [
        '1F: 전공 세미나실, 기초회로실습실, 로비 복합출력기',
        '2F: 통신프로토콜실습실, 하드웨어설계실',
        '3F: 지능정보통신공학과 전공강의실 (01301~01315)',
        '4F: 교수연구실, 대학원 세미나실',
      ],
      amenities: ['무인프린트존', '학생휴게실', '학과사무실'],
      icon: Icons.memory_rounded,
      mapX: 440,
      mapY: 645,
    ),
    CampusBuilding(
      id: '02',
      name: '공학2관 (2호관)',
      category: '공학관',
      description: 'AI실습실, 소프트웨어 캡스톤디자인실, 정보보안 연구실',
      floors: [
        '1F: 미래혁신 오픈랩, 컴퓨터실습실',
        '2F: 캡스톤디자인 프로젝트룸',
        '3F: VR/AR 첨단미디어실습실',
        '4F: ICT 융합연구센터',
      ],
      amenities: ['프로젝트 회의실', '자판기', '사물함'],
      icon: Icons.developer_board_rounded,
      mapX: 280,
      mapY: 650,
    ),
    CampusBuilding(
      id: '03',
      name: '상경학관 (3호관)',
      category: '학관',
      description: '경영학과, 국제통상학과, 유통마케팅학과 전공 강의실',
      floors: ['1F~4F: 전공 강의실, 학생회실, 세미나룸'],
      amenities: ['복사실', '휴게라운지'],
      icon: Icons.business_center_rounded,
      mapX: 490,
      mapY: 575,
    ),
    CampusBuilding(
      id: '07',
      name: '조형학관 (7호관)',
      category: '학관',
      description: '시각디자인학과, 유리조형디자인학과, 영상예술디자인학과 실습실',
      floors: ['1F~5F: 디자인 스튜디오, 전시장, 가마실, 그래픽랩'],
      amenities: ['아트갤러리', '모형제작실'],
      icon: Icons.palette_rounded,
      mapX: 580,
      mapY: 495,
    ),
    CampusBuilding(
      id: '08',
      name: '학생복지회관 (8호관)',
      category: '복지시설',
      description: '학생식당(1~2F), CU편의점, 보건진료실, 총학생회실, 신한은행 ATM',
      floors: [
        'B1F: 동아리방, 학생자치기구실',
        '1F: 학생식당 푸드코트, CU편의점, 우체국취급소, 신한은행 ATM, 서점',
        '2F: 교직원/학생식당, 보건진료실, 학생상담센터',
        '3F: 총학생회, 대의원회실, 동아리연합회',
      ],
      amenities: ['학생식당', '보건진료실', 'CU편의점', 'ATM', '우체국', '서점'],
      icon: Icons.restaurant_rounded,
      mapX: 415,
      mapY: 310,
    ),
    CampusBuilding(
      id: '09',
      name: '성암기념중앙도서관 (9호관)',
      category: '도서관/체육',
      description: '자유열람실(1~3열람실), 일반자료실, 디지털정보실, 그룹스터디룸',
      floors: [
        '1F: 안내데스크, 북카페, 제1열람실(일반학습), 무인반납기',
        '2F: 제2열람실(노트북/자료실), 디지털정보검색실',
        '3F: 제3열람실(집중학습), 인문/사회과학 자료실',
        '4F: 자연과학/공학 기술자료실, 그룹스터디룸',
      ],
      amenities: ['무인복사/프린트존', '카페테리아', '스터디룸', '휴게실'],
      icon: Icons.local_library_rounded,
      mapX: 395,
      mapY: 455,
    ),
    CampusBuilding(
      id: '10',
      name: '인문사회학관 (10호관)',
      category: '학관',
      description: '인문사회계열 학과 전공 강의동 및 교수 연구실',
      floors: ['1F~4F: 인문사회 전공 강의실, 과사무실, 세미나룸'],
      amenities: ['휴게라운지', '자판기', '사물함'],
      icon: Icons.menu_book_rounded,
      mapX: 565,
      mapY: 425,
    ),
    CampusBuilding(
      id: '11',
      name: '지식정보관 (11호관)',
      category: '학관',
      description: '컴퓨터 실습실, 대형 계단식 강의실, 첨단 미디어 강의실',
      floors: ['1F~4F: 대형 멀티미디어 강의실, PC실습실, 소프트웨어랩'],
      amenities: ['컴퓨터실습실', '복사실'],
      icon: Icons.devices_rounded,
      mapX: 560,
      mapY: 230,
    ),
    CampusBuilding(
      id: '12',
      name: '21세기개발관 (12호관)',
      category: '행정/학관',
      description: '교무처, 입학처, 글로벌어학원, 종합민원센터',
      floors: [
        '1F: 종합행정실, 글로벌어학센터, 신한은행',
        '2F~4F: 스마트 강의실, 세미나룸',
      ],
      amenities: ['행정실', '신한은행', '어학원'],
      icon: Icons.apartment_rounded,
      mapX: 550,
      mapY: 320,
    ),
    CampusBuilding(
      id: '14',
      name: '성암체육관 (14호관)',
      category: '도서관/체육',
      description: '대강당, 피트니스센터, 실내수영장, 무용실, 실내 대형 주경기장',
      floors: [
        'B1F: 실내수영장, 라커룸, 샤워실',
        '1F: 피트니스센터, 체력단련실, 종합안내실',
        '2F: 실내 농구·배구 대형 주경기장, 대강당',
      ],
      amenities: ['수영장', '헬스장', '주경기장'],
      icon: Icons.fitness_center_rounded,
      mapX: 810,
      mapY: 335,
    ),
    CampusBuilding(
      id: '16',
      name: '보건의료학관 (16호관)',
      category: '학관',
      description: '간호학과, 물리치료학과, 임상병리학과, 응급구조학과 전용 학관 (16419 강의실 위치)',
      floors: [
        '1F: 시뮬레이션 임상센터, 기초의학실습실',
        '2F~4F: 학과별 전용 강의실(16401~16425) 및 실습실',
        '5F: 간호학술정보실, 국가고시 준비실',
      ],
      amenities: ['임상실습실', '국시실', '라운지'],
      icon: Icons.local_hospital_rounded,
      mapX: 600,
      mapY: 580,
    ),
    CampusBuilding(
      id: '21',
      name: '본관',
      category: '행정',
      description: '남서울대학교 본관, 총장실, 기획처, 법인사무국',
      floors: [
        '1F: 안내실, 접견실',
        '2F~3F: 총장실, 기획처, 대회의실',
      ],
      amenities: ['종합안내', '총장실'],
      icon: Icons.account_balance_rounded,
      mapX: 360,
      mapY: 650,
    ),
    CampusBuilding(
      id: 'BUS',
      name: '버스·셔틀 승차장',
      category: '정문/교통',
      description: '성환역 무료 셔틀버스 및 수도권 직통 통학버스 승하차장',
      floors: [
        '성환역 셔틀: 성환역 1번 출구 ⇄ 남서울대 무료 상시 운행 (피크 3~6분)',
        '직통 통학버스: 서울·인천·수도권 주요 거점 직통 운행',
      ],
      amenities: ['셔틀 승차장', '버스 매표소', '학생 쉼터'],
      icon: Icons.directions_bus_rounded,
      mapX: 285,
      mapY: 290,
    ),
  ];

  // 5자리 강의실 번호 스마트 파싱 (예: 16419 -> 16호관 4층 19호)
  Map<String, String>? _parseRoomCode(String query) {
    final clean = query.trim().replaceAll('호', '').replaceAll('관', '');
    if (RegExp(r'^\d{5}$').hasMatch(clean)) {
      final bldg = clean.substring(0, 2);
      final floor = clean.substring(2, 3);
      final room = clean.substring(3, 5);
      return {'bldg': bldg, 'floor': floor, 'room': room};
    } else if (RegExp(r'^\d{4}$').hasMatch(clean)) {
      final bldg = clean.substring(0, 1).padLeft(2, '0');
      final floor = clean.substring(1, 2);
      final room = clean.substring(2, 4);
      return {'bldg': bldg, 'floor': floor, 'room': room};
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final parsed = _parseRoomCode(_searchQuery);
    CampusBuilding? parsedBuilding;
    if (parsed != null) {
      try {
        parsedBuilding = _buildings.firstWhere((b) => b.id == parsed['bldg']);
      } catch (_) {
        parsedBuilding = null;
      }
    }

    final filteredBuildings = _buildings.where((b) {
      if (_selectedCategory != '전체' && b.category != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return b.name.toLowerCase().contains(q) ||
          b.id.contains(q) ||
          b.description.toLowerCase().contains(q) ||
          b.amenities.any((a) => a.toLowerCase().contains(q));
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. 🍱 [실시간] 오늘의 학생식당 & 카페테리아 위젯 (맨 최상단 배치!)
          _buildCafeteriaSection(),

          const SizedBox(height: 16),

          // 2. 🚌 [실시간] 성환역 ⇄ 남서울대 셔틀버스 운행 위젯
          _buildShuttleBusSection(),

          const SizedBox(height: 16),

          // 3. 📚 [실시간] 성암기념중앙도서관(9호관) 좌석 현황 위젯 (버스 바로 밑 배치!)
          _buildLibrarySection(),

          const SizedBox(height: 16),

          // 4. 🔍 [스마트 검색바] 5자리 강의실 & 건물 실시간 검색
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: '5자리 강의실(예: 16419) 또는 시설 검색...',
                hintStyle: const TextStyle(fontSize: 13.5, color: Colors.grey),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF003B70)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),

          // 3-1. 5자리 강의실 해석 결과 배너 (입력 시 실시간 표출)
          if (parsed != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF003B70).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF003B70).withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFF003B70),
                    child: Icon(Icons.pin_drop_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '강의실 [$_searchQuery] 위치 분석 완료!',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF003B70),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${parsedBuilding?.name ?? "${parsed['bldg']}호관"}  ➔  ${parsed['floor']}층 ${parsed['room']}호',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  if (parsedBuilding != null)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003B70),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        textStyle: const TextStyle(fontSize: 11.5),
                      ),
                      onPressed: () => _showBuildingDetail(parsedBuilding!),
                      child: const Text('건물 안내'),
                    ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // 4. 🔍 [강의실 스마트 가이드] 남서울대 강의실 스마트 위치 찾기 & 23개 학과사무실
          _buildClassroomFinderSection(parsedBuilding, parsed),

          const SizedBox(height: 16),

          // 5. 🎓 [신규 탑재] 전교생 데이터 허브 (장학금 15종 & 학과/행정 전화번호부)
          _buildCampusInfoHubCards(),

          const SizedBox(height: 16),

          // 6. 🏥 학생 복지 및 편의시설 퀵 안내 카드
          _buildWelfareSection(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // [위젯 1] 학생식당 & 멀베리 오늘의 학식 카드
  // --------------------------------------------------------------------------
  // --------------------------------------------------------------------------
  // [위젯 1] 학생식당 & 멀베리 오늘의 학식 카드 (요일별 실시간 식단표)
  // --------------------------------------------------------------------------
  Widget _buildCafeteriaSection() {
    final Map<String, dynamic> daysData = _weeklyMealData?['days'] ?? {
      '월': {
        'date': '10.05(월) [오늘]',
        'corner1_foodcourt': {
          'name': '1층 푸드코트',
          'hours': '10:30 ~ 19:00',
          'items': [
            {'name': '수제등심돈까스', 'price': 5500, 'is_best': true, 'kcal': 780},
            {'name': '직화제육덮밥', 'price': 5000, 'is_best': true, 'kcal': 650},
            {'name': '치킨마요덮밥', 'price': 4800, 'is_best': false, 'kcal': 610},
            {'name': '치즈라면 + 공기밥', 'price': 3800, 'is_best': false, 'kcal': 550}
          ]
        },
        'corner2_korean': {
          'name': '2층 백반/찌개 (오늘의 일품)',
          'hours': '11:30 ~ 14:00 (중식)',
          'main_dish': '차돌된장찌개백반 & 매콤돈육제육볶음',
          'price': 5500,
          'kcal': 820,
          'side_dishes': ['계란말이', '미역줄기볶음', '깍두기', '조미김']
        },
        'corner3_mulberry': {
          'name': '엘림2관 멀베리',
          'breakfast': {
            'title': '⭐ 천원의 아침밥 (1,000원)',
            'hours': '08:20 ~ 09:30',
            'menu': '소고기미역국 · 햄구이 · 계란후라이 · 포기김치',
            'note': '선착순 100명 한정 (학생증/페이코)'
          },
          'lunch': {
            'title': '멀베리 중·석식 특선',
            'hours': '11:30 ~ 19:00',
            'menu': '뚝배기소불고기(6,000원) · 치즈닭갈비덮밥(5,800원)'
          }
        },
        'corner4_faculty': {
          'name': '3층 교직원식당',
          'hours': '11:30 ~ 13:30 (중식)',
          'main_dish': '특선 소불고기전골 & 쌈채소 (자율배식)',
          'price': 6500,
          'kcal': 860,
          'side_dishes': ['해물동그랑땡', '도토리묵야채무침', '포기김치', '미역미소된장국', '수제식혜']
        }
      },
      '화': {
        'date': '10.06(화)',
        'corner1_foodcourt': {
          'name': '1층 푸드코트',
          'hours': '10:30 ~ 19:00',
          'items': [
            {'name': '모짜렐라치즈돈까스', 'price': 6000, 'is_best': true, 'kcal': 820},
            {'name': '오징어제육덮밥', 'price': 5200, 'is_best': true, 'kcal': 640},
            {'name': '참치마요비빔밥', 'price': 4800, 'is_best': false, 'kcal': 590},
            {'name': '떡만두라면 + 공기밥', 'price': 4000, 'is_best': false, 'kcal': 570}
          ]
        },
        'corner2_korean': {
          'name': '2층 백반/찌개 (오늘의 일품)',
          'hours': '11:30 ~ 14:00 (중식)',
          'main_dish': '얼큰순두부찌개 & 언양식바싹불고기',
          'price': 5500,
          'kcal': 790,
          'side_dishes': ['어묵야채볶음', '콩나물무침', '열무김치', '요구르트']
        },
        'corner3_mulberry': {
          'name': '엘림2관 멀베리',
          'breakfast': {
            'title': '⭐ 천원의 아침밥 (1,000원)',
            'hours': '08:20 ~ 09:30',
            'menu': '콩나물황태해장국 · 떡갈비구이 · 조미김 · 깍두기',
            'note': '선착순 100명 한정 (학생증/페이코)'
          },
          'lunch': {
            'title': '멀베리 중·석식 특선',
            'hours': '11:30 ~ 19:00',
            'menu': '우삼겹된장찌개(5,800원) · 가츠동(5,800원)'
          }
        },
        'corner4_faculty': {
          'name': '3층 교직원식당',
          'hours': '11:30 ~ 13:30 (중식)',
          'main_dish': '매콤 춘천닭갈비 & 온두부김치 (자율배식)',
          'price': 6500,
          'kcal': 840,
          'side_dishes': ['잡채', '오이부추무침', '열무김치', '맑은콩나물국', '매실차']
        }
      },
      '수': {
        'date': '10.07(수)',
        'corner1_foodcourt': {
          'name': '1층 푸드코트',
          'hours': '10:30 ~ 19:00',
          'items': [
            {'name': '일본식 카레돈까스', 'price': 5800, 'is_best': true, 'kcal': 800},
            {'name': '김치제육덮밥', 'price': 5000, 'is_best': true, 'kcal': 660},
            {'name': '돈코츠라멘', 'price': 5500, 'is_best': false, 'kcal': 620},
            {'name': '신라면 + 김밥세트', 'price': 4500, 'is_best': false, 'kcal': 580}
          ]
        },
        'corner2_korean': {
          'name': '2층 백반/찌개 (오늘의 일품)',
          'hours': '11:30 ~ 14:00 (중식)',
          'main_dish': '뚝배기닭볶음탕 & 참치김치찌개',
          'price': 5500,
          'kcal': 850,
          'side_dishes': ['비엔나소시지볶음', '감자채조림', '오이소박이', '도시락김']
        },
        'corner3_mulberry': {
          'name': '엘림2관 멀베리',
          'breakfast': {
            'title': '⭐ 천원의 아침밥 (1,000원)',
            'hours': '08:20 ~ 09:30',
            'menu': '사골우거지장국 · 고기산적전 · 계란찜 · 겉절이',
            'note': '선착순 100명 한정 (학생증/페이코)'
          },
          'lunch': {
            'title': '멀베리 중·석식 특선',
            'hours': '11:30 ~ 19:00',
            'menu': '매콤낙지덮밥(6,200원) · 돈까스카레(6,000원)'
          }
        },
        'corner4_faculty': {
          'name': '3층 교직원식당',
          'hours': '11:30 ~ 13:30 (중식)',
          'main_dish': '수제 한방갈비탕 & 당면사리 (자율배식)',
          'price': 6500,
          'kcal': 890,
          'side_dishes': ['오징어초무침', '시금치나물', '석박지', '조미김', '오렌지주스']
        }
      },
      '목': {
        'date': '10.08(목)',
        'corner1_foodcourt': {
          'name': '1층 푸드코트',
          'hours': '10:30 ~ 19:00',
          'items': [
            {'name': '고구마치즈돈까스', 'price': 6200, 'is_best': true, 'kcal': 840},
            {'name': '불고기덮밥', 'price': 5200, 'is_best': true, 'kcal': 670},
            {'name': '스팸마요덮밥', 'price': 4800, 'is_best': false, 'kcal': 630},
            {'name': '해물짬뽕라면', 'price': 4200, 'is_best': false, 'kcal': 540}
          ]
        },
        'corner2_korean': {
          'name': '2층 백반/찌개 (오늘의 일품)',
          'hours': '11:30 ~ 14:00 (중식)',
          'main_dish': '뚝배기부대찌개 & 안동간장찜닭',
          'price': 5500,
          'kcal': 810,
          'side_dishes': ['야채고로케', '시금치나물', '포기김치', '단무지']
        },
        'corner3_mulberry': {
          'name': '엘림2관 멀베리',
          'breakfast': {
            'title': '⭐ 천원의 아침밥 (1,000원)',
            'hours': '08:20 ~ 09:30',
            'menu': '얼큰소고기뭇국 · 스크램블에그 · 비엔나소시지 · 깍두기',
            'note': '선착순 100명 한정 (학생증/페이코)'
          },
          'lunch': {
            'title': '멀베리 중·석식 특선',
            'hours': '11:30 ~ 19:00',
            'menu': '차돌우삼겹덮밥(6,000원) · 뚝배기알탕(6,500원)'
          }
        },
        'corner4_faculty': {
          'name': '3층 교직원식당',
          'hours': '11:30 ~ 13:30 (중식)',
          'main_dish': '버섯소고기전골 & 단호박돼지갈비찜 (자율배식)',
          'price': 6500,
          'kcal': 870,
          'side_dishes': ['계란찜', '가지나물볶음', '배추김치', '꽃게된장찌개', '수정과']
        }
      },
      '금': {
        'date': '10.09(금)',
        'corner1_foodcourt': {
          'name': '1층 푸드코트',
          'hours': '10:30 ~ 18:00',
          'items': [
            {'name': '수제왕돈까스', 'price': 6000, 'is_best': true, 'kcal': 890},
            {'name': '마파두부덮밥', 'price': 4800, 'is_best': false, 'kcal': 600},
            {'name': '비빔만두 + 쫄면', 'price': 4800, 'is_best': true, 'kcal': 590},
            {'name': '만두라면 + 밥', 'price': 4000, 'is_best': false, 'kcal': 530}
          ]
        },
        'corner2_korean': {
          'name': '2층 백반/찌개 (오늘의 일품)',
          'hours': '11:30 ~ 13:30 (중식)',
          'main_dish': '돼지고기김치찌개 & 돈육간장불고기',
          'price': 5500,
          'kcal': 830,
          'side_dishes': ['만두튀김', '마카로니콘샐러드', '겉절이', '야쿠르트']
        },
        'corner3_mulberry': {
          'name': '엘림2관 멀베리',
          'breakfast': {
            'title': '⭐ 천원의 아침밥 (1,000원)',
            'hours': '08:20 ~ 09:30',
            'menu': '북어포해장국 · 분홍소시지전 · 조미김 · 포기김치',
            'note': '선착순 100명 한정 (학생증/페이코)'
          },
          'lunch': {
            'title': '멀베리 중·석식 특선',
            'hours': '11:30 ~ 18:00',
            'menu': '뚝배기김치나베(6,000원) · 제육비빔밥(5,500원)'
          }
        },
        'corner4_faculty': {
          'name': '3층 교직원식당',
          'hours': '11:30 ~ 13:30 (중식)',
          'main_dish': '특선 낙지제육볶음 & 잔치국수 (자율배식)',
          'price': 6500,
          'kcal': 850,
          'side_dishes': ['해물해초샐러드', '고구마맛탕', '겉절이', '유부장국', '요구르트']
        }
      }
    };

    final currentDay = daysData[_selectedMealDay] ?? daysData['월']!;
    final c3 = currentDay['corner3_mulberry'] as Map<String, dynamic>;
    final c4 = (currentDay['corner4_faculty'] ?? {
      'name': '3층 교직원식당',
      'hours': '11:30 ~ 13:30',
      'main_dish': '오늘의 뷔페식 한식 특선 (자율배식)',
      'price': 6500,
      'side_dishes': ['특선메인', '계절나물', '포기김치', '국/찌개', '후식음료'],
    }) as Map<String, dynamic>;

    String formatPrice(dynamic price) {
      if (price == null) return '';
      final s = price.toString();
      return '${s.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원';
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1.5,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.restaurant_menu_rounded, color: Color(0xFF003B70), size: 22),
                    SizedBox(width: 8),
                    Text('남서울대 학식 & 푸드코트',
                        style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF003B70).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '키오스크 & 직영식당',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003B70),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 층별 식당 탭 선택 (1층, 2층, 3층, 멀베리)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  {'id': '1층', 'label': '1층 푸드코트 (71종)', 'icon': Icons.storefront_rounded},
                  {'id': '2층', 'label': '2층 학생식당 (64종)', 'icon': Icons.soup_kitchen_rounded},
                  {'id': '3층', 'label': '3층 교직원식당 (뷔페)', 'icon': Icons.dining_rounded},
                  {'id': '멀베리', 'label': '엘림2관 멀베리', 'icon': Icons.breakfast_dining_rounded},
                ].map((fl) {
                  final isSel = _selectedCafeteriaFloor == fl['id'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      avatar: Icon(
                        fl['icon'] as IconData,
                        size: 16,
                        color: isSel ? Colors.white : const Color(0xFF003B70),
                      ),
                      label: Text(fl['label'] as String),
                      selected: isSel,
                      selectedColor: const Color(0xFF003B70),
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : Colors.black87,
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) => setState(() => _selectedCafeteriaFloor = fl['id'] as String),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // [1층 푸드코트 화면 (컴팩트)]
            if (_selectedCafeteriaFloor == '1층') ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time_rounded, color: Colors.blue.shade800, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '학생회관 1층 | 10:00 ~ 18:30 (키오스크 상시 주문 즉시 조리)',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 4개 코너 브랜드 안내 칩
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  {'icon': '🍔', 'name': '버거운베어(16종)'},
                  {'icon': '🍛', 'name': '청년한끼(23종)'},
                  {'icon': '🍱', 'name': '쑝쑝돈까스(16종)'},
                  {'icon': '🍲', 'name': '태산김치찜(16종)'},
                ].map((c) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      '${c['icon']} ${c['name']}',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),

              // 대표 인기 메뉴 미리보기 4종
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.restaurant_menu_rounded, color: Color(0xFF003B70), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '코너별 메뉴 샘플 (4개 코너)',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildPreviewMenuItem('🍔 불새버거', '6,400원', '버거운베어 · 세트 8,700원'),
                    const SizedBox(height: 6),
                    _buildPreviewMenuItem('🍛 치킨 데리 마요 덮밥', '6,900원', '청년한끼 · 데리마요 소스'),
                    const SizedBox(height: 6),
                    _buildPreviewMenuItem('🍱 쑝쑝돈까스', '8,400원', '쑝쑝돈까스 · 수제 등심 돈까스'),
                    const SizedBox(height: 6),
                    _buildPreviewMenuItem('🍲 태산 돼지김치찜 백반', '7,500원', '태산김치찜 · 묵은지 돼지김치찜'),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 1층 전체보기 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003B70),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: () => _showFloorFullMenuModal('1층'),
                  icon: const Icon(Icons.list_alt_rounded, size: 17),
                  label: const Text(
                    '1층 푸드코트 전체 메뉴 & 가격표 전체보기 (71종) 📋',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                  ),
                ),
              ),
            ],

            // [2층 학생식당 화면 (컴팩트)]
            if (_selectedCafeteriaFloor == '2층') ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.soup_kitchen_rounded, color: Colors.teal.shade800, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '학생회관 2층 | 중식 11:30~14:00 · 석식 17:00~18:30 (뚝배기·국밥·직화)',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 4개 코너 브랜드 안내 칩
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  {'icon': '🍲', 'name': '언덕뜰소반(16종)'},
                  {'icon': '🥘', 'name': '부대통령(16종)'},
                  {'icon': '🍜', 'name': '포한끼(16종)'},
                  {'icon': '🌶️', 'name': '한우사골마라탕(16종)'},
                ].map((c) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.teal.shade200),
                    ),
                    child: Text(
                      '${c['icon']} ${c['name']}',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),

              // 대표 인기 메뉴 미리보기 4종
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.restaurant_menu_rounded, color: Colors.teal.shade800, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '코너별 메뉴 샘플 (4개 코너)',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildPreviewMenuItem('🍲 뚝배기 불고기', '8,900원', '언덕뜰소반 · 소불고기 뚝배기'),
                    const SizedBox(height: 6),
                    _buildPreviewMenuItem('🥘 부대찌개 (치즈/라면)', '7,000원', '부대통령 · 햄·소시지 부대찌개'),
                    const SizedBox(height: 6),
                    _buildPreviewMenuItem('🍜 양지쌀국수', '6,900원', '포한끼 · 소고기 육수 쌀국수'),
                    const SizedBox(height: 6),
                    _buildPreviewMenuItem('🌶️ 한우사골 마라탕', '6,900원', '한우사골마라탕 · 사골 육수 마라탕'),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 2층 전체보기 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: () => _showFloorFullMenuModal('2층'),
                  icon: const Icon(Icons.list_alt_rounded, size: 17),
                  label: const Text(
                    '2층 학생식당 전체 메뉴 & 가격표 전체보기 (64종) 📋',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                  ),
                ),
              ),
            ],

            // [3층 교직원식당 화면]
            if (_selectedCafeteriaFloor == '3층') ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.dining_rounded, color: Colors.purple.shade800, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '학생회관 3층 | 11:30 ~ 13:30 (학생 & 교직원 모두 이용 가능)',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.purple.shade900),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade700,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('6,500원', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 요일 선택 (월~금)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    {'id': '월', 'label': '월(오늘)'},
                    {'id': '화', 'label': '화요일'},
                    {'id': '수', 'label': '수요일'},
                    {'id': '목', 'label': '목요일'},
                    {'id': '금', 'label': '금요일'},
                  ].map((d) {
                    final isSel = _selectedMealDay == d['id'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(d['label']!),
                        selected: isSel,
                        selectedColor: Colors.purple.shade700,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : Colors.black87,
                          fontSize: 12,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (_) => setState(() => _selectedMealDay = d['id']!),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),

              // 뷔페 특선 상세 카드
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.eco_rounded, color: Colors.purple, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '${currentDay['date']} 자율배식 한식 뷔페 특선',
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.purple.shade900),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      c4['main_dish'].toString(),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: (c4['side_dishes'] as List<dynamic>).map((sd) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.purple.shade100),
                          ),
                          child: Text(sd.toString(), style: TextStyle(fontSize: 11, color: Colors.grey.shade800)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '※ 영양사가 직접 구성한 영양 균형 뷔페 식단으로, 원하는 만큼 자율 배식 가능합니다.',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],

            // [멀베리 화면]
            if (_selectedCafeteriaFloor == '멀베리') ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.breakfast_dining_rounded, color: Colors.amber.shade900, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '엘림생활관 2관 멀베리 | 천원의 아침밥 & 기숙사 식당',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 요일 선택 (월~금)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    {'id': '월', 'label': '월(오늘)'},
                    {'id': '화', 'label': '화요일'},
                    {'id': '수', 'label': '수요일'},
                    {'id': '목', 'label': '목요일'},
                    {'id': '금', 'label': '금요일'},
                  ].map((d) {
                    final isSel = _selectedMealDay == d['id'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(d['label']!),
                        selected: isSel,
                        selectedColor: Colors.amber.shade800,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : Colors.black87,
                          fontSize: 12,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (_) => setState(() => _selectedMealDay = d['id']!),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),

              // 천원의 아침밥 카드
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.wb_sunny_rounded, color: Colors.orange, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              c3['breakfast']['title'].toString(),
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade700,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('1,000원', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      c3['breakfast']['menu'].toString(),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '운영시간: ${c3['breakfast']['hours']} (남서울대 재학생 한정 / 선착순 100명)',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // 중·석식 메뉴 카드
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.dinner_dining_rounded, color: Color(0xFF003B70), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('중·석식 특선 (${c3['lunch']['hours']})',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF003B70))),
                          const SizedBox(height: 2),
                          Text(c3['lunch']['menu'].toString(),
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.black87)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 멀베리 상시 식당 메뉴
              const Text('멀베리 상시 식당 메뉴', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Column(
                children: _mulberryPopularMenus.map((m) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m['name'].toString(), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                            if (m['desc'] != null)
                              Text(m['desc'].toString(), style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600)),
                          ],
                        ),
                        Text(formatPrice(m['price']), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF003B70))),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 12),

            // 1주일 전체 식단표 보기 버튼
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF003B70)),
                  foregroundColor: const Color(0xFF003B70),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _showWeeklyMenuModal(daysData),
                icon: const Icon(Icons.calendar_month_rounded, size: 17),
                label: const Text('1주일 주간식단표 전체보기 📋',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 대표 메뉴 미리보기 컴포넌트
  Widget _buildPreviewMenuItem(String title, String price, String sub) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              Text(
                sub,
                style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            price,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF003B70)),
          ),
        ),
      ],
    );
  }

  // 가격 천단위 콤마 포맷터
  String _formatPrice(dynamic price) {
    if (price == null) return '';
    final s = price.toString();
    return '${s.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원';
  }

  // 1층/2층 전체 메뉴 & 가격표 모달 팝업
  void _showFloorFullMenuModal(String floor) {
    final isFloor1 = floor == '1층';
    final menus = isFloor1 ? _floor1OfficialMenus : _floor2OfficialMenus;
    final totalCount = menus.values.fold<int>(0, (sum, list) => sum + list.length);
    final themeColor = isFloor1 ? const Color(0xFF003B70) : Colors.teal.shade800;

    String selectedCorner = '전체';

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
            final cornerNames = ['전체', ...menus.keys];

            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 6),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Modal Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: themeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isFloor1 ? Icons.storefront_rounded : Icons.soup_kitchen_rounded,
                              color: themeColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isFloor1
                                      ? '학생회관 1층 푸드코트 ($totalCount종)'
                                      : '학생회관 2층 학생식당 ($totalCount종)',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isFloor1
                                      ? '10:00 ~ 18:30 | 키오스크 상시 주문 즉시 조리'
                                      : '중식 11:30~14:00 · 석식 17:00~18:30 (뚝배기·국밥·직화)',
                                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    // Corner Selector Chips
                    Container(
                      color: Colors.grey.shade50,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: cornerNames.map((cName) {
                            final isSel = selectedCorner == cName;
                            final count = cName == '전체'
                                ? totalCount
                                : (menus[cName]?.length ?? 0);
                            final label = cName == '전체' ? '전체 ($count)' : '$cName ($count)';

                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: FilterChip(
                                label: Text(label),
                                selected: isSel,
                                selectedColor: themeColor.withValues(alpha: 0.15),
                                checkmarkColor: themeColor,
                                labelStyle: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                  color: isSel ? themeColor : Colors.black87,
                                ),
                                onSelected: (_) {
                                  setModalState(() {
                                    selectedCorner = cName;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    // Menu items list
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        children: [
                          for (final entry in menus.entries)
                            if (selectedCorner == '전체' || selectedCorner == entry.key) ...[
                              // Corner header
                              Container(
                                margin: const EdgeInsets.only(top: 8, bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: themeColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: themeColor.withValues(alpha: 0.2)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          isFloor1 ? Icons.fastfood_rounded : Icons.soup_kitchen_rounded,
                                          size: 16,
                                          color: themeColor,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          entry.key,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: themeColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${entry.value.length}개 메뉴',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Items in this corner
                              ...entry.value.map((item) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['name'].toString(),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            if (item['desc'] != null && (item['desc'] as String).isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                item['desc'].toString(),
                                                style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      Text(
                                        _formatPrice(item['price']),
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: themeColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 6),
                            ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  // 1주일 전체 식단표 모달 팝업
  void _showWeeklyMenuModal(Map<String, dynamic> daysData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
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
                  const Row(
                    children: [
                      Icon(Icons.restaurant_menu_rounded, color: Color(0xFF003B70), size: 22),
                      SizedBox(width: 8),
                      Text(
                        '남서울대 2026년 10월 1주차 주간식단표',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '학생복지회관 1·2·3층 & 엘림생활관2관 멀베리 공식 주간 식단',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const Divider(height: 24),
                  ...['월', '화', '수', '목', '금'].map((dKey) {
                    final d = daysData[dKey];
                    if (d == null) return const SizedBox.shrink();
                    final c1 = d['corner1_foodcourt'];
                    final c2 = d['corner2_korean'];
                    final c3 = d['corner3_mulberry'];
                    final c4 = d['corner4_faculty'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${d['date']} 식단',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF003B70)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('• [1층 푸드코트]: ${(c1['items'] as List<dynamic>).map((i) => "${i['name']}(${i['price']}원)").join(' · ')}', style: TextStyle(fontSize: 12, color: Colors.grey.shade800)),
                          const SizedBox(height: 4),
                          Text('• [2층 백반/찌개]: ${c2['main_dish']} (${c2['price']}원)', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          if (c4 != null) ...[
                            Text('• [3층 교직원식당]: ${c4['main_dish']} (${c4['price']}원)', style: TextStyle(fontSize: 12, color: Colors.purple.shade900, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                          ],
                          Text('• [멀베리 조식]: ${c3['breakfast']['menu']} (1,000원)', style: TextStyle(fontSize: 12, color: Colors.orange.shade900)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // --------------------------------------------------------------------------
  // [위젯 2] 성환역 ⇄ 남서울대 셔틀버스 안내 (정확한 시간표 반영)
  // --------------------------------------------------------------------------
  Widget _buildShuttleBusSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1.5,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.directions_bus_filled_rounded, color: Color(0xFF003B70), size: 20),
                    SizedBox(width: 8),
                    Text('성환역 ⇄ 학교 셔틀버스 시간표',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '전액 무료',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '순환 운행',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildBusInfoBox(
                    title: '성환역 ➔ 학교 (등교)',
                    desc: '성환역 1번 출구 (도솔신협 앞)',
                    badge: '첫차 08:00 / 피크 3~6분',
                    badgeColor: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildBusInfoBox(
                    title: '학교 ➔ 성환역 (하교)',
                    desc: '정문 통학버스장 / 12호관 앞',
                    badge: '피크 5~8분 / 막차 21:30',
                    badgeColor: Colors.indigo.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 시간대별 핵심 운행 요약 바
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 15, color: Color(0xFF003B70)),
                      SizedBox(width: 6),
                      Text('시간대별 공식 배차 기준 (월~금 운행)',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF003B70))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildScheduleBadge('등교 피크(08:20~10:30)', '3~6분 간격', Colors.blue.shade700),
                      _buildScheduleBadge('주간 평시(10:30~17:00)', '10~15분 간격', Colors.teal.shade700),
                      _buildScheduleBadge('하교 피크(17:00~18:30)', '5~8분 간격', Colors.orange.shade800),
                      _buildScheduleBadge('야간 정시(19:30~21:30)', '30분 간격 (막차 21:30)', Colors.indigo.shade800),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '※ 야간 정시 출발: 19:30 | 20:00 | 20:30 | 21:00 | 21:30 (금요일은 18:30 이후 단축 운행)',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF003B70)),
                  foregroundColor: const Color(0xFF003B70),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _showBusTimetableModal,
                icon: const Icon(Icons.table_chart_rounded, size: 18),
                label: const Text('통학·셔틀버스 전체 노선 & 상세 시간표 보기',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildBusInfoBox({
    required String title,
    required String desc,
    required String badge,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 2),
          Text(desc, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              badge,
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: badgeColor),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // [위젯 3] 중앙도서관 9호관 좌석 현황 (남서울대 SeatMate 실데이터 연동)
  // --------------------------------------------------------------------------
  Widget _buildLibrarySection() {
    final rooms = (_librarySeatData?['rooms'] as List<dynamic>?) ?? [
      {
        'code': 1,
        'name': '제1 자유열람실',
        'floor': '2층',
        'total': 357,
        'available': 354,
        'in_use': 0,
        'disabled': 3,
        'start_time': '07:00',
        'end_time': '23:00'
      },
      {
        'code': 2,
        'name': '제2 자유열람실',
        'floor': '2층',
        'total': 265,
        'available': 262,
        'in_use': 2,
        'disabled': 3,
        'start_time': '07:00',
        'end_time': '23:00'
      },
      {
        'code': 3,
        'name': '제3 자유열람실',
        'floor': '1층',
        'total': 324,
        'available': 324,
        'in_use': 0,
        'disabled': 0,
        'start_time': '07:00',
        'end_time': '23:00'
      }
    ];

    final totalSeats = _librarySeatData?['total_seats'] ?? 946;
    final availableSeats = _librarySeatData?['available_seats'] ?? 940;
    final inUseSeats = _librarySeatData?['in_use_seats'] ?? 2;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1.5,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.local_library_rounded, color: Color(0xFF003B70), size: 20),
                    SizedBox(width: 8),
                    Text('성암기념중앙도서관 (9호관) 좌석 현황',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '실시간 연동',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: _isLoadingSeats
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh_rounded, size: 18, color: Color(0xFF003B70)),
                      onPressed: _isLoadingSeats ? null : _loadLibrarySeats,
                      tooltip: '실시간 좌석 갱신',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 총 잔여 요약 배너
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF003B70).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '총 $totalSeats석 중 $availableSeats석 이용 가능',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003B70),
                    ),
                  ),
                  Text(
                    '현재 $inUseSeats명 열공 중 🔥',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 20),
            ...rooms.map((room) {
              final name = '${room['name']} (${room['floor']})';
              final total = (room['total'] as num?)?.toInt() ?? 100;
              final available = (room['available'] as num?)?.toInt() ?? 0;
              final inUse = (room['in_use'] as num?)?.toInt() ?? (total - available);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildSeatProgress(name, inUse, total),
              );
            }),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('운영시간: 07:00 ~ 23:00 (시험기간 24시간)',
                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
                InkWell(
                  onTap: () async {
                    final uri = Uri.parse('http://220.68.191.20/');
                    try {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } catch (_) {}
                  },
                  child: const Row(
                    children: [
                      Text(
                        'SeatMate 좌석배정 바로가기',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003B70),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.open_in_new_rounded, size: 12, color: Color(0xFF003B70)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatProgress(String name, int used, int total) {
    final remaining = total - used;
    final ratio = used / total;
    final color = ratio > 0.85
        ? Colors.red
        : (ratio > 0.65 ? Colors.orange : const Color(0xFF003B70));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            Text('잔여 $remaining석 / 총 $total석',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // [위젯 4] 건물 리스트 카드
  // --------------------------------------------------------------------------
  Widget _buildBuildingCard(CampusBuilding b) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      color: Colors.white,
      child: ListTile(
        onTap: () => _showBuildingDetail(b),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF003B70).withValues(alpha: 0.1),
          child: Icon(b.icon, color: const Color(0xFF003B70), size: 22),
        ),
        title: Row(
          children: [
            Text(b.name, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                b.category,
                style: TextStyle(fontSize: 10.5, color: Colors.grey.shade700),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            b.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // [위젯 5] 학생 복지 및 편의시설 퀵 그리드
  // --------------------------------------------------------------------------
  Widget _buildWelfareSection() {
    final items = [
      {
        'icon': Icons.bakery_dining_rounded,
        'name': '베이커리 (브래댄코)',
        'loc': '학생복지회관 B1층 8012호',
        'tel': '041-582-3850',
        'color': const Color(0xFFD97706),
      },
      {
        'icon': Icons.content_cut_rounded,
        'name': '미용실 (리안헤어)',
        'loc': '학생복지회관 B1층 8017호',
        'tel': '0507-1484-1915',
        'color': const Color(0xFFDB2777),
      },
      {
        'icon': Icons.local_laundry_service_rounded,
        'name': '세탁소 (크린토피아)',
        'loc': '학생복지회관 B1층 8016호',
        'tel': '041-587-3681',
        'color': const Color(0xFF2563EB),
      },
      {
        'icon': Icons.palette_rounded,
        'name': '화방문구 (누보아트)',
        'loc': '학생복지회관 B1층 8011호',
        'tel': '041-581-0990',
        'color': const Color(0xFF4F46E5),
      },
      {
        'icon': Icons.store_rounded,
        'name': 'CU편의점 (학생회관점)',
        'loc': '학생복지회관 B1층 8007호',
        'tel': '041-584-3860',
        'color': const Color(0xFF7C3AED),
      },
      {
        'icon': Icons.print_rounded,
        'name': '남서울출력 (복사실)',
        'loc': '학생복지회관 B1층 8010호',
        'tel': '041-585-2752',
        'color': const Color(0xFF0D9488),
      },
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1.5,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.storefront_rounded, color: Color(0xFF003B70), size: 20),
                    SizedBox(width: 8),
                    Text('남서울대 공식 편의·복지시설',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF003B70).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '홈페이지 공식 입점',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003B70),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: items.length,
              itemBuilder: (context, idx) {
                final item = items[idx];
                final color = item['color'] as Color;
                final tel = item['tel'] as String;

                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    if (tel.isNotEmpty) {
                      launchUrl(Uri.parse('tel:$tel'));
                    } else {
                      _showAllWelfareFacilitiesModal();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(item['icon'] as IconData, size: 20, color: color),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item['name'] as String,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 11.5),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['loc'] as String,
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: _showAllWelfareFacilitiesModal,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF003B70),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF003B70).withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.format_list_bulleted_rounded, size: 17, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      '남서울대 공식 편의시설 17개소 전체보기 ➔',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // [모달] 🏫 남서울대학교 공식 17개 편의·복지시설 전체보기 (메뉴 ID: 52 연동)
  // --------------------------------------------------------------------------
  void _showAllWelfareFacilitiesModal() {
    final facilities = [
      // 1. 식음료 & 카페
      {
        'category': '식음료·카페',
        'name': '베이커리 (브래댄코)',
        'bldg': '학생복지회관(8호관)',
        'room': 'B1층 8012호',
        'tel': '041-582-3850',
        'desc': '갓 구운 빵, 디저트, 샌드위치 전문 베이커리',
        'icon': Icons.bakery_dining_rounded,
        'color': const Color(0xFFD97706),
      },
      {
        'category': '식음료·카페',
        'name': '카페 (크레센도)',
        'bldg': '지식정보관(11호관)',
        'room': '4층 15401호',
        'tel': '041-585-2992',
        'desc': '원두커피, 에이드, 베이글 & 야외 테라스 라운지',
        'icon': Icons.local_cafe_rounded,
        'color': const Color(0xFF78350F),
      },
      {
        'category': '식음료·카페',
        'name': '카페 (그라찌에)',
        'bldg': '성암기념중앙도서관(9호관)',
        'room': '1층 9117호 (북카페)',
        'tel': '041-580-2043',
        'desc': '도서관 1층 라운지 북카페 & 스터디 음료',
        'icon': Icons.coffee_rounded,
        'color': const Color(0xFF92400E),
      },
      {
        'category': '식음료·카페',
        'name': '카페 (아이엔지)',
        'bldg': '학생복지회관(8호관)',
        'room': 'B1층 8017호',
        'tel': '041-580-2043',
        'desc': '학생회관 지하 휴식 라운지 & 테이크아웃 커피',
        'icon': Icons.emoji_food_beverage_rounded,
        'color': const Color(0xFFB45309),
      },
      {
        'category': '식음료·카페',
        'name': '학생식당 멀베리',
        'bldg': '엘림생활관 2관',
        'room': '1층',
        'tel': '041-582-3820',
        'desc': '천원의 아침밥(08:20~09:30), 뚝배기불고기, 분식',
        'icon': Icons.restaurant_rounded,
        'color': const Color(0xFFDC2626),
      },
      {
        'category': '식음료·카페',
        'name': '학생식당 푸드코트 (1·2·3층)',
        'bldg': '학생복지회관(8호관)',
        'room': '1층~3층',
        'tel': '010-8824-2662',
        'desc': '1층 수제돈까스·덮밥 / 2층 백반·찌개 / 3층 교직원식당',
        'icon': Icons.dinner_dining_rounded,
        'color': const Color(0xFFE11D48),
      },

      // 2. 생활 편의
      {
        'category': '생활편의',
        'name': 'CU편의점 (학생회관점)',
        'bldg': '학생복지회관(8호관)',
        'room': 'B1층 8007호',
        'tel': '041-584-3860',
        'desc': '간식, 삼각김밥, 음료, 생필품, 택배 픽업',
        'icon': Icons.store_rounded,
        'color': const Color(0xFF7C3AED),
      },
      {
        'category': '생활편의',
        'name': 'CU편의점 (엘림생활관점)',
        'bldg': '엘림생활관 1관',
        'room': '1층',
        'tel': '041-584-3860',
        'desc': '기숙사 사생 편의점 (야간 무인 운영)',
        'icon': Icons.store_rounded,
        'color': const Color(0xFF7C3AED),
      },
      {
        'category': '생활편의',
        'name': '미용실 (리안헤어 남서울대점)',
        'bldg': '학생복지회관(8호관)',
        'room': 'B1층 8017호',
        'tel': '0507-1484-1915',
        'desc': '헤어 커트, 펌, 염색 (재학생 할인 혜택)',
        'icon': Icons.content_cut_rounded,
        'color': const Color(0xFFDB2777),
      },
      {
        'category': '생활편의',
        'name': '세탁편의점 (크린토피아)',
        'bldg': '학생복지회관(8호관)',
        'room': 'B1층 8016호',
        'tel': '041-587-3681',
        'desc': '의류 세탁, 패딩/정장 드라이클리닝, 수선',
        'icon': Icons.local_laundry_service_rounded,
        'color': const Color(0xFF2563EB),
      },
      {
        'category': '생활편의',
        'name': '우체국 (우편취급소)',
        'bldg': '학생복지회관(8호관)',
        'room': 'B1층 8020호',
        'tel': '041-582-1919',
        'desc': '국내/국제 우편 발송, 소포/택배 접수, 등기',
        'icon': Icons.local_post_office_rounded,
        'color': const Color(0xFFEA580C),
      },
      {
        'category': '생활편의',
        'name': '보건진료실 (학생/교직원)',
        'bldg': '학생복지회관(8호관)',
        'room': '2층',
        'tel': '041-580-2090',
        'desc': '무료 일반의약품 지급, 응급처치, 안정실, 인바디',
        'icon': Icons.medical_services_rounded,
        'color': const Color(0xFFEF4444),
      },

      // 3. 학습 & 도서·문구
      {
        'category': '학습·출력',
        'name': '남서울출력 (복사/인쇄실)',
        'bldg': '학생복지회관(8호관)',
        'room': 'B1층 8010호',
        'tel': '041-585-2752',
        'desc': '과제물 대량 출력, 제본, 코팅, 전공 논문 인쇄',
        'icon': Icons.print_rounded,
        'color': const Color(0xFF0D9488),
      },
      {
        'category': '학습·출력',
        'name': '화방문구점 (누보아트)',
        'bldg': '학생복지회관(8호관)',
        'room': 'B1층 8011호',
        'tel': '041-581-0990',
        'desc': '디자인/조형 전공 전문 미술재료, 제도용품, 문구',
        'icon': Icons.palette_rounded,
        'color': const Color(0xFF4F46E5),
      },
      {
        'category': '학습·출력',
        'name': '남서울서점 (구내서점)',
        'bldg': '학생복지회관(8호관)',
        'room': 'B1층 8015호',
        'tel': '041-580-2405',
        'desc': '전공/교양 서적, 자격증 수험서, 도서 주문',
        'icon': Icons.menu_book_rounded,
        'color': const Color(0xFF475569),
      },

      // 4. 스포츠 & 기숙사
      {
        'category': '체육·기숙사',
        'name': '성암문화체육관',
        'bldg': '성암체육관(14호관)',
        'room': 'B1F~2F',
        'tel': '041-580-2570',
        'desc': '실내수영장, 피트니스 헬스장, 사우나(남/여탕 200평), 골프/스쿼시',
        'icon': Icons.fitness_center_rounded,
        'color': const Color(0xFF0284C7),
      },
      {
        'category': '체육·기숙사',
        'name': '엘림생활관 (기숙사 행정실)',
        'bldg': '엘림생활관 1·2관',
        'room': '행정실 (1층)',
        'tel': '041-580-2271',
        'desc': '기숙사 입사/퇴사, 호실 배정, 시설 관리',
        'icon': Icons.apartment_rounded,
        'color': const Color(0xFF16A34A),
      },
    ];

    String searchQuery = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final filtered = facilities.where((f) {
            final query = searchQuery.trim().toLowerCase();
            if (query.isEmpty) return true;
            return (f['name'] as String).toLowerCase().contains(query) ||
                (f['bldg'] as String).toLowerCase().contains(query) ||
                (f['room'] as String).toLowerCase().contains(query) ||
                (f['desc'] as String).toLowerCase().contains(query) ||
                (f['category'] as String).toLowerCase().contains(query);
          }).toList();

          return DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, scrollController) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 모달 헤더
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF003B70).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.storefront_rounded, color: Color(0xFF003B70), size: 22),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '남서울대 공식 편의·복지시설 (17개소)',
                                style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '학교 홈페이지(학생지원처) 공식 입점 매장 및 직통 연락처',
                                style: TextStyle(fontSize: 11.5, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 검색바
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '매장명, 위치 검색 (예: 빵집, 미용실, 세탁, 8011)',
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF003B70)),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () => setModalState(() => searchQuery = ''),
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF003B70), width: 1.5),
                        ),
                      ),
                      onChanged: (val) => setModalState(() => searchQuery = val),
                    ),
                  ),
                  const Divider(height: 20),

                  // 매장 목록 리스트
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                            child: Text(
                              '검색 결과가 없습니다.',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, idx) {
                              final f = filtered[idx];
                              final color = f['color'] as Color;
                              final icon = f['icon'] as IconData;
                              final tel = f['tel'] as String;

                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.grey.shade200),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(icon, color: color, size: 20),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      f['name'] as String,
                                                      style: const TextStyle(
                                                        fontSize: 14.5,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: color.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      f['category'] as String,
                                                      style: TextStyle(
                                                        fontSize: 10.5,
                                                        fontWeight: FontWeight.bold,
                                                        color: color,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                f['desc'] as String,
                                                style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF003B70)),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              '${f['bldg']} ${f['room']}',
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () => launchUrl(Uri.parse('tel:$tel')),
                                            borderRadius: BorderRadius.circular(6),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF003B70).withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.call_rounded, size: 13, color: Color(0xFF003B70)),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    tel,
                                                    style: const TextStyle(
                                                      fontSize: 11.5,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF003B70),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
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
          );
        },
      ),
    );
  }

  // --------------------------------------------------------------------------
  // [모달] 건물 상세 정보 팝업
  // --------------------------------------------------------------------------
  void _showBuildingDetail(CampusBuilding b) {
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
          initialChildSize: 0.6,
          maxChildSize: 0.9,
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
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFF003B70).withValues(alpha: 0.1),
                        child: Icon(b.icon, color: const Color(0xFF003B70), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.name,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('${b.category} · 고유번호 [${b.id}호관]',
                                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(b.description,
                      style: const TextStyle(fontSize: 13.5, height: 1.4, color: Colors.black87)),
                  const Divider(height: 24),
                  const Text('층별 주요 안내',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...b.floors.map(
                    (f) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF003B70))),
                          Expanded(
                            child: Text(f,
                                style: const TextStyle(fontSize: 13, height: 1.3)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  const Text('입주 편의시설',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: b.amenities.map((a) {
                      return Chip(
                        label: Text(a, style: const TextStyle(fontSize: 12)),
                        backgroundColor: const Color(0xFF003B70).withValues(alpha: 0.08),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // [모달] 통학·셔틀버스 전체 노선 & 시간표 팝업
  // --------------------------------------------------------------------------
  void _showBusTimetableModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DefaultTabController(
          length: 3,
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            maxChildSize: 0.95,
            builder: (_, controller) {
              return Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(Icons.directions_bus_rounded, color: Color(0xFF003B70), size: 24),
                        SizedBox(width: 10),
                        Text('남서울대 통학·셔틀버스 전체 시간표',
                            style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const TabBar(
                    labelColor: Color(0xFF003B70),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Color(0xFF003B70),
                    indicatorWeight: 3,
                    labelStyle: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                    tabs: [
                      Tab(text: '성환역 셔틀 (무료)'),
                      Tab(text: '천안·평택·안성'),
                      Tab(text: '수도권 통학버스'),
                    ],
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // 1. 성환역 셔틀버스 (정확한 시간대별 타임테이블)
                        ListView(
                          controller: controller,
                          padding: const EdgeInsets.all(18),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.pin_drop_rounded, size: 16, color: Color(0xFF003B70)),
                                      SizedBox(width: 4),
                                      Text('승하차 전용 승강장 안내 (재학생 전액 무료)',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF003B70))),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Text('• 성환역: 1호선 성환역 1번 출구 도솔신협 앞 전용 승강장',
                                      style: TextStyle(fontSize: 12.5)),
                                  Text('• 학교: 정문 경비실 앞 및 21세기개발관(12호관) 앞 전용 승강장',
                                      style: TextStyle(fontSize: 12.5)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            _buildTimelineCard('08:00 ~ 08:20', '등교 시작 (첫차 08:00)', '10분 간격 배차 출발', Colors.blue.shade600),
                            _buildTimelineCard('08:20 ~ 10:30', '등교 피크타임 집중 배차', '3 ~ 6분 간격 수시 출발 (전철 도착 시 즉시 순환)', Colors.blue.shade800),
                            _buildTimelineCard('10:30 ~ 12:00', '오전 평시 순환 배차', '10 ~ 15분 간격 수시 운행', Colors.teal.shade700),
                            _buildTimelineCard('12:00 ~ 14:00', '점심시간 순환 배차', '10 ~ 15분 간격 운행', Colors.cyan.shade800),
                            _buildTimelineCard('14:00 ~ 17:00', '오후 강의시간 평시 배차', '10 ~ 15분 간격 운행', Colors.teal.shade800),
                            _buildTimelineCard('17:00 ~ 18:30', '하교 피크타임 집중 배차', '5 ~ 8분 간격 집중 순환 배차', Colors.orange.shade800),
                            _buildTimelineCard('18:30 ~ 19:30', '저녁 하교 배차', '15분 간격 순환 운행', Colors.deepOrange.shade800),
                            _buildTimelineCard('19:30 ~ 21:30', '야간 정시 출발 (막차 21:30)', '19:30 | 20:00 | 20:30 | 21:00 | 21:30 (30분 간격)', Colors.indigo.shade800),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.amber.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.info_outline_rounded, size: 15, color: Colors.amber.shade900),
                                      const SizedBox(width: 6),
                                      Text('요일별 운행 안내',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.amber.shade900)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  const Text('• 월~목요일: 21:30 막차까지 정상 운행', style: TextStyle(fontSize: 11.5)),
                                  const Text('• 금요일: 학생 조기 귀가로 인해 18:30 이후 단축 운행', style: TextStyle(fontSize: 11.5)),
                                  const Text('• 주말·공휴일·방학: 미운행 (시험기간 별도 연장 운행)', style: TextStyle(fontSize: 11.5)),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // 2. 천안·평택·안성 무료 셔틀
                        ListView(
                          controller: controller,
                          padding: const EdgeInsets.all(18),
                          children: [
                            _buildRegionalRouteCard(
                              region: '천안 방면 (무료)',
                              color: Colors.blue.shade700,
                              inbound: '신부동 터미널(08:15) ➔ 두정역(08:30) ➔ 백석동(08:40) ➔ 학교(09:00)',
                              outbound: '학교 정문 출발 17:15, 18:15 (역순 운행)',
                            ),
                            const SizedBox(height: 12),
                            _buildRegionalRouteCard(
                              region: '평택 방면 (무료)',
                              color: Colors.green.shade700,
                              inbound: '평택역(08:20) ➔ 평택터미널(08:30) ➔ 안성IC/용이동(08:40) ➔ 학교(09:05)',
                              outbound: '학교 정문 출발 17:20, 18:20 (역순 운행)',
                            ),
                            const SizedBox(height: 12),
                            _buildRegionalRouteCard(
                              region: '안성 방면 (무료)',
                              color: Colors.orange.shade800,
                              inbound: '안성터미널(08:10) ➔ 중앙대 안성캠(08:25) ➔ 공도(08:35) ➔ 학교(09:00)',
                              outbound: '학교 정문 출발 17:15 (역순 운행)',
                            ),
                          ],
                        ),

                        // 3. 수도권 통학버스 및 충남형 M버스
                        ListView(
                          controller: controller,
                          padding: const EdgeInsets.all(18),
                          children: [
                            // 충남형 광역급행 M2000
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.teal.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.electric_bolt_rounded, size: 16, color: Colors.teal.shade800),
                                      const SizedBox(width: 6),
                                      Text('충남형 광역급행 M버스 (2000번) - 남서울대 정문 경유',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Colors.teal.shade800)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  const Text('• 주요 노선: 평택지제역(SRT) ⇄ 성환터미널 ⇄ 남서울대(정문) ⇄ 천안아산역(KTX) ⇄ 순천향대',
                                      style: TextStyle(fontSize: 11.5)),
                                  const Text('• 배차 간격: 20~30분 간격 (수도권 전철/천안 시내버스 환승할인 적용)',
                                      style: TextStyle(fontSize: 11.5)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                '💡 하교 통학버스(공통): 학교 정문 통학버스 승강장에서 17:10 및 18:15 출발',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF003B70)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildCommuterItem('강남 / 양재', '양재역 9번출구(07:30) ➔ 양재시민의숲(07:35) ➔ 학교(08:50)'),
                            _buildCommuterItem('잠실 / 송파', '잠실역 4번출구(07:20) ➔ 가락시장역(07:30) ➔ 복정역(07:40) ➔ 학교(08:55)'),
                            _buildCommuterItem('노원 / 강북', '노원역 6번출구(07:00) ➔ 하계역(07:10) ➔ 태릉입구(07:15) ➔ 학교(08:50)'),
                            _buildCommuterItem('수원 / 영통', '수원역 4번출구(07:40) ➔ 영통입구(07:55) ➔ 학교(08:50)'),
                            _buildCommuterItem('성남 / 분당', '야탑역(07:25) ➔ 서현역(07:35) ➔ 미금역(07:45) ➔ 학교(08:50)'),
                            _buildCommuterItem('부천 / 안산', '부천 송내역(07:10) ➔ 안산 한대앞역(07:45) ➔ 학교(08:50)'),
                            _buildCommuterItem('일산 노선', '대화역(06:50) ➔ 정발산역(07:00) ➔ 백석역(07:10) ➔ 학교(08:55)'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTimelineCard(String time, String title, String subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(time, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionalRouteCard({
    required String region,
    required Color color,
    required String inbound,
    required String outbound,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(region, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('등교: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Expanded(child: Text(inbound, style: const TextStyle(fontSize: 12, height: 1.3))),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('하교: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Expanded(child: Text(outbound, style: const TextStyle(fontSize: 12, height: 1.3))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommuterItem(String line, String detail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(line, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF003B70))),
          const SizedBox(height: 4),
          Text(detail, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }
  // --------------------------------------------------------------------------
  // [신규 기능] 카카오맵 / 네이버 지도 길찾기 연동
  // --------------------------------------------------------------------------
  Future<void> _openKakaoMap(CampusBuilding b) async {
    final query = '남서울대학교 ${b.name}';
    final url = 'https://map.kakao.com/link/search/${Uri.encodeComponent(query)}';
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _openNaverMap(CampusBuilding b) async {
    final query = '남서울대학교 ${b.name}';
    final url = 'https://m.map.naver.com/search2/search.naver?query=${Uri.encodeComponent(query)}';
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  // --------------------------------------------------------------------------
  // [신규 위젯] 🔍 남서울대학교 강의실 스마트 위치 찾기 & 수업 동선 계산기
  // --------------------------------------------------------------------------
  Widget _buildClassroomFinderSection(CampusBuilding? parsedBuilding, Map<String, String>? parsed) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. [제미나이 생성 고화질 일러스트 배너]
          Stack(
            children: [
              Image.asset(
                'assets/images/nsu_classroom_guide.jpg',
                width: double.infinity,
                height: 165,
                fit: BoxFit.cover,
              ),
              Container(
                height: 165,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withValues(alpha: 0.65), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF003B70),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('남서울대 공식 가이드',
                              style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 4),
                        const Text('수강신청 전 보는 강의실 찾는 법!',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        const Text('5자리 강의실 번호 해독 & 연강 수업 동선 체크',
                            style: TextStyle(fontSize: 11, color: Colors.white70)),
                      ],
                    ),
                    const Icon(Icons.school_rounded, color: Colors.white, size: 28),
                  ],
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. 검색창 입력부
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: Color(0xFF003B70)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '5자리 강의실 번호 입력 (예: 16419, 01305)',
                            border: InputBorder.none,
                            hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          onChanged: (val) => setState(() => _searchQuery = val),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 3. 빠른 입력 칩 버튼
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text('자주 찾는 곳: ', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.grey)),
                      _buildQuickRoomChip('16419', '보건의료학관(16호관) 4층'),
                      _buildQuickRoomChip('01305', '공학1관(1호관) 3층'),
                      _buildQuickRoomChip('02203', '공학2관(2호관) 2층'),
                      _buildQuickRoomChip('03210', '상경학관(3호관) 2층'),
                      _buildQuickRoomChip('08101', '학생복지회관(8호관) 1층'),
                      _buildQuickRoomChip('11301', '지식정보관(11호관) 3층'),
                      _buildQuickRoomChip('10205', '인문사회학관(10호관) 2층'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. 시각적 3단계 번호 해독 블록 (인스타그램 카드뉴스 원본 구현)
                if (parsed != null && parsedBuilding != null) ...[
                  // [해독 블록 애니메이션 카드]
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_fix_high_rounded, size: 16, color: Color(0xFF003B70)),
                            SizedBox(width: 6),
                            Text('시간표 번호 분해 공식',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF003B70))),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            // 블록 1: 학관
                            Expanded(
                              flex: 3,
                              child: _buildCodeBlock(
                                title: '학관 번호',
                                code: parsed['bldg']!,
                                name: parsedBuilding.name.split(' ')[0],
                                color: const Color(0xFF003B70),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text('+', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                            ),
                            // 블록 2: 층수
                            Expanded(
                              flex: 2,
                              child: _buildCodeBlock(
                                title: '층수',
                                code: parsed['floor']!,
                                name: '${parsed['floor']}층',
                                color: Colors.orange.shade800,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text('+', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                            ),
                            // 블록 3: 호실
                            Expanded(
                              flex: 2,
                              child: _buildCodeBlock(
                                title: '호실',
                                code: parsed['room']!,
                                name: '${parsed['room']}호',
                                color: Colors.teal.shade800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // [상세 안내 및 길찾기 프리미엄 카드]
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF003B70), const Color(0xFF00569E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF003B70).withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${parsedBuilding.name.split(' ')[0]} (${parsedBuilding.category})',
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ),
                            Text(
                              '검색 번호: ${_searchQuery.trim()}',
                              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${parsedBuilding.name} ${parsed['floor']}층 ${parsed['room']}호',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '위치: ${parsedBuilding.description}',
                          style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.9)),
                        ),
                        const Divider(color: Colors.white24, height: 18),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.stairs_rounded, color: Colors.lightGreenAccent, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _getFloorDetail(parsedBuilding, parsed['floor']!),
                                style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // 길찾기 버튼
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFEE500),
                                  foregroundColor: Colors.black87,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.navigation_rounded, size: 16),
                                label: const Text('카카오맵 길찾기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                onPressed: () => _openKakaoMap(parsedBuilding),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF03C75A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.map_rounded, size: 16),
                                label: const Text('네이버 지도 길찾기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                onPressed: () => _openNaverMap(parsedBuilding),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // [초기 가이드 카드: 공식 카드뉴스 규칙]
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: Color(0xFF003B70), size: 18),
                            SizedBox(width: 6),
                            Text('시간표에 나와있는 5자리 강의실 번호 규칙',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF003B70))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '• 왼쪽 1~2자리: 학관 번호 (01: 공학1관, 02: 공학2관, 03: 상경학관, 16: 보건의료학관 등)\n• 가운데 1자리: 층수 (1~5층)\n• 오른쪽 2자리: 강의실 호수 (01~30호)\n예시) 16419 ➔ 보건의료학관(16호관) 4층 19호 강의실',
                          style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.45),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // 5. 🏃 [연강 수업 동선 계산기 모달 열기 버튼]
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: ListTile(
                    dense: true,
                    leading: const CircleAvatar(
                      backgroundColor: Colors.amber,
                      child: Icon(Icons.directions_run_rounded, color: Colors.black87, size: 20),
                    ),
                    title: const Text('🏃 연강 수업 이동 동선 계산기',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    subtitle: const Text('수강신청 전 10분 쉬는시간 이동 가능 여부 체크',
                        style: TextStyle(fontSize: 11, color: Colors.black87)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF003B70)),
                    onTap: _showRouteCalculatorModal,
                  ),
                ),

                const SizedBox(height: 16),

                // 6. 🏛️ [신규 교체] 남서울대학교 학과별 학과사무실 위치 & 전화번호
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.business_rounded, color: Color(0xFF003B70), size: 18),
                        SizedBox(width: 6),
                        Text('남서울대학교 학과사무실 위치 & 전화번호',
                            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF003B70))),
                      ],
                    ),
                    Text('${_departmentOffices.length}개 학과',
                        style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('단과대별 과사 위치 및 직통 전화번호 (터치 시 통화 연결)',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                const SizedBox(height: 10),

                // 단과대 필터 칩
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['전체', '공과대학', '보건의료복지', '글로벌상경', '창조예술'].map((college) {
                      final isSel = _selectedDeptCollege == college;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(college),
                          selected: isSel,
                          selectedColor: const Color(0xFF003B70),
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : Colors.black87,
                            fontSize: 11.5,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (_) => setState(() => _selectedDeptCollege = college),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),

                // 학과 목록 렌더링 (접기/더보기 기능 적용)
                Builder(
                  builder: (_) {
                    final filteredDepts = _departmentOffices
                        .where((d) => _selectedDeptCollege == '전체' || d['college'] == _selectedDeptCollege)
                        .toList();
                    final displayedDepts = _isDeptExpanded ? filteredDepts : filteredDepts.take(4).toList();

                    return Column(
                      children: [
                        ...displayedDepts.map((d) => _buildDeptOfficeRow(d)),
                        if (filteredDepts.length > 4) ...[
                          const SizedBox(height: 6),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF003B70),
                                side: BorderSide(color: Colors.grey.shade300),
                                backgroundColor: const Color(0xFFF8FAFC),
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => setState(() => _isDeptExpanded = !_isDeptExpanded),
                              icon: Icon(_isDeptExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 18),
                              label: Text(
                                _isDeptExpanded ? '학과 목록 접기' : '+ ${filteredDepts.length - 4}개 학과 더보기',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeBlock({
    required String title,
    required String code,
    required String name,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(code, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
        ],
      ),
    );
  }

  // 🏃 연강 수업 이동 동선 계산기 모달
  void _showRouteCalculatorModal() {
    String fromBldg = '01';
    String toBldg = '16';

    final bldgNames = {
      '01': '공학1관 (1호관)',
      '02': '공학2관 (2호관)',
      '03': '상경학관 (3호관)',
      '07': '조형학관 (7호관)',
      '08': '학생복지회관 (8호관)',
      '09': '성암기념중앙도서관 (9호관)',
      '10': '인문사회학관 (10호관)',
      '11': '지식정보관 (11호관)',
      '12': '21세기개발관 (12호관)',
      '14': '성암체육관 (14호관)',
      '16': '보건의료학관 (16호관)',
      '21': '대학본부 (본관)',
    };

    int estimateMinutes(String a, String b) {
      if (a == b) return 1;
      final pair = '${a}_${b}';
      final rpair = '${b}_${a}';
      final times = {
        '01_02': 1, '01_03': 2, '01_16': 4, '01_08': 4, '01_09': 3, '01_14': 8, '01_11': 6,
        '02_03': 2, '02_16': 4, '02_14': 8, '03_16': 2, '03_07': 3, '08_09': 2, '08_14': 5,
        '09_16': 3, '09_10': 3, '10_11': 3, '10_16': 4, '11_12': 2, '14_16': 6,
      };
      return times[pair] ?? times[rpair] ?? 4;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setMState) {
          final mins = estimateMinutes(fromBldg, toBldg);
          final isHard = mins >= 7;

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('🏃 연강 수업 동선 & 이동시간 체크',
                        style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: Color(0xFF003B70))),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Text('수강신청 전, 쉬는시간 10분 내 이동 가능한 동선인지 시뮬레이션합니다.',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),

                // 출발 건물
                DropdownButtonFormField<String>(
                  value: fromBldg,
                  decoration: const InputDecoration(
                    labelText: '1교시 (이전 강의실 건물)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: bldgNames.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                  onChanged: (val) {
                    if (val != null) setMState(() => fromBldg = val);
                  },
                ),
                const SizedBox(height: 12),

                // 도착 건물
                DropdownButtonFormField<String>(
                  value: toBldg,
                  decoration: const InputDecoration(
                    labelText: '2교시 (다음 강의실 건물)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: bldgNames.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                  onChanged: (val) {
                    if (val != null) setMState(() => toBldg = val);
                  },
                ),
                const SizedBox(height: 18),

                // 동선 분석 결과 카드
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isHard ? Colors.red.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isHard ? Colors.red.shade300 : Colors.green.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(isHard ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
                              color: isHard ? Colors.red.shade700 : Colors.green.shade700, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            isHard ? '⚠️ 빠른 이동 필요 (경사 구간)' : '✅ 10분 내 넉넉하게 이동 가능',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isHard ? Colors.red.shade800 : Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('예상 도보 소요시간: 약 $mins분 (거리 약 ${mins * 70}m)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isHard ? Colors.red.shade900 : Colors.green.shade900)),
                      const SizedBox(height: 4),
                      Text(
                        isHard
                            ? '※ 체육관(14호관) 등 외곽 건물은 오르막길이 있어 10분 쉬는시간 동안 빠른 걸음이 필요합니다!'
                            : '※ 인접 학관 간 이동으로 쉬는 시간 10분 동안 화장실을 들르고도 여유 있게 도착할 수 있습니다.',
                        style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickRoomChip(String code, String desc) {
    final isSelected = _searchQuery.trim() == code;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        backgroundColor: isSelected ? const Color(0xFF003B70) : Colors.grey.shade100,
        label: Text(
          '$code ($desc)',
          style: TextStyle(
            fontSize: 11,
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onPressed: () {
          _searchController.text = code;
          setState(() => _searchQuery = code);
        },
      ),
    );
  }

  String _getFloorDetail(CampusBuilding bldg, String floor) {
    for (final f in bldg.floors) {
      if (f.startsWith('${floor}F') || f.contains('${floor}층') || f.contains(floor)) {
        return f;
      }
    }
    return '${floor}층 강의실 및 실습실 (${bldg.floors.join(" | ")})';
  }


  // [남서울대 23개 학과사무실 위치 및 직통 전화번호 데이터]
  final List<Map<String, String>> _departmentOffices = const [
    // 공과대학
    {
      'dept': '컴퓨터소프트웨어학과',
      'college': '공과대학',
      'loc': '공학2관(2호관) 3층',
      'tel': '041-580-2100',
    },
    {
      'dept': '지능정보통신공학과',
      'college': '공과대학',
      'loc': '공학1관(1호관) 3층',
      'tel': '041-580-2120',
    },
    {
      'dept': '전자공학과',
      'college': '공과대학',
      'loc': '공학1관(1호관) 2층',
      'tel': '041-580-2110',
    },
    {
      'dept': '가상현실학과',
      'college': '공과대학',
      'loc': '공학2관(2호관) 2층',
      'tel': '041-580-5350',
    },
    {
      'dept': '드론공간정보공학과',
      'college': '공과대학',
      'loc': '공학1관(1호관) 4층',
      'tel': '041-580-2370',
    },
    {
      'dept': '건축공학과',
      'college': '공과대학',
      'loc': '공학1관(1호관) 1층',
      'tel': '041-580-2760',
    },
    {
      'dept': '건축학과 (5년제)',
      'college': '공과대학',
      'loc': '공학1관(1호관) 1층',
      'tel': '041-580-2180',
    },
    {
      'dept': '스마트팜학과',
      'college': '공과대학',
      'loc': '공학1관(1호관) 2층',
      'tel': '041-580-3250',
    },
    // 보건의료복지대학
    {
      'dept': '간호학과',
      'college': '보건의료복지',
      'loc': '보건의료학관(16호관) 4층',
      'tel': '041-580-2710',
    },
    {
      'dept': '물리치료학과',
      'college': '보건의료복지',
      'loc': '보건의료학관(16호관) 3층',
      'tel': '041-580-2530',
    },
    {
      'dept': '임상병리학과',
      'college': '보건의료복지',
      'loc': '보건의료학관(16호관) 3층',
      'tel': '041-580-2720',
    },
    {
      'dept': '치위생학과',
      'college': '보건의료복지',
      'loc': '보건의료학관(16호관) 2층',
      'tel': '041-580-2560',
    },
    {
      'dept': '응급구조학과',
      'college': '보건의료복지',
      'loc': '보건의료학관(16호관) 2층',
      'tel': '041-580-2730',
    },
    {
      'dept': '보건행정학과',
      'college': '보건의료복지',
      'loc': '보건의료학관(16호관) 1층',
      'tel': '041-580-2330',
    },
    {
      'dept': '사회복지학과',
      'college': '보건의료복지',
      'loc': '인문사회학관(10호관) 3층',
      'tel': '041-580-2520',
    },
    {
      'dept': '아동복지학과',
      'college': '보건의료복지',
      'loc': '인문사회학관(10호관) 2층',
      'tel': '041-580-2320',
    },
    {
      'dept': '스포츠건강관리학과',
      'college': '보건의료복지',
      'loc': '성암체육관(14호관) 1층',
      'tel': '041-580-2630',
    },
    // 글로벌상경대학
    {
      'dept': '경영학과',
      'college': '글로벌상경',
      'loc': '상경학관(3호관) 2층',
      'tel': '041-580-2000',
    },
    {
      'dept': '글로벌무역학과',
      'college': '글로벌상경',
      'loc': '상경학관(3호관) 3층',
      'tel': '041-580-2000',
    },
    {
      'dept': '호텔경영학과',
      'college': '글로벌상경',
      'loc': '상경학관(3호관) 4층',
      'tel': '041-580-2000',
    },
    // 창조문화예술대학
    {
      'dept': '시각미디어디자인학과',
      'college': '창조예술',
      'loc': '조형학관(7호관) 3층',
      'tel': '041-580-2000',
    },
    {
      'dept': '공간조형디자인학과',
      'college': '창조예술',
      'loc': '조형학관(7호관) 2층',
      'tel': '041-580-2000',
    },
    {
      'dept': '실용음악학과',
      'college': '창조예술',
      'loc': '조형학관(7호관) 5층',
      'tel': '041-580-2000',
    },
  ];

  IconData _getCollegeIcon(String college) {
    switch (college) {
      case '공과대학':
        return Icons.memory_rounded;
      case '보건의료복지':
        return Icons.medical_services_rounded;
      case '글로벌상경':
        return Icons.business_center_rounded;
      case '창조예술':
        return Icons.palette_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  Widget _buildDeptOfficeRow(Map<String, String> d) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF003B70).withValues(alpha: 0.08),
            child: Icon(_getCollegeIcon(d['college']!), color: const Color(0xFF003B70), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        d['dept']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        d['college']!,
                        style: TextStyle(fontSize: 10, color: Colors.blue.shade800, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 13, color: Color(0xFFD32F2F)),
                    const SizedBox(width: 2),
                    Text(
                      '과사 위치: ',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      d['loc']!,
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF003B70), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF003B70),
              side: const BorderSide(color: Color(0xFF003B70), width: 1.2),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => launchUrl(Uri.parse('tel:${d['tel']}')),
            icon: const Icon(Icons.phone_rounded, size: 13),
            label: Text(d['tel']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // [위젯] 🎓 전교생 데이터 허브 (장학금 전수 안내 & 학과/행정 연락처)
  // --------------------------------------------------------------------------
  Widget _buildCampusInfoHubCards() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _showScholarshipsModal,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF003B70), const Color(0xFF00569E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF003B70).withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.monetization_on_rounded, color: Colors.amber, size: 20),
                      SizedBox(width: 6),
                      Text('교내·외 장학금',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('15종 선발요건 & 혜택',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: InkWell(
            onTap: _showDirectoryModal,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF0A5844), const Color(0xFF138A6B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0A5844).withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.contact_phone_rounded, color: Colors.lightGreenAccent, size: 20),
                      SizedBox(width: 6),
                      Text('학과/부서 전화번호',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('23개 학과 & 10개 행정처',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 장학금 15종 모달
  void _showScholarshipsModal() {
    final scholarships = [
      {'name': '모범장학금 (성적우수)', 'cat': '교내 성적', 'benefit': '수업료 전액~일부 감면', 'req': '직전학기 15학점 이상, 평점 3.0 이상 (성적순 자동선발)'},
      {'name': 'N+ 마일리지 장학금', 'cat': '교내 비교과', 'benefit': '학기당 최대 100만원 현금', 'req': '비교과 프로그램(자격증, 취업캠프, 봉사 등) 참여 적립'},
      {'name': '희망장학금 (가계곤란)', 'cat': '교내 복지', 'benefit': '등록금 차등 감면 / 생활비 50만원', 'req': '소득분위 0~3구간, 직전 12학점, 평점 2.0 이상'},
      {'name': '가족장학금 (패밀리)', 'cat': '교내 복지', 'benefit': '수업료 30%~50% 감면', 'req': '직계가족 2인 이상 남서울대 동시 재학'},
      {'name': '학업증진장학금', 'cat': '교내 성적', 'benefit': '학업장려금 30~50만원', 'req': '성적 부진(2.5미만) 후 프로그램 이수 및 성적 대폭 향상자'},
      {'name': '근로봉사장학금', 'cat': '교내 근로', 'benefit': '시급 기준 월별 장학금', 'req': '학과사무실, 도서관, 행정부서 주당 근로'},
      {'name': '외국어능력우수장학금', 'cat': '교내 자기계발', 'benefit': 'TOEIC 800+ 30만원 / 900+ 50만원', 'req': '공인 외국어 성적표 유효기간 내 제출'},
      {'name': '사랑/은혜장학금', 'cat': '교내 복지', 'benefit': '수업료 일부 감면', 'req': '학부모 실직/파산 등 갑작스러운 가계 곤란 (학과장 추천)'},
      {'name': '선교/세례교인장학금', 'cat': '교내 종교', 'benefit': '30만~50만원 감면', 'req': '세례증명서 제출 및 교목실 모범 학생'},
      {'name': '공로장학금', 'cat': '교내 자치', 'benefit': '수업료 전액~30% 감면', 'req': '총학생회, 대의원, 학회장, 동아리연합회 간부'},
      {'name': '국가장학금 Ⅰ유형', 'cat': '국가장학금', 'benefit': '학기당 전액 ~ 175만원', 'req': '소득 8구간 이하, 직전 12학점, 백분위 80점 이상'},
      {'name': '국가장학금 Ⅱ유형', 'cat': '국가장학금', 'benefit': '대학 자체 추가 차등 지급', 'req': '1유형 신청자 중 9구간 이하'},
      {'name': '국가근로장학금', 'cat': '국가근로', 'benefit': '교내 9,860원 / 교외 12,220원 시급', 'req': '소득 8구간 이하, 교내외 매칭 기관 근로'},
      {'name': '희망사다리 Ⅰ유형', 'cat': '국가장학금', 'benefit': '등록금 전액 + 취창업비 200만원', 'req': '3학년 이상 중소/중견기업 취창업 희망자 (의무재직)'},
      {'name': '다자녀 국가장학금', 'cat': '국가장학금', 'benefit': '최대 전액 ~ 225만원', 'req': '다자녀 가정(자녀 3명 이상), 소득 8구간 이하'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('💰 남서울대학교 장학금 안내 (15종)',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF003B70))),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              Text('문의: 학생처 장학복지팀 (학생복지회관 2층, ☎ 041-580-2040)',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
              const Divider(height: 20),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: scholarships.length,
                  separatorBuilder: (_, __) => const Divider(height: 14),
                  itemBuilder: (_, idx) {
                    final s = scholarships[idx];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(s['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                              child: Text(s['cat']!, style: TextStyle(fontSize: 10.5, color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('혜택: ${s['benefit']}', style: const TextStyle(fontSize: 12.5, color: Color(0xFF003B70), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('요건: ${s['req']}', style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700)),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 학과 & 행정부서 전화번호부 모달
  void _showDirectoryModal() {
    final depts = [
      {'name': '컴퓨터소프트웨어학과', 'col': '공과대학', 'loc': '공학2관 3층', 'tel': '041-580-2100'},
      {'name': '지능정보통신공학과', 'col': '공과대학', 'loc': '공학1관 3층', 'tel': '041-580-2120'},
      {'name': '전자공학과', 'col': '공과대학', 'loc': '공학1관 2층', 'tel': '041-580-2110'},
      {'name': '가상현실학과', 'col': '공과대학', 'loc': '공학2관 2층', 'tel': '041-580-5350'},
      {'name': '드론공간정보공학과', 'col': '공과대학', 'loc': '공학1관 4층', 'tel': '041-580-2370'},
      {'name': '건축공학과', 'col': '공과대학', 'loc': '공학1관 1층', 'tel': '041-580-2760'},
      {'name': '건축학과 (5년제)', 'col': '공과대학', 'loc': '공학1관 1층', 'tel': '041-580-2180'},
      {'name': '간호학과', 'col': '보건의료', 'loc': '보건의료학관 4층', 'tel': '041-580-2710'},
      {'name': '물리치료학과', 'col': '보건의료', 'loc': '보건의료학관 3층', 'tel': '041-580-2530'},
      {'name': '임상병리학과', 'col': '보건의료', 'loc': '보건의료학관 3층', 'tel': '041-580-2720'},
      {'name': '치위생학과', 'col': '보건의료', 'loc': '보건의료학관 2층', 'tel': '041-580-2560'},
      {'name': '응급구조학과', 'col': '보건의료', 'loc': '보건의료학관 2층', 'tel': '041-580-2730'},
      {'name': '보건행정학과', 'col': '보건의료', 'loc': '보건의료학관 1층', 'tel': '041-580-2330'},
      {'name': '사회복지학과', 'col': '보건의료', 'loc': '인문사회학관 3층', 'tel': '041-580-2520'},
      {'name': '아동복지학과', 'col': '보건의료', 'loc': '인문사회학관 2층', 'tel': '041-580-2320'},
      {'name': '스포츠건강관리학과', 'col': '보건의료', 'loc': '성암체육관 1층', 'tel': '041-580-2630'},
      {'name': '경영학과', 'col': '글로벌상경', 'loc': '상경학관 2층', 'tel': '041-580-2000'},
      {'name': '글로벌무역학과', 'col': '글로벌상경', 'loc': '상경학관 3층', 'tel': '041-580-2000'},
      {'name': '호텔경영학과', 'col': '글로벌상경', 'loc': '상경학관 4층', 'tel': '041-580-2000'},
      {'name': '시각미디어디자인학과', 'col': '창조예술', 'loc': '조형학관 3층', 'tel': '041-580-2000'},
      {'name': '공간조형디자인학과', 'col': '창조예술', 'loc': '조형학관 2층', 'tel': '041-580-2000'},
      {'name': '실용음악학과', 'col': '창조예술', 'loc': '조형학관 5층', 'tel': '041-580-2000'},
    ];

    final offices = [
      {'name': '교무처 (학사지원팀)', 'loc': '21세기개발관 1층', 'tel': '041-580-2030', 'task': '수강신청, 휴학/복학, 성적, 졸업'},
      {'name': '학생처 (장학복지팀)', 'loc': '학생복지회관 2층', 'tel': '041-580-2040', 'task': '국가/교내 장학금, 학생증, 학자금'},
      {'name': '입학처', 'loc': '21세기개발관 1층', 'tel': '041-580-2500', 'task': '수시/정시 모집, 편입학'},
      {'name': '총무처 (교통운영)', 'loc': '본관 2층', 'tel': '041-580-2060', 'task': '성환역 셔틀버스, 통학버스, 시설'},
      {'name': '보건진료소', 'loc': '학생복지회관 2층', 'tel': '041-580-2090', 'task': '무료 투약, 응급처치, 안정실'},
      {'name': '취창업지원처', 'loc': '학생복지회관 2층', 'tel': '041-580-2070', 'task': '자소서 첨삭, 취업추천, 모의면접'},
      {'name': '학술정보원 (성암도서관)', 'loc': '성암도서관 1층', 'tel': '041-580-2240', 'task': '도서 대출/반납, 열람실 좌석'},
      {'name': '정보전산원', 'loc': '지식정보관 3층', 'tel': '041-580-2220', 'task': '포털 계정, 캠퍼스 Wi-Fi'},
      {'name': '예비군연대', 'loc': '학생복지회관 3층', 'tel': '041-580-2080', 'task': '학생예비군 훈련 편성/연기'},
      {'name': '교목실', 'loc': '본관 1층', 'tel': '041-580-2020', 'task': '채플 출결 및 이수 상담'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollController) => DefaultTabController(
          length: 2,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('📞 캠퍼스 전화번호부 & 위치',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF003B70))),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const TabBar(
                  labelColor: Color(0xFF003B70),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Color(0xFF003B70),
                  tabs: [
                    Tab(text: '🏛️ 23개 학과사무실'),
                    Tab(text: '🏢 10개 행정부서'),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    children: [
                      // 학과 목록
                      ListView.separated(
                        controller: scrollController,
                        itemCount: depts.length,
                        separatorBuilder: (_, __) => const Divider(height: 10),
                        itemBuilder: (_, idx) {
                          final d = depts[idx];
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(d['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                            subtitle: Text('${d['col']} · ${d['loc']}', style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700)),
                            trailing: TextButton.icon(
                              onPressed: () => launchUrl(Uri.parse('tel:${d['tel']}')),
                              icon: const Icon(Icons.phone, size: 16, color: Color(0xFF003B70)),
                              label: Text(d['tel']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF003B70))),
                            ),
                          );
                        },
                      ),
                      // 행정부서 목록
                      ListView.separated(
                        itemCount: offices.length,
                        separatorBuilder: (_, __) => const Divider(height: 10),
                        itemBuilder: (_, idx) {
                          final o = offices[idx];
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(o['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                            subtitle: Text('${o['loc']} | ${o['task']}', style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700)),
                            trailing: TextButton.icon(
                              onPressed: () => launchUrl(Uri.parse('tel:${o['tel']}')),
                              icon: const Icon(Icons.phone, size: 16, color: Colors.teal),
                              label: Text(o['tel']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal)),
                            ),
                          );
                        },
                      ),
                    ],
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
