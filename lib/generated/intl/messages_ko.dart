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

  static String m1(curVersion, newVersion, releaseNote) =>
      "현재 버전 : ${curVersion}\nL최신 버전 : ${newVersion}\n개발 노트:\n${releaseNote}";

  static String m2(url) =>
      "Chaldea - 멀티 플랫폼의 Fate/GO 아이템 계획 어플. 게임정보의 열람 및 서번트/이벤트/아이템 계획, 마스터 미션 계획, 가챠 시뮬레이터 등의 기능을 서포트합니다.\n\n자세히 보기: \n${url}\n";

  static String m3(version) => "Required app version: ≥ ${version}";

  static String m4(n) => "최대 ${n}회 제한";

  static String m5(n) => "전승결정으로 대체되는 성배의 개수 : ${n}";

  static String m6(filename, hash, localHash) =>
      "File ${filename} not found or mismatched hash: ${hash} - ${localHash}";

  static String m7(error) => "불러오기 실패. Error:\n${error}";

  static String m8(name) => "${name}은 이미 존재합니다";

  static String m9(site) => "${site}(으)로 이동";

  static String m10(shown, total) => "${shown} 표시 (합계 ${total})";

  static String m11(shown, ignore, total) =>
      "${shown} 표시, ${ignore} 무시 (합계 ${total})";

  static String m12(first) => "${Intl.select(first, {
            'true': '이미 첫번째입니다.',
            'false': '이미 마지막입니다.',
            'other': '마지막입니다.',
          })}";

  static String m14(n) => "계획 초기화 ${n}(모두)";

  static String m15(n) => "계획 초기화 ${n}(표시된)";

  static String m0(a, b) => "${a} ${b}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about_app": MessageLookupByLibrary.simpleMessage("에 관해"),
        "about_app_declaration_text": MessageLookupByLibrary.simpleMessage(
            "이 어플리케이션에 사용되는 데이터는 게임 Fate/GO 및 게임 사이트에서 가져왔습니다. 게임의 텍스트, 그림, 음성의 저작권은 TYPE MOON/FGO PROJECT에 있습니다.\n\n프로그램의 설계는 WeChat의 프로그램인  \"Material Programe\" 과 IOS 앱인  \"Guda\"를 기반으로 제작되었습니다.\n"),
        "about_data_source": MessageLookupByLibrary.simpleMessage("데이터 소스"),
        "about_data_source_footer": MessageLookupByLibrary.simpleMessage(
            "출처가 표시되어 있지 않거나 침해가 있는 경우 알려주세요"),
        "about_feedback": MessageLookupByLibrary.simpleMessage("피드백"),
        "about_update_app_detail": m1,
        "account_title": MessageLookupByLibrary.simpleMessage("Account"),
        "active_skill": MessageLookupByLibrary.simpleMessage("보유 스킬"),
        "add": MessageLookupByLibrary.simpleMessage("추가"),
        "add_feedback_details_warning":
            MessageLookupByLibrary.simpleMessage("피드백 내용을 작성해주세요"),
        "add_to_blacklist": MessageLookupByLibrary.simpleMessage("블랙리스트 추가"),
        "ap": MessageLookupByLibrary.simpleMessage("AP"),
        "ap_efficiency": MessageLookupByLibrary.simpleMessage("AP 효율"),
        "append_skill": MessageLookupByLibrary.simpleMessage("어펜드 스킬"),
        "append_skill_short": MessageLookupByLibrary.simpleMessage("어펜드"),
        "ascension": MessageLookupByLibrary.simpleMessage("영기"),
        "ascension_short": MessageLookupByLibrary.simpleMessage("영기"),
        "ascension_up": MessageLookupByLibrary.simpleMessage("영기재림"),
        "attachment": MessageLookupByLibrary.simpleMessage("애정"),
        "auto_update": MessageLookupByLibrary.simpleMessage("자동 업데이트"),
        "backup": MessageLookupByLibrary.simpleMessage("백업"),
        "backup_failed":
            MessageLookupByLibrary.simpleMessage("백업 불러오기를 실패하였습니다"),
        "backup_history": MessageLookupByLibrary.simpleMessage("백업 기록"),
        "blacklist": MessageLookupByLibrary.simpleMessage("블랙리스트"),
        "bond": MessageLookupByLibrary.simpleMessage("인연"),
        "bond_craft": MessageLookupByLibrary.simpleMessage("인연예장"),
        "bond_eff": MessageLookupByLibrary.simpleMessage("인연 효율"),
        "bootstrap_page_title":
            MessageLookupByLibrary.simpleMessage("Bootstrap Page"),
        "bronze": MessageLookupByLibrary.simpleMessage("동색"),
        "calc_weight": MessageLookupByLibrary.simpleMessage("몸무게"),
        "cancel": MessageLookupByLibrary.simpleMessage("취소"),
        "card_description": MessageLookupByLibrary.simpleMessage("상세 정보"),
        "card_info": MessageLookupByLibrary.simpleMessage("정보"),
        "card_name": MessageLookupByLibrary.simpleMessage("카드명"),
        "carousel_setting": MessageLookupByLibrary.simpleMessage("배너 설정"),
        "chaldea_server_cn": MessageLookupByLibrary.simpleMessage("중국"),
        "chaldea_server_global": MessageLookupByLibrary.simpleMessage("국제성"),
        "chaldea_share_msg": m2,
        "change_log": MessageLookupByLibrary.simpleMessage("업데이트 내역"),
        "characters_in_card": MessageLookupByLibrary.simpleMessage("캐릭터"),
        "check_update": MessageLookupByLibrary.simpleMessage("업데이트 확인"),
        "clear": MessageLookupByLibrary.simpleMessage("지우기"),
        "clear_cache": MessageLookupByLibrary.simpleMessage("캐시 삭제하기"),
        "clear_cache_finish": MessageLookupByLibrary.simpleMessage("캐시 삭제됨"),
        "clear_cache_hint":
            MessageLookupByLibrary.simpleMessage("일러스트와 음성을 포함"),
        "clear_data": MessageLookupByLibrary.simpleMessage("Clear Data"),
        "command_code": MessageLookupByLibrary.simpleMessage("커맨드 코드"),
        "confirm": MessageLookupByLibrary.simpleMessage("확인"),
        "consumed": MessageLookupByLibrary.simpleMessage("소비량"),
        "contact_information_not_filled":
            MessageLookupByLibrary.simpleMessage("연락처 정보가 입력되어있지 않습니다"),
        "contact_information_not_filled_warning":
            MessageLookupByLibrary.simpleMessage("개발자는 당신의 피드백에 응답할 수 없게 됩니다"),
        "copied": MessageLookupByLibrary.simpleMessage("복사됨"),
        "copy": MessageLookupByLibrary.simpleMessage("복사하기"),
        "copy_plan_menu": MessageLookupByLibrary.simpleMessage("다른 플랜에서 복사"),
        "costume": MessageLookupByLibrary.simpleMessage("영의"),
        "costume_unlock": MessageLookupByLibrary.simpleMessage("영의개방"),
        "counts": MessageLookupByLibrary.simpleMessage("카운트"),
        "craft_essence": MessageLookupByLibrary.simpleMessage("개념예장"),
        "create_account_textfield_helper": MessageLookupByLibrary.simpleMessage(
            "You can add more accounts later in Settings"),
        "create_duplicated_svt":
            MessageLookupByLibrary.simpleMessage("2호기 생성하기"),
        "cur_account": MessageLookupByLibrary.simpleMessage("계정"),
        "current_": MessageLookupByLibrary.simpleMessage("현재"),
        "current_version":
            MessageLookupByLibrary.simpleMessage("Current Version"),
        "database": MessageLookupByLibrary.simpleMessage("Database"),
        "database_not_downloaded": MessageLookupByLibrary.simpleMessage(
            "Database is not downloaded, still continue?"),
        "date": MessageLookupByLibrary.simpleMessage("일"),
        "debug": MessageLookupByLibrary.simpleMessage("Debug"),
        "debug_fab": MessageLookupByLibrary.simpleMessage("Debug FAB"),
        "debug_menu": MessageLookupByLibrary.simpleMessage("Debug Menu"),
        "delete": MessageLookupByLibrary.simpleMessage("삭제"),
        "demands": MessageLookupByLibrary.simpleMessage("요구량"),
        "display_setting": MessageLookupByLibrary.simpleMessage("화면 설정"),
        "done": MessageLookupByLibrary.simpleMessage("DONE"),
        "download": MessageLookupByLibrary.simpleMessage("다운로드"),
        "download_latest_gamedata_hint": MessageLookupByLibrary.simpleMessage(
            "호환성을 보장하려면 업데이트 전에 최신 APP 버전으로 업그레이드하십시오."),
        "download_source": MessageLookupByLibrary.simpleMessage("다운로드 소스"),
        "downloaded": MessageLookupByLibrary.simpleMessage("다운로드 끝남"),
        "downloading": MessageLookupByLibrary.simpleMessage("다운로드 중"),
        "drop_calc_empty_hint":
            MessageLookupByLibrary.simpleMessage("+를 클릭하여 아이템 추가"),
        "drop_calc_min_ap": MessageLookupByLibrary.simpleMessage("최소 AP"),
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
        "exp_card_same_class": MessageLookupByLibrary.simpleMessage("같은 클래스"),
        "exp_card_title": MessageLookupByLibrary.simpleMessage("경험치 카드"),
        "failed": MessageLookupByLibrary.simpleMessage("실패"),
        "faq": MessageLookupByLibrary.simpleMessage("FAQ"),
        "favorite": MessageLookupByLibrary.simpleMessage("즐겨찾기"),
        "feedback_add_attachments":
            MessageLookupByLibrary.simpleMessage("e.g. 스크린샷, 기타 파일"),
        "feedback_contact": MessageLookupByLibrary.simpleMessage("연락처 정보"),
        "feedback_content_hint":
            MessageLookupByLibrary.simpleMessage("피드백 또는 제안"),
        "feedback_form_alert":
            MessageLookupByLibrary.simpleMessage("피드백은 전송되지 않습니다만, 종료하시겠습니까?"),
        "feedback_info": MessageLookupByLibrary.simpleMessage(
            "피드백을 전송하기 전에, <**FAQ**>를 확인해주세요. 피드백을 적을 때에는 상세하게 적어주시길 바랍니다.\n- 재현 방법/기대하고 있는 퍼포먼스\n- 앱/데이터의 버전, 디바이스 시스템/버전\n- 스크린샷과 로그를 첨부한다\n- 마지막으로, 연락처 정보(전자메일 등)을 적어주시는 것이 좋습니다"),
        "feedback_send": MessageLookupByLibrary.simpleMessage("전송"),
        "feedback_subject": MessageLookupByLibrary.simpleMessage("항목명"),
        "ffo_background": MessageLookupByLibrary.simpleMessage("배경"),
        "ffo_body": MessageLookupByLibrary.simpleMessage("몸"),
        "ffo_crop": MessageLookupByLibrary.simpleMessage("자르기"),
        "ffo_head": MessageLookupByLibrary.simpleMessage("머리"),
        "ffo_missing_data_hint":
            MessageLookupByLibrary.simpleMessage("먼저 FFO데이터를 다운로드하거나 가져오세요↗"),
        "ffo_same_svt": MessageLookupByLibrary.simpleMessage("동일 서번트"),
        "fgo_domus_aurea": MessageLookupByLibrary.simpleMessage("도무스 아우레아"),
        "file_not_found_or_mismatched_hash": m6,
        "filename": MessageLookupByLibrary.simpleMessage("파일명"),
        "fill_email_warning":
            MessageLookupByLibrary.simpleMessage("연락처 정보가 없다면 답장이 불가능합니다."),
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
        "gamedata": MessageLookupByLibrary.simpleMessage("게임 데이터"),
        "gold": MessageLookupByLibrary.simpleMessage("금색"),
        "grail": MessageLookupByLibrary.simpleMessage("성배"),
        "grail_up": MessageLookupByLibrary.simpleMessage("성배전림"),
        "growth_curve": MessageLookupByLibrary.simpleMessage("성장 곡선"),
        "guda_female": MessageLookupByLibrary.simpleMessage("구다코"),
        "guda_male": MessageLookupByLibrary.simpleMessage("구다오"),
        "help": MessageLookupByLibrary.simpleMessage("도움말"),
        "hide_outdated": MessageLookupByLibrary.simpleMessage("기간종료 숨기기"),
        "http_sniff_hint": MessageLookupByLibrary.simpleMessage(
            "(NA/JP/CN/TW)계정 로그인 시 데이터 캡쳐, KR은 지원하지 않습니다"),
        "https_sniff": MessageLookupByLibrary.simpleMessage("Https 스나이핑"),
        "icons": MessageLookupByLibrary.simpleMessage("아이콘"),
        "ignore": MessageLookupByLibrary.simpleMessage("무시"),
        "illustration": MessageLookupByLibrary.simpleMessage("일러스트"),
        "illustrator": MessageLookupByLibrary.simpleMessage("일러스트레이터"),
        "import_active_skill_hint":
            MessageLookupByLibrary.simpleMessage("강화 - 서번트 스킬 강화"),
        "import_active_skill_screenshots":
            MessageLookupByLibrary.simpleMessage("액티브 스킬 스크린샷"),
        "import_append_skill_hint":
            MessageLookupByLibrary.simpleMessage("강화 - 어펜드 스킬 강화"),
        "import_append_skill_screenshots":
            MessageLookupByLibrary.simpleMessage("어펜드 스킬 스크린샷"),
        "import_backup": MessageLookupByLibrary.simpleMessage("백업 불러오기"),
        "import_data": MessageLookupByLibrary.simpleMessage("불러오기"),
        "import_data_error": m7,
        "import_data_success":
            MessageLookupByLibrary.simpleMessage("불러오기를 성공했습니다"),
        "import_from_clipboard": MessageLookupByLibrary.simpleMessage("클립보드에서"),
        "import_from_file": MessageLookupByLibrary.simpleMessage("파일에서"),
        "import_http_body_duplicated":
            MessageLookupByLibrary.simpleMessage("중복 서번트"),
        "import_http_body_hint": MessageLookupByLibrary.simpleMessage(
            "복호환된 HTTPS 응답을 출력하기 위해 출력버튼을 누르세요"),
        "import_http_body_hint_hide":
            MessageLookupByLibrary.simpleMessage("서번트를 클릭해서 숨기기,표시하기"),
        "import_http_body_locked":
            MessageLookupByLibrary.simpleMessage("잠금된것만"),
        "import_item_hint":
            MessageLookupByLibrary.simpleMessage("마이룸 - 아이템 리스트"),
        "import_item_screenshots":
            MessageLookupByLibrary.simpleMessage("아이템 스크린샷"),
        "import_screenshot": MessageLookupByLibrary.simpleMessage("스크린샷 가져오기"),
        "import_screenshot_hint":
            MessageLookupByLibrary.simpleMessage("식별된 자료들만 갱신하기"),
        "import_screenshot_update_items":
            MessageLookupByLibrary.simpleMessage("갱신소재"),
        "import_source_file":
            MessageLookupByLibrary.simpleMessage("소스 파일 가져오기"),
        "import_userdata_more":
            MessageLookupByLibrary.simpleMessage("이외의 불러오는 방법"),
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
        "info_luck": MessageLookupByLibrary.simpleMessage("행운"),
        "info_mana": MessageLookupByLibrary.simpleMessage("마력"),
        "info_np": MessageLookupByLibrary.simpleMessage("보구"),
        "info_np_rate": MessageLookupByLibrary.simpleMessage("NP 수급률"),
        "info_star_rate": MessageLookupByLibrary.simpleMessage("스타 수급률"),
        "info_strength": MessageLookupByLibrary.simpleMessage("근력"),
        "info_trait": MessageLookupByLibrary.simpleMessage("속성"),
        "info_value": MessageLookupByLibrary.simpleMessage("값"),
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
        "item_already_exist_hint": m8,
        "item_apple": MessageLookupByLibrary.simpleMessage("사과"),
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
        "jump_to": m9,
        "language": MessageLookupByLibrary.simpleMessage("한국어"),
        "language_en": MessageLookupByLibrary.simpleMessage("Korean"),
        "level": MessageLookupByLibrary.simpleMessage("레벨"),
        "limited_event": MessageLookupByLibrary.simpleMessage("기간 한정 이벤트"),
        "link": MessageLookupByLibrary.simpleMessage("링크"),
        "list_count_shown_all": m10,
        "list_count_shown_hidden_all": m11,
        "list_end_hint": m12,
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
        "main_story": MessageLookupByLibrary.simpleMessage("메인 스토리"),
        "main_story_chapter": MessageLookupByLibrary.simpleMessage("챕터"),
        "master_detail_width":
            MessageLookupByLibrary.simpleMessage("Master-Detail width"),
        "master_mission": MessageLookupByLibrary.simpleMessage("마스터 미션"),
        "master_mission_related_quest":
            MessageLookupByLibrary.simpleMessage("관련된 퀘스트"),
        "master_mission_solution": MessageLookupByLibrary.simpleMessage("풀이"),
        "master_mission_tasklist": MessageLookupByLibrary.simpleMessage("미션"),
        "master_mission_weekly": MessageLookupByLibrary.simpleMessage("주간 미션"),
        "mystic_code": MessageLookupByLibrary.simpleMessage("마술예장"),
        "new_account": MessageLookupByLibrary.simpleMessage("새 계정 추가"),
        "next_card": MessageLookupByLibrary.simpleMessage("다음"),
        "no_servant_quest_hint":
            MessageLookupByLibrary.simpleMessage("막간의 이야기 또는 강화 퀘스트가 없습니다"),
        "no_servant_quest_hint_subtitle":
            MessageLookupByLibrary.simpleMessage("♡를 클릭해서 모든 퀘스트를 표시합니다"),
        "noble_phantasm": MessageLookupByLibrary.simpleMessage("보구"),
        "noble_phantasm_level": MessageLookupByLibrary.simpleMessage("보구 레벨"),
        "not_found": MessageLookupByLibrary.simpleMessage("Not Found"),
        "np_short": MessageLookupByLibrary.simpleMessage("보구"),
        "obtain_time": MessageLookupByLibrary.simpleMessage("시간"),
        "ok": MessageLookupByLibrary.simpleMessage("확인"),
        "open": MessageLookupByLibrary.simpleMessage("열기"),
        "open_condition": MessageLookupByLibrary.simpleMessage("개방 조건"),
        "open_in_file_manager":
            MessageLookupByLibrary.simpleMessage("파일 매니저로 열어주십시오"),
        "overview": MessageLookupByLibrary.simpleMessage("개요"),
        "passive_skill": MessageLookupByLibrary.simpleMessage("클래스 스킬"),
        "plan": MessageLookupByLibrary.simpleMessage("계획"),
        "plan_max10": MessageLookupByLibrary.simpleMessage("계획 최대(310)"),
        "plan_max9": MessageLookupByLibrary.simpleMessage("계획 최대(999)"),
        "plan_objective": MessageLookupByLibrary.simpleMessage("계획 목표"),
        "plan_title": MessageLookupByLibrary.simpleMessage("계획표"),
        "planning_free_quest_btn": MessageLookupByLibrary.simpleMessage("퀘스트"),
        "preview": MessageLookupByLibrary.simpleMessage("미리보기"),
        "previous_card": MessageLookupByLibrary.simpleMessage("이전"),
        "priority": MessageLookupByLibrary.simpleMessage("우선 순위"),
        "project_homepage": MessageLookupByLibrary.simpleMessage("프로젝트 홈페이지"),
        "quest": MessageLookupByLibrary.simpleMessage("퀘스트"),
        "quest_condition": MessageLookupByLibrary.simpleMessage("개방 조건"),
        "quest_fixed_drop": MessageLookupByLibrary.simpleMessage("드롭"),
        "quest_fixed_drop_short": MessageLookupByLibrary.simpleMessage("드롭"),
        "quest_reward": MessageLookupByLibrary.simpleMessage("보너스"),
        "quest_reward_short": MessageLookupByLibrary.simpleMessage("보너스"),
        "rarity": MessageLookupByLibrary.simpleMessage("레어도"),
        "remove_duplicated_svt":
            MessageLookupByLibrary.simpleMessage("2호기 삭제하기"),
        "remove_from_blacklist":
            MessageLookupByLibrary.simpleMessage("블랙리스트 삭제"),
        "rename": MessageLookupByLibrary.simpleMessage("이름 변경"),
        "rerun_event": MessageLookupByLibrary.simpleMessage("복각 이벤트"),
        "reset": MessageLookupByLibrary.simpleMessage("초기화"),
        "reset_plan_all": m14,
        "reset_plan_shown": m15,
        "restart_to_apply_changes":
            MessageLookupByLibrary.simpleMessage("Restart to take effect"),
        "restart_to_upgrade_hint": MessageLookupByLibrary.simpleMessage(
            "업데이트 후 재시작합니다. 만약 업데이트에 실패했다면 수동으로 소스 파일을 다른곳에 옮겨주시기 바랍니다."),
        "restore": MessageLookupByLibrary.simpleMessage("복원"),
        "results": MessageLookupByLibrary.simpleMessage("결과"),
        "save": MessageLookupByLibrary.simpleMessage("저장"),
        "save_to_photos": MessageLookupByLibrary.simpleMessage("사진 저장하기"),
        "saved": MessageLookupByLibrary.simpleMessage("저장됨"),
        "screenshots": MessageLookupByLibrary.simpleMessage("스크린샷"),
        "search": MessageLookupByLibrary.simpleMessage("검색"),
        "search_option_basic": MessageLookupByLibrary.simpleMessage("기본 옵션"),
        "search_options": MessageLookupByLibrary.simpleMessage("검색 옵션"),
        "select_copy_plan_source":
            MessageLookupByLibrary.simpleMessage("복사할 파일을 선택"),
        "select_lang": MessageLookupByLibrary.simpleMessage("Select Language"),
        "select_plan": MessageLookupByLibrary.simpleMessage("계획 선택"),
        "servant": MessageLookupByLibrary.simpleMessage("서번트"),
        "servant_coin": MessageLookupByLibrary.simpleMessage("서번트 코인"),
        "servant_coin_short": MessageLookupByLibrary.simpleMessage("코인"),
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
        "settings_documents": MessageLookupByLibrary.simpleMessage("사용 설명서"),
        "settings_general": MessageLookupByLibrary.simpleMessage("일반"),
        "settings_language": MessageLookupByLibrary.simpleMessage("언어"),
        "settings_tab_name": MessageLookupByLibrary.simpleMessage("설정"),
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
        "sq_fragment_convert":
            MessageLookupByLibrary.simpleMessage("21성정편 = 3 성정석"),
        "sq_short": MessageLookupByLibrary.simpleMessage("돌"),
        "statistics_title": MessageLookupByLibrary.simpleMessage("통계"),
        "still_send": MessageLookupByLibrary.simpleMessage("계속 보내기"),
        "success": MessageLookupByLibrary.simpleMessage("성공"),
        "summon": MessageLookupByLibrary.simpleMessage("가챠"),
        "summon_ticket_short": MessageLookupByLibrary.simpleMessage("호부"),
        "summon_title": MessageLookupByLibrary.simpleMessage("가챠"),
        "support_chaldea": MessageLookupByLibrary.simpleMessage("서포트 및 기부하기"),
        "svt_not_planned": MessageLookupByLibrary.simpleMessage("팔로우 하지않음"),
        "svt_plan_hidden": MessageLookupByLibrary.simpleMessage("숨김"),
        "svt_reset_plan": MessageLookupByLibrary.simpleMessage("계획 초기화"),
        "svt_second_archive": MessageLookupByLibrary.simpleMessage("영기 보관실"),
        "svt_switch_slider_dropdown":
            MessageLookupByLibrary.simpleMessage("Slider/Dropdown 전환"),
        "toogle_dark_mode":
            MessageLookupByLibrary.simpleMessage("Toggle Dark Mode"),
        "tooltip_refresh_sliders":
            MessageLookupByLibrary.simpleMessage("슬라이드 갱신"),
        "total_ap": MessageLookupByLibrary.simpleMessage("AP 합계"),
        "total_counts": MessageLookupByLibrary.simpleMessage("합계 카운트"),
        "update": MessageLookupByLibrary.simpleMessage("갱신"),
        "update_already_latest":
            MessageLookupByLibrary.simpleMessage("이미 최신버전 입니다"),
        "update_dataset": MessageLookupByLibrary.simpleMessage("게임 데이터 갱신하기"),
        "userdata": MessageLookupByLibrary.simpleMessage("사용자 데이터"),
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
        "words_separate": m0
      };
}
