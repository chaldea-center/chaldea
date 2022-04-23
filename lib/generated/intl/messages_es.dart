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

  static String m0(curVersion, newVersion, releaseNote) =>
      "Versión actual: ${curVersion}\nÚltima versión: ${newVersion}\nNota de lanzamiento:\n${releaseNote}";

  static String m2(version) =>
      "Versión de la aplicación requerida: ≥ ${version}";

  static String m3(n) => "Lotería Máx. ${n}";

  static String m4(n) => "Griales a Lore: ${n}";

  static String m5(filename, hash, localHash) =>
      "Archivo ${filename} no encontrado o el hash no coincide: ${hash} - ${localHash}";

  static String m6(error) => "La importación ha fallado. Error:\n${error}";

  static String m7(name) => "${name} ya existe";

  static String m8(site) => "Ir a ${site}";

  static String m11(first) =>
      "{primer, selecciona, verdadero{Ya es el primero} falso{Ya es el último} otro{No más}}";

  static String m12(n) => "Restablecer plan ${n}(Todo)";

  static String m13(n) => "Restablecer plan ${n} (Mostrado)";

  static String m15(a, b) => "${a} ${b}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about_app": MessageLookupByLibrary.simpleMessage("Acerca de"),
        "about_app_declaration_text": MessageLookupByLibrary.simpleMessage(
            "Los datos utilizados en esta aplicación provienen del juego Fate/GO y de los siguientes sitios web. Los derechos de autor de los textos, imágenes y voces originales del juego pertenecen a TYPE MOON/FGO PROJECT.\n\nEl diseño del programa se basa en el miniprograma WeChat \"Material Programe\" y la aplicación para iOS \"Guda\".\n"),
        "about_data_source":
            MessageLookupByLibrary.simpleMessage("Fuente de datos"),
        "about_data_source_footer": MessageLookupByLibrary.simpleMessage(
            "Por favor, infórmenos si hay una fuente no acreditada o una infracción"),
        "about_feedback": MessageLookupByLibrary.simpleMessage("Feedback"),
        "about_update_app_detail": m0,
        "account_title": MessageLookupByLibrary.simpleMessage("Cuenta"),
        "active_skill": MessageLookupByLibrary.simpleMessage("Active Skill"),
        "add": MessageLookupByLibrary.simpleMessage("Añadir"),
        "add_feedback_details_warning": MessageLookupByLibrary.simpleMessage(
            "Por favor, agregue sus comentarios"),
        "add_to_blacklist":
            MessageLookupByLibrary.simpleMessage("Añadir a la lista negra"),
        "ap": MessageLookupByLibrary.simpleMessage("AP"),
        "ap_efficiency": MessageLookupByLibrary.simpleMessage("AP rate"),
        "append_skill": MessageLookupByLibrary.simpleMessage("Append Skill"),
        "append_skill_short": MessageLookupByLibrary.simpleMessage("Append"),
        "ascension": MessageLookupByLibrary.simpleMessage("Ascension"),
        "ascension_short": MessageLookupByLibrary.simpleMessage("Ascen"),
        "ascension_up": MessageLookupByLibrary.simpleMessage("Ascension"),
        "attach_from_files": MessageLookupByLibrary.simpleMessage("Archivos"),
        "attach_from_photos": MessageLookupByLibrary.simpleMessage("Imágenes"),
        "attach_help": MessageLookupByLibrary.simpleMessage(
            "Si tienes problemas para seleccionar desde Imágenes, utiliza Archivos en su lugar"),
        "attachment": MessageLookupByLibrary.simpleMessage("Archivo adjunto"),
        "auto_reset":
            MessageLookupByLibrary.simpleMessage("Reinicio automático"),
        "auto_update":
            MessageLookupByLibrary.simpleMessage("Actualizar automáticamente"),
        "backup": MessageLookupByLibrary.simpleMessage("Respaldo"),
        "backup_history": MessageLookupByLibrary.simpleMessage(
            "Historial de copias de seguridad"),
        "blacklist": MessageLookupByLibrary.simpleMessage("Lista negra"),
        "bond": MessageLookupByLibrary.simpleMessage("Bond"),
        "bond_craft": MessageLookupByLibrary.simpleMessage("Bond Craft"),
        "bond_eff": MessageLookupByLibrary.simpleMessage("Bond Eff"),
        "bootstrap_page_title":
            MessageLookupByLibrary.simpleMessage("Página de Arranque"),
        "bronze": MessageLookupByLibrary.simpleMessage("Bronce"),
        "calc_weight": MessageLookupByLibrary.simpleMessage("Peso"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "card_description": MessageLookupByLibrary.simpleMessage("Descripción"),
        "card_info": MessageLookupByLibrary.simpleMessage("Información"),
        "carousel_setting":
            MessageLookupByLibrary.simpleMessage("Configuración del carrusel"),
        "chaldea_account":
            MessageLookupByLibrary.simpleMessage("Usuario de Chaldea"),
        "change_log":
            MessageLookupByLibrary.simpleMessage("Registro de cambios"),
        "characters_in_card":
            MessageLookupByLibrary.simpleMessage("Personajes"),
        "check_update":
            MessageLookupByLibrary.simpleMessage("Comprobar actualización"),
        "clear": MessageLookupByLibrary.simpleMessage("Borrar"),
        "clear_cache": MessageLookupByLibrary.simpleMessage("Borrar caché"),
        "clear_cache_finish":
            MessageLookupByLibrary.simpleMessage("Caché borrada"),
        "clear_cache_hint": MessageLookupByLibrary.simpleMessage(
            "Incluyendo ilustraciones, voces"),
        "clear_data": MessageLookupByLibrary.simpleMessage("Borrar Datos"),
        "command_code": MessageLookupByLibrary.simpleMessage("Command Code"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirmar"),
        "consumed": MessageLookupByLibrary.simpleMessage("Consumido"),
        "contact_information_not_filled": MessageLookupByLibrary.simpleMessage(
            "La información de contacto no está completa"),
        "contact_information_not_filled_warning":
            MessageLookupByLibrary.simpleMessage(
                "El desarrollador no podrá responder a sus comentarios"),
        "copied": MessageLookupByLibrary.simpleMessage("Copiado"),
        "copy": MessageLookupByLibrary.simpleMessage("Copiar"),
        "copy_plan_menu":
            MessageLookupByLibrary.simpleMessage("Copiar Plan de..."),
        "costume": MessageLookupByLibrary.simpleMessage("Vestuario"),
        "costume_unlock":
            MessageLookupByLibrary.simpleMessage("Desbloquear Vestuario"),
        "counts": MessageLookupByLibrary.simpleMessage("Cantidad"),
        "craft_essence": MessageLookupByLibrary.simpleMessage("Craft Essences"),
        "create_account_textfield_helper": MessageLookupByLibrary.simpleMessage(
            "Puedes agregar más cuentas más tarde en Configuración"),
        "create_duplicated_svt":
            MessageLookupByLibrary.simpleMessage("Crear duplicado"),
        "cur_account": MessageLookupByLibrary.simpleMessage("Cuenta Actual"),
        "current_": MessageLookupByLibrary.simpleMessage("Actual"),
        "current_version":
            MessageLookupByLibrary.simpleMessage("Versión Actual"),
        "dark_mode": MessageLookupByLibrary.simpleMessage("Tema"),
        "dark_mode_dark": MessageLookupByLibrary.simpleMessage("Oscuro"),
        "dark_mode_light": MessageLookupByLibrary.simpleMessage("Claro"),
        "dark_mode_system": MessageLookupByLibrary.simpleMessage("Sistema"),
        "database": MessageLookupByLibrary.simpleMessage("Base de datos"),
        "database_not_downloaded": MessageLookupByLibrary.simpleMessage(
            "La Base de Datos no ha sido descargada, ¿Seguro de que desea continuar?"),
        "dataset_version":
            MessageLookupByLibrary.simpleMessage("Versión de los datos"),
        "debug": MessageLookupByLibrary.simpleMessage("Depurar"),
        "debug_fab": MessageLookupByLibrary.simpleMessage("FAB de Depuración"),
        "debug_menu": MessageLookupByLibrary.simpleMessage("Debug Menu"),
        "delete": MessageLookupByLibrary.simpleMessage("Eliminar"),
        "demands": MessageLookupByLibrary.simpleMessage("Demandado"),
        "display_setting":
            MessageLookupByLibrary.simpleMessage("Configuración de pantalla"),
        "done": MessageLookupByLibrary.simpleMessage("FIN."),
        "download": MessageLookupByLibrary.simpleMessage("Descargar"),
        "download_latest_gamedata_hint": MessageLookupByLibrary.simpleMessage(
            "Para garantizar la compatibilidad, actualice a la última versión de la aplicación antes de actualizar"),
        "download_source":
            MessageLookupByLibrary.simpleMessage("Fuente de la descarga"),
        "downloaded": MessageLookupByLibrary.simpleMessage("Descargado"),
        "downloading": MessageLookupByLibrary.simpleMessage("Descargando"),
        "drop_calc_empty_hint": MessageLookupByLibrary.simpleMessage(
            "Haga clic en + para agregar elementos"),
        "drop_calc_min_ap": MessageLookupByLibrary.simpleMessage("AP Mín."),
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
        "email": MessageLookupByLibrary.simpleMessage("Correo electrónico"),
        "enemy_list": MessageLookupByLibrary.simpleMessage("Enemigos"),
        "enhance": MessageLookupByLibrary.simpleMessage("Mejorar"),
        "enhance_warning": MessageLookupByLibrary.simpleMessage(
            "Los siguientes objetos se consumirán para mejorar"),
        "error_no_internet":
            MessageLookupByLibrary.simpleMessage("Sin internet"),
        "error_no_network": MessageLookupByLibrary.simpleMessage("Sin red"),
        "error_no_version_data_found": MessageLookupByLibrary.simpleMessage(
            "No se encontró ninguna versión de datos"),
        "error_required_app_version": m2,
        "event_collect_item_confirm": MessageLookupByLibrary.simpleMessage(
            "Todos los objetos se añadirán al inventario y se eliminará el evento fuera del plan"),
        "event_collect_items":
            MessageLookupByLibrary.simpleMessage("Recoger objetos"),
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
        "exp_card_same_class":
            MessageLookupByLibrary.simpleMessage("Misma Clase"),
        "exp_card_title": MessageLookupByLibrary.simpleMessage("Exp Card"),
        "failed": MessageLookupByLibrary.simpleMessage("Falló"),
        "faq": MessageLookupByLibrary.simpleMessage("FAQ"),
        "favorite": MessageLookupByLibrary.simpleMessage("Favorito"),
        "feedback_add_attachments": MessageLookupByLibrary.simpleMessage(
            "Ej. capturas de pantalla, archivos"),
        "feedback_contact":
            MessageLookupByLibrary.simpleMessage("Información de contacto"),
        "feedback_content_hint":
            MessageLookupByLibrary.simpleMessage("Comentarios o Sugerencias"),
        "feedback_form_alert": MessageLookupByLibrary.simpleMessage(
            "El formulario de comentarios no está vacío, ¿todavía existe?"),
        "feedback_info": MessageLookupByLibrary.simpleMessage(
            "Consulte las <**FAQ**> antes de enviar comentarios. Los siguientes detalles son deseados:\n- Cómo reproducir el problema, comportamiento esperado\n- Versión de la aplicación/conjunto de datos, sistema del dispositivo y versión\n- Adjunte capturas de pantalla y registros\n- Es mejor proporcionar información de contacto (por ejemplo, correo electrónico)"),
        "feedback_send": MessageLookupByLibrary.simpleMessage("Enviar"),
        "feedback_subject": MessageLookupByLibrary.simpleMessage("Asunto"),
        "ffo_background": MessageLookupByLibrary.simpleMessage("Fondo"),
        "ffo_body": MessageLookupByLibrary.simpleMessage("Cuerpo"),
        "ffo_crop": MessageLookupByLibrary.simpleMessage("Cortar"),
        "ffo_head": MessageLookupByLibrary.simpleMessage("Cabeza"),
        "ffo_missing_data_hint": MessageLookupByLibrary.simpleMessage(
            "Primero descargue o importe los datos de FFO↗"),
        "ffo_same_svt": MessageLookupByLibrary.simpleMessage("Mismo Servant"),
        "fgo_domus_aurea": MessageLookupByLibrary.simpleMessage("Domus Áurea"),
        "file_not_found_or_mismatched_hash": m5,
        "filename": MessageLookupByLibrary.simpleMessage("nombre del archivo"),
        "fill_email_warning": MessageLookupByLibrary.simpleMessage(
            "Por favor, rellene la dirección de correo. De lo contrario NO hay respuesta."),
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
        "game_data_not_found": MessageLookupByLibrary.simpleMessage(
            "No se encontraron los datos del juego, descargue los datos primero"),
        "game_drop": MessageLookupByLibrary.simpleMessage("Drop"),
        "game_experience": MessageLookupByLibrary.simpleMessage("Experiencia"),
        "game_kizuna": MessageLookupByLibrary.simpleMessage("Bond"),
        "game_rewards": MessageLookupByLibrary.simpleMessage("Recompensas"),
        "game_server": MessageLookupByLibrary.simpleMessage("Servidor"),
        "gamedata": MessageLookupByLibrary.simpleMessage("Datos del juego"),
        "gold": MessageLookupByLibrary.simpleMessage("Oro"),
        "grail": MessageLookupByLibrary.simpleMessage("Grial"),
        "grail_up": MessageLookupByLibrary.simpleMessage("Palingenesis"),
        "growth_curve":
            MessageLookupByLibrary.simpleMessage("Curva de crecimiento"),
        "help": MessageLookupByLibrary.simpleMessage("Ayuda"),
        "hide_outdated":
            MessageLookupByLibrary.simpleMessage("Ocultar desactualizado"),
        "icons": MessageLookupByLibrary.simpleMessage("Iconos"),
        "ignore": MessageLookupByLibrary.simpleMessage("Ignorar"),
        "illustration": MessageLookupByLibrary.simpleMessage("Ilustración"),
        "illustrator": MessageLookupByLibrary.simpleMessage("Ilustrador"),
        "import_data": MessageLookupByLibrary.simpleMessage("Importar"),
        "import_data_error": m6,
        "import_data_success":
            MessageLookupByLibrary.simpleMessage("Importar datos con éxito"),
        "import_http_body_duplicated":
            MessageLookupByLibrary.simpleMessage("Duplicado"),
        "import_http_body_hint": MessageLookupByLibrary.simpleMessage(
            "Haga clic en el botón Importar para importar la respuesta HTTPS descifrada"),
        "import_http_body_hint_hide": MessageLookupByLibrary.simpleMessage(
            "Haga clic en el Servant para ocultar/mostrar"),
        "import_http_body_locked":
            MessageLookupByLibrary.simpleMessage("Solo bloqueado"),
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
        "info_luck": MessageLookupByLibrary.simpleMessage("Suerte"),
        "info_mana": MessageLookupByLibrary.simpleMessage("Maná"),
        "info_np": MessageLookupByLibrary.simpleMessage("NP"),
        "info_np_rate": MessageLookupByLibrary.simpleMessage("NP Rate"),
        "info_star_rate": MessageLookupByLibrary.simpleMessage("Star Rate"),
        "info_strength": MessageLookupByLibrary.simpleMessage("Fuerza"),
        "info_trait": MessageLookupByLibrary.simpleMessage("Traits"),
        "info_value": MessageLookupByLibrary.simpleMessage("Valor"),
        "input_invalid_hint":
            MessageLookupByLibrary.simpleMessage("Entradas inválidas"),
        "install": MessageLookupByLibrary.simpleMessage("Instalar"),
        "interlude_and_rankup":
            MessageLookupByLibrary.simpleMessage("Interlude & Rank Up"),
        "invalid_input":
            MessageLookupByLibrary.simpleMessage("Entrada inválida."),
        "invalid_startup_path":
            MessageLookupByLibrary.simpleMessage("¡Ruta de inicio inválida!"),
        "invalid_startup_path_info": MessageLookupByLibrary.simpleMessage(
            "Please, extract zip to non-system path then start the app. \"C:\\\", \"C:\\Program Files\" are not allowed."),
        "ios_app_path": MessageLookupByLibrary.simpleMessage(
            "Aplicación \"Archivos\"/En mi iPhone/Caldea"),
        "issues": MessageLookupByLibrary.simpleMessage("Problemas"),
        "item": MessageLookupByLibrary.simpleMessage("Objeto"),
        "item_already_exist_hint": m7,
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
        "jump_to": m8,
        "language": MessageLookupByLibrary.simpleMessage("Español"),
        "language_en": MessageLookupByLibrary.simpleMessage("Spanish"),
        "level": MessageLookupByLibrary.simpleMessage("Nivel"),
        "limited_event":
            MessageLookupByLibrary.simpleMessage("Evento Limitado"),
        "link": MessageLookupByLibrary.simpleMessage("enlace"),
        "list_end_hint": m11,
        "login_change_name":
            MessageLookupByLibrary.simpleMessage("Cambiar nombre"),
        "login_change_password":
            MessageLookupByLibrary.simpleMessage("Cambiar contraseña"),
        "login_confirm_password":
            MessageLookupByLibrary.simpleMessage("Confirmar contraseña"),
        "login_first_hint": MessageLookupByLibrary.simpleMessage(
            "Por favor, inicie sesión primero"),
        "login_forget_pwd":
            MessageLookupByLibrary.simpleMessage("Contraseña olvidada"),
        "login_login": MessageLookupByLibrary.simpleMessage("Iniciar sesión"),
        "login_logout": MessageLookupByLibrary.simpleMessage("Cerrar sesión"),
        "login_new_name": MessageLookupByLibrary.simpleMessage("Nuevo nombre"),
        "login_new_password":
            MessageLookupByLibrary.simpleMessage("Nueva contraseña"),
        "login_password": MessageLookupByLibrary.simpleMessage("Contraseña"),
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
        "main_record_chapter": MessageLookupByLibrary.simpleMessage("Capítulo"),
        "master_detail_width":
            MessageLookupByLibrary.simpleMessage("Ancho Master-Detalles"),
        "master_mission":
            MessageLookupByLibrary.simpleMessage("Misiones de Master"),
        "master_mission_related_quest":
            MessageLookupByLibrary.simpleMessage("Misiones relacionadas"),
        "master_mission_solution":
            MessageLookupByLibrary.simpleMessage("Solución"),
        "master_mission_tasklist":
            MessageLookupByLibrary.simpleMessage("Misiones"),
        "move_down": MessageLookupByLibrary.simpleMessage("Mover hacia abajo"),
        "move_up": MessageLookupByLibrary.simpleMessage("Mover hacia arriba"),
        "mystic_code": MessageLookupByLibrary.simpleMessage("Mystic Code"),
        "new_account": MessageLookupByLibrary.simpleMessage("Nueva Cuenta"),
        "next_card": MessageLookupByLibrary.simpleMessage("Siguiente"),
        "no_servant_quest_hint": MessageLookupByLibrary.simpleMessage(
            "No hay interludio o rank up quest"),
        "no_servant_quest_hint_subtitle": MessageLookupByLibrary.simpleMessage(
            "Haga clic en ♡ para ver todos los quests de los servants"),
        "noble_phantasm":
            MessageLookupByLibrary.simpleMessage("Noble Phantasm"),
        "noble_phantasm_level":
            MessageLookupByLibrary.simpleMessage("Noble Phantasm"),
        "not_found": MessageLookupByLibrary.simpleMessage("No encontrado"),
        "not_implemented":
            MessageLookupByLibrary.simpleMessage("Todavía sin implementar"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "open": MessageLookupByLibrary.simpleMessage("Abrir"),
        "open_condition": MessageLookupByLibrary.simpleMessage("Condición"),
        "overview": MessageLookupByLibrary.simpleMessage("Resumen"),
        "passive_skill": MessageLookupByLibrary.simpleMessage("Passive Skill"),
        "plan": MessageLookupByLibrary.simpleMessage("Plan"),
        "plan_max10": MessageLookupByLibrary.simpleMessage("Plan Máx(310)"),
        "plan_max9": MessageLookupByLibrary.simpleMessage("Plan Máx(999)"),
        "plan_objective":
            MessageLookupByLibrary.simpleMessage("Objetivo del Plan"),
        "plan_title": MessageLookupByLibrary.simpleMessage("Plan"),
        "planning_free_quest_btn":
            MessageLookupByLibrary.simpleMessage("Planificación de Quests"),
        "preferred_translation":
            MessageLookupByLibrary.simpleMessage("Traducción preferida"),
        "preferred_translation_footer": MessageLookupByLibrary.simpleMessage(
            "Arrastre para cambiar el orden.\nSe utiliza para la descripción de los datos del juego, no para el idioma de la interfaz de usuario. No todos los datos del juego están traducidos para los 5 idiomas oficiales."),
        "preview": MessageLookupByLibrary.simpleMessage("Vista previa"),
        "previous_card": MessageLookupByLibrary.simpleMessage("Anterior"),
        "priority": MessageLookupByLibrary.simpleMessage("Prioridad"),
        "project_homepage": MessageLookupByLibrary.simpleMessage(
            "Página de inicio del proyecto"),
        "quest": MessageLookupByLibrary.simpleMessage("Quest"),
        "quest_condition": MessageLookupByLibrary.simpleMessage("Condiciones"),
        "quest_fixed_drop": MessageLookupByLibrary.simpleMessage("Drops"),
        "quest_fixed_drop_short": MessageLookupByLibrary.simpleMessage("Drops"),
        "quest_reward": MessageLookupByLibrary.simpleMessage("Bonus"),
        "quest_reward_short": MessageLookupByLibrary.simpleMessage("Bonus"),
        "rarity": MessageLookupByLibrary.simpleMessage("Rareza"),
        "rate_app_store":
            MessageLookupByLibrary.simpleMessage("Valorar en App Store"),
        "rate_play_store":
            MessageLookupByLibrary.simpleMessage("Valorar en Google Play"),
        "remove_duplicated_svt":
            MessageLookupByLibrary.simpleMessage("Remover duplicado"),
        "remove_from_blacklist":
            MessageLookupByLibrary.simpleMessage("Remover de la lista negra"),
        "rename": MessageLookupByLibrary.simpleMessage("Renombrar"),
        "rerun_event": MessageLookupByLibrary.simpleMessage("Rerun"),
        "reset": MessageLookupByLibrary.simpleMessage("Reiniciar"),
        "reset_plan_all": m12,
        "reset_plan_shown": m13,
        "restart_to_apply_changes": MessageLookupByLibrary.simpleMessage(
            "Reiniciar para que surta efecto"),
        "restart_to_upgrade_hint": MessageLookupByLibrary.simpleMessage(
            "Reiniciar para actualizar. Si la actualización falla, copie manualmente la carpeta de origen en el destino"),
        "restore": MessageLookupByLibrary.simpleMessage("Restaurar"),
        "saint_quartz_plan": MessageLookupByLibrary.simpleMessage("SQ Plan"),
        "save": MessageLookupByLibrary.simpleMessage("Guardar"),
        "save_to_photos":
            MessageLookupByLibrary.simpleMessage("Guardar en Fotos"),
        "saved": MessageLookupByLibrary.simpleMessage("Guardado"),
        "screen_size":
            MessageLookupByLibrary.simpleMessage("Tamaño de la pantalla"),
        "search": MessageLookupByLibrary.simpleMessage("Buscar"),
        "search_option_basic": MessageLookupByLibrary.simpleMessage("Básica"),
        "search_options":
            MessageLookupByLibrary.simpleMessage("Alcances de búsqueda"),
        "select_copy_plan_source":
            MessageLookupByLibrary.simpleMessage("Seleccionar fuente de copia"),
        "select_lang":
            MessageLookupByLibrary.simpleMessage("Selecciona un idioma"),
        "select_plan": MessageLookupByLibrary.simpleMessage("Seleccionar Plan"),
        "send_email_to":
            MessageLookupByLibrary.simpleMessage("Enviar el correo a"),
        "sending": MessageLookupByLibrary.simpleMessage("Enviando"),
        "sending_failed": MessageLookupByLibrary.simpleMessage("Envío fallido"),
        "sent": MessageLookupByLibrary.simpleMessage("Enviado"),
        "servant": MessageLookupByLibrary.simpleMessage("Servants"),
        "servant_coin": MessageLookupByLibrary.simpleMessage("Servant Coin"),
        "servant_detail_page": MessageLookupByLibrary.simpleMessage(
            "Página de detalles del Servant"),
        "servant_list_page":
            MessageLookupByLibrary.simpleMessage("Pagína de lista de Servants"),
        "servant_title": MessageLookupByLibrary.simpleMessage("Servants"),
        "set_plan_name":
            MessageLookupByLibrary.simpleMessage("Establecer nombre del plan"),
        "setting_always_on_top":
            MessageLookupByLibrary.simpleMessage("Siempre al frente"),
        "setting_auto_rotate":
            MessageLookupByLibrary.simpleMessage("Auto rotar"),
        "setting_auto_turn_on_plan_not_reach":
            MessageLookupByLibrary.simpleMessage(
                "Encendido automático cuando el Plan no se alcanza"),
        "setting_home_plan_list_page": MessageLookupByLibrary.simpleMessage(
            "Página de lista de Inicio-Plan"),
        "setting_only_change_second_append_skill":
            MessageLookupByLibrary.simpleMessage(
                "Solo cambiar la 2da Append Skill"),
        "setting_priority_tagging":
            MessageLookupByLibrary.simpleMessage("Prioridad de las Etiquetas"),
        "setting_servant_class_filter_style":
            MessageLookupByLibrary.simpleMessage(
                "Estilo de filtro de la Clase de Servart"),
        "setting_setting_favorite_button_default":
            MessageLookupByLibrary.simpleMessage(
                "Predeterminado del Botón Favorito"),
        "setting_show_account_at_homepage":
            MessageLookupByLibrary.simpleMessage(
                "Mostrar cuenta en la página de Inicio"),
        "setting_tabs_sorting":
            MessageLookupByLibrary.simpleMessage("Orden de las Pestañas"),
        "settings_data": MessageLookupByLibrary.simpleMessage("Datos"),
        "settings_documents":
            MessageLookupByLibrary.simpleMessage("Documentación"),
        "settings_general": MessageLookupByLibrary.simpleMessage("General"),
        "settings_language": MessageLookupByLibrary.simpleMessage("Idioma"),
        "settings_tab_name":
            MessageLookupByLibrary.simpleMessage("Configuración"),
        "settings_userdata_footer": MessageLookupByLibrary.simpleMessage(
            "Realice una copia de seguridad de los datos del usuario antes de actualizar la aplicación y traslade las copias de seguridad a ubicaciones seguras fuera de la carpeta de documentos de la aplicación"),
        "share": MessageLookupByLibrary.simpleMessage("Compartir"),
        "show_frame_rate": MessageLookupByLibrary.simpleMessage(
            "Mostrar velocidad de fotogramas"),
        "show_outdated":
            MessageLookupByLibrary.simpleMessage("Mostrar desactualizado"),
        "silver": MessageLookupByLibrary.simpleMessage("Plata"),
        "simulator": MessageLookupByLibrary.simpleMessage("Simulador"),
        "skill": MessageLookupByLibrary.simpleMessage("Skill"),
        "skill_up": MessageLookupByLibrary.simpleMessage("Subir Skill"),
        "skilled_max10":
            MessageLookupByLibrary.simpleMessage("Skills Máx(310)"),
        "sprites": MessageLookupByLibrary.simpleMessage("Sprites"),
        "statistics_title":
            MessageLookupByLibrary.simpleMessage("Estadísticas"),
        "still_send":
            MessageLookupByLibrary.simpleMessage("Enviar de todas formas"),
        "success": MessageLookupByLibrary.simpleMessage("Éxito"),
        "summon": MessageLookupByLibrary.simpleMessage("Summon"),
        "summon_title": MessageLookupByLibrary.simpleMessage("Summons"),
        "support_chaldea":
            MessageLookupByLibrary.simpleMessage("Apoyo y Donación"),
        "svt_not_planned":
            MessageLookupByLibrary.simpleMessage("No es favorito"),
        "svt_plan_hidden": MessageLookupByLibrary.simpleMessage("Oculto"),
        "svt_reset_plan":
            MessageLookupByLibrary.simpleMessage("Restablecer plan"),
        "svt_switch_slider_dropdown": MessageLookupByLibrary.simpleMessage(
            "Cambiar control deslizante/desplegable"),
        "test_info_pad":
            MessageLookupByLibrary.simpleMessage("Información de Testeo"),
        "toogle_dark_mode":
            MessageLookupByLibrary.simpleMessage("Alternar tema"),
        "tooltip_refresh_sliders":
            MessageLookupByLibrary.simpleMessage("Actualizar diapositivas"),
        "total_ap": MessageLookupByLibrary.simpleMessage("AP total"),
        "total_counts": MessageLookupByLibrary.simpleMessage("Cantidad total"),
        "update": MessageLookupByLibrary.simpleMessage("Actualizar"),
        "update_already_latest":
            MessageLookupByLibrary.simpleMessage("Ya es la última versión"),
        "update_dataset": MessageLookupByLibrary.simpleMessage(
            "Actualizar conjunto de datos"),
        "userdata": MessageLookupByLibrary.simpleMessage("Datos del usuario"),
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
        "warning": MessageLookupByLibrary.simpleMessage("Advertencia"),
        "web_renderer":
            MessageLookupByLibrary.simpleMessage("Renderizador Web"),
        "words_separate": m15
      };
}
