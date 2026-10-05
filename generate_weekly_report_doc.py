import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
import shutil

def create_weekly_report():
    doc = docx.Document()

    # 페이지 여백 설정 (1인치)
    for section in doc.sections:
        section.top_margin = Inches(0.9)
        section.bottom_margin = Inches(0.9)
        section.left_margin = Inches(0.9)
        section.right_margin = Inches(0.9)

    # 스타일 설정
    style = doc.styles['Normal']
    style.font.name = '맑은 고딕'
    style.font.size = Pt(10)
    style.font.color.rgb = RGBColor(0x22, 0x22, 0x22)

    # 제목
    p_title = doc.add_paragraph()
    p_title.paragraph_format.space_before = Pt(0)
    p_title.paragraph_format.space_after = Pt(12)
    run_t = p_title.add_run("[캡스톤 디자인 5주차 주간 진행 보고서]")
    run_t.font.size = Pt(16)
    run_t.font.bold = True
    run_t.font.color.rgb = RGBColor(0x00, 0x3B, 0x70)

    def add_sec_title(title):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(10)
        p.paragraph_format.space_after = Pt(4)
        run = p.add_run(title)
        run.font.size = Pt(12)
        run.font.bold = True
        run.font.color.rgb = RGBColor(0x1F, 0x4E, 0x79)
        return p

    def add_sub_title(title):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(6)
        p.paragraph_format.space_after = Pt(2)
        run = p.add_run(title)
        run.font.size = Pt(11)
        run.font.bold = True
        run.font.color.rgb = RGBColor(0x33, 0x33, 0x33)
        return p

    def add_bullet_lv1(bold_prefix, text):
        p = doc.add_paragraph(style='List Bullet')
        p.paragraph_format.line_spacing = 1.2
        p.paragraph_format.space_after = Pt(2)
        run_b = p.add_run(bold_prefix)
        run_b.font.bold = True
        p.add_run(text)
        return p

    def add_bullet_lv2(text):
        p = doc.add_paragraph()
        p.paragraph_format.left_indent = Inches(0.25)
        p.paragraph_format.line_spacing = 1.15
        p.paragraph_format.space_after = Pt(2)
        run_o = p.add_run("o  ")
        run_o.font.bold = True
        run_o.font.color.rgb = RGBColor(0x00, 0x3B, 0x70)
        p.add_run(text)
        return p

    # 1. 프로젝트 개요
    add_sec_title("1. 프로젝트 개요")
    add_bullet_lv1("프로젝트명: ", "CHAT-NSU (남서울대학교 스마트 캠퍼스 종합 어시스턴트 & 캠퍼스 라이프 플랫폼)")
    add_bullet_lv1("보고 주차: ", "5주차 종합 (9월 28일 ~ 10월 5일)")
    add_bullet_lv1("개발 플랫폼: ", "Flutter Web/Mobile (크로스 플랫폼) & FastAPI (Python 백엔드)")
    add_bullet_lv1("실시간 웹 배포: ", "https://singular-moonbeam-adafa6.netlify.app")

    # 2. 이번 주차 수행 내용 (역할 분담)
    add_sec_title("2. 이번 주차 수행 내용 (역할 분담)")

    add_sub_title("프론트엔드 김기석")
    add_bullet_lv1("학교 홈페이지 공식 학식 135종 100% 무결 연동 및 가짜 데이터 전면 퇴출", "")
    add_bullet_lv2("남서울대 공식 CMS 동적 게시판(Board 465, 466, 467) 렌더링 파싱을 통해 100% 실제 입점 브랜드 및 공식 가격표 연동")
    add_bullet_lv2("1층 푸드코트(71종): 버거운베어(수제버거 16종), 청년한끼(덮밥·라면 23종), 쑝쑝돈까스(16종), 태산김치찜(백반 16종) 전 메뉴 및 단품/세트 가격표 완벽 반영")
    add_bullet_lv2("2층 학생식당(64종): 언덕뜰소반(한식·국밥 16종), 부대통령(부대찌개·직화 16종), 포한끼(쌀국수 16종), 한우사골마라탕(16종) 정규 고정 메뉴 완벽 반영")
    add_bullet_lv2("3층 교직원식당: 6,500원 자율배식 한식 뷔페 식단표(제육볶음, 들기름막국수 등) 및 요일별(월~금) 식단 제공")
    add_bullet_lv2("엘림2관 멀베리: 재학생 대상 1,000원 천원의 아침밥(선착순 100명) 및 중·석식 기숙사 식당 메뉴 연동")

    add_bullet_lv1("학식 UI/UX 스크롤 과부하 전면 리팩토링 및 모달(BottomSheet) 개편", "")
    add_bullet_lv2("기존 135개 이상의 메뉴가 메인 화면을 수천 픽셀 차지하던 스크롤 병목 현상 해결")
    add_bullet_lv2("메인 카드: 층별 선택 탭(1층, 2층, 3층, 멀베리) + 4개 코너 브랜드 태그 + 대표 샘플 4개만 콤팩트 노출")
    add_bullet_lv2("전용 바텀시트 모달: [O층 전체 메뉴 & 가격표 전체보기 📋] 버튼 신설, 터치 시 부드럽게 열리는 DraggableScrollableSheet 모달 구현")
    add_bullet_lv2("모달 내 코너별 필터 칩([전체], [브랜드별]) 탑재로 원하는 식당의 메뉴만 즉시 필터링 가능하도록 최적화")

    add_bullet_lv1("데이터 신뢰성 확보를 위한 임의 표기(인기/대표 뱃지) 전면 삭제", "")
    add_bullet_lv2("학교 공식 데이터에 존재하지 않는 개발자 임의의 '⭐ 인기', '대표' 뱃지 및 색상 강조를 전면 삭제")
    add_bullet_lv2("학교 공식 홈페이지 게시판과 토씨 하나 틀리지 않는 100% 순수 메뉴명과 정가(원 단위)만 정직하게 표기")

    add_bullet_lv1("스마트 학점 계산기 및 졸업 로드맵 플래너 구현", "")
    add_bullet_lv2("학적 정보(학과, 현재 학년, 학기) 및 영역별 취득 학점(전공필수, 전공선택, 교양)을 직접 입력·수정할 수 있는 인터랙티브 모달 폼 UI 구축")
    add_bullet_lv2("정규 잔여 학기 수 기반 (남은 학점 ÷ 잔여 학기) = 학기당 권장 수강 학점 자동 연산 로직 구현")
    add_bullet_lv2("권장 수강 학점에 따른 단계별 진단 피드백(정규 졸업 안정 / 최대 학점 주의 / 계절학기 권장 경고) 시각화 카드 배치")

    add_bullet_lv1("남서울대 실제 교육과정 및 교양필수 과목 연동", "")
    add_bullet_lv2("지능정보통신공학과 1~4학년 공식 전공 과목 및 학수번호, 학점 데이터 구축 및 연동")
    add_bullet_lv2("남서울대 공통 교양필수(채플 4회, 아가페인문학, 현대인과 사회적 영성 등) 과목 데이터 추가 구축")
    add_bullet_lv2("학년별 필터 칩([전체], [1~4학년], [교양필수]) 및 터치 시 실시간 취득 학점에 가감되는 인터랙티브 체크박스 리스트 구현")
    add_bullet_lv2("학생의 현재 학년/학기를 기반으로 다음 학기에 수강해야 할 필수·권장 과목 우선 추천 알고리즘 적용")

    add_bullet_lv1("가짜(Mock) 데이터 전면 제거 및 100% 공식 실데이터 정제", "")
    add_bullet_lv2("앱 내 모호한 호관 번호 표기를 전면 제거하고, 학교 공식 건물명(학생복지회관, 성암기념중앙도서관, 지식정보관, 성암문화체육관, 21세기개발관, 공학1관 등)으로 동기화 완료")

    add_bullet_lv1("남서울대 공식 편의·복지시설 17개소 UI 개편 및 직통 전화 연동", "")
    add_bullet_lv2("학교 공식 홈페이지 입점 17개 전 매장의 공식 명칭, 호실 위치, 직통 전화번호 데이터 연동")
    add_bullet_lv2("메인 화면에 주요 6개 매장(브래댄코, 리안헤어, 크린토피아, 누보아트, CU학생회관점, 남서울출력) 직관적 카드 배치")
    add_bullet_lv2("상단 탭 복잡도를 제거하고 실시간 검색창 및 원클릭 전화걸기(tel:)가 지원되는 17개소 전체보기 모달 구축")

    add_bullet_lv1("로컬 영구 저장소(SharedPreferences) 및 웹 배포 파이프라인 구축", "")
    add_bullet_lv2("사용자 입력 학적 정보 및 교과목 이수 체크 상태가 앱 재실행 시에도 유지되도록 디바이스 로컬 영구 저장소 연동 완료")
    add_bullet_lv2("Flutter Web 최신 프로덕션 빌드 완료 및 Netlify 클라우드 자동 배포 파이프라인(singular-moonbeam-adafa6.netlify.app) 구축 및 HTTP 200 서비스 검증 완료")

    add_sub_title("백엔드 김영훈")
    add_bullet_lv1("인프라 고정 및 네트워크 통신 환경 안정화", "")
    add_bullet_lv2("기존 임시 ngrok 터널링 환경에서 DuckDNS 기반 고정 IP 도메인(http://nsugpt.duckdns.org:8000) 인프라 구축 및 포트포워딩 배포 완료")
    add_bullet_lv2("모바일 앱 및 웹(Web)과의 크로스 오리진 통신을 위한 CORS 정책 및 헤더 최적화 완료")

    add_bullet_lv1("학칙 RAG 파이프라인 및 실시간 스트리밍 서빙", "")
    add_bullet_lv2("남서울대 공식 학칙 규정 데이터베이스 기반 검색 증강 생성(RAG) 파이프라인 구축")
    add_bullet_lv2("토큰 단위 SSE 실시간 스트리밍 엔드포인트(POST /chat/stream) 안정화 및 응답 메타데이터(출처 조항, 확정형 여부) 스키마 제공")

    add_bullet_lv1("편의시설 및 학사 데이터베이스 구축 (MongoDB Atlas)", "")
    add_bullet_lv2("학교 홈페이지 공식 편의·복지시설 17개소 데이터 크롤링 및 MongoDB Atlas welfare_facilities 컬렉션 시딩 완료")
    add_bullet_lv2("편의시설 조회 API 엔드포인트(GET /welfare/facilities) 및 학점 자가진단 API(POST /graduation/check) 연동 지원")

    # 3. 주차별 목표 달성도
    add_sec_title("3. 주차별 목표 달성도")
    add_bullet_lv1("학교 홈페이지 100% 공식 학식(135종) 연동 및 임의 뱃지 전면 정제: ", "100% 완료")
    add_bullet_lv1("학식 메인 화면 콤팩트화 및 바텀시트 모달/코너 필터 개편: ", "100% 완료")
    add_bullet_lv1("프론트엔드 학점 계산기 고도화 및 실제 교육과정 연동: ", "100% 완료")
    add_bullet_lv1("가짜 데이터 정제 및 공식 건물명 / 4개 구역 학식 / 17개 편의시설 실데이터 구축: ", "100% 완료")
    add_bullet_lv1("로컬 데이터 영구 저장 및 웹(Netlify) 자동 배포 환경 구축: ", "100% 완료")
    add_bullet_lv1("백엔드 고정 도메인(DuckDNS) 인프라 전환 및 학칙 RAG 스트리밍 연동: ", "100% 완료")
    add_bullet_lv1("전체 5주차 계획 대비 종합 달성도: ", "100% 달성")

    # 4. 차주(6주차) 계획
    add_sec_title("4. 차주(6주차) 계획")
    add_bullet_lv1("모바일 / 웹 크로스 플랫폼 실서비스 환경 라이브 데모 시연 및 안정성 검증", "")
    add_bullet_lv1("백엔드 RAG 챗봇 질의응답 고도화:", "")
    add_bullet_lv2("학사 규정 외에도 실시간 학식(1~3층, 멀베리) 및 편의시설 위치를 챗봇 질문을 통해 자연어로 안내하는 통합 RAG 파이프라인 연계")
    add_bullet_lv2("실제 학사 FAQ 및 학과별 졸업요건 추가 데이터 임베딩 고도화")
    add_bullet_lv1("학생 생활 밀착형 부가 기능 최적화:", "")
    add_bullet_lv2("성환역 ⇄ 남서울대 셔틀버스 실시간 출발 타이머 및 시간표 고도화")
    add_bullet_lv2("학교 홈페이지 실시간 학사 공지사항 크롤러 파이프라인 연계")

    # 저장
    p1 = r"C:\src\capstone_app\capstone_report_5th_week.docx"
    p2 = r"C:\Users\ohmor\Desktop\capstone_report_5th_week.docx"
    doc.save(p1)
    try:
        shutil.copy2(p1, p2)
        print("Copied to Desktop successfully!")
    except Exception as e:
        print(f"Error copying to Desktop: {e}")
    print(f"Successfully generated: {p1}")

if __name__ == "__main__":
    create_weekly_report()
