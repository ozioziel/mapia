import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ay.dart';
import 'app_localizations_es.dart';
import 'app_localizations_gn.dart';
import 'app_localizations_qu.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ay'),
    Locale('es'),
    Locale('gn'),
    Locale('qu'),
  ];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'Mapia'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get login;

  /// No description provided for @register.
  ///
  /// In es, this message translates to:
  /// **'Registrarse'**
  String get register;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get email;

  /// No description provided for @password.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// No description provided for @fullName.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get fullName;

  /// No description provided for @confirmPassword.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get confirmPassword;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logout;

  /// No description provided for @logoutQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Cerrar sesión?'**
  String get logoutQuestion;

  /// No description provided for @logoutMessage.
  ///
  /// In es, this message translates to:
  /// **'Tendrás que iniciar sesión nuevamente.'**
  String get logoutMessage;

  /// No description provided for @sessionClosed.
  ///
  /// In es, this message translates to:
  /// **'Sesión cerrada'**
  String get sessionClosed;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @saveChanges.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get saveChanges;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @back.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get back;

  /// No description provided for @continueText.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continueText;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @map.
  ///
  /// In es, this message translates to:
  /// **'Mapa'**
  String get map;

  /// No description provided for @explore.
  ///
  /// In es, this message translates to:
  /// **'Explorar'**
  String get explore;

  /// No description provided for @publish.
  ///
  /// In es, this message translates to:
  /// **'Publicar'**
  String get publish;

  /// No description provided for @publishing.
  ///
  /// In es, this message translates to:
  /// **'Publicando...'**
  String get publishing;

  /// No description provided for @alerts.
  ///
  /// In es, this message translates to:
  /// **'Alertas'**
  String get alerts;

  /// No description provided for @profile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profile;

  /// No description provided for @publications.
  ///
  /// In es, this message translates to:
  /// **'Publicaciones'**
  String get publications;

  /// No description provided for @publication.
  ///
  /// In es, this message translates to:
  /// **'Publicación'**
  String get publication;

  /// No description provided for @createPost.
  ///
  /// In es, this message translates to:
  /// **'Crear publicación'**
  String get createPost;

  /// No description provided for @editProfile.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get editProfile;

  /// No description provided for @myPosts.
  ///
  /// In es, this message translates to:
  /// **'Mis publicaciones'**
  String get myPosts;

  /// No description provided for @followers.
  ///
  /// In es, this message translates to:
  /// **'Seguidores'**
  String get followers;

  /// No description provided for @following.
  ///
  /// In es, this message translates to:
  /// **'Siguiendo'**
  String get following;

  /// No description provided for @likes.
  ///
  /// In es, this message translates to:
  /// **'Likes'**
  String get likes;

  /// No description provided for @comments.
  ///
  /// In es, this message translates to:
  /// **'Comentarios'**
  String get comments;

  /// No description provided for @share.
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get share;

  /// No description provided for @verified.
  ///
  /// In es, this message translates to:
  /// **'Verificado'**
  String get verified;

  /// No description provided for @inReview.
  ///
  /// In es, this message translates to:
  /// **'En revisión'**
  String get inReview;

  /// No description provided for @nearYou.
  ///
  /// In es, this message translates to:
  /// **'Cerca de ti'**
  String get nearYou;

  /// No description provided for @nearbyPosts.
  ///
  /// In es, this message translates to:
  /// **'Publicaciones cercanas'**
  String get nearbyPosts;

  /// No description provided for @useMyLocation.
  ///
  /// In es, this message translates to:
  /// **'Usar mi ubicación'**
  String get useMyLocation;

  /// No description provided for @currentLocation.
  ///
  /// In es, this message translates to:
  /// **'Ubicación actual'**
  String get currentLocation;

  /// No description provided for @location.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get location;

  /// No description provided for @use.
  ///
  /// In es, this message translates to:
  /// **'Usar'**
  String get use;

  /// No description provided for @postTitle.
  ///
  /// In es, this message translates to:
  /// **'Título'**
  String get postTitle;

  /// No description provided for @postDescription.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get postDescription;

  /// No description provided for @postType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de publicación'**
  String get postType;

  /// No description provided for @optionalPhoto.
  ///
  /// In es, this message translates to:
  /// **'Foto opcional'**
  String get optionalPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In es, this message translates to:
  /// **'Tomar foto'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In es, this message translates to:
  /// **'Galería'**
  String get chooseFromGallery;

  /// No description provided for @publishPost.
  ///
  /// In es, this message translates to:
  /// **'Publicar'**
  String get publishPost;

  /// No description provided for @postCreatedSuccessfully.
  ///
  /// In es, this message translates to:
  /// **'Publicación creada correctamente'**
  String get postCreatedSuccessfully;

  /// No description provided for @postNotFound.
  ///
  /// In es, this message translates to:
  /// **'Publicación no encontrada.'**
  String get postNotFound;

  /// No description provided for @writeComment.
  ///
  /// In es, this message translates to:
  /// **'Escribe un comentario...'**
  String get writeComment;

  /// No description provided for @sendComment.
  ///
  /// In es, this message translates to:
  /// **'Enviar comentario'**
  String get sendComment;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar idioma'**
  String get selectLanguage;

  /// No description provided for @spanish.
  ///
  /// In es, this message translates to:
  /// **'Castellano'**
  String get spanish;

  /// No description provided for @quechua.
  ///
  /// In es, this message translates to:
  /// **'Quechua'**
  String get quechua;

  /// No description provided for @aymara.
  ///
  /// In es, this message translates to:
  /// **'Aymara'**
  String get aymara;

  /// No description provided for @guarani.
  ///
  /// In es, this message translates to:
  /// **'Guaraní'**
  String get guarani;

  /// No description provided for @available.
  ///
  /// In es, this message translates to:
  /// **'Disponible'**
  String get available;

  /// No description provided for @availablePartial.
  ///
  /// In es, this message translates to:
  /// **'Disponible / Parcial'**
  String get availablePartial;

  /// No description provided for @translationInPreparation.
  ///
  /// In es, this message translates to:
  /// **'Traducción en preparación'**
  String get translationInPreparation;

  /// No description provided for @otherOfficialLanguages.
  ///
  /// In es, this message translates to:
  /// **'Otras lenguas oficiales de Bolivia'**
  String get otherOfficialLanguages;

  /// No description provided for @languagePreparingMessage.
  ///
  /// In es, this message translates to:
  /// **'La traducción a {languageName} está en preparación. Mientras tanto, Mapia usará castellano.'**
  String languagePreparingMessage(String languageName);

  /// No description provided for @welcomeTitle.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a Mapia'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión para ver alertas ciudadanas cerca de ti.'**
  String get welcomeSubtitle;

  /// No description provided for @createAccountTitle.
  ///
  /// In es, this message translates to:
  /// **'Crea tu cuenta Mapia'**
  String get createAccountTitle;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Únete y reporta lo que está pasando cerca.'**
  String get createAccountSubtitle;

  /// No description provided for @forgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In es, this message translates to:
  /// **'Ingresar'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get signUp;

  /// No description provided for @continueWithGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get continueWithGoogle;

  /// No description provided for @dontHaveAccount.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta?'**
  String get alreadyHaveAccount;

  /// No description provided for @or.
  ///
  /// In es, this message translates to:
  /// **'o'**
  String get or;

  /// No description provided for @termsAgreementPrefix.
  ///
  /// In es, this message translates to:
  /// **'Acepto los '**
  String get termsAgreementPrefix;

  /// No description provided for @terms.
  ///
  /// In es, this message translates to:
  /// **'Términos'**
  String get terms;

  /// No description provided for @termsAgreementMiddle.
  ///
  /// In es, this message translates to:
  /// **' y la '**
  String get termsAgreementMiddle;

  /// No description provided for @privacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get privacyPolicy;

  /// No description provided for @searchMapia.
  ///
  /// In es, this message translates to:
  /// **'Buscar en Mapia'**
  String get searchMapia;

  /// No description provided for @voiceSearch.
  ///
  /// In es, this message translates to:
  /// **'Búsqueda por voz'**
  String get voiceSearch;

  /// No description provided for @searchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar lugares, sucesos o novedades...'**
  String get searchHint;

  /// No description provided for @sectionReady.
  ///
  /// In es, this message translates to:
  /// **'Sección lista para conectar'**
  String get sectionReady;

  /// No description provided for @layersEnabled.
  ///
  /// In es, this message translates to:
  /// **'Capas activadas'**
  String get layersEnabled;

  /// No description provided for @layersHidden.
  ///
  /// In es, this message translates to:
  /// **'Capas ocultas'**
  String get layersHidden;

  /// No description provided for @centeredOnLocation.
  ///
  /// In es, this message translates to:
  /// **'Centrado en tu ubicación'**
  String get centeredOnLocation;

  /// No description provided for @postByAuthor.
  ///
  /// In es, this message translates to:
  /// **'Publicación de {authorName}'**
  String postByAuthor(String authorName);

  /// No description provided for @whatIsHappening.
  ///
  /// In es, this message translates to:
  /// **'¿Qué está pasando?'**
  String get whatIsHappening;

  /// No description provided for @tellUsMore.
  ///
  /// In es, this message translates to:
  /// **'Cuéntanos más'**
  String get tellUsMore;

  /// No description provided for @postTitleHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Pollo barato cerca de la plaza'**
  String get postTitleHint;

  /// No description provided for @postDescriptionHint.
  ///
  /// In es, this message translates to:
  /// **'Describe la novedad de forma corta y útil.'**
  String get postDescriptionHint;

  /// No description provided for @completeTitleAndDescription.
  ///
  /// In es, this message translates to:
  /// **'Completa título y descripción para publicar.'**
  String get completeTitleAndDescription;

  /// No description provided for @defaultApproxLocation.
  ///
  /// In es, this message translates to:
  /// **'La Paz, Bolivia - ubicación aproximada'**
  String get defaultApproxLocation;

  /// No description provided for @nearCurrentLocation.
  ///
  /// In es, this message translates to:
  /// **'Sopocachi, La Paz - cerca de tu ubicación'**
  String get nearCurrentLocation;

  /// No description provided for @photoSelectedFrom.
  ///
  /// In es, this message translates to:
  /// **'Foto seleccionada desde {source}'**
  String photoSelectedFrom(String source);

  /// No description provided for @camera.
  ///
  /// In es, this message translates to:
  /// **'Cámara'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In es, this message translates to:
  /// **'Galería'**
  String get gallery;

  /// No description provided for @changePhoto.
  ///
  /// In es, this message translates to:
  /// **'Cambiar foto'**
  String get changePhoto;

  /// No description provided for @name.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get name;

  /// No description provided for @username.
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get username;

  /// No description provided for @bio.
  ///
  /// In es, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @nameAndUsernameRequired.
  ///
  /// In es, this message translates to:
  /// **'Nombre y usuario son obligatorios.'**
  String get nameAndUsernameRequired;

  /// No description provided for @couldNotSaveChanges.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar cambios.'**
  String get couldNotSaveChanges;

  /// No description provided for @couldNotLogout.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cerrar sesión.'**
  String get couldNotLogout;

  /// No description provided for @noPostsYet.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay publicaciones.'**
  String get noPostsYet;

  /// No description provided for @alertsNearYou.
  ///
  /// In es, this message translates to:
  /// **'Alertas cerca de ti'**
  String get alertsNearYou;

  /// No description provided for @radius.
  ///
  /// In es, this message translates to:
  /// **'Radio'**
  String get radius;

  /// No description provided for @radiusKm.
  ///
  /// In es, this message translates to:
  /// **'Radio: {radius} km'**
  String radiusKm(String radius);

  /// No description provided for @locationWithAddress.
  ///
  /// In es, this message translates to:
  /// **'Ubicación: {address}'**
  String locationWithAddress(String address);

  /// No description provided for @nearbySummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen cerca de ti'**
  String get nearbySummary;

  /// No description provided for @noNearbyPosts.
  ///
  /// In es, this message translates to:
  /// **'No hay publicaciones cerca con este radio.'**
  String get noNearbyPosts;

  /// No description provided for @defaultCity.
  ///
  /// In es, this message translates to:
  /// **'La Paz, Bolivia'**
  String get defaultCity;

  /// No description provided for @laPaz.
  ///
  /// In es, this message translates to:
  /// **'La Paz'**
  String get laPaz;

  /// No description provided for @postsNearYou.
  ///
  /// In es, this message translates to:
  /// **'{type} cerca de ti'**
  String postsNearYou(String type);

  /// No description provided for @sharePostReady.
  ///
  /// In es, this message translates to:
  /// **'Compartir publicación listo para conectar'**
  String get sharePostReady;

  /// No description provided for @news.
  ///
  /// In es, this message translates to:
  /// **'Noticia'**
  String get news;

  /// No description provided for @novelty.
  ///
  /// In es, this message translates to:
  /// **'Novedad'**
  String get novelty;

  /// No description provided for @party.
  ///
  /// In es, this message translates to:
  /// **'Fiesta / evento'**
  String get party;

  /// No description provided for @foodDeal.
  ///
  /// In es, this message translates to:
  /// **'Comida barata'**
  String get foodDeal;

  /// No description provided for @sale.
  ///
  /// In es, this message translates to:
  /// **'Venta'**
  String get sale;

  /// No description provided for @traffic.
  ///
  /// In es, this message translates to:
  /// **'Tráfico'**
  String get traffic;

  /// No description provided for @blockade.
  ///
  /// In es, this message translates to:
  /// **'Bloqueo'**
  String get blockade;

  /// No description provided for @accident.
  ///
  /// In es, this message translates to:
  /// **'Accidente'**
  String get accident;

  /// No description provided for @serviceCut.
  ///
  /// In es, this message translates to:
  /// **'Corte de servicio'**
  String get serviceCut;

  /// No description provided for @security.
  ///
  /// In es, this message translates to:
  /// **'Seguridad'**
  String get security;

  /// No description provided for @lostFound.
  ///
  /// In es, this message translates to:
  /// **'Perdido / encontrado'**
  String get lostFound;

  /// No description provided for @other.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get other;

  /// No description provided for @newsPlural.
  ///
  /// In es, this message translates to:
  /// **'Noticias'**
  String get newsPlural;

  /// No description provided for @noveltyPlural.
  ///
  /// In es, this message translates to:
  /// **'Novedades'**
  String get noveltyPlural;

  /// No description provided for @partyPlural.
  ///
  /// In es, this message translates to:
  /// **'Fiestas / eventos'**
  String get partyPlural;

  /// No description provided for @foodDealPlural.
  ///
  /// In es, this message translates to:
  /// **'Comida barata'**
  String get foodDealPlural;

  /// No description provided for @salePlural.
  ///
  /// In es, this message translates to:
  /// **'Ventas'**
  String get salePlural;

  /// No description provided for @trafficPlural.
  ///
  /// In es, this message translates to:
  /// **'Tráfico'**
  String get trafficPlural;

  /// No description provided for @blockadePlural.
  ///
  /// In es, this message translates to:
  /// **'Bloqueos'**
  String get blockadePlural;

  /// No description provided for @accidentPlural.
  ///
  /// In es, this message translates to:
  /// **'Accidentes'**
  String get accidentPlural;

  /// No description provided for @serviceCutPlural.
  ///
  /// In es, this message translates to:
  /// **'Cortes de servicio'**
  String get serviceCutPlural;

  /// No description provided for @lostFoundPlural.
  ///
  /// In es, this message translates to:
  /// **'Perdidos / encontrados'**
  String get lostFoundPlural;

  /// No description provided for @otherPlural.
  ///
  /// In es, this message translates to:
  /// **'Otros'**
  String get otherPlural;

  /// No description provided for @newsDescription.
  ///
  /// In es, this message translates to:
  /// **'Algo importante para el barrio'**
  String get newsDescription;

  /// No description provided for @noveltyDescription.
  ///
  /// In es, this message translates to:
  /// **'Algo curioso o útil que pasa cerca'**
  String get noveltyDescription;

  /// No description provided for @partyDescription.
  ///
  /// In es, this message translates to:
  /// **'Actividades, ferias o encuentros'**
  String get partyDescription;

  /// No description provided for @foodDealDescription.
  ///
  /// In es, this message translates to:
  /// **'Promos, almuerzos y antojos'**
  String get foodDealDescription;

  /// No description provided for @saleDescription.
  ///
  /// In es, this message translates to:
  /// **'Productos o ventas temporales'**
  String get saleDescription;

  /// No description provided for @trafficDescription.
  ///
  /// In es, this message translates to:
  /// **'Rutas lentas o congestionadas'**
  String get trafficDescription;

  /// No description provided for @blockadeDescription.
  ///
  /// In es, this message translates to:
  /// **'Calles o rutas cerradas'**
  String get blockadeDescription;

  /// No description provided for @accidentDescription.
  ///
  /// In es, this message translates to:
  /// **'Choques o incidentes viales'**
  String get accidentDescription;

  /// No description provided for @serviceCutDescription.
  ///
  /// In es, this message translates to:
  /// **'Agua, luz, internet u otros'**
  String get serviceCutDescription;

  /// No description provided for @securityDescription.
  ///
  /// In es, this message translates to:
  /// **'Zonas de cuidado o apoyo'**
  String get securityDescription;

  /// No description provided for @lostFoundDescription.
  ///
  /// In es, this message translates to:
  /// **'Mascotas, documentos u objetos'**
  String get lostFoundDescription;

  /// No description provided for @otherDescription.
  ///
  /// In es, this message translates to:
  /// **'Algo que no encaja arriba'**
  String get otherDescription;

  /// No description provided for @nearbyBlockadesCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{No hay bloqueos cerca de ti} =1{Hay 1 bloqueo cerca de ti} other{Hay {count} bloqueos cerca de ti}}'**
  String nearbyBlockadesCount(num count);

  /// No description provided for @nearbyFoodDealsCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{No hay comidas baratas cerca de ti} =1{Hay 1 comida barata cerca de ti} other{Hay {count} comidas baratas cerca de ti}}'**
  String nearbyFoodDealsCount(num count);

  /// No description provided for @nearbyPartiesCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{No hay fiestas cerca de ti} =1{Hay 1 fiesta cerca de ti} other{Hay {count} fiestas cerca de ti}}'**
  String nearbyPartiesCount(num count);

  /// No description provided for @nearbySalesCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{No hay ventas cerca de ti} =1{Hay 1 venta cerca de ti} other{Hay {count} ventas cerca de ti}}'**
  String nearbySalesCount(num count);

  /// No description provided for @commentsCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin comentarios} =1{1 comentario} other{{count} comentarios}}'**
  String commentsCount(num count);

  /// No description provided for @likesCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin likes} =1{1 like} other{{count} likes}}'**
  String likesCount(num count);

  /// No description provided for @postsCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin publicaciones} =1{1 publicación} other{{count} publicaciones}}'**
  String postsCount(num count);

  /// No description provided for @followersCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin seguidores} =1{1 seguidor} other{{count} seguidores}}'**
  String followersCount(num count);

  /// No description provided for @timeAgoNow.
  ///
  /// In es, this message translates to:
  /// **'Ahora'**
  String get timeAgoNow;

  /// No description provided for @timeAgoMinutes.
  ///
  /// In es, this message translates to:
  /// **'{minutes, plural, =1{Hace 1 minuto} other{Hace {minutes} minutos}}'**
  String timeAgoMinutes(num minutes);

  /// No description provided for @timeAgoHours.
  ///
  /// In es, this message translates to:
  /// **'{hours, plural, =1{Hace 1 hora} other{Hace {hours} horas}}'**
  String timeAgoHours(num hours);

  /// No description provided for @timeAgoDays.
  ///
  /// In es, this message translates to:
  /// **'{days, plural, =1{Hace 1 día} other{Hace {days} días}}'**
  String timeAgoDays(num days);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ay', 'es', 'gn', 'qu'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ay':
      return AppLocalizationsAy();
    case 'es':
      return AppLocalizationsEs();
    case 'gn':
      return AppLocalizationsGn();
    case 'qu':
      return AppLocalizationsQu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
