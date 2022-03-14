// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ko locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ko';

  static String m0(email, logPath) =>
      "스크린샷과 로그 파일을 이메일로 보내주세요 :\n ${email}\n로그 파일 위치 : ${logPath}";

  static String m1(curVersion, newVersion, releaseNote) =>
      "현재 버전 : ${curVersion}\nL최신 버전 : ${newVersion}\n개발 노트:\n${releaseNote}";

  static String m2(name) => "소스 ${name}";

  static String m3(version) => "Required app version: ≥ ${version}";

  static String m4(n) => "최대 ${n}회 제한";

  static String m5(n) => "전승결정으로 대체되는 성배의 개수 : ${n}";

  static String m6(filename, hash, localHash) =>
      "File ${filename} not found or mismatched hash: ${hash} - ${localHash}";

  static String m7(filename, hash, dataHash) =>
      "Hash mismatch: ${filename}: ${hash} - ${dataHash}";

  static String m8(error) => "불러오기 실패. Error:\n${error}";

  static String m9(account) => "계정을 ${account}로 전환";

  static String m10(itemNum, svtNum) => "${itemNum} 아이템과 ${svtNum} 서번트를 출력";

  static String m11(name) => "${name}은 이미 존재합니다";

  static String m12(site) => "${site}(으)로 이동";

  static String m13(first) => "${Intl.select(first, {
            'true': '이미 첫번째입니다.',
            'false': '이미 마지막입니다.',
            'other': '마지막입니다.',
          })}";

  static String m14(version) => "데이터 버전이 ${version}(으)로 업데이트 됨";

  static String m15(index) => "계획 ${index}";

  static String m16(n) => "계획 초기화 ${n}(모두)";

  static String m17(n) => "계획 초기화 ${n}(표시된)";

  static String m18(total) => "합계 : ${total}";

  static String m19(total, hidden) => "합계 : ${total} 결과 (${hidden} 숨기기)";

  static String m20(server) => "${server} 서버와 연동";

  static String m21(a, b) => "${a} ${b}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about_app": MessageLookupByLibrary.simpleMessage("에 관해"),
        "about_app_declaration_text": MessageLookupByLibrary.simpleMessage(
            "이 어플리케이션에 사용되는 데이터는 게임 Fate/GO 및 게임 사이트에서 가져왔습니다. 게임의 텍스트, 그림, 음성의 저작권은 TYPE MOON/FGO PROJECT에 있습니다.\n\n프로그램의 설계는 WeChat의 프로그램인  \"Material Programe\" 과 IOS 앱인  \"Guda\"를 기반으로 제작되었습니다.\n"),
        "about_appstore_rating":
            MessageLookupByLibrary.simpleMessage("앱 스토어 점수"),
        "about_data_source": MessageLookupByLibrary.simpleMessage("데이터 소스"),
        "about_data_source_footer": MessageLookupByLibrary.simpleMessage(
            "출처가 표시되어 있지 않거나 침해가 있는 경우 알려주세요"),
        "about_email_dialog": m0,
        "about_email_subtitle":
            MessageLookupByLibrary.simpleMessage("스크린샷과 로그 파일을 첨부"),
        "about_feedback": MessageLookupByLibrary.simpleMessage("피드백"),
        "about_update_app": MessageLookupByLibrary.simpleMessage("앱 업데이트"),
        "about_update_app_alert_ios_mac":
            MessageLookupByLibrary.simpleMessage("앱스토어에서 업데이트를 확인하세요."),
        "about_update_app_detail": m1,
        "account_title": MessageLookupByLibrary.simpleMessage("Account"),
        "active_skill": MessageLookupByLibrary.simpleMessage("보유 스킬"),
        "add": MessageLookupByLibrary.simpleMessage("추가"),
        "add_to_blacklist": MessageLookupByLibrary.simpleMessage("블랙리스트 추가"),
        "ap": MessageLookupByLibrary.simpleMessage("AP"),
        "ap_calc_page_joke":
            MessageLookupByLibrary.simpleMessage("口算不及格的?朗台.jpg"),
        "ap_calc_title": MessageLookupByLibrary.simpleMessage("AP 계산기"),
        "ap_efficiency": MessageLookupByLibrary.simpleMessage("AP 효율"),
        "ap_overflow_time": MessageLookupByLibrary.simpleMessage("AP가 꽉 차는 시간"),
        "append_skill": MessageLookupByLibrary.simpleMessage("어펜드 스킬"),
        "append_skill_short": MessageLookupByLibrary.simpleMessage("어펜드"),
        "ascension": MessageLookupByLibrary.simpleMessage("영기"),
        "ascension_icon":
            MessageLookupByLibrary.simpleMessage("Ascension Icon"),
        "ascension_short": MessageLookupByLibrary.simpleMessage("영기"),
        "ascension_up": MessageLookupByLibrary.simpleMessage("영기재림"),
        "attachment": MessageLookupByLibrary.simpleMessage("애정"),
        "auto_update": MessageLookupByLibrary.simpleMessage("자동 업데이트"),
        "backup": MessageLookupByLibrary.simpleMessage("백업"),
        "backup_data_alert":
            MessageLookupByLibrary.simpleMessage("Timely backup wanted"),
        "backup_history": MessageLookupByLibrary.simpleMessage("백업 기록"),
        "backup_success": MessageLookupByLibrary.simpleMessage("백업 성공"),
        "blacklist": MessageLookupByLibrary.simpleMessage("블랙리스트"),
        "bond": MessageLookupByLibrary.simpleMessage("인연"),
        "bond_craft": MessageLookupByLibrary.simpleMessage("인연예장"),
        "bond_eff": MessageLookupByLibrary.simpleMessage("인연 효율"),
        "boostrap_page_title":
            MessageLookupByLibrary.simpleMessage("Bootstrap Page"),
        "bronze": MessageLookupByLibrary.simpleMessage("동색"),
        "calc_weight": MessageLookupByLibrary.simpleMessage("몸무게"),
        "calculate": MessageLookupByLibrary.simpleMessage("계산"),
        "calculator": MessageLookupByLibrary.simpleMessage("계산기"),
        "campaign_event": MessageLookupByLibrary.simpleMessage("캠페인"),
        "cancel": MessageLookupByLibrary.simpleMessage("취소"),
        "card_description": MessageLookupByLibrary.simpleMessage("상세 정보"),
        "card_info": MessageLookupByLibrary.simpleMessage("정보"),
        "carousel_setting": MessageLookupByLibrary.simpleMessage("배너 설정"),
        "chaldea_user": MessageLookupByLibrary.simpleMessage("Chaldea User"),
        "change_log": MessageLookupByLibrary.simpleMessage("업데이트 내역"),
        "characters_in_card": MessageLookupByLibrary.simpleMessage("캐릭터"),
        "check_update": MessageLookupByLibrary.simpleMessage("업데이트 확인"),
        "choose_quest_hint": MessageLookupByLibrary.simpleMessage("프리퀘스트 선택"),
        "clear": MessageLookupByLibrary.simpleMessage("지우기"),
        "clear_cache": MessageLookupByLibrary.simpleMessage("캐시 삭제하기"),
        "clear_cache_finish": MessageLookupByLibrary.simpleMessage("캐시 삭제됨"),
        "clear_cache_hint":
            MessageLookupByLibrary.simpleMessage("일러스트와 음성을 포함"),
        "clear_data": MessageLookupByLibrary.simpleMessage("Clear Data"),
        "clear_userdata": MessageLookupByLibrary.simpleMessage("사용자 데이터 지우기"),
        "cmd_code_title": MessageLookupByLibrary.simpleMessage("커맨드 코드"),
        "command_code": MessageLookupByLibrary.simpleMessage("커맨드 코드"),
        "confirm": MessageLookupByLibrary.simpleMessage("확인"),
        "consumed": MessageLookupByLibrary.simpleMessage("소비량"),
        "copied": MessageLookupByLibrary.simpleMessage("복사됨"),
        "copy": MessageLookupByLibrary.simpleMessage("복사하기"),
        "copy_plan_menu": MessageLookupByLibrary.simpleMessage("다른 플랜에서 복사"),
        "costume": MessageLookupByLibrary.simpleMessage("영의"),
        "costume_unlock": MessageLookupByLibrary.simpleMessage("영의개방"),
        "counts": MessageLookupByLibrary.simpleMessage("카운트"),
        "craft_essence": MessageLookupByLibrary.simpleMessage("개념예장"),
        "craft_essence_title": MessageLookupByLibrary.simpleMessage("개념예장"),
        "create_account_textfield_helper": MessageLookupByLibrary.simpleMessage(
            "You can add more accounts later in Settings"),
        "create_account_textfield_hint":
            MessageLookupByLibrary.simpleMessage("Any name"),
        "create_duplicated_svt":
            MessageLookupByLibrary.simpleMessage("2호기 생성하기"),
        "critical_attack": MessageLookupByLibrary.simpleMessage("크리티컬"),
        "cur_account": MessageLookupByLibrary.simpleMessage("계정"),
        "cur_ap": MessageLookupByLibrary.simpleMessage("남아있는 AP"),
        "current_": MessageLookupByLibrary.simpleMessage("현재"),
        "current_version":
            MessageLookupByLibrary.simpleMessage("Current Version"),
        "database": MessageLookupByLibrary.simpleMessage("Database"),
        "database_not_downloaded": MessageLookupByLibrary.simpleMessage(
            "Database is not downloaded, still continue?"),
        "dataset_goto_download_page":
            MessageLookupByLibrary.simpleMessage("다운로드 페이지로 이동"),
        "dataset_goto_download_page_hint":
            MessageLookupByLibrary.simpleMessage("다운로드 후 수동으로 불러오기"),
        "dataset_management": MessageLookupByLibrary.simpleMessage("데이터베이스"),
        "dataset_type_image": MessageLookupByLibrary.simpleMessage("아이콘 데이터"),
        "dataset_type_text": MessageLookupByLibrary.simpleMessage("텍스트 데이터"),
        "debug": MessageLookupByLibrary.simpleMessage("Debug"),
        "debug_fab": MessageLookupByLibrary.simpleMessage("Debug FAB"),
        "debug_menu": MessageLookupByLibrary.simpleMessage("Debug Menu"),
        "delete": MessageLookupByLibrary.simpleMessage("삭제"),
        "demands": MessageLookupByLibrary.simpleMessage("요구량"),
        "display_setting": MessageLookupByLibrary.simpleMessage("화면 설정"),
        "done": MessageLookupByLibrary.simpleMessage("DONE"),
        "download": MessageLookupByLibrary.simpleMessage("다운로드"),
        "download_complete": MessageLookupByLibrary.simpleMessage("다운로드 완료"),
        "download_full_gamedata":
            MessageLookupByLibrary.simpleMessage("최신 데이터 다운로드"),
        "download_full_gamedata_hint":
            MessageLookupByLibrary.simpleMessage("최대 용량 압축 파일"),
        "download_latest_gamedata":
            MessageLookupByLibrary.simpleMessage("최신 데이터 다운로드"),
        "download_latest_gamedata_hint": MessageLookupByLibrary.simpleMessage(
            "호환성을 보장하려면 업데이트 전에 최신 APP 버전으로 업그레이드하십시오."),
        "download_source": MessageLookupByLibrary.simpleMessage("다운로드 소스"),
        "download_source_hint":
            MessageLookupByLibrary.simpleMessage("데이터셋과 앱을 업데이트 하십시오"),
        "download_source_of": m2,
        "downloaded": MessageLookupByLibrary.simpleMessage("다운로드 끝남"),
        "downloading": MessageLookupByLibrary.simpleMessage("다운로드 중"),
        "drop_calc_empty_hint":
            MessageLookupByLibrary.simpleMessage("+를 클릭하여 아이템 추가"),
        "drop_calc_min_ap": MessageLookupByLibrary.simpleMessage("최소 AP"),
        "drop_calc_optimize": MessageLookupByLibrary.simpleMessage("최적화"),
        "drop_calc_solve": MessageLookupByLibrary.simpleMessage("풀이"),
        "drop_rate": MessageLookupByLibrary.simpleMessage("드롭률"),
        "edit": MessageLookupByLibrary.simpleMessage("수정"),
        "effect_search": MessageLookupByLibrary.simpleMessage("버프 검색"),
        "efficiency": MessageLookupByLibrary.simpleMessage("효율"),
        "efficiency_type": MessageLookupByLibrary.simpleMessage("효율 타입"),
        "efficiency_type_ap": MessageLookupByLibrary.simpleMessage("20AP 효율"),
        "efficiency_type_drop": MessageLookupByLibrary.simpleMessage("드롭률"),
        "enemy_list": MessageLookupByLibrary.simpleMessage("적"),
        "enhance": MessageLookupByLibrary.simpleMessage("강화"),
        "enhance_warning":
            MessageLookupByLibrary.simpleMessage("강화하게 되면 다음 아이템이 소비됩니다"),
        "error_no_internet": MessageLookupByLibrary.simpleMessage("인터넷 연결 없음"),
        "error_no_network": MessageLookupByLibrary.simpleMessage("No network"),
        "error_no_version_data_found":
            MessageLookupByLibrary.simpleMessage("No version data found"),
        "error_required_app_version": m3,
        "event_collect_item_confirm": MessageLookupByLibrary.simpleMessage(
            "모든 아이템을 창고에 추가하고 플랜에서 이벤트를 삭제합니다"),
        "event_collect_items": MessageLookupByLibrary.simpleMessage("아이템 수집"),
        "event_item_default":
            MessageLookupByLibrary.simpleMessage("상점/미션/포인트/퀘스트"),
        "event_item_extra": MessageLookupByLibrary.simpleMessage("기타 아이템"),
        "event_lottery_limit_hint": m4,
        "event_lottery_limited": MessageLookupByLibrary.simpleMessage("제한된 룰렛"),
        "event_lottery_unit": MessageLookupByLibrary.simpleMessage("룰렛"),
        "event_lottery_unlimited":
            MessageLookupByLibrary.simpleMessage("무제한 룰렛"),
        "event_not_planned":
            MessageLookupByLibrary.simpleMessage("이벤트가 계획되지 않았습니다"),
        "event_progress": MessageLookupByLibrary.simpleMessage("진행 중인 이벤트"),
        "event_rerun_replace_grail": m5,
        "event_title": MessageLookupByLibrary.simpleMessage("이벤트"),
        "exchange_ticket": MessageLookupByLibrary.simpleMessage("교환 티켓"),
        "exchange_ticket_short": MessageLookupByLibrary.simpleMessage("티켓"),
        "exp_card_plan_lv": MessageLookupByLibrary.simpleMessage("레벨"),
        "exp_card_rarity5": MessageLookupByLibrary.simpleMessage("5성 종화"),
        "exp_card_same_class": MessageLookupByLibrary.simpleMessage("같은 클래스"),
        "exp_card_select_lvs": MessageLookupByLibrary.simpleMessage("레벨 범위 선택"),
        "exp_card_title": MessageLookupByLibrary.simpleMessage("경험치 카드"),
        "failed": MessageLookupByLibrary.simpleMessage("실패"),
        "favorite": MessageLookupByLibrary.simpleMessage("즐겨찾기"),
        "feedback_add_attachments":
            MessageLookupByLibrary.simpleMessage("스크린샷 또는 파일 추가"),
        "feedback_add_crash_log":
            MessageLookupByLibrary.simpleMessage("크래쉬 로그 추가"),
        "feedback_contact": MessageLookupByLibrary.simpleMessage("연락처 정보"),
        "feedback_content_hint":
            MessageLookupByLibrary.simpleMessage("피드백 또는 제안"),
        "feedback_send": MessageLookupByLibrary.simpleMessage("전송"),
        "feedback_subject": MessageLookupByLibrary.simpleMessage("항목명"),
        "ffo_background": MessageLookupByLibrary.simpleMessage("배경"),
        "ffo_body": MessageLookupByLibrary.simpleMessage("몸"),
        "ffo_crop": MessageLookupByLibrary.simpleMessage("자르기"),
        "ffo_head": MessageLookupByLibrary.simpleMessage("머리"),
        "ffo_missing_data_hint":
            MessageLookupByLibrary.simpleMessage("먼저 FFO데이터를 다운로드하거나 가져오세요↗"),
        "ffo_same_svt": MessageLookupByLibrary.simpleMessage("동일 서번트"),
        "fgo_domus_aurea": MessageLookupByLibrary.simpleMessage("FGO 도무스 아우레아"),
        "file_not_found_or_mismatched_hash": m6,
        "filename": MessageLookupByLibrary.simpleMessage("파일명"),
        "filter": MessageLookupByLibrary.simpleMessage("필터"),
        "filter_atk_hp_type": MessageLookupByLibrary.simpleMessage("타입"),
        "filter_attribute": MessageLookupByLibrary.simpleMessage("속성"),
        "filter_category": MessageLookupByLibrary.simpleMessage("카테고리"),
        "filter_effects": MessageLookupByLibrary.simpleMessage("효과"),
        "filter_gender": MessageLookupByLibrary.simpleMessage("성별"),
        "filter_match_all": MessageLookupByLibrary.simpleMessage("모두 선택"),
        "filter_obtain": MessageLookupByLibrary.simpleMessage("습득 방법"),
        "filter_plan_not_reached":
            MessageLookupByLibrary.simpleMessage("계획 미달성"),
        "filter_plan_reached": MessageLookupByLibrary.simpleMessage("계획 달성"),
        "filter_revert": MessageLookupByLibrary.simpleMessage("역선택"),
        "filter_shown_type": MessageLookupByLibrary.simpleMessage("표시"),
        "filter_skill_lv": MessageLookupByLibrary.simpleMessage("스킬 레벨"),
        "filter_sort": MessageLookupByLibrary.simpleMessage("정렬"),
        "filter_sort_class": MessageLookupByLibrary.simpleMessage("클래스"),
        "filter_sort_number": MessageLookupByLibrary.simpleMessage("번호"),
        "filter_sort_rarity": MessageLookupByLibrary.simpleMessage("레어도"),
        "filter_special_trait": MessageLookupByLibrary.simpleMessage("특별한 특성"),
        "free_efficiency": MessageLookupByLibrary.simpleMessage("자유 효율"),
        "free_progress": MessageLookupByLibrary.simpleMessage("퀘스트"),
        "free_progress_newest": MessageLookupByLibrary.simpleMessage("최신(일그오)"),
        "free_quest": MessageLookupByLibrary.simpleMessage("프리 퀘스트"),
        "free_quest_calculator": MessageLookupByLibrary.simpleMessage("프리 퀘스트"),
        "free_quest_calculator_short":
            MessageLookupByLibrary.simpleMessage("프리 퀘스트"),
        "gallery_tab_name": MessageLookupByLibrary.simpleMessage("홈"),
        "game_data_not_found": MessageLookupByLibrary.simpleMessage(
            "Game data not found, please download data first"),
        "game_drop": MessageLookupByLibrary.simpleMessage("드롭"),
        "game_experience": MessageLookupByLibrary.simpleMessage("경험치"),
        "game_kizuna": MessageLookupByLibrary.simpleMessage("몽화"),
        "game_rewards": MessageLookupByLibrary.simpleMessage("보상"),
        "game_server": MessageLookupByLibrary.simpleMessage("서버"),
        "game_server_cn": MessageLookupByLibrary.simpleMessage("중국"),
        "game_server_jp": MessageLookupByLibrary.simpleMessage("일본"),
        "game_server_na": MessageLookupByLibrary.simpleMessage("북미"),
        "game_server_tw": MessageLookupByLibrary.simpleMessage("대만"),
        "gamedata": MessageLookupByLibrary.simpleMessage("게임 데이터"),
        "gold": MessageLookupByLibrary.simpleMessage("금색"),
        "grail": MessageLookupByLibrary.simpleMessage("성배"),
        "grail_level": MessageLookupByLibrary.simpleMessage("성배"),
        "grail_up": MessageLookupByLibrary.simpleMessage("성배전림"),
        "growth_curve": MessageLookupByLibrary.simpleMessage("성장 곡선"),
        "guda_item_data": MessageLookupByLibrary.simpleMessage("Guda 아이템 데이터"),
        "guda_servant_data":
            MessageLookupByLibrary.simpleMessage("Guda 서번트 데이터"),
        "hash_mismatch": m7,
        "hello": MessageLookupByLibrary.simpleMessage("안녕하십니까, 마스터."),
        "help": MessageLookupByLibrary.simpleMessage("도움말"),
        "hide_outdated": MessageLookupByLibrary.simpleMessage("기간종료 숨기기"),
        "hint_no_bond_craft": MessageLookupByLibrary.simpleMessage("인연예장 없음"),
        "hint_no_valentine_craft":
            MessageLookupByLibrary.simpleMessage("발렌타인 예장 없음"),
        "icons": MessageLookupByLibrary.simpleMessage("아이콘"),
        "ignore": MessageLookupByLibrary.simpleMessage("무시"),
        "illustration": MessageLookupByLibrary.simpleMessage("일러스트"),
        "illustrator": MessageLookupByLibrary.simpleMessage("일러스트레이터"),
        "image_analysis": MessageLookupByLibrary.simpleMessage("이미지 분석"),
        "import_data": MessageLookupByLibrary.simpleMessage("불러오기"),
        "import_data_error": m8,
        "import_data_success":
            MessageLookupByLibrary.simpleMessage("불러오기를 성공했습니다"),
        "import_guda_data": MessageLookupByLibrary.simpleMessage("Guda 데이터"),
        "import_guda_hint": MessageLookupByLibrary.simpleMessage(
            "업데이트：사용자 데이터를 보존하고 업데이트(권장)\n덮어쓰기：사용자 데이터를 삭제하고 업데이트"),
        "import_guda_items": MessageLookupByLibrary.simpleMessage("아이템 불러오기"),
        "import_guda_servants":
            MessageLookupByLibrary.simpleMessage("서번트 불러오기"),
        "import_http_body_duplicated":
            MessageLookupByLibrary.simpleMessage("중복 서번트"),
        "import_http_body_hint": MessageLookupByLibrary.simpleMessage(
            "복호환된 HTTPS 응답을 출력하기 위해 출력버튼을 누르세요"),
        "import_http_body_hint_hide":
            MessageLookupByLibrary.simpleMessage("서번트를 클릭해서 숨기기,표시하기"),
        "import_http_body_locked":
            MessageLookupByLibrary.simpleMessage("잠금된것만"),
        "import_http_body_success_switch": m9,
        "import_http_body_target_account_header": m10,
        "import_screenshot": MessageLookupByLibrary.simpleMessage("스크린샷 가져오기"),
        "import_screenshot_hint":
            MessageLookupByLibrary.simpleMessage("식별된 자료들만 갱신하기"),
        "import_screenshot_update_items":
            MessageLookupByLibrary.simpleMessage("갱신소재"),
        "import_source_file":
            MessageLookupByLibrary.simpleMessage("소스 파일 가져오기"),
        "info_agility": MessageLookupByLibrary.simpleMessage("민첩"),
        "info_alignment": MessageLookupByLibrary.simpleMessage("성향"),
        "info_bond_points": MessageLookupByLibrary.simpleMessage("인연 포인트"),
        "info_bond_points_single": MessageLookupByLibrary.simpleMessage("포인트"),
        "info_bond_points_sum": MessageLookupByLibrary.simpleMessage("합계"),
        "info_cards": MessageLookupByLibrary.simpleMessage("카드"),
        "info_critical_rate": MessageLookupByLibrary.simpleMessage("스타 집중도"),
        "info_cv": MessageLookupByLibrary.simpleMessage("CV"),
        "info_death_rate": MessageLookupByLibrary.simpleMessage("즉사율"),
        "info_endurance": MessageLookupByLibrary.simpleMessage("내구"),
        "info_gender": MessageLookupByLibrary.simpleMessage("성별"),
        "info_height": MessageLookupByLibrary.simpleMessage("신장"),
        "info_human": MessageLookupByLibrary.simpleMessage("인간형"),
        "info_luck": MessageLookupByLibrary.simpleMessage("행운"),
        "info_mana": MessageLookupByLibrary.simpleMessage("마력"),
        "info_np": MessageLookupByLibrary.simpleMessage("보구"),
        "info_np_rate": MessageLookupByLibrary.simpleMessage("NP 수급률"),
        "info_star_rate": MessageLookupByLibrary.simpleMessage("스타 수급률"),
        "info_strength": MessageLookupByLibrary.simpleMessage("근력"),
        "info_trait": MessageLookupByLibrary.simpleMessage("속성"),
        "info_value": MessageLookupByLibrary.simpleMessage("값"),
        "info_weak_to_ea": MessageLookupByLibrary.simpleMessage("에누마 엘리시에 취약"),
        "info_weight": MessageLookupByLibrary.simpleMessage("몸무게"),
        "input_invalid_hint":
            MessageLookupByLibrary.simpleMessage("입력이 유효하지 않습니다"),
        "install": MessageLookupByLibrary.simpleMessage("설치"),
        "interlude_and_rankup":
            MessageLookupByLibrary.simpleMessage("막간퀘 및 강화퀘"),
        "invalid_input": MessageLookupByLibrary.simpleMessage("Invalid input."),
        "invalid_startup_path":
            MessageLookupByLibrary.simpleMessage("Invalid startup path!"),
        "invalid_startup_path_info": MessageLookupByLibrary.simpleMessage(
            "Please, extract zip to non-system path then start the app. \"C:\\\", \"C:\\Program Files\" are not allowed."),
        "ios_app_path": MessageLookupByLibrary.simpleMessage(
            "\"Files\" app/On My iPhone/Chaldea"),
        "issues": MessageLookupByLibrary.simpleMessage("문제"),
        "item": MessageLookupByLibrary.simpleMessage("아이템"),
        "item_already_exist_hint": m11,
        "item_category_ascension":
            MessageLookupByLibrary.simpleMessage("영기재림 재료"),
        "item_category_bronze": MessageLookupByLibrary.simpleMessage("동색 아이템"),
        "item_category_event_svt_ascension":
            MessageLookupByLibrary.simpleMessage("이벤트 아이템"),
        "item_category_gem": MessageLookupByLibrary.simpleMessage("휘석"),
        "item_category_gems": MessageLookupByLibrary.simpleMessage("스킬 강화 아이템"),
        "item_category_gold": MessageLookupByLibrary.simpleMessage("금색 아이템"),
        "item_category_magic_gem": MessageLookupByLibrary.simpleMessage("마석"),
        "item_category_monument": MessageLookupByLibrary.simpleMessage("모뉴먼트"),
        "item_category_others": MessageLookupByLibrary.simpleMessage("기타"),
        "item_category_piece": MessageLookupByLibrary.simpleMessage("피스"),
        "item_category_secret_gem": MessageLookupByLibrary.simpleMessage("비석"),
        "item_category_silver": MessageLookupByLibrary.simpleMessage("은색 아이템"),
        "item_category_special": MessageLookupByLibrary.simpleMessage("특별 아이템"),
        "item_category_usual": MessageLookupByLibrary.simpleMessage("아이템"),
        "item_eff": MessageLookupByLibrary.simpleMessage("아이템 효율"),
        "item_exceed_hint": MessageLookupByLibrary.simpleMessage(
            "플랜을 계산하기 전에 초과한 재료를 설정할 수 있습니다(프리퀘스트 플랜의 경우에만)"),
        "item_left": MessageLookupByLibrary.simpleMessage("나머지"),
        "item_no_free_quests": MessageLookupByLibrary.simpleMessage("프리퀘스트 없음"),
        "item_only_show_lack":
            MessageLookupByLibrary.simpleMessage("부족한 것만 표시"),
        "item_own": MessageLookupByLibrary.simpleMessage("소유"),
        "item_screenshot": MessageLookupByLibrary.simpleMessage("아이템 캡처"),
        "item_title": MessageLookupByLibrary.simpleMessage("아이템"),
        "item_total_demand": MessageLookupByLibrary.simpleMessage("합계"),
        "join_beta": MessageLookupByLibrary.simpleMessage("베타 프로그램에 참가하기"),
        "jump_to": m12,
        "language": MessageLookupByLibrary.simpleMessage("한국어"),
        "language_en": MessageLookupByLibrary.simpleMessage("Korean"),
        "level": MessageLookupByLibrary.simpleMessage("레벨"),
        "limited_event": MessageLookupByLibrary.simpleMessage("기간 한정 이벤트"),
        "link": MessageLookupByLibrary.simpleMessage("링크"),
        "list_end_hint": m13,
        "load_dataset_error": MessageLookupByLibrary.simpleMessage("불러오기 실패"),
        "load_dataset_error_hint": MessageLookupByLibrary.simpleMessage(
            "먼저 설정-게임 데이터에서 기본 리소스를 다시 불러와주세요"),
        "loading_data_failed":
            MessageLookupByLibrary.simpleMessage("Loading Data Failed"),
        "login_change_password":
            MessageLookupByLibrary.simpleMessage("비밀번호 변경"),
        "login_first_hint":
            MessageLookupByLibrary.simpleMessage("먼저 로그인을 해주세요"),
        "login_forget_pwd":
            MessageLookupByLibrary.simpleMessage("비밀번호를 잊어버렸습니다"),
        "login_login": MessageLookupByLibrary.simpleMessage("로그인"),
        "login_logout": MessageLookupByLibrary.simpleMessage("로그아웃"),
        "login_new_password": MessageLookupByLibrary.simpleMessage("새 비밀번호"),
        "login_password": MessageLookupByLibrary.simpleMessage("비밀번호"),
        "login_password_error":
            MessageLookupByLibrary.simpleMessage("4자리 이상 문자와 숫자만"),
        "login_password_error_same_as_old":
            MessageLookupByLibrary.simpleMessage("이전 비밀번호와 같음"),
        "login_signup": MessageLookupByLibrary.simpleMessage("회원가입"),
        "login_state_not_login":
            MessageLookupByLibrary.simpleMessage("로그인이 필요합니다"),
        "login_username": MessageLookupByLibrary.simpleMessage("사용자 이름"),
        "login_username_error":
            MessageLookupByLibrary.simpleMessage("4자리 이상의 문자 또는 숫자로 구성할수 있습니다"),
        "long_press_to_save_hint":
            MessageLookupByLibrary.simpleMessage("길게 눌러서 저장"),
        "lucky_bag": MessageLookupByLibrary.simpleMessage("복주머니"),
        "main_record": MessageLookupByLibrary.simpleMessage("메인 스토리"),
        "main_record_bonus": MessageLookupByLibrary.simpleMessage("보너스"),
        "main_record_bonus_short": MessageLookupByLibrary.simpleMessage("보너스"),
        "main_record_chapter": MessageLookupByLibrary.simpleMessage("챕터"),
        "main_record_fixed_drop": MessageLookupByLibrary.simpleMessage("드롭"),
        "main_record_fixed_drop_short":
            MessageLookupByLibrary.simpleMessage("드롭"),
        "master_detail_width":
            MessageLookupByLibrary.simpleMessage("Master-Detail width"),
        "master_mission": MessageLookupByLibrary.simpleMessage("마스터 미션"),
        "master_mission_related_quest":
            MessageLookupByLibrary.simpleMessage("관련된 퀘스트"),
        "master_mission_solution": MessageLookupByLibrary.simpleMessage("풀이"),
        "master_mission_tasklist": MessageLookupByLibrary.simpleMessage("미션"),
        "max_ap": MessageLookupByLibrary.simpleMessage("AP 최대량"),
        "more": MessageLookupByLibrary.simpleMessage("더보기"),
        "mystic_code": MessageLookupByLibrary.simpleMessage("마술예장"),
        "new_account": MessageLookupByLibrary.simpleMessage("새 계정 추가"),
        "next": MessageLookupByLibrary.simpleMessage("NEXT"),
        "next_card": MessageLookupByLibrary.simpleMessage("다음"),
        "nga": MessageLookupByLibrary.simpleMessage("NGA"),
        "nga_fgo": MessageLookupByLibrary.simpleMessage("NGA-FGO"),
        "no": MessageLookupByLibrary.simpleMessage("X"),
        "no_servant_quest_hint":
            MessageLookupByLibrary.simpleMessage("막간의 이야기 또는 강화 퀘스트가 없습니다"),
        "no_servant_quest_hint_subtitle":
            MessageLookupByLibrary.simpleMessage("♡를 클릭해서 모든 퀘스트를 표시합니다"),
        "noble_phantasm": MessageLookupByLibrary.simpleMessage("보구"),
        "noble_phantasm_level": MessageLookupByLibrary.simpleMessage("보구 레벨"),
        "not_available": MessageLookupByLibrary.simpleMessage("Not Available"),
        "not_found": MessageLookupByLibrary.simpleMessage("Not Found"),
        "obtain_methods": MessageLookupByLibrary.simpleMessage("습득방법"),
        "ok": MessageLookupByLibrary.simpleMessage("확인"),
        "open": MessageLookupByLibrary.simpleMessage("열기"),
        "open_condition": MessageLookupByLibrary.simpleMessage("개방 조건"),
        "overview": MessageLookupByLibrary.simpleMessage("개요"),
        "overwrite": MessageLookupByLibrary.simpleMessage("덮어쓰기"),
        "passive_skill": MessageLookupByLibrary.simpleMessage("클래스 스킬"),
        "patch_gamedata": MessageLookupByLibrary.simpleMessage("게임 데이터 갱신"),
        "patch_gamedata_error_no_compatible":
            MessageLookupByLibrary.simpleMessage("현재 앱 버전과 호환되는 버전이 없습니다"),
        "patch_gamedata_error_unknown_version":
            MessageLookupByLibrary.simpleMessage(
                "서버에 현재 버전이 존재하지 않습니다, 앱을 재설치 해주세요 "),
        "patch_gamedata_hint": MessageLookupByLibrary.simpleMessage("패치만 다운로드"),
        "patch_gamedata_success_to": m14,
        "plan": MessageLookupByLibrary.simpleMessage("계획"),
        "plan_max10": MessageLookupByLibrary.simpleMessage("계획 최대(310)"),
        "plan_max9": MessageLookupByLibrary.simpleMessage("계획 최대(999)"),
        "plan_objective": MessageLookupByLibrary.simpleMessage("계획 목표"),
        "plan_title": MessageLookupByLibrary.simpleMessage("계획표"),
        "plan_x": m15,
        "planning_free_quest_btn": MessageLookupByLibrary.simpleMessage("퀘스트"),
        "prev": MessageLookupByLibrary.simpleMessage("PREV"),
        "preview": MessageLookupByLibrary.simpleMessage("미리보기"),
        "previous_card": MessageLookupByLibrary.simpleMessage("이전"),
        "priority": MessageLookupByLibrary.simpleMessage("우선 순위"),
        "project_homepage": MessageLookupByLibrary.simpleMessage("프로젝트 홈페이지"),
        "query_failed": MessageLookupByLibrary.simpleMessage("쿼리를 실패했습니다"),
        "quest": MessageLookupByLibrary.simpleMessage("퀘스트"),
        "quest_condition": MessageLookupByLibrary.simpleMessage("개방 조건"),
        "rarity": MessageLookupByLibrary.simpleMessage("레어도"),
        "release_page": MessageLookupByLibrary.simpleMessage("웹사이트"),
        "reload_data_success": MessageLookupByLibrary.simpleMessage("불러오기 성공"),
        "reload_default_gamedata":
            MessageLookupByLibrary.simpleMessage("기본으로 재설정"),
        "reloading_data": MessageLookupByLibrary.simpleMessage("불러오는 중"),
        "remove_duplicated_svt":
            MessageLookupByLibrary.simpleMessage("2호기 삭제하기"),
        "remove_from_blacklist":
            MessageLookupByLibrary.simpleMessage("블랙리스트 삭제"),
        "rename": MessageLookupByLibrary.simpleMessage("이름 변경"),
        "rerun_event": MessageLookupByLibrary.simpleMessage("복각 이벤트"),
        "reset": MessageLookupByLibrary.simpleMessage("초기화"),
        "reset_plan_all": m16,
        "reset_plan_shown": m17,
        "reset_success": MessageLookupByLibrary.simpleMessage("초기화 성공"),
        "reset_svt_enhance_state":
            MessageLookupByLibrary.simpleMessage("스킬/보구 초기화"),
        "reset_svt_enhance_state_hint":
            MessageLookupByLibrary.simpleMessage("스킬/보구렙 초기화"),
        "restart_to_take_effect":
            MessageLookupByLibrary.simpleMessage("Restart to take effect"),
        "restart_to_upgrade_hint": MessageLookupByLibrary.simpleMessage(
            "업데이트 후 재시작합니다. 만약 업데이트에 실패했다면 수동으로 소스 파일을 다른곳에 옮겨주시기 바랍니다."),
        "restore": MessageLookupByLibrary.simpleMessage("복원"),
        "save": MessageLookupByLibrary.simpleMessage("저장"),
        "save_to_photos": MessageLookupByLibrary.simpleMessage("사진 저장하기"),
        "saved": MessageLookupByLibrary.simpleMessage("저장됨"),
        "search": MessageLookupByLibrary.simpleMessage("검색"),
        "search_option_basic": MessageLookupByLibrary.simpleMessage("기본 옵션"),
        "search_options": MessageLookupByLibrary.simpleMessage("검색 옵션"),
        "search_result_count": m18,
        "search_result_count_hide": m19,
        "select_copy_plan_source":
            MessageLookupByLibrary.simpleMessage("복사할 파일을 선택"),
        "select_lang": MessageLookupByLibrary.simpleMessage("Select Language"),
        "select_plan": MessageLookupByLibrary.simpleMessage("계획 선택"),
        "servant": MessageLookupByLibrary.simpleMessage("서번트"),
        "servant_coin": MessageLookupByLibrary.simpleMessage("서번트 코인"),
        "servant_detail_page":
            MessageLookupByLibrary.simpleMessage("서번트 상세 페이지"),
        "servant_list_page":
            MessageLookupByLibrary.simpleMessage("서번트 리스트 페이지"),
        "servant_title": MessageLookupByLibrary.simpleMessage("서번트"),
        "set_plan_name": MessageLookupByLibrary.simpleMessage("계획 이름 설정"),
        "setting_always_on_top":
            MessageLookupByLibrary.simpleMessage("항상 맨 위에 표시"),
        "setting_auto_rotate": MessageLookupByLibrary.simpleMessage("자동 회전"),
        "setting_auto_turn_on_plan_not_reach":
            MessageLookupByLibrary.simpleMessage("Auto Turn on PlanNotReach"),
        "setting_home_plan_list_page":
            MessageLookupByLibrary.simpleMessage("홈-계획 리스트 페이지"),
        "setting_only_change_second_append_skill":
            MessageLookupByLibrary.simpleMessage("어펜드 스킬 2만 변경"),
        "setting_plans_list_page":
            MessageLookupByLibrary.simpleMessage("Plans List Page"),
        "setting_priority_tagging":
            MessageLookupByLibrary.simpleMessage("우선순위 매기기"),
        "setting_servant_class_filter_style":
            MessageLookupByLibrary.simpleMessage("서번트 클래스 필터 스타일"),
        "setting_setting_favorite_button_default":
            MessageLookupByLibrary.simpleMessage("「즐겨찾기」버튼 디폴트"),
        "setting_show_account_at_homepage":
            MessageLookupByLibrary.simpleMessage("홈페이지에 계정 표시"),
        "setting_tabs_sorting":
            MessageLookupByLibrary.simpleMessage("페이지 표시 순서"),
        "settings_data": MessageLookupByLibrary.simpleMessage("데이터"),
        "settings_data_management":
            MessageLookupByLibrary.simpleMessage("데이터베이스"),
        "settings_documents": MessageLookupByLibrary.simpleMessage("사용 설명서"),
        "settings_general": MessageLookupByLibrary.simpleMessage("일반"),
        "settings_language": MessageLookupByLibrary.simpleMessage("언어"),
        "settings_tab_name": MessageLookupByLibrary.simpleMessage("설정"),
        "settings_use_mobile_network":
            MessageLookupByLibrary.simpleMessage("모바일 데이터 허용"),
        "settings_userdata_footer": MessageLookupByLibrary.simpleMessage(
            "앱 업데이트 전에 유저 데이터를 백업하시고,앱 폴더외의 안전한 공간에 보관하십시오"),
        "share": MessageLookupByLibrary.simpleMessage("공유"),
        "show_frame_rate":
            MessageLookupByLibrary.simpleMessage("Show Frame Rate"),
        "show_outdated": MessageLookupByLibrary.simpleMessage("기간종료 보이기"),
        "silver": MessageLookupByLibrary.simpleMessage("은색"),
        "simulator": MessageLookupByLibrary.simpleMessage("시뮬레이터"),
        "skill": MessageLookupByLibrary.simpleMessage("스킬"),
        "skill_up": MessageLookupByLibrary.simpleMessage("스킬 강화"),
        "skilled_max10": MessageLookupByLibrary.simpleMessage("스킬 최대(310)"),
        "sprites": MessageLookupByLibrary.simpleMessage("스프라이트"),
        "statistics_include_checkbox":
            MessageLookupByLibrary.simpleMessage("가진 아이템도 포함"),
        "statistics_title": MessageLookupByLibrary.simpleMessage("통계"),
        "storage_permission_title":
            MessageLookupByLibrary.simpleMessage("스토리지 권한"),
        "success": MessageLookupByLibrary.simpleMessage("성공"),
        "summon": MessageLookupByLibrary.simpleMessage("가챠"),
        "summon_simulator": MessageLookupByLibrary.simpleMessage("소환 시뮬레이터"),
        "summon_title": MessageLookupByLibrary.simpleMessage("가챠"),
        "support_chaldea": MessageLookupByLibrary.simpleMessage("서포트 및 기부하기"),
        "support_party": MessageLookupByLibrary.simpleMessage("서포트 파티"),
        "svt_info_tab_base": MessageLookupByLibrary.simpleMessage("기본 정보"),
        "svt_info_tab_bond_story": MessageLookupByLibrary.simpleMessage("프로필"),
        "svt_not_planned": MessageLookupByLibrary.simpleMessage("팔로우 하지않음"),
        "svt_obtain_event": MessageLookupByLibrary.simpleMessage("이벤트"),
        "svt_obtain_friend_point":
            MessageLookupByLibrary.simpleMessage("친구포인트"),
        "svt_obtain_initial": MessageLookupByLibrary.simpleMessage("초기"),
        "svt_obtain_limited": MessageLookupByLibrary.simpleMessage("한정"),
        "svt_obtain_permanent": MessageLookupByLibrary.simpleMessage("상시"),
        "svt_obtain_story": MessageLookupByLibrary.simpleMessage("스토리"),
        "svt_obtain_unavailable":
            MessageLookupByLibrary.simpleMessage("획득할 수 없음"),
        "svt_plan_hidden": MessageLookupByLibrary.simpleMessage("숨김"),
        "svt_related_cards": MessageLookupByLibrary.simpleMessage("관련 카드"),
        "svt_reset_plan": MessageLookupByLibrary.simpleMessage("계획 초기화"),
        "svt_switch_slider_dropdown":
            MessageLookupByLibrary.simpleMessage("Slider/Dropdown 전환"),
        "sync_server": m20,
        "toogle_dark_mode":
            MessageLookupByLibrary.simpleMessage("Toggle Dark Mode"),
        "tooltip_refresh_sliders":
            MessageLookupByLibrary.simpleMessage("슬라이드 갱신"),
        "total_ap": MessageLookupByLibrary.simpleMessage("AP 합계"),
        "total_counts": MessageLookupByLibrary.simpleMessage("합계 카운트"),
        "translations": MessageLookupByLibrary.simpleMessage("Translations"),
        "unsupported_type":
            MessageLookupByLibrary.simpleMessage("Unsupported type"),
        "update": MessageLookupByLibrary.simpleMessage("갱신"),
        "update_already_latest":
            MessageLookupByLibrary.simpleMessage("이미 최신버전 입니다"),
        "update_dataset": MessageLookupByLibrary.simpleMessage("게임 데이터 갱신하기"),
        "update_now": MessageLookupByLibrary.simpleMessage("Update Now"),
        "upload": MessageLookupByLibrary.simpleMessage("업로드"),
        "userdata": MessageLookupByLibrary.simpleMessage("사용자 데이터"),
        "userdata_cleared":
            MessageLookupByLibrary.simpleMessage("사용자 데이터를 지웠습니다"),
        "userdata_download_backup":
            MessageLookupByLibrary.simpleMessage("백업 파일을 다운로드"),
        "userdata_download_choose_backup":
            MessageLookupByLibrary.simpleMessage("백업 파일을 선택"),
        "userdata_sync": MessageLookupByLibrary.simpleMessage("데이터 동기화"),
        "userdata_upload_backup":
            MessageLookupByLibrary.simpleMessage("백업 파일을 업로드"),
        "valentine_craft": MessageLookupByLibrary.simpleMessage("발렌타인 예장"),
        "version": MessageLookupByLibrary.simpleMessage("버전"),
        "view_illustration": MessageLookupByLibrary.simpleMessage("일러스트 보기"),
        "voice": MessageLookupByLibrary.simpleMessage("음성"),
        "warning": MessageLookupByLibrary.simpleMessage("Warning"),
        "web_renderer": MessageLookupByLibrary.simpleMessage("Web Renderer"),
        "words_separate": m21,
        "yes": MessageLookupByLibrary.simpleMessage("O")
      };
}
