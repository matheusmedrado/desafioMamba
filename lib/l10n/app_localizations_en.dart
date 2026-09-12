// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get back => 'Back';

  @override
  String get settings => 'Settings';

  @override
  String get signedInAs => 'Signed in as';

  @override
  String get logOut => 'Log out';

  @override
  String get save => 'Save';

  @override
  String get accountSection => 'Account';

  @override
  String get appSection => 'App';

  @override
  String get addYourName => 'Add your name';

  @override
  String get yourName => 'Your name';

  @override
  String get yourNameHint => 'How should we call you?';

  @override
  String get changeName => 'Change name';

  @override
  String get profilePhoto => 'Profile photo';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get photoUpdated => 'Photo updated';

  @override
  String get photoRemoved => 'Photo removed';

  @override
  String get nameUpdated => 'Name updated';

  @override
  String get couldNotSaveProfile => 'Could not save. Try again.';

  @override
  String get changePassword => 'Change password';

  @override
  String get changePasswordSubtitle =>
      'We email you a link to choose a new one';

  @override
  String get language => 'Language';

  @override
  String get languageFollowsDevice => 'Follows your device';

  @override
  String get version => 'Version';

  @override
  String get tryAgain => 'Try again';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get mealsTab => 'Meals';

  @override
  String get historyTab => 'History';

  @override
  String get brandTagline => 'Fast Tracker';

  @override
  String get loginTitle => 'Back to your rhythm.';

  @override
  String get loginSubtitle => 'Your fasting plan, right where you left it.';

  @override
  String get signUpTitle => 'Start your rhythm.';

  @override
  String get signUpSubtitle =>
      'Create an account to start tracking your fasts.';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String passwordHint(int count) {
    return 'At least $count characters';
  }

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get confirmPasswordHint => 'Repeat your password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get logIn => 'Log in';

  @override
  String get signingIn => 'Signing in...';

  @override
  String get createAccount => 'Create account';

  @override
  String get creatingAccount => 'Creating account...';

  @override
  String get newToMamba => 'New to Mamba?';

  @override
  String get createAnAccount => 'Create an account';

  @override
  String get alreadyHaveAnAccount => 'Already have an account?';

  @override
  String get resetPasswordTitle => 'Reset your password';

  @override
  String get resetPasswordBody =>
      'We will email you a link to choose a new password.';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get sending => 'Sending...';

  @override
  String get resetLinkSent =>
      'If an account exists for this email, a reset link is on its way.';

  @override
  String get errorEmailRequired => 'Enter your email.';

  @override
  String get errorEmailInvalid => 'That email does not look right.';

  @override
  String get errorPasswordRequired => 'Enter your password.';

  @override
  String errorPasswordTooShort(int count) {
    return 'Password must be at least $count characters.';
  }

  @override
  String get errorConfirmPasswordRequired => 'Repeat your password.';

  @override
  String get errorPasswordsDoNotMatch => 'Passwords do not match.';

  @override
  String get authInvalidCredentials => 'Email or password is incorrect.';

  @override
  String get authEmailInUse =>
      'An account already exists for this email. Log in instead.';

  @override
  String get authWeakPassword => 'Choose a stronger password.';

  @override
  String get authInvalidEmail => 'That email does not look right.';

  @override
  String get authTooManyAttempts =>
      'Too many attempts. Try again in a few minutes.';

  @override
  String get authNetwork => 'No connection. Check your internet and try again.';

  @override
  String get authDisabled => 'This account has been disabled.';

  @override
  String get authNotEnabled => 'Email sign-in is not available right now.';

  @override
  String get authUnknown => 'Something went wrong. Try again.';

  @override
  String get yourNextFast => 'Your next fast';

  @override
  String fastingSplit(int fasting, int eating) {
    return '${fasting}h fasting / ${eating}h eating';
  }

  @override
  String get now => 'Now';

  @override
  String get ifYouStart => 'If you start';

  @override
  String get youFinish => 'You finish';

  @override
  String get startFast => 'Start fast';

  @override
  String get starting => 'Starting...';

  @override
  String get changeProtocol => 'Change protocol';

  @override
  String get fastingNow => 'Fasting now';

  @override
  String get paused => 'Paused';

  @override
  String get pausedLowercase => 'paused';

  @override
  String get goalReached => 'Goal reached';

  @override
  String get timeElapsed => 'Time elapsed';

  @override
  String get remainingSuffix => ' remaining';

  @override
  String get endWheneverReady => 'You can end your fast whenever you’re ready.';

  @override
  String percentOfGoal(int percent, int hours) {
    return '$percent% of ${hours}h goal';
  }

  @override
  String get startedLabel => 'Started';

  @override
  String get endsLabel => 'Ends';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get endFast => 'End fast';

  @override
  String get sessionSavesHint => 'Your session saves whenever you finish.';

  @override
  String get couldNotUpdateFast => 'Could not update the fast. Try again.';

  @override
  String get couldNotLoadFast => 'We could not load your fast.';

  @override
  String notFastingSemantics(int hours) {
    return 'Not fasting. Planned fasting duration $hours hours.';
  }

  @override
  String elapsedSemantics(String time) {
    return 'Elapsed $time';
  }

  @override
  String progressSemantics(String elapsed, String remaining) {
    return '$elapsed elapsed, $remaining remaining.';
  }

  @override
  String get endThisFast => 'End this fast?';

  @override
  String get endSheetBody => 'Your session will be saved to History.';

  @override
  String endSheetWarning(String time, int hours) {
    return 'You’re $time short of your ${hours}h goal. Ending now marks today as “goal not reached”.';
  }

  @override
  String get fastedSoFar => 'Fasted so far';

  @override
  String get keepFasting => 'Keep fasting';

  @override
  String get fastComplete => 'Fast complete.';

  @override
  String get sessionIsSaved => 'Your session is saved';

  @override
  String get timeFasted => 'Time fasted';

  @override
  String get endedEarly => 'Ended early';

  @override
  String goalWithHours(int hours) {
    return '${hours}h goal';
  }

  @override
  String percentOfHours(int percent, int hours) {
    return '$percent% of ${hours}h';
  }

  @override
  String get endedLabel => 'Ended';

  @override
  String get eatingWindow => 'Eating window';

  @override
  String untilTime(String time) {
    return 'Until $time';
  }

  @override
  String untilTimeOnDay(String time, String day) {
    return 'Until $time $day';
  }

  @override
  String get backToToday => 'Back to Today';

  @override
  String get logAMeal => 'Log a meal';

  @override
  String get close => 'Close';

  @override
  String fastedOfGoalSemantics(String time, int hours) {
    return '$time fasted of a $hours-hour goal.';
  }

  @override
  String get findYourRhythm => 'Find your rhythm.';

  @override
  String get protocolLead =>
      'A fasting window that fits your day. Change it whenever you need.';

  @override
  String get protocolTagGentle => 'Gentle';

  @override
  String get protocolTagPopular => 'Popular';

  @override
  String get protocolTagAdvanced => 'Advanced';

  @override
  String get protocolTagCustom => 'Custom';

  @override
  String get protocolDescriptionGentle =>
      'A gentle start. Skip late-night snacks and eat normally during the day.';

  @override
  String get protocolDescriptionPopular =>
      'Skip breakfast or dinner. The most common daily rhythm.';

  @override
  String get protocolDescriptionAdvanced =>
      'A tighter window for experienced fasters.';

  @override
  String get protocolCustomName => 'Custom';

  @override
  String get protocolCustomEmptyDescription =>
      'Set your own fasting and eating hours.';

  @override
  String get protocolCustomDescription => 'Your own hours, tap to edit';

  @override
  String protocolSemanticsPreset(String name, String tag) {
    return '$name, $tag';
  }

  @override
  String get protocolSemanticsCustomEmpty =>
      'Custom protocol, set your own hours';

  @override
  String protocolSemanticsCustom(String name) {
    return 'Custom protocol $name, tap to edit';
  }

  @override
  String get saveProtocol => 'Save protocol';

  @override
  String get saving => 'Saving...';

  @override
  String get protocolSaveError => 'Could not save the protocol. Try again.';

  @override
  String get customProtocolTitle => 'Custom protocol';

  @override
  String get customProtocolLead =>
      'A day is 24 hours. Set one side and the other adjusts.';

  @override
  String fastingHoursLabel(int hours) {
    return '${hours}h fasting';
  }

  @override
  String eatingHoursLabel(int hours) {
    return '${hours}h eating';
  }

  @override
  String fastHoursShort(int hours) {
    return '${hours}h fast';
  }

  @override
  String get fasting => 'Fasting';

  @override
  String get eating => 'Eating';

  @override
  String hoursRange(int min, int max) {
    return '$min to $max hours';
  }

  @override
  String decreaseHours(String title) {
    return 'Decrease $title hours';
  }

  @override
  String increaseHours(String title) {
    return 'Increase $title hours';
  }

  @override
  String get longFastNote =>
      'Fasts longer than 20 hours are not recommended without medical guidance. The app will still track them.';

  @override
  String get useThisProtocol => 'Use this protocol';

  @override
  String get mealsToday => 'TODAY';

  @override
  String get nothingLoggedYet => 'Nothing logged yet';

  @override
  String mealsMeta(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals · last at $time',
      one: '1 meal · last at $time',
    );
    return '$_temp0';
  }

  @override
  String get noMealsYet => 'No meals yet';

  @override
  String get noMealsBody =>
      'Log what you eat during your eating window.\nThe time is recorded automatically.';

  @override
  String get addMeal => 'Add meal';

  @override
  String editMealNamed(String name) {
    return 'Edit $name';
  }

  @override
  String get mealAdded => 'Meal added';

  @override
  String get mealUpdated => 'Meal updated';

  @override
  String get mealDeleted => 'Meal deleted';

  @override
  String get mealDeleteError => 'Could not delete the meal. Try again.';

  @override
  String get couldNotLoadMeals => 'We could not load your meals.';

  @override
  String get kcal => 'kcal';

  @override
  String kcalWithValue(String value) {
    return '$value kcal';
  }

  @override
  String get editMealTitle => 'Edit meal';

  @override
  String mealTimeRecorded(String time) {
    return 'Time $time · recorded automatically';
  }

  @override
  String get mealNameLabel => 'Meal name';

  @override
  String get mealNameHint => 'e.g. Grilled chicken salad';

  @override
  String get caloriesLabel => 'Calories';

  @override
  String get caloriesHelper => 'Whole numbers, up to 5,000';

  @override
  String get saveMeal => 'Save meal';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get deleteMeal => 'Delete meal';

  @override
  String get deleteThisMeal => 'Delete this meal?';

  @override
  String deleteMealBody(String name) {
    return '“$name” will be removed from today. This can’t be undone.';
  }

  @override
  String get mealSaveError => 'Could not save the meal. Try again.';

  @override
  String get errorMealName => 'Give the meal a name.';

  @override
  String errorMealNameTooLong(int count) {
    return 'Use at most $count characters.';
  }

  @override
  String errorMealCalories(String max) {
    return 'Enter a whole number between 1 and $max.';
  }

  @override
  String get yourDay => 'Your day';

  @override
  String get withinGoal => 'Within goal';

  @override
  String get outsideGoal => 'Outside goal';

  @override
  String get inProgress => 'In progress';

  @override
  String get calories => 'Calories';

  @override
  String get fastedToday => 'Fasted today';

  @override
  String get changeCalorieLimit => 'Change calorie limit';

  @override
  String calorieLimitUnit(String limit) {
    return '/ $limit kcal';
  }

  @override
  String get dayWithinMessage =>
      'Calories within your limit and fasting goal reached.';

  @override
  String dayInProgressMessage(String limit) {
    return 'Stay within $limit kcal and reach your fasting goal.';
  }

  @override
  String dayOverCaloriesMessage(String amount) {
    return 'Over your calorie limit by $amount kcal.';
  }

  @override
  String get dayFastShortMessage => 'Today\'s fast ended before its goal.';

  @override
  String get couldNotLoadDay => 'We could not load your day.';

  @override
  String get calorieLimitTitle => 'Daily calorie limit';

  @override
  String get calorieLimitBody =>
      'A day is within goal when its calories stay at or under this limit and a fast reaches its goal.';

  @override
  String calorieLimitHelper(String min, String max) {
    return 'Whole numbers, $min to $max';
  }

  @override
  String get saveLimit => 'Save limit';

  @override
  String get limitSaveError => 'Could not save the limit. Try again.';

  @override
  String errorCalorieLimit(String min, String max) {
    return 'Enter a whole number between $min and $max.';
  }

  @override
  String get days => 'Days';

  @override
  String get week => 'Week';

  @override
  String get last7Days => 'Last 7 days';

  @override
  String get goalsOutOfSeven => '/7 goals';

  @override
  String get averageFast => 'Average fast';

  @override
  String get nothingHereYet => 'Nothing here yet';

  @override
  String get historyEmptyBody =>
      'Your completed fasts and daily calories will show up here, one line per day.';

  @override
  String get couldNotLoadHistory => 'We could not load your history.';

  @override
  String get thisWeek => 'THIS WEEK';

  @override
  String get lastWeek => 'LAST WEEK';

  @override
  String get earlier => 'EARLIER';

  @override
  String get noFast => 'No fast';

  @override
  String fastOfDuration(String time) {
    return '$time fast';
  }

  @override
  String protocolAndCalories(String protocol, String calories) {
    return '$protocol · $calories kcal';
  }

  @override
  String get dayReasonWithin =>
      'Calories within the limit and a fast reached its goal.';

  @override
  String dayReasonOverLimit(String amount) {
    return 'over the calorie limit by $amount kcal';
  }

  @override
  String get dayReasonsJoin => ' and ';

  @override
  String get dayReasonNoFastEnded => 'no fast ended';

  @override
  String get dayReasonNoFastReached => 'no fast reached its goal';

  @override
  String get fastingSession => 'FASTING SESSION';

  @override
  String percentOfTarget(int percent) {
    return '$percent% of target';
  }

  @override
  String startedWithTime(String time) {
    return 'Started $time';
  }

  @override
  String endedWithTime(String time) {
    return 'Ended $time';
  }

  @override
  String get protocolLabel => 'Protocol';

  @override
  String get targetLabel => 'Target';

  @override
  String get resultLabel => 'Result';

  @override
  String hoursShort(int hours) {
    return '${hours}h';
  }

  @override
  String get mealsSection => 'Meals';

  @override
  String caloriesOfLimit(String calories, String limit) {
    return '$calories / $limit kcal';
  }

  @override
  String get noFastEndedOnThisDay => 'No fast ended on this day.';

  @override
  String get noMealsLogged => 'No meals logged.';

  @override
  String get fastingHoursPerDay => 'Fasting hours per day';

  @override
  String get legendGoalReached => 'Goal reached';

  @override
  String get legendShort => 'Short';

  @override
  String dailyGoal(int hours) {
    return 'Daily goal: ${hours}h';
  }

  @override
  String get perFast => 'per fast';

  @override
  String get goalCompletion => 'Goal completion';

  @override
  String goalCompletionValue(int count) {
    return '$count/7';
  }

  @override
  String percentOfDays(int percent) {
    return '$percent% of days';
  }

  @override
  String get bestDay => 'Best day';

  @override
  String get noFasts => 'No fasts';

  @override
  String withinGoalOnDays(int count) {
    return 'You were within goal on $count of the last 7 days.';
  }

  @override
  String chartSemantics(int hours) {
    return 'Fasting hours for each of the last seven days against the $hours-hour goal';
  }

  @override
  String barSemantics(String day, String description) {
    return '$day: $description';
  }

  @override
  String barGoalReached(String time) {
    return '$time, goal reached';
  }

  @override
  String barShort(String time) {
    return '$time, short';
  }

  @override
  String get barNoFast => 'no fast';

  @override
  String get notificationStartedTitle => 'Fast started';

  @override
  String get notificationStartedBody => 'Your fasting timer is now running.';

  @override
  String get notificationGoalTitle => 'Fasting goal reached';

  @override
  String get notificationGoalBody => 'Your planned fasting window is complete.';

  @override
  String get notificationFastingTitle => 'Fasting now';

  @override
  String get notificationPausedTitle => 'Fast paused';

  @override
  String notificationPausedBody(String time, int hours) {
    return '$time fasted · ${hours}h goal';
  }
}
