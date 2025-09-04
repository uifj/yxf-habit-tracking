import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @todosOverviewAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Todos'**
  String get todosOverviewAppBarTitle;

  /// No description provided for @todosOverviewFilterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get todosOverviewFilterTooltip;

  /// No description provided for @todosOverviewFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get todosOverviewFilterAll;

  /// No description provided for @todosOverviewFilterActiveOnly.
  ///
  /// In en, this message translates to:
  /// **'Active only'**
  String get todosOverviewFilterActiveOnly;

  /// No description provided for @todosOverviewFilterCompletedOnly.
  ///
  /// In en, this message translates to:
  /// **'Completed only'**
  String get todosOverviewFilterCompletedOnly;

  /// No description provided for @todosOverviewMarkAllCompleteButtonText.
  ///
  /// In en, this message translates to:
  /// **'Mark all complete'**
  String get todosOverviewMarkAllCompleteButtonText;

  /// No description provided for @todosOverviewClearCompletedButtonText.
  ///
  /// In en, this message translates to:
  /// **'Clear completed'**
  String get todosOverviewClearCompletedButtonText;

  /// No description provided for @todosOverviewEmptyText.
  ///
  /// In en, this message translates to:
  /// **'No todos found with the selected filters.'**
  String get todosOverviewEmptyText;

  /// No description provided for @todosOverviewTodoDeletedSnackbarText.
  ///
  /// In en, this message translates to:
  /// **'Todo \"{todoTitle}\" deleted.'**
  String todosOverviewTodoDeletedSnackbarText(Object todoTitle);

  /// No description provided for @todosOverviewUndoDeletionButtonText.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get todosOverviewUndoDeletionButtonText;

  /// No description provided for @todosOverviewErrorSnackbarText.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading todos.'**
  String get todosOverviewErrorSnackbarText;

  /// No description provided for @todosOverviewOptionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get todosOverviewOptionsTooltip;

  /// No description provided for @todosOverviewOptionsMarkAllComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark all as completed'**
  String get todosOverviewOptionsMarkAllComplete;

  /// No description provided for @todosOverviewOptionsMarkAllIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Mark all as incomplete'**
  String get todosOverviewOptionsMarkAllIncomplete;

  /// No description provided for @todosOverviewOptionsClearCompleted.
  ///
  /// In en, this message translates to:
  /// **'Clear completed'**
  String get todosOverviewOptionsClearCompleted;

  /// No description provided for @todoDetailsAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Todo Details'**
  String get todoDetailsAppBarTitle;

  /// No description provided for @todoDetailsDeleteButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get todoDetailsDeleteButtonTooltip;

  /// No description provided for @todoDetailsEditButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get todoDetailsEditButtonTooltip;

  /// No description provided for @editTodoEditAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Todo'**
  String get editTodoEditAppBarTitle;

  /// No description provided for @editTodoAddAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Todo'**
  String get editTodoAddAppBarTitle;

  /// No description provided for @editTodoTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get editTodoTitleLabel;

  /// No description provided for @editTodoDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get editTodoDescriptionLabel;

  /// No description provided for @editTodoSaveButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get editTodoSaveButtonTooltip;

  /// No description provided for @statsAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statsAppBarTitle;

  /// No description provided for @statsCompletedTodoCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed todos'**
  String get statsCompletedTodoCountLabel;

  /// No description provided for @statsActiveTodoCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Active todos'**
  String get statsActiveTodoCountLabel;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
