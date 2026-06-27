// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Quechua (`qu`).
class AppLocalizationsQu extends AppLocalizations {
  AppLocalizationsQu([String locale = 'qu']) : super(locale);

  @override
  String get appName => 'Mapia';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get register => 'Registrarse';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get logoutQuestion => '¿Cerrar sesión?';

  @override
  String get logoutMessage => 'Tendrás que iniciar sesión nuevamente.';

  @override
  String get sessionClosed => 'Sesión cerrada';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get close => 'Cerrar';

  @override
  String get back => 'Volver';

  @override
  String get continueText => 'Continuar';

  @override
  String get retry => 'Reintentar';

  @override
  String get map => 'Mapa';

  @override
  String get explore => 'Explorar';

  @override
  String get publish => 'Publicar';

  @override
  String get publishing => 'Publicando...';

  @override
  String get alerts => 'Alertas';

  @override
  String get profile => 'Perfil';

  @override
  String get publications => 'Publicaciones';

  @override
  String get publication => 'Publicación';

  @override
  String get createPost => 'Crear publicación';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get myPosts => 'Mis publicaciones';

  @override
  String get followers => 'Seguidores';

  @override
  String get following => 'Siguiendo';

  @override
  String get likes => 'Likes';

  @override
  String get comments => 'Comentarios';

  @override
  String get share => 'Compartir';

  @override
  String get verified => 'Verificado';

  @override
  String get inReview => 'En revisión';

  @override
  String get nearYou => 'Cerca de ti';

  @override
  String get nearbyPosts => 'Publicaciones cercanas';

  @override
  String get useMyLocation => 'Usar mi ubicación';

  @override
  String get currentLocation => 'Ubicación actual';

  @override
  String get location => 'Ubicación';

  @override
  String get use => 'Usar';

  @override
  String get postTitle => 'Título';

  @override
  String get postDescription => 'Descripción';

  @override
  String get postType => 'Tipo de publicación';

  @override
  String get optionalPhoto => 'Foto opcional';

  @override
  String get takePhoto => 'Tomar foto';

  @override
  String get chooseFromGallery => 'Galería';

  @override
  String get publishPost => 'Publicar';

  @override
  String get postCreatedSuccessfully => 'Publicación creada correctamente';

  @override
  String get postNotFound => 'Publicación no encontrada.';

  @override
  String get writeComment => 'Escribe un comentario...';

  @override
  String get sendComment => 'Enviar comentario';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get spanish => 'Castellano';

  @override
  String get quechua => 'Quechua';

  @override
  String get aymara => 'Aymara';

  @override
  String get guarani => 'Guaraní';

  @override
  String get available => 'Disponible';

  @override
  String get availablePartial => 'Disponible / Parcial';

  @override
  String get translationInPreparation => 'Traducción en preparación';

  @override
  String get otherOfficialLanguages => 'Otras lenguas oficiales de Bolivia';

  @override
  String languagePreparingMessage(String languageName) {
    return 'La traducción a $languageName está en preparación. Mientras tanto, Mapia usará castellano.';
  }

  @override
  String get welcomeTitle => 'Bienvenido a Mapia';

  @override
  String get welcomeSubtitle =>
      'Inicia sesión para ver alertas ciudadanas cerca de ti.';

  @override
  String get createAccountTitle => 'Crea tu cuenta Mapia';

  @override
  String get createAccountSubtitle =>
      'Únete y reporta lo que está pasando cerca.';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get signIn => 'Ingresar';

  @override
  String get signUp => 'Crear cuenta';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get dontHaveAccount => '¿No tienes cuenta?';

  @override
  String get alreadyHaveAccount => '¿Ya tienes cuenta?';

  @override
  String get or => 'o';

  @override
  String get termsAgreementPrefix => 'Acepto los ';

  @override
  String get terms => 'Términos';

  @override
  String get termsAgreementMiddle => ' y la ';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get searchMapia => 'Buscar en Mapia';

  @override
  String get voiceSearch => 'Búsqueda por voz';

  @override
  String get searchHint => 'Buscar lugares, sucesos o novedades...';

  @override
  String get sectionReady => 'Sección lista para conectar';

  @override
  String get layersEnabled => 'Capas activadas';

  @override
  String get layersHidden => 'Capas ocultas';

  @override
  String get centeredOnLocation => 'Centrado en tu ubicación';

  @override
  String postByAuthor(String authorName) {
    return 'Publicación de $authorName';
  }

  @override
  String get whatIsHappening => '¿Qué está pasando?';

  @override
  String get tellUsMore => 'Cuéntanos más';

  @override
  String get postTitleHint => 'Ej: Pollo barato cerca de la plaza';

  @override
  String get postDescriptionHint =>
      'Describe la novedad de forma corta y útil.';

  @override
  String get completeTitleAndDescription =>
      'Completa título y descripción para publicar.';

  @override
  String get defaultApproxLocation => 'La Paz, Bolivia - ubicación aproximada';

  @override
  String get nearCurrentLocation => 'Sopocachi, La Paz - cerca de tu ubicación';

  @override
  String photoSelectedFrom(String source) {
    return 'Foto seleccionada desde $source';
  }

  @override
  String get camera => 'Cámara';

  @override
  String get gallery => 'Galería';

  @override
  String get changePhoto => 'Cambiar foto';

  @override
  String get name => 'Nombre';

  @override
  String get username => 'Usuario';

  @override
  String get bio => 'Bio';

  @override
  String get nameAndUsernameRequired => 'Nombre y usuario son obligatorios.';

  @override
  String get couldNotSaveChanges => 'No pudimos guardar cambios.';

  @override
  String get couldNotLogout => 'No pudimos cerrar sesión.';

  @override
  String get noPostsYet => 'Todavía no hay publicaciones.';

  @override
  String get alertsNearYou => 'Alertas cerca de ti';

  @override
  String get radius => 'Radio';

  @override
  String radiusKm(String radius) {
    return 'Radio: $radius km';
  }

  @override
  String locationWithAddress(String address) {
    return 'Ubicación: $address';
  }

  @override
  String get nearbySummary => 'Resumen cerca de ti';

  @override
  String get noNearbyPosts => 'No hay publicaciones cerca con este radio.';

  @override
  String get defaultCity => 'La Paz, Bolivia';

  @override
  String get laPaz => 'La Paz';

  @override
  String postsNearYou(String type) {
    return '$type cerca de ti';
  }

  @override
  String get sharePostReady => 'Compartir publicación listo para conectar';

  @override
  String get news => 'Noticia';

  @override
  String get novelty => 'Novedad';

  @override
  String get party => 'Fiesta / evento';

  @override
  String get foodDeal => 'Comida barata';

  @override
  String get sale => 'Venta';

  @override
  String get traffic => 'Tráfico';

  @override
  String get blockade => 'Bloqueo';

  @override
  String get accident => 'Accidente';

  @override
  String get serviceCut => 'Corte de servicio';

  @override
  String get security => 'Seguridad';

  @override
  String get lostFound => 'Perdido / encontrado';

  @override
  String get other => 'Otro';

  @override
  String get newsPlural => 'Noticias';

  @override
  String get noveltyPlural => 'Novedades';

  @override
  String get partyPlural => 'Fiestas / eventos';

  @override
  String get foodDealPlural => 'Comida barata';

  @override
  String get salePlural => 'Ventas';

  @override
  String get trafficPlural => 'Tráfico';

  @override
  String get blockadePlural => 'Bloqueos';

  @override
  String get accidentPlural => 'Accidentes';

  @override
  String get serviceCutPlural => 'Cortes de servicio';

  @override
  String get lostFoundPlural => 'Perdidos / encontrados';

  @override
  String get otherPlural => 'Otros';

  @override
  String get newsDescription => 'Algo importante para el barrio';

  @override
  String get noveltyDescription => 'Algo curioso o útil que pasa cerca';

  @override
  String get partyDescription => 'Actividades, ferias o encuentros';

  @override
  String get foodDealDescription => 'Promos, almuerzos y antojos';

  @override
  String get saleDescription => 'Productos o ventas temporales';

  @override
  String get trafficDescription => 'Rutas lentas o congestionadas';

  @override
  String get blockadeDescription => 'Calles o rutas cerradas';

  @override
  String get accidentDescription => 'Choques o incidentes viales';

  @override
  String get serviceCutDescription => 'Agua, luz, internet u otros';

  @override
  String get securityDescription => 'Zonas de cuidado o apoyo';

  @override
  String get lostFoundDescription => 'Mascotas, documentos u objetos';

  @override
  String get otherDescription => 'Algo que no encaja arriba';

  @override
  String nearbyBlockadesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hay $count bloqueos cerca de ti',
      one: 'Hay 1 bloqueo cerca de ti',
      zero: 'No hay bloqueos cerca de ti',
    );
    return '$_temp0';
  }

  @override
  String nearbyFoodDealsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hay $count comidas baratas cerca de ti',
      one: 'Hay 1 comida barata cerca de ti',
      zero: 'No hay comidas baratas cerca de ti',
    );
    return '$_temp0';
  }

  @override
  String nearbyPartiesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hay $count fiestas cerca de ti',
      one: 'Hay 1 fiesta cerca de ti',
      zero: 'No hay fiestas cerca de ti',
    );
    return '$_temp0';
  }

  @override
  String nearbySalesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hay $count ventas cerca de ti',
      one: 'Hay 1 venta cerca de ti',
      zero: 'No hay ventas cerca de ti',
    );
    return '$_temp0';
  }

  @override
  String commentsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comentarios',
      one: '1 comentario',
      zero: 'Sin comentarios',
    );
    return '$_temp0';
  }

  @override
  String likesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count likes',
      one: '1 like',
      zero: 'Sin likes',
    );
    return '$_temp0';
  }

  @override
  String postsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publicaciones',
      one: '1 publicación',
      zero: 'Sin publicaciones',
    );
    return '$_temp0';
  }

  @override
  String followersCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seguidores',
      one: '1 seguidor',
      zero: 'Sin seguidores',
    );
    return '$_temp0';
  }

  @override
  String get timeAgoNow => 'Ahora';

  @override
  String timeAgoMinutes(num minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Hace $minutes minutos',
      one: 'Hace 1 minuto',
    );
    return '$_temp0';
  }

  @override
  String timeAgoHours(num hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Hace $hours horas',
      one: 'Hace 1 hora',
    );
    return '$_temp0';
  }

  @override
  String timeAgoDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Hace $days días',
      one: 'Hace 1 día',
    );
    return '$_temp0';
  }
}
