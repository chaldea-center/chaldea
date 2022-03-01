// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a es locale. All the
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
  String get localeName => 'es';

  static String m0(email, logPath) =>
      "Por favor, envíe una captura de pantalla y un archivo de registro al correo electrónico:\n ${email}\nRuta del archivo de registro: ${logPath}";

  static String m1(curVersion, newVersion, releaseNote) =>
      "Versión actual: ${curVersion}\nÚltima versión: ${newVersion}\nNota de lanzamiento:\n${releaseNote}";

  static String m2(name) => "Fuente ${name}";

  static String m3(n) => "Lotería Máx. ${n}";

  static String m4(n) => "Griales a Lore: ${n}";

  static String m5(error) => "La importación ha fallado. Error:\n${error}";

  static String m6(account) => "Cambiado a la cuenta ${account}";

  static String m7(itemNum, svtNum) =>
      "Importar ${itemNum} objetos y ${svtNum} servants a";

  static String m8(name) => "${name} ya existe";

  static String m9(site) => "Ir a ${site}";

  static String m10(first) =>
      "{primer, selecciona, verdadero{Ya es el primero} falso{Ya es el último} otro{No más}}";

  static String m11(version) => "Conjunto de datos actualizado a ${version}";

  static String m12(index) => "Plan ${index}";

  static String m13(n) => "Restablecer plan ${n}(Todo)";

  static String m14(n) => "Restablecer plan ${n} (Mostrado)";

  static String m15(total) => "Resultados totales ${total}";

  static String m16(total, hidden) =>
      "Resultados totales ${total} (${hidden} ocultos)";

  static String m17(server) => "Sincronizar con ${server}";

  static String m18(a, b) => "${a} ${b}";

  final messages = _notInlinedMessages(_notInlinedMessages);

  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about_app": MessageLookupByLibrary.simpleMessage("Acerca de"),
        "about_app_declaration_text": MessageLookupByLibrary.simpleMessage(
            "Los datos utilizados en esta aplicación provienen del juego Fate/GO y de los siguientes sitios web. Los derechos de autor de los textos, imágenes y voces originales del juego pertenecen a TYPE MOON/FGO PROJECT.\n\nEl diseño del programa se basa en el miniprograma WeChat \"Material Programe\" y la aplicación para iOS \"Guda\".\n"),
        "about_appstore_rating": MessageLookupByLibrary.simpleMessage(
            "Clasificación de la App Store"),
        "about_data_source":
            MessageLookupByLibrary.simpleMessage("Fuente de datos"),
        "about_data_source_footer": MessageLookupByLibrary.simpleMessage(
            "Por favor, infórmenos si hay una fuente no acreditada o una infracción"),
        "about_email_dialog": m0,
        "about_email_subtitle": MessageLookupByLibrary.simpleMessage(
            "Por favor, adjunte una captura de pantalla y un archivo de registro"),
        "about_feedback": MessageLookupByLibrary.simpleMessage("Feedback"),
        "about_update_app":
            MessageLookupByLibrary.simpleMessage("Actualizar Aplicación"),
        "about_update_app_alert_ios_mac": MessageLookupByLibrary.simpleMessage(
            "Por favor, compruebe la actualización en la App Store"),
        "about_update_app_detail": m1,
        "active_skill": MessageLookupByLibrary.simpleMessage("Active Skill"),
        "add": MessageLookupByLibrary.simpleMessage("Añadir"),
        "add_to_blacklist":
            MessageLookupByLibrary.simpleMessage("Añadir a la lista negra"),
        "ap": MessageLookupByLibrary.simpleMessage("AP"),
        "ap_calc_page_joke":
            MessageLookupByLibrary.simpleMessage("口算不及格的咕朗台.jpg"),
        "ap_calc_title": MessageLookupByLibrary.simpleMessage("Calc. AP"),
        "ap_efficiency": MessageLookupByLibrary.simpleMessage("AP rate"),
        "ap_overflow_time":
            MessageLookupByLibrary.simpleMessage("Tiempo para AP full"),
        "append_skill": MessageLookupByLibrary.simpleMessage("Append Skill"),
        "append_skill_short": MessageLookupByLibrary.simpleMessage("Append"),
        "ascension": MessageLookupByLibrary.simpleMessage("Ascension"),
        "ascension_short": MessageLookupByLibrary.simpleMessage("Ascen"),
        "ascension_up": MessageLookupByLibrary.simpleMessage("Ascension"),
        "attachment": MessageLookupByLibrary.simpleMessage("Archivo adjunto"),
        "auto_reset":
            MessageLookupByLibrary.simpleMessage("Reinicio automático"),
        "auto_update":
            MessageLookupByLibrary.simpleMessage("Actualización automática"),
        "backup": MessageLookupByLibrary.simpleMessage("Respaldo"),
        "backup_data_alert": MessageLookupByLibrary.simpleMessage(
            "Se necesita copia de seguridad oportuna"),
        "backup_history": MessageLookupByLibrary.simpleMessage(
            "Historial de copias de seguridad"),
        "backup_success":
            MessageLookupByLibrary.simpleMessage("Copia de seguridad exitosa"),
        "blacklist": MessageLookupByLibrary.simpleMessage("Lista negra"),
        "bond": MessageLookupByLibrary.simpleMessage("Bond"),
        "bond_craft": MessageLookupByLibrary.simpleMessage("Bond Craft"),
        "bond_eff": MessageLookupByLibrary.simpleMessage("Bond Eff"),
        "bronze": MessageLookupByLibrary.simpleMessage("Bronce"),
        "calc_weight": MessageLookupByLibrary.simpleMessage("Peso"),
        "calculate": MessageLookupByLibrary.simpleMessage("Calcular"),
        "calculator": MessageLookupByLibrary.simpleMessage("Calculadora"),
        "campaign_event": MessageLookupByLibrary.simpleMessage("Campaña"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "card_description": MessageLookupByLibrary.simpleMessage("Descripción"),
        "card_info": MessageLookupByLibrary.simpleMessage("Información"),
        "carousel_setting":
            MessageLookupByLibrary.simpleMessage("Configuración del carrusel"),
        "change_log":
            MessageLookupByLibrary.simpleMessage("Registro de cambios"),
        "characters_in_card":
            MessageLookupByLibrary.simpleMessage("Personajes"),
        "check_update":
            MessageLookupByLibrary.simpleMessage("Comprobar actualización"),
        "choose_quest_hint":
            MessageLookupByLibrary.simpleMessage("Elegir Free Quest"),
        "clear": MessageLookupByLibrary.simpleMessage("Borrar"),
        "clear_cache": MessageLookupByLibrary.simpleMessage("Borrar caché"),
        "clear_cache_finish":
            MessageLookupByLibrary.simpleMessage("Caché borrada"),
        "clear_cache_hint": MessageLookupByLibrary.simpleMessage(
            "Incluyendo ilustraciones, voces"),
        "clear_userdata":
            MessageLookupByLibrary.simpleMessage("Borrar datos de usuario"),
        "cmd_code_title": MessageLookupByLibrary.simpleMessage("Command Code"),
        "command_code": MessageLookupByLibrary.simpleMessage("Command Code"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirmar"),
        "consumed": MessageLookupByLibrary.simpleMessage("Consumido"),
        "copied": MessageLookupByLibrary.simpleMessage("Copiado"),
        "copy": MessageLookupByLibrary.simpleMessage("Copiar"),
        "copy_plan_menu":
            MessageLookupByLibrary.simpleMessage("Copiar Plan de..."),
        "costume": MessageLookupByLibrary.simpleMessage("Vestuario"),
        "costume_unlock":
            MessageLookupByLibrary.simpleMessage("Desbloquear Vestuario"),
        "counts": MessageLookupByLibrary.simpleMessage("Cantidad"),
        "craft_essence": MessageLookupByLibrary.simpleMessage("Craft Essence"),
        "craft_essence_title": MessageLookupByLibrary.simpleMessage("Craft"),
        "create_duplicated_svt":
            MessageLookupByLibrary.simpleMessage("Crear duplicado"),
        "critical_attack": MessageLookupByLibrary.simpleMessage("Crítico"),
        "cur_account": MessageLookupByLibrary.simpleMessage("Cuenta Actual"),
        "cur_ap": MessageLookupByLibrary.simpleMessage("AP Actual"),
        "current_": MessageLookupByLibrary.simpleMessage("Actual"),
        "dark_mode": MessageLookupByLibrary.simpleMessage("Modo oscuro"),
        "dark_mode_dark": MessageLookupByLibrary.simpleMessage("Oscuro"),
        "dark_mode_light": MessageLookupByLibrary.simpleMessage("Color claro"),
        "dark_mode_system": MessageLookupByLibrary.simpleMessage("Sistema"),
        "dataset_goto_download_page":
            MessageLookupByLibrary.simpleMessage("Ir a la página de descarga"),
        "dataset_goto_download_page_hint": MessageLookupByLibrary.simpleMessage(
            "Importar después de descargar"),
        "dataset_management":
            MessageLookupByLibrary.simpleMessage("Gestión de datos"),
        "dataset_type_image":
            MessageLookupByLibrary.simpleMessage("Conjunto de datos de iconos"),
        "dataset_type_text":
            MessageLookupByLibrary.simpleMessage("Conjunto de datos de texto"),
        "delete": MessageLookupByLibrary.simpleMessage("Eliminar"),
        "demands": MessageLookupByLibrary.simpleMessage("Demandado"),
        "display_setting":
            MessageLookupByLibrary.simpleMessage("Configuración de pantalla"),
        "download": MessageLookupByLibrary.simpleMessage("Descargar"),
        "download_complete": MessageLookupByLibrary.simpleMessage("Descargado"),
        "download_full_gamedata": MessageLookupByLibrary.simpleMessage(
            "Descargar los últimos datos del juego"),
        "download_full_gamedata_hint": MessageLookupByLibrary.simpleMessage(
            "Archivo zip de tamaño completo"),
        "download_latest_gamedata":
            MessageLookupByLibrary.simpleMessage("Descargar lo último"),
        "download_latest_gamedata_hint": MessageLookupByLibrary.simpleMessage(
            "Para garantizar la compatibilidad, actualice a la última versión de la aplicación antes de actualizar"),
        "download_source":
            MessageLookupByLibrary.simpleMessage("Fuente de la descarga"),
        "download_source_hint": MessageLookupByLibrary.simpleMessage(
            "actualizar el conjunto de datos y la aplicación"),
        "download_source_of": m2,
        "downloaded": MessageLookupByLibrary.simpleMessage("Descargado"),
        "downloading": MessageLookupByLibrary.simpleMessage("Descargando"),
        "drop_calc_empty_hint": MessageLookupByLibrary.simpleMessage(
            "Haga clic en + para agregar elementos"),
        "drop_calc_min_ap": MessageLookupByLibrary.simpleMessage("AP Mín."),
        "drop_calc_optimize": MessageLookupByLibrary.simpleMessage("Optimizar"),
        "drop_calc_solve": MessageLookupByLibrary.simpleMessage("Resolver"),
        "drop_rate": MessageLookupByLibrary.simpleMessage("Drop rate"),
        "edit": MessageLookupByLibrary.simpleMessage("Editar"),
        "effect_search": MessageLookupByLibrary.simpleMessage("Buscar Buff"),
        "efficiency": MessageLookupByLibrary.simpleMessage("Eficiencia"),
        "efficiency_type": MessageLookupByLibrary.simpleMessage("Eficiente"),
        "efficiency_type_ap":
            MessageLookupByLibrary.simpleMessage("20 AP Rate"),
        "efficiency_type_drop":
            MessageLookupByLibrary.simpleMessage("Drop Rate"),
        "enemy_list": MessageLookupByLibrary.simpleMessage("Enemigos"),
        "enhance": MessageLookupByLibrary.simpleMessage("Mejorar"),
        "enhance_warning": MessageLookupByLibrary.simpleMessage(
            "Los siguientes objetos se consumirán para mejorar"),
        "error_no_network":
            MessageLookupByLibrary.simpleMessage("Sin internet"),
        "event_collect_item_confirm": MessageLookupByLibrary.simpleMessage(
            "Todos los objetos se añadirán al inventario y se eliminará el evento fuera del plan"),
        "event_collect_items":
            MessageLookupByLibrary.simpleMessage("Recoger objetos"),
        "event_item_default":
            MessageLookupByLibrary.simpleMessage("Tienda/Tarea/Puntos/Quests"),
        "event_item_extra":
            MessageLookupByLibrary.simpleMessage("Obtenibles adicionales"),
        "event_lottery_limit_hint": m3,
        "event_lottery_limited":
            MessageLookupByLibrary.simpleMessage("Lotería limitada"),
        "event_lottery_unit": MessageLookupByLibrary.simpleMessage("Lotería"),
        "event_lottery_unlimited":
            MessageLookupByLibrary.simpleMessage("Lotería ilimitada"),
        "event_not_planned":
            MessageLookupByLibrary.simpleMessage("Evento no planificado"),
        "event_progress": MessageLookupByLibrary.simpleMessage("Progreso"),
        "event_rerun_replace_grail": m4,
        "event_title": MessageLookupByLibrary.simpleMessage("Eventos"),
        "exchange_ticket":
            MessageLookupByLibrary.simpleMessage("Exchange Ticket"),
        "exchange_ticket_short": MessageLookupByLibrary.simpleMessage("Ticket"),
        "exp_card_plan_lv": MessageLookupByLibrary.simpleMessage("Niveles"),
        "exp_card_rarity5": MessageLookupByLibrary.simpleMessage("5☆ Exp Card"),
        "exp_card_same_class":
            MessageLookupByLibrary.simpleMessage("Misma Clase"),
        "exp_card_select_lvs": MessageLookupByLibrary.simpleMessage(
            "Seleccionar rango de niveles"),
        "exp_card_title": MessageLookupByLibrary.simpleMessage("Exp Card"),
        "failed": MessageLookupByLibrary.simpleMessage("Falló"),
        "favorite": MessageLookupByLibrary.simpleMessage("Favorito"),
        "feedback_add_attachments": MessageLookupByLibrary.simpleMessage(
            "Agregar capturas de pantalla o archivos adjuntos"),
        "feedback_add_crash_log":
            MessageLookupByLibrary.simpleMessage("Agregar registro de fallas"),
        "feedback_contact":
            MessageLookupByLibrary.simpleMessage("Información de contacto"),
        "feedback_content_hint":
            MessageLookupByLibrary.simpleMessage("Comentarios o Sugerencias"),
        "feedback_send": MessageLookupByLibrary.simpleMessage("Enviar"),
        "feedback_subject": MessageLookupByLibrary.simpleMessage("Asunto"),
        "ffo_background": MessageLookupByLibrary.simpleMessage("Fondo"),
        "ffo_body": MessageLookupByLibrary.simpleMessage("Cuerpo"),
        "ffo_crop": MessageLookupByLibrary.simpleMessage("Cortar"),
        "ffo_head": MessageLookupByLibrary.simpleMessage("Cabeza"),
        "ffo_missing_data_hint": MessageLookupByLibrary.simpleMessage(
            "Primero descargue o importe los datos de FFO↗"),
        "ffo_same_svt": MessageLookupByLibrary.simpleMessage("Mismo Servant"),
        "fgo_domus_aurea":
            MessageLookupByLibrary.simpleMessage("FGO Domus Áurea"),
        "filename": MessageLookupByLibrary.simpleMessage("nombre del archivo"),
        "filter": MessageLookupByLibrary.simpleMessage("Filtro"),
        "filter_atk_hp_type": MessageLookupByLibrary.simpleMessage("Tipo"),
        "filter_attribute": MessageLookupByLibrary.simpleMessage("Atributo"),
        "filter_category": MessageLookupByLibrary.simpleMessage("Categoría"),
        "filter_effects": MessageLookupByLibrary.simpleMessage("Efectos"),
        "filter_gender": MessageLookupByLibrary.simpleMessage("Género"),
        "filter_match_all":
            MessageLookupByLibrary.simpleMessage("Coincidir todo"),
        "filter_obtain": MessageLookupByLibrary.simpleMessage("Obtiene"),
        "filter_plan_not_reached":
            MessageLookupByLibrary.simpleMessage("Fuera del Plan"),
        "filter_plan_reached":
            MessageLookupByLibrary.simpleMessage("Dentro del Plan"),
        "filter_revert": MessageLookupByLibrary.simpleMessage("Revertir"),
        "filter_shown_type": MessageLookupByLibrary.simpleMessage("Mostrar"),
        "filter_skill_lv": MessageLookupByLibrary.simpleMessage("Skills"),
        "filter_sort": MessageLookupByLibrary.simpleMessage("Ordenar"),
        "filter_sort_class": MessageLookupByLibrary.simpleMessage("Clase"),
        "filter_sort_number": MessageLookupByLibrary.simpleMessage("Nº"),
        "filter_sort_rarity": MessageLookupByLibrary.simpleMessage("Rareza"),
        "filter_special_trait":
            MessageLookupByLibrary.simpleMessage("Rasgo Especial"),
        "free_efficiency":
            MessageLookupByLibrary.simpleMessage("Eficiencia Free"),
        "free_progress":
            MessageLookupByLibrary.simpleMessage("Límite del Quest"),
        "free_progress_newest":
            MessageLookupByLibrary.simpleMessage("Más reciente (JP)"),
        "free_quest": MessageLookupByLibrary.simpleMessage("Free Quest"),
        "free_quest_calculator":
            MessageLookupByLibrary.simpleMessage("Free Quest"),
        "free_quest_calculator_short":
            MessageLookupByLibrary.simpleMessage("Free Quest"),
        "gallery_tab_name": MessageLookupByLibrary.simpleMessage("Inicio"),
        "game_drop": MessageLookupByLibrary.simpleMessage("Drop"),
        "game_experience": MessageLookupByLibrary.simpleMessage("Experiencia"),
        "game_kizuna": MessageLookupByLibrary.simpleMessage("Bond"),
        "game_rewards": MessageLookupByLibrary.simpleMessage("Recompensas"),
        "gamedata": MessageLookupByLibrary.simpleMessage("Datos del juego"),
        "gold": MessageLookupByLibrary.simpleMessage("Oro"),
        "grail": MessageLookupByLibrary.simpleMessage("Grial"),
        "grail_level": MessageLookupByLibrary.simpleMessage("Grial"),
        "grail_up": MessageLookupByLibrary.simpleMessage("Palingenesis"),
        "growth_curve":
            MessageLookupByLibrary.simpleMessage("Curva de crecimiento"),
        "guda_item_data": MessageLookupByLibrary.simpleMessage(
            "Datos de los objetos de Guda"),
        "guda_servant_data":
            MessageLookupByLibrary.simpleMessage("Datos del Servant de Guda"),
        "hello": MessageLookupByLibrary.simpleMessage("¡Hola, Master!"),
        "help": MessageLookupByLibrary.simpleMessage("Ayuda"),
        "hide_outdated":
            MessageLookupByLibrary.simpleMessage("Ocultar desactualizado"),
        "hint_no_bond_craft":
            MessageLookupByLibrary.simpleMessage("Sin bond craft"),
        "hint_no_valentine_craft":
            MessageLookupByLibrary.simpleMessage("Sin valentine craft"),
        "icons": MessageLookupByLibrary.simpleMessage("Iconos"),
        "ignore": MessageLookupByLibrary.simpleMessage("Ignorar"),
        "illustration": MessageLookupByLibrary.simpleMessage("Ilustración"),
        "illustrator": MessageLookupByLibrary.simpleMessage("Ilustrador"),
        "image_analysis":
            MessageLookupByLibrary.simpleMessage("Análisis de imagen"),
        "import_data": MessageLookupByLibrary.simpleMessage("Importar"),
        "import_data_error": m5,
        "import_data_success":
            MessageLookupByLibrary.simpleMessage("Importar datos con éxito"),
        "import_guda_data":
            MessageLookupByLibrary.simpleMessage("Datos de Guda"),
        "import_guda_hint": MessageLookupByLibrary.simpleMessage(
            "Actualizar: mantener los datos de usuario actuales y actualizar (recomendado)\nSobreescribir: borrar los datos de usuario y luego actualizar"),
        "import_guda_items":
            MessageLookupByLibrary.simpleMessage("Importar Objeto"),
        "import_guda_servants":
            MessageLookupByLibrary.simpleMessage("Importar Servant"),
        "import_http_body_duplicated":
            MessageLookupByLibrary.simpleMessage("Duplicado"),
        "import_http_body_hint": MessageLookupByLibrary.simpleMessage(
            "Haga clic en el botón Importar para importar la respuesta HTTPS descifrada"),
        "import_http_body_hint_hide": MessageLookupByLibrary.simpleMessage(
            "Haga clic en el Servant para ocultar/mostrar"),
        "import_http_body_locked":
            MessageLookupByLibrary.simpleMessage("Solo bloqueado"),
        "import_http_body_success_switch": m6,
        "import_http_body_target_account_header": m7,
        "import_screenshot": MessageLookupByLibrary.simpleMessage(
            "Importar capturas de pantalla"),
        "import_screenshot_hint": MessageLookupByLibrary.simpleMessage(
            "Actualizar solo elementos reconocidos"),
        "import_screenshot_update_items":
            MessageLookupByLibrary.simpleMessage("Actualizar elementos"),
        "import_source_file":
            MessageLookupByLibrary.simpleMessage("Importar Archivo Fuente"),
        "info_agility": MessageLookupByLibrary.simpleMessage("Agilidad"),
        "info_alignment": MessageLookupByLibrary.simpleMessage("Alineación"),
        "info_bond_points": MessageLookupByLibrary.simpleMessage("Bond Points"),
        "info_bond_points_single":
            MessageLookupByLibrary.simpleMessage("Point"),
        "info_bond_points_sum": MessageLookupByLibrary.simpleMessage("Sum"),
        "info_cards": MessageLookupByLibrary.simpleMessage("Cards"),
        "info_critical_rate":
            MessageLookupByLibrary.simpleMessage("Critical Rate"),
        "info_cv": MessageLookupByLibrary.simpleMessage("Actor de voz"),
        "info_death_rate": MessageLookupByLibrary.simpleMessage("Death Rate"),
        "info_endurance": MessageLookupByLibrary.simpleMessage("Resistencia"),
        "info_gender": MessageLookupByLibrary.simpleMessage("Género"),
        "info_height": MessageLookupByLibrary.simpleMessage("Altura"),
        "info_human": MessageLookupByLibrary.simpleMessage("Humano"),
        "info_luck": MessageLookupByLibrary.simpleMessage("Suerte"),
        "info_mana": MessageLookupByLibrary.simpleMessage("Maná"),
        "info_np": MessageLookupByLibrary.simpleMessage("NP"),
        "info_np_rate": MessageLookupByLibrary.simpleMessage("NP Rate"),
        "info_star_rate": MessageLookupByLibrary.simpleMessage("Star Rate"),
        "info_strength": MessageLookupByLibrary.simpleMessage("Fuerza"),
        "info_trait": MessageLookupByLibrary.simpleMessage("Traits"),
        "info_value": MessageLookupByLibrary.simpleMessage("Valor"),
        "info_weak_to_ea": MessageLookupByLibrary.simpleMessage("Débil a EA"),
        "info_weight": MessageLookupByLibrary.simpleMessage("Peso"),
        "input_invalid_hint":
            MessageLookupByLibrary.simpleMessage("Entradas inválidas"),
        "install": MessageLookupByLibrary.simpleMessage("Instalar"),
        "interlude_and_rankup":
            MessageLookupByLibrary.simpleMessage("Interlude & Rank Up"),
        "ios_app_path": MessageLookupByLibrary.simpleMessage(
            "Aplicación \"Archivos\"/En mi iPhone/Caldea"),
        "issues": MessageLookupByLibrary.simpleMessage("Problemas"),
        "item": MessageLookupByLibrary.simpleMessage("Objeto"),
        "item_already_exist_hint": m8,
        "item_category_ascension":
            MessageLookupByLibrary.simpleMessage("Objetos de Ascension"),
        "item_category_bronze":
            MessageLookupByLibrary.simpleMessage("Objetos de bronce"),
        "item_category_event_svt_ascension":
            MessageLookupByLibrary.simpleMessage("Objeto de evento"),
        "item_category_gem": MessageLookupByLibrary.simpleMessage("Gem"),
        "item_category_gems":
            MessageLookupByLibrary.simpleMessage("Objetos de Skill"),
        "item_category_gold":
            MessageLookupByLibrary.simpleMessage("Objetos de oro"),
        "item_category_magic_gem":
            MessageLookupByLibrary.simpleMessage("Magic Gem"),
        "item_category_monument":
            MessageLookupByLibrary.simpleMessage("Monument"),
        "item_category_others": MessageLookupByLibrary.simpleMessage("Otros"),
        "item_category_piece": MessageLookupByLibrary.simpleMessage("Piece"),
        "item_category_secret_gem":
            MessageLookupByLibrary.simpleMessage("Secret Gem"),
        "item_category_silver":
            MessageLookupByLibrary.simpleMessage("Objetos de plata"),
        "item_category_special":
            MessageLookupByLibrary.simpleMessage("Objetos especiales"),
        "item_category_usual": MessageLookupByLibrary.simpleMessage("Objetos"),
        "item_eff":
            MessageLookupByLibrary.simpleMessage("Eficiencia de objetos"),
        "item_exceed_hint": MessageLookupByLibrary.simpleMessage(
            "Antes de planificar, puede establecer el número excedido de objetos (solo se usa para la planificación de Free Quest)"),
        "item_left": MessageLookupByLibrary.simpleMessage("Sobra"),
        "item_no_free_quests":
            MessageLookupByLibrary.simpleMessage("Sin Free Quests"),
        "item_only_show_lack":
            MessageLookupByLibrary.simpleMessage("Mostrar solo lo faltante"),
        "item_own": MessageLookupByLibrary.simpleMessage("Posee"),
        "item_screenshot": MessageLookupByLibrary.simpleMessage(
            "Captura de pantalla de los objetos"),
        "item_title": MessageLookupByLibrary.simpleMessage("Objeto"),
        "item_total_demand": MessageLookupByLibrary.simpleMessage("Total"),
        "join_beta":
            MessageLookupByLibrary.simpleMessage("Únete al programa Beta"),
        "jump_to": m9,
        "language": MessageLookupByLibrary.simpleMessage("Español"),
        "language_en": MessageLookupByLibrary.simpleMessage("Spanish"),
        "level": MessageLookupByLibrary.simpleMessage("Nivel"),
        "limited_event":
            MessageLookupByLibrary.simpleMessage("Evento Limitado"),
        "link": MessageLookupByLibrary.simpleMessage("enlace"),
        "list_end_hint": m10,
        "load_dataset_error": MessageLookupByLibrary.simpleMessage(
            "Error al cargar el conjunto de datos"),
        "load_dataset_error_hint": MessageLookupByLibrary.simpleMessage(
            "Por favor, vuelva a cargar los datos del juego predeterminados en Configuración-Datos del juego"),
        "login_change_password":
            MessageLookupByLibrary.simpleMessage("Cambiar contraseña"),
        "login_first_hint": MessageLookupByLibrary.simpleMessage(
            "Por favor, inicie sesión primero"),
        "login_forget_pwd":
            MessageLookupByLibrary.simpleMessage("Contraseña olvidada"),
        "login_login": MessageLookupByLibrary.simpleMessage("Iniciar sesión"),
        "login_logout": MessageLookupByLibrary.simpleMessage("Cerrar sesión"),
        "login_new_password":
            MessageLookupByLibrary.simpleMessage("Nueva contraseña"),
        "login_password": MessageLookupByLibrary.simpleMessage("Contraseña"),
        "login_password_error": MessageLookupByLibrary.simpleMessage(
            "Sólo puede contener letras y números, no menos de 4 dígitos"),
        "login_password_error_same_as_old":
            MessageLookupByLibrary.simpleMessage(
                "No puede ser la misma que la antigua contraseña"),
        "login_signup": MessageLookupByLibrary.simpleMessage("Registrarse"),
        "login_state_not_login":
            MessageLookupByLibrary.simpleMessage("No ha iniciado sesión"),
        "login_username":
            MessageLookupByLibrary.simpleMessage("Nombre de usuario"),
        "login_username_error": MessageLookupByLibrary.simpleMessage(
            "Sólo puede contener letras y números, empezando por una letra, no menos de 4 dígitos"),
        "long_press_to_save_hint": MessageLookupByLibrary.simpleMessage(
            "Mantenga presionado para guardar"),
        "lucky_bag": MessageLookupByLibrary.simpleMessage("Bolsa de la suerte"),
        "main_record":
            MessageLookupByLibrary.simpleMessage("Historia Principal"),
        "main_record_bonus": MessageLookupByLibrary.simpleMessage("Bonus"),
        "main_record_bonus_short":
            MessageLookupByLibrary.simpleMessage("Bonus"),
        "main_record_chapter": MessageLookupByLibrary.simpleMessage("Capítulo"),
        "main_record_fixed_drop": MessageLookupByLibrary.simpleMessage("Drops"),
        "main_record_fixed_drop_short":
            MessageLookupByLibrary.simpleMessage("Drops"),
        "master_mission":
            MessageLookupByLibrary.simpleMessage("Misiones de Master"),
        "master_mission_related_quest":
            MessageLookupByLibrary.simpleMessage("Misiones relacionadas"),
        "master_mission_solution":
            MessageLookupByLibrary.simpleMessage("Solución"),
        "master_mission_tasklist":
            MessageLookupByLibrary.simpleMessage("Misiones"),
        "max_ap": MessageLookupByLibrary.simpleMessage("AP Máximo"),
        "more": MessageLookupByLibrary.simpleMessage("Más"),
        "move_down": MessageLookupByLibrary.simpleMessage("Mover hacia abajo"),
        "move_up": MessageLookupByLibrary.simpleMessage("Mover hacia arriba"),
        "mystic_code": MessageLookupByLibrary.simpleMessage("Mystic Code"),
        "new_account": MessageLookupByLibrary.simpleMessage("Nueva Cuenta"),
        "next_card": MessageLookupByLibrary.simpleMessage("Siguiente"),
        "nga": MessageLookupByLibrary.simpleMessage("NGA"),
        "nga_fgo": MessageLookupByLibrary.simpleMessage("NGA-FGO"),
        "no": MessageLookupByLibrary.simpleMessage("No"),
        "no_servant_quest_hint": MessageLookupByLibrary.simpleMessage(
            "No hay interludio o rank up quest"),
        "no_servant_quest_hint_subtitle": MessageLookupByLibrary.simpleMessage(
            "Haga clic en ♡ para ver todos los quests de los servants"),
        "noble_phantasm":
            MessageLookupByLibrary.simpleMessage("Noble Phantasm"),
        "noble_phantasm_level":
            MessageLookupByLibrary.simpleMessage("Noble Phantasm"),
        "not_implemented":
            MessageLookupByLibrary.simpleMessage("Todavía sin implementar"),
        "obtain_methods": MessageLookupByLibrary.simpleMessage("Obtiene"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "open": MessageLookupByLibrary.simpleMessage("Abrir"),
        "open_condition": MessageLookupByLibrary.simpleMessage("Condición"),
        "overview": MessageLookupByLibrary.simpleMessage("Resumen"),
        "overwrite": MessageLookupByLibrary.simpleMessage("Sobreescribir"),
        "passive_skill": MessageLookupByLibrary.simpleMessage("Passive Skill"),
        "patch_gamedata":
            MessageLookupByLibrary.simpleMessage("Parche de datos del juego"),
        "patch_gamedata_error_no_compatible": MessageLookupByLibrary.simpleMessage(
            "No hay versión compatible con la versión actual de la aplicación"),
        "patch_gamedata_error_unknown_version":
            MessageLookupByLibrary.simpleMessage(
                "No se ha encontrado la versión actual en el servidor, descargando el paquete completo"),
        "patch_gamedata_hint":
            MessageLookupByLibrary.simpleMessage("Sólo parche descargado"),
        "patch_gamedata_success_to": m11,
        "plan": MessageLookupByLibrary.simpleMessage("Plan"),
        "plan_max10": MessageLookupByLibrary.simpleMessage("Plan Máx(310)"),
        "plan_max9": MessageLookupByLibrary.simpleMessage("Plan Máx(999)"),
        "plan_objective":
            MessageLookupByLibrary.simpleMessage("Objetivo del Plan"),
        "plan_title": MessageLookupByLibrary.simpleMessage("Plan"),
        "plan_x": m12,
        "planning_free_quest_btn":
            MessageLookupByLibrary.simpleMessage("Planificación de Quests"),
        "preview": MessageLookupByLibrary.simpleMessage("Vista previa"),
        "previous_card": MessageLookupByLibrary.simpleMessage("Anterior"),
        "priority": MessageLookupByLibrary.simpleMessage("Prioridad"),
        "project_homepage": MessageLookupByLibrary.simpleMessage(
            "Página de inicio del proyecto"),
        "query_failed":
            MessageLookupByLibrary.simpleMessage("Consulta fallida"),
        "quest": MessageLookupByLibrary.simpleMessage("Quest"),
        "quest_condition": MessageLookupByLibrary.simpleMessage("Condiciones"),
        "rarity": MessageLookupByLibrary.simpleMessage("Rareza"),
        "rate_app_store":
            MessageLookupByLibrary.simpleMessage("Valorar en App Store"),
        "rate_play_store":
            MessageLookupByLibrary.simpleMessage("Valorar en Google Play"),
        "release_page":
            MessageLookupByLibrary.simpleMessage("Página de lanzamiento"),
        "reload_data_success":
            MessageLookupByLibrary.simpleMessage("Importación exitosa"),
        "reload_default_gamedata":
            MessageLookupByLibrary.simpleMessage("Recargar predeterminado"),
        "reloading_data": MessageLookupByLibrary.simpleMessage("Importando"),
        "remove_duplicated_svt":
            MessageLookupByLibrary.simpleMessage("Remover duplicado"),
        "remove_from_blacklist":
            MessageLookupByLibrary.simpleMessage("Remover de la lista negra"),
        "rename": MessageLookupByLibrary.simpleMessage("Renombrar"),
        "rerun_event": MessageLookupByLibrary.simpleMessage("Rerun"),
        "reset": MessageLookupByLibrary.simpleMessage("Reiniciar"),
        "reset_plan_all": m13,
        "reset_plan_shown": m14,
        "reset_success":
            MessageLookupByLibrary.simpleMessage("Reestablecimiento exitoso"),
        "reset_svt_enhance_state": MessageLookupByLibrary.simpleMessage(
            "Restablecer Habilidad/NP por defecto"),
        "reset_svt_enhance_state_hint": MessageLookupByLibrary.simpleMessage(
            "Restablecer el rango de las habilidades y el noble phantasm"),
        "restart_to_upgrade_hint": MessageLookupByLibrary.simpleMessage(
            "Reiniciar para actualizar. Si la actualización falla, copie manualmente la carpeta de origen en el destino"),
        "restore": MessageLookupByLibrary.simpleMessage("Restaurar"),
        "save": MessageLookupByLibrary.simpleMessage("Guardar"),
        "save_to_photos":
            MessageLookupByLibrary.simpleMessage("Guardar en Fotos"),
        "saved": MessageLookupByLibrary.simpleMessage("Guardado"),
        "search": MessageLookupByLibrary.simpleMessage("Buscar"),
        "search_option_basic": MessageLookupByLibrary.simpleMessage("Básica"),
        "search_options":
            MessageLookupByLibrary.simpleMessage("Alcances de búsqueda"),
        "search_result_count": m15,
        "search_result_count_hide": m16,
        "select_copy_plan_source":
            MessageLookupByLibrary.simpleMessage("Seleccionar fuente de copia"),
        "select_plan": MessageLookupByLibrary.simpleMessage("Seleccionar Plan"),
        "servant": MessageLookupByLibrary.simpleMessage("Servant"),
        "servant_coin": MessageLookupByLibrary.simpleMessage("Servant Coin"),
        "servant_title": MessageLookupByLibrary.simpleMessage("Servant"),
        "server": MessageLookupByLibrary.simpleMessage("Server"),
        "server_cn":
            MessageLookupByLibrary.simpleMessage("Chino (Simplificado)"),
        "server_jp": MessageLookupByLibrary.simpleMessage("Japonés"),
        "server_na": MessageLookupByLibrary.simpleMessage("Norteamérica (NA)"),
        "server_tw":
            MessageLookupByLibrary.simpleMessage("Chino (Tradicional)"),
        "set_plan_name":
            MessageLookupByLibrary.simpleMessage("Establecer nombre del plan"),
        "setting_auto_rotate":
            MessageLookupByLibrary.simpleMessage("Auto rotar"),
        "settings_data": MessageLookupByLibrary.simpleMessage("Datos"),
        "settings_data_management":
            MessageLookupByLibrary.simpleMessage("Gestión de Datos"),
        "settings_documents":
            MessageLookupByLibrary.simpleMessage("Documentación"),
        "settings_general": MessageLookupByLibrary.simpleMessage("General"),
        "settings_language": MessageLookupByLibrary.simpleMessage("Lenguaje"),
        "settings_tab_name":
            MessageLookupByLibrary.simpleMessage("Configuración"),
        "settings_use_mobile_network":
            MessageLookupByLibrary.simpleMessage("Permitir red móvil"),
        "settings_userdata_footer": MessageLookupByLibrary.simpleMessage(
            "Realice una copia de seguridad de los datos del usuario antes de actualizar la aplicación y traslade las copias de seguridad a ubicaciones seguras fuera de la carpeta de documentos de la aplicación"),
        "share": MessageLookupByLibrary.simpleMessage("Compartir"),
        "show_outdated":
            MessageLookupByLibrary.simpleMessage("Mostrar desactualizado"),
        "silver": MessageLookupByLibrary.simpleMessage("Plata"),
        "simulator": MessageLookupByLibrary.simpleMessage("Simulador"),
        "skill": MessageLookupByLibrary.simpleMessage("Skill"),
        "skill_up": MessageLookupByLibrary.simpleMessage("Subir Skill"),
        "skilled_max10":
            MessageLookupByLibrary.simpleMessage("Skills Máx(310)"),
        "sprites": MessageLookupByLibrary.simpleMessage("Sprites"),
        "statistics_include_checkbox":
            MessageLookupByLibrary.simpleMessage("Incluyendo objetos propios"),
        "statistics_title":
            MessageLookupByLibrary.simpleMessage("Estadísticas"),
        "storage_permission_title":
            MessageLookupByLibrary.simpleMessage("Permiso de almacenamiento"),
        "success": MessageLookupByLibrary.simpleMessage("Éxito"),
        "summon": MessageLookupByLibrary.simpleMessage("Summon"),
        "summon_simulator":
            MessageLookupByLibrary.simpleMessage("Simulador de Summon"),
        "summon_title": MessageLookupByLibrary.simpleMessage("Summons"),
        "support_chaldea":
            MessageLookupByLibrary.simpleMessage("Apoyo y Donación"),
        "support_party": MessageLookupByLibrary.simpleMessage("Support Setup"),
        "svt_info_tab_base":
            MessageLookupByLibrary.simpleMessage("Información básica"),
        "svt_info_tab_bond_story": MessageLookupByLibrary.simpleMessage("Lore"),
        "svt_not_planned":
            MessageLookupByLibrary.simpleMessage("No es favorito"),
        "svt_obtain_event": MessageLookupByLibrary.simpleMessage("Evento"),
        "svt_obtain_friend_point":
            MessageLookupByLibrary.simpleMessage("FriendPoint"),
        "svt_obtain_initial": MessageLookupByLibrary.simpleMessage("Inicial"),
        "svt_obtain_limited": MessageLookupByLibrary.simpleMessage("Limitado"),
        "svt_obtain_permanent": MessageLookupByLibrary.simpleMessage("Summon"),
        "svt_obtain_story": MessageLookupByLibrary.simpleMessage("Historia"),
        "svt_obtain_unavailable":
            MessageLookupByLibrary.simpleMessage("No disponible"),
        "svt_plan_hidden": MessageLookupByLibrary.simpleMessage("Oculto"),
        "svt_related_cards":
            MessageLookupByLibrary.simpleMessage("Cards relacionadas"),
        "svt_reset_plan":
            MessageLookupByLibrary.simpleMessage("Restablecer plan"),
        "svt_switch_slider_dropdown": MessageLookupByLibrary.simpleMessage(
            "Cambiar control deslizante/desplegable"),
        "sync_server": m17,
        "tooltip_refresh_sliders":
            MessageLookupByLibrary.simpleMessage("Actualizar diapositivas"),
        "total_ap": MessageLookupByLibrary.simpleMessage("AP total"),
        "total_counts": MessageLookupByLibrary.simpleMessage("Cantidad total"),
        "update": MessageLookupByLibrary.simpleMessage("Actualizar"),
        "update_already_latest":
            MessageLookupByLibrary.simpleMessage("Ya es la última versión"),
        "update_dataset": MessageLookupByLibrary.simpleMessage(
            "Actualizar conjunto de datos"),
        "upload": MessageLookupByLibrary.simpleMessage("Cargar"),
        "userdata": MessageLookupByLibrary.simpleMessage("Datos del usuario"),
        "userdata_cleared":
            MessageLookupByLibrary.simpleMessage("Datos de usuario borrados"),
        "userdata_download_backup": MessageLookupByLibrary.simpleMessage(
            "Descargar copia de seguridad"),
        "userdata_download_choose_backup": MessageLookupByLibrary.simpleMessage(
            "Elegir una copia de seguridad"),
        "userdata_sync":
            MessageLookupByLibrary.simpleMessage("Sincronización de datos"),
        "userdata_upload_backup":
            MessageLookupByLibrary.simpleMessage("Cargar copia de seguridad"),
        "valentine_craft":
            MessageLookupByLibrary.simpleMessage("Valentine craft"),
        "version": MessageLookupByLibrary.simpleMessage("Versión"),
        "view_illustration":
            MessageLookupByLibrary.simpleMessage("Ver Ilustración"),
        "voice": MessageLookupByLibrary.simpleMessage("Voz"),
        "words_separate": m18,
        "yes": MessageLookupByLibrary.simpleMessage("Sí")
      };
}
