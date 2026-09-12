import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as'**
  String get signedInAs;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @appSection.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get appSection;

  /// No description provided for @addYourName.
  ///
  /// In en, this message translates to:
  /// **'Add your name'**
  String get addYourName;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @yourNameHint.
  ///
  /// In en, this message translates to:
  /// **'How should we call you?'**
  String get yourNameHint;

  /// No description provided for @changeName.
  ///
  /// In en, this message translates to:
  /// **'Change name'**
  String get changeName;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhoto;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @photoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Photo updated'**
  String get photoUpdated;

  /// No description provided for @photoRemoved.
  ///
  /// In en, this message translates to:
  /// **'Photo removed'**
  String get photoRemoved;

  /// No description provided for @nameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Name updated'**
  String get nameUpdated;

  /// No description provided for @couldNotSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Try again.'**
  String get couldNotSaveProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We email you a link to choose a new one'**
  String get changePasswordSubtitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageFollowsDevice.
  ///
  /// In en, this message translates to:
  /// **'Follows your device'**
  String get languageFollowsDevice;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @mealsTab.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get mealsTab;

  /// No description provided for @historyTab.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTab;

  /// No description provided for @brandTagline.
  ///
  /// In en, this message translates to:
  /// **'Fast Tracker'**
  String get brandTagline;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Back to your rhythm.'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your fasting plan, right where you left it.'**
  String get loginSubtitle;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Start your rhythm.'**
  String get signUpTitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account to start tracking your fasts.'**
  String get signUpSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'At least {count} characters'**
  String passwordHint(int count);

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Repeat your password'**
  String get confirmPasswordHint;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signingIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @creatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating account...'**
  String get creatingAccount;

  /// No description provided for @newToMamba.
  ///
  /// In en, this message translates to:
  /// **'New to Mamba?'**
  String get newToMamba;

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAnAccount;

  /// No description provided for @alreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAnAccount;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'We will email you a link to choose a new password.'**
  String get resetPasswordBody;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for this email, a reset link is on its way.'**
  String get resetLinkSent;

  /// No description provided for @errorEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email.'**
  String get errorEmailRequired;

  /// No description provided for @errorEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'That email does not look right.'**
  String get errorEmailInvalid;

  /// No description provided for @errorPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get errorPasswordRequired;

  /// No description provided for @errorPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {count} characters.'**
  String errorPasswordTooShort(int count);

  /// No description provided for @errorConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Repeat your password.'**
  String get errorConfirmPasswordRequired;

  /// No description provided for @errorPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get errorPasswordsDoNotMatch;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get authInvalidCredentials;

  /// No description provided for @authEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'An account already exists for this email. Log in instead.'**
  String get authEmailInUse;

  /// No description provided for @authWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a stronger password.'**
  String get authWeakPassword;

  /// No description provided for @authInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'That email does not look right.'**
  String get authInvalidEmail;

  /// No description provided for @authTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in a few minutes.'**
  String get authTooManyAttempts;

  /// No description provided for @authNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your internet and try again.'**
  String get authNetwork;

  /// No description provided for @authDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get authDisabled;

  /// No description provided for @authNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'Email sign-in is not available right now.'**
  String get authNotEnabled;

  /// No description provided for @authUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get authUnknown;

  /// No description provided for @yourNextFast.
  ///
  /// In en, this message translates to:
  /// **'Your next fast'**
  String get yourNextFast;

  /// No description provided for @fastingSplit.
  ///
  /// In en, this message translates to:
  /// **'{fasting}h fasting / {eating}h eating'**
  String fastingSplit(int fasting, int eating);

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @ifYouStart.
  ///
  /// In en, this message translates to:
  /// **'If you start'**
  String get ifYouStart;

  /// No description provided for @youFinish.
  ///
  /// In en, this message translates to:
  /// **'You finish'**
  String get youFinish;

  /// No description provided for @startFast.
  ///
  /// In en, this message translates to:
  /// **'Start fast'**
  String get startFast;

  /// No description provided for @starting.
  ///
  /// In en, this message translates to:
  /// **'Starting...'**
  String get starting;

  /// No description provided for @changeProtocol.
  ///
  /// In en, this message translates to:
  /// **'Change protocol'**
  String get changeProtocol;

  /// No description provided for @fastingNow.
  ///
  /// In en, this message translates to:
  /// **'Fasting now'**
  String get fastingNow;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @pausedLowercase.
  ///
  /// In en, this message translates to:
  /// **'paused'**
  String get pausedLowercase;

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached'**
  String get goalReached;

  /// No description provided for @timeElapsed.
  ///
  /// In en, this message translates to:
  /// **'Time elapsed'**
  String get timeElapsed;

  /// No description provided for @remainingSuffix.
  ///
  /// In en, this message translates to:
  /// **' remaining'**
  String get remainingSuffix;

  /// No description provided for @endWheneverReady.
  ///
  /// In en, this message translates to:
  /// **'You can end your fast whenever you’re ready.'**
  String get endWheneverReady;

  /// No description provided for @percentOfGoal.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of {hours}h goal'**
  String percentOfGoal(int percent, int hours);

  /// No description provided for @startedLabel.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get startedLabel;

  /// No description provided for @endsLabel.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get endsLabel;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @endFast.
  ///
  /// In en, this message translates to:
  /// **'End fast'**
  String get endFast;

  /// No description provided for @sessionSavesHint.
  ///
  /// In en, this message translates to:
  /// **'Your session saves whenever you finish.'**
  String get sessionSavesHint;

  /// No description provided for @couldNotUpdateFast.
  ///
  /// In en, this message translates to:
  /// **'Could not update the fast. Try again.'**
  String get couldNotUpdateFast;

  /// No description provided for @couldNotLoadFast.
  ///
  /// In en, this message translates to:
  /// **'We could not load your fast.'**
  String get couldNotLoadFast;

  /// No description provided for @notFastingSemantics.
  ///
  /// In en, this message translates to:
  /// **'Not fasting. Planned fasting duration {hours} hours.'**
  String notFastingSemantics(int hours);

  /// No description provided for @elapsedSemantics.
  ///
  /// In en, this message translates to:
  /// **'Elapsed {time}'**
  String elapsedSemantics(String time);

  /// No description provided for @progressSemantics.
  ///
  /// In en, this message translates to:
  /// **'{elapsed} elapsed, {remaining} remaining.'**
  String progressSemantics(String elapsed, String remaining);

  /// No description provided for @endThisFast.
  ///
  /// In en, this message translates to:
  /// **'End this fast?'**
  String get endThisFast;

  /// No description provided for @endSheetBody.
  ///
  /// In en, this message translates to:
  /// **'Your session will be saved to History.'**
  String get endSheetBody;

  /// No description provided for @endSheetWarning.
  ///
  /// In en, this message translates to:
  /// **'You’re {time} short of your {hours}h goal. Ending now marks today as “goal not reached”.'**
  String endSheetWarning(String time, int hours);

  /// No description provided for @fastedSoFar.
  ///
  /// In en, this message translates to:
  /// **'Fasted so far'**
  String get fastedSoFar;

  /// No description provided for @keepFasting.
  ///
  /// In en, this message translates to:
  /// **'Keep fasting'**
  String get keepFasting;

  /// No description provided for @fastComplete.
  ///
  /// In en, this message translates to:
  /// **'Fast complete.'**
  String get fastComplete;

  /// No description provided for @sessionIsSaved.
  ///
  /// In en, this message translates to:
  /// **'Your session is saved'**
  String get sessionIsSaved;

  /// No description provided for @timeFasted.
  ///
  /// In en, this message translates to:
  /// **'Time fasted'**
  String get timeFasted;

  /// No description provided for @endedEarly.
  ///
  /// In en, this message translates to:
  /// **'Ended early'**
  String get endedEarly;

  /// No description provided for @goalWithHours.
  ///
  /// In en, this message translates to:
  /// **'{hours}h goal'**
  String goalWithHours(int hours);

  /// No description provided for @percentOfHours.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of {hours}h'**
  String percentOfHours(int percent, int hours);

  /// No description provided for @endedLabel.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get endedLabel;

  /// No description provided for @eatingWindow.
  ///
  /// In en, this message translates to:
  /// **'Eating window'**
  String get eatingWindow;

  /// No description provided for @untilTime.
  ///
  /// In en, this message translates to:
  /// **'Until {time}'**
  String untilTime(String time);

  /// No description provided for @untilTimeOnDay.
  ///
  /// In en, this message translates to:
  /// **'Until {time} {day}'**
  String untilTimeOnDay(String time, String day);

  /// No description provided for @backToToday.
  ///
  /// In en, this message translates to:
  /// **'Back to Today'**
  String get backToToday;

  /// No description provided for @logAMeal.
  ///
  /// In en, this message translates to:
  /// **'Log a meal'**
  String get logAMeal;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @fastedOfGoalSemantics.
  ///
  /// In en, this message translates to:
  /// **'{time} fasted of a {hours}-hour goal.'**
  String fastedOfGoalSemantics(String time, int hours);

  /// No description provided for @findYourRhythm.
  ///
  /// In en, this message translates to:
  /// **'Find your rhythm.'**
  String get findYourRhythm;

  /// No description provided for @protocolLead.
  ///
  /// In en, this message translates to:
  /// **'A fasting window that fits your day. Change it whenever you need.'**
  String get protocolLead;

  /// No description provided for @protocolTagGentle.
  ///
  /// In en, this message translates to:
  /// **'Gentle'**
  String get protocolTagGentle;

  /// No description provided for @protocolTagPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get protocolTagPopular;

  /// No description provided for @protocolTagAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get protocolTagAdvanced;

  /// No description provided for @protocolTagCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get protocolTagCustom;

  /// No description provided for @protocolDescriptionGentle.
  ///
  /// In en, this message translates to:
  /// **'A gentle start. Skip late-night snacks and eat normally during the day.'**
  String get protocolDescriptionGentle;

  /// No description provided for @protocolDescriptionPopular.
  ///
  /// In en, this message translates to:
  /// **'Skip breakfast or dinner. The most common daily rhythm.'**
  String get protocolDescriptionPopular;

  /// No description provided for @protocolDescriptionAdvanced.
  ///
  /// In en, this message translates to:
  /// **'A tighter window for experienced fasters.'**
  String get protocolDescriptionAdvanced;

  /// No description provided for @protocolCustomName.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get protocolCustomName;

  /// No description provided for @protocolCustomEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Set your own fasting and eating hours.'**
  String get protocolCustomEmptyDescription;

  /// No description provided for @protocolCustomDescription.
  ///
  /// In en, this message translates to:
  /// **'Your own hours, tap to edit'**
  String get protocolCustomDescription;

  /// No description provided for @protocolSemanticsPreset.
  ///
  /// In en, this message translates to:
  /// **'{name}, {tag}'**
  String protocolSemanticsPreset(String name, String tag);

  /// No description provided for @protocolSemanticsCustomEmpty.
  ///
  /// In en, this message translates to:
  /// **'Custom protocol, set your own hours'**
  String get protocolSemanticsCustomEmpty;

  /// No description provided for @protocolSemanticsCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom protocol {name}, tap to edit'**
  String protocolSemanticsCustom(String name);

  /// No description provided for @saveProtocol.
  ///
  /// In en, this message translates to:
  /// **'Save protocol'**
  String get saveProtocol;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @protocolSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save the protocol. Try again.'**
  String get protocolSaveError;

  /// No description provided for @customProtocolTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom protocol'**
  String get customProtocolTitle;

  /// No description provided for @customProtocolLead.
  ///
  /// In en, this message translates to:
  /// **'A day is 24 hours. Set one side and the other adjusts.'**
  String get customProtocolLead;

  /// No description provided for @fastingHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'{hours}h fasting'**
  String fastingHoursLabel(int hours);

  /// No description provided for @eatingHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'{hours}h eating'**
  String eatingHoursLabel(int hours);

  /// No description provided for @fastHoursShort.
  ///
  /// In en, this message translates to:
  /// **'{hours}h fast'**
  String fastHoursShort(int hours);

  /// No description provided for @fasting.
  ///
  /// In en, this message translates to:
  /// **'Fasting'**
  String get fasting;

  /// No description provided for @eating.
  ///
  /// In en, this message translates to:
  /// **'Eating'**
  String get eating;

  /// No description provided for @hoursRange.
  ///
  /// In en, this message translates to:
  /// **'{min} to {max} hours'**
  String hoursRange(int min, int max);

  /// No description provided for @decreaseHours.
  ///
  /// In en, this message translates to:
  /// **'Decrease {title} hours'**
  String decreaseHours(String title);

  /// No description provided for @increaseHours.
  ///
  /// In en, this message translates to:
  /// **'Increase {title} hours'**
  String increaseHours(String title);

  /// No description provided for @longFastNote.
  ///
  /// In en, this message translates to:
  /// **'Fasts longer than 20 hours are not recommended without medical guidance. The app will still track them.'**
  String get longFastNote;

  /// No description provided for @useThisProtocol.
  ///
  /// In en, this message translates to:
  /// **'Use this protocol'**
  String get useThisProtocol;

  /// No description provided for @mealsToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get mealsToday;

  /// No description provided for @nothingLoggedYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet'**
  String get nothingLoggedYet;

  /// No description provided for @mealsMeta.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 meal · last at {time}} other{{count} meals · last at {time}}}'**
  String mealsMeta(int count, String time);

  /// No description provided for @noMealsYet.
  ///
  /// In en, this message translates to:
  /// **'No meals yet'**
  String get noMealsYet;

  /// No description provided for @noMealsBody.
  ///
  /// In en, this message translates to:
  /// **'Log what you eat during your eating window.\nThe time is recorded automatically.'**
  String get noMealsBody;

  /// No description provided for @addMeal.
  ///
  /// In en, this message translates to:
  /// **'Add meal'**
  String get addMeal;

  /// No description provided for @editMealNamed.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String editMealNamed(String name);

  /// No description provided for @mealAdded.
  ///
  /// In en, this message translates to:
  /// **'Meal added'**
  String get mealAdded;

  /// No description provided for @mealUpdated.
  ///
  /// In en, this message translates to:
  /// **'Meal updated'**
  String get mealUpdated;

  /// No description provided for @mealDeleted.
  ///
  /// In en, this message translates to:
  /// **'Meal deleted'**
  String get mealDeleted;

  /// No description provided for @mealDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the meal. Try again.'**
  String get mealDeleteError;

  /// No description provided for @couldNotLoadMeals.
  ///
  /// In en, this message translates to:
  /// **'We could not load your meals.'**
  String get couldNotLoadMeals;

  /// No description provided for @kcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get kcal;

  /// No description provided for @kcalWithValue.
  ///
  /// In en, this message translates to:
  /// **'{value} kcal'**
  String kcalWithValue(String value);

  /// No description provided for @editMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit meal'**
  String get editMealTitle;

  /// No description provided for @mealTimeRecorded.
  ///
  /// In en, this message translates to:
  /// **'Time {time} · recorded automatically'**
  String mealTimeRecorded(String time);

  /// No description provided for @mealNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Meal name'**
  String get mealNameLabel;

  /// No description provided for @mealNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Grilled chicken salad'**
  String get mealNameHint;

  /// No description provided for @caloriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get caloriesLabel;

  /// No description provided for @caloriesHelper.
  ///
  /// In en, this message translates to:
  /// **'Whole numbers, up to 5,000'**
  String get caloriesHelper;

  /// No description provided for @saveMeal.
  ///
  /// In en, this message translates to:
  /// **'Save meal'**
  String get saveMeal;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @deleteMeal.
  ///
  /// In en, this message translates to:
  /// **'Delete meal'**
  String get deleteMeal;

  /// No description provided for @deleteThisMeal.
  ///
  /// In en, this message translates to:
  /// **'Delete this meal?'**
  String get deleteThisMeal;

  /// No description provided for @deleteMealBody.
  ///
  /// In en, this message translates to:
  /// **'“{name}” will be removed from today. This can’t be undone.'**
  String deleteMealBody(String name);

  /// No description provided for @mealSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save the meal. Try again.'**
  String get mealSaveError;

  /// No description provided for @errorMealName.
  ///
  /// In en, this message translates to:
  /// **'Give the meal a name.'**
  String get errorMealName;

  /// No description provided for @errorMealNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Use at most {count} characters.'**
  String errorMealNameTooLong(int count);

  /// No description provided for @errorMealCalories.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number between 1 and {max}.'**
  String errorMealCalories(String max);

  /// No description provided for @yourDay.
  ///
  /// In en, this message translates to:
  /// **'Your day'**
  String get yourDay;

  /// No description provided for @withinGoal.
  ///
  /// In en, this message translates to:
  /// **'Within goal'**
  String get withinGoal;

  /// No description provided for @outsideGoal.
  ///
  /// In en, this message translates to:
  /// **'Outside goal'**
  String get outsideGoal;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @fastedToday.
  ///
  /// In en, this message translates to:
  /// **'Fasted today'**
  String get fastedToday;

  /// No description provided for @changeCalorieLimit.
  ///
  /// In en, this message translates to:
  /// **'Change calorie limit'**
  String get changeCalorieLimit;

  /// No description provided for @calorieLimitUnit.
  ///
  /// In en, this message translates to:
  /// **'/ {limit} kcal'**
  String calorieLimitUnit(String limit);

  /// No description provided for @dayWithinMessage.
  ///
  /// In en, this message translates to:
  /// **'Calories within your limit and fasting goal reached.'**
  String get dayWithinMessage;

  /// No description provided for @dayInProgressMessage.
  ///
  /// In en, this message translates to:
  /// **'Stay within {limit} kcal and reach your fasting goal.'**
  String dayInProgressMessage(String limit);

  /// No description provided for @dayOverCaloriesMessage.
  ///
  /// In en, this message translates to:
  /// **'Over your calorie limit by {amount} kcal.'**
  String dayOverCaloriesMessage(String amount);

  /// No description provided for @dayFastShortMessage.
  ///
  /// In en, this message translates to:
  /// **'Today\'s fast ended before its goal.'**
  String get dayFastShortMessage;

  /// No description provided for @couldNotLoadDay.
  ///
  /// In en, this message translates to:
  /// **'We could not load your day.'**
  String get couldNotLoadDay;

  /// No description provided for @calorieLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily calorie limit'**
  String get calorieLimitTitle;

  /// No description provided for @calorieLimitBody.
  ///
  /// In en, this message translates to:
  /// **'A day is within goal when its calories stay at or under this limit and a fast reaches its goal.'**
  String get calorieLimitBody;

  /// No description provided for @calorieLimitHelper.
  ///
  /// In en, this message translates to:
  /// **'Whole numbers, {min} to {max}'**
  String calorieLimitHelper(String min, String max);

  /// No description provided for @saveLimit.
  ///
  /// In en, this message translates to:
  /// **'Save limit'**
  String get saveLimit;

  /// No description provided for @limitSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save the limit. Try again.'**
  String get limitSaveError;

  /// No description provided for @errorCalorieLimit.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number between {min} and {max}.'**
  String errorCalorieLimit(String min, String max);

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// No description provided for @goalsOutOfSeven.
  ///
  /// In en, this message translates to:
  /// **'/7 goals'**
  String get goalsOutOfSeven;

  /// No description provided for @averageFast.
  ///
  /// In en, this message translates to:
  /// **'Average fast'**
  String get averageFast;

  /// No description provided for @nothingHereYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get nothingHereYet;

  /// No description provided for @historyEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Your completed fasts and daily calories will show up here, one line per day.'**
  String get historyEmptyBody;

  /// No description provided for @couldNotLoadHistory.
  ///
  /// In en, this message translates to:
  /// **'We could not load your history.'**
  String get couldNotLoadHistory;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'THIS WEEK'**
  String get thisWeek;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'LAST WEEK'**
  String get lastWeek;

  /// No description provided for @earlier.
  ///
  /// In en, this message translates to:
  /// **'EARLIER'**
  String get earlier;

  /// No description provided for @noFast.
  ///
  /// In en, this message translates to:
  /// **'No fast'**
  String get noFast;

  /// No description provided for @fastOfDuration.
  ///
  /// In en, this message translates to:
  /// **'{time} fast'**
  String fastOfDuration(String time);

  /// No description provided for @protocolAndCalories.
  ///
  /// In en, this message translates to:
  /// **'{protocol} · {calories} kcal'**
  String protocolAndCalories(String protocol, String calories);

  /// No description provided for @dayReasonWithin.
  ///
  /// In en, this message translates to:
  /// **'Calories within the limit and a fast reached its goal.'**
  String get dayReasonWithin;

  /// No description provided for @dayReasonOverLimit.
  ///
  /// In en, this message translates to:
  /// **'over the calorie limit by {amount} kcal'**
  String dayReasonOverLimit(String amount);

  /// No description provided for @dayReasonsJoin.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get dayReasonsJoin;

  /// No description provided for @dayReasonNoFastEnded.
  ///
  /// In en, this message translates to:
  /// **'no fast ended'**
  String get dayReasonNoFastEnded;

  /// No description provided for @dayReasonNoFastReached.
  ///
  /// In en, this message translates to:
  /// **'no fast reached its goal'**
  String get dayReasonNoFastReached;

  /// No description provided for @fastingSession.
  ///
  /// In en, this message translates to:
  /// **'FASTING SESSION'**
  String get fastingSession;

  /// No description provided for @percentOfTarget.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of target'**
  String percentOfTarget(int percent);

  /// No description provided for @startedWithTime.
  ///
  /// In en, this message translates to:
  /// **'Started {time}'**
  String startedWithTime(String time);

  /// No description provided for @endedWithTime.
  ///
  /// In en, this message translates to:
  /// **'Ended {time}'**
  String endedWithTime(String time);

  /// No description provided for @protocolLabel.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get protocolLabel;

  /// No description provided for @targetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get targetLabel;

  /// No description provided for @resultLabel.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get resultLabel;

  /// No description provided for @hoursShort.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String hoursShort(int hours);

  /// No description provided for @mealsSection.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get mealsSection;

  /// No description provided for @caloriesOfLimit.
  ///
  /// In en, this message translates to:
  /// **'{calories} / {limit} kcal'**
  String caloriesOfLimit(String calories, String limit);

  /// No description provided for @noFastEndedOnThisDay.
  ///
  /// In en, this message translates to:
  /// **'No fast ended on this day.'**
  String get noFastEndedOnThisDay;

  /// No description provided for @noMealsLogged.
  ///
  /// In en, this message translates to:
  /// **'No meals logged.'**
  String get noMealsLogged;

  /// No description provided for @fastingHoursPerDay.
  ///
  /// In en, this message translates to:
  /// **'Fasting hours per day'**
  String get fastingHoursPerDay;

  /// No description provided for @legendGoalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached'**
  String get legendGoalReached;

  /// No description provided for @legendShort.
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get legendShort;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily goal: {hours}h'**
  String dailyGoal(int hours);

  /// No description provided for @perFast.
  ///
  /// In en, this message translates to:
  /// **'per fast'**
  String get perFast;

  /// No description provided for @goalCompletion.
  ///
  /// In en, this message translates to:
  /// **'Goal completion'**
  String get goalCompletion;

  /// No description provided for @goalCompletionValue.
  ///
  /// In en, this message translates to:
  /// **'{count}/7'**
  String goalCompletionValue(int count);

  /// No description provided for @percentOfDays.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of days'**
  String percentOfDays(int percent);

  /// No description provided for @bestDay.
  ///
  /// In en, this message translates to:
  /// **'Best day'**
  String get bestDay;

  /// No description provided for @noFasts.
  ///
  /// In en, this message translates to:
  /// **'No fasts'**
  String get noFasts;

  /// No description provided for @withinGoalOnDays.
  ///
  /// In en, this message translates to:
  /// **'You were within goal on {count} of the last 7 days.'**
  String withinGoalOnDays(int count);

  /// No description provided for @chartSemantics.
  ///
  /// In en, this message translates to:
  /// **'Fasting hours for each of the last seven days against the {hours}-hour goal'**
  String chartSemantics(int hours);

  /// No description provided for @barSemantics.
  ///
  /// In en, this message translates to:
  /// **'{day}: {description}'**
  String barSemantics(String day, String description);

  /// No description provided for @barGoalReached.
  ///
  /// In en, this message translates to:
  /// **'{time}, goal reached'**
  String barGoalReached(String time);

  /// No description provided for @barShort.
  ///
  /// In en, this message translates to:
  /// **'{time}, short'**
  String barShort(String time);

  /// No description provided for @barNoFast.
  ///
  /// In en, this message translates to:
  /// **'no fast'**
  String get barNoFast;

  /// No description provided for @notificationStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'Fast started'**
  String get notificationStartedTitle;

  /// No description provided for @notificationStartedBody.
  ///
  /// In en, this message translates to:
  /// **'Your fasting timer is now running.'**
  String get notificationStartedBody;

  /// No description provided for @notificationGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Fasting goal reached'**
  String get notificationGoalTitle;

  /// No description provided for @notificationGoalBody.
  ///
  /// In en, this message translates to:
  /// **'Your planned fasting window is complete.'**
  String get notificationGoalBody;

  /// No description provided for @notificationFastingTitle.
  ///
  /// In en, this message translates to:
  /// **'Fasting now'**
  String get notificationFastingTitle;

  /// No description provided for @notificationPausedTitle.
  ///
  /// In en, this message translates to:
  /// **'Fast paused'**
  String get notificationPausedTitle;

  /// No description provided for @notificationPausedBody.
  ///
  /// In en, this message translates to:
  /// **'{time} fasted · {hours}h goal'**
  String notificationPausedBody(String time, int hours);
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
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
