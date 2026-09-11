// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get back => 'Voltar';

  @override
  String get settings => 'Configurações';

  @override
  String get signedInAs => 'Conectado como';

  @override
  String get logOut => 'Sair';

  @override
  String get tryAgain => 'Tentar de novo';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get today => 'Hoje';

  @override
  String get yesterday => 'Ontem';

  @override
  String get tomorrow => 'Amanhã';

  @override
  String get greetingMorning => 'Bom dia';

  @override
  String get greetingAfternoon => 'Boa tarde';

  @override
  String get greetingEvening => 'Boa noite';

  @override
  String get mealsTab => 'Refeições';

  @override
  String get historyTab => 'Histórico';

  @override
  String get brandTagline => 'Fast Tracker';

  @override
  String get loginTitle => 'De volta ao seu ritmo.';

  @override
  String get loginSubtitle => 'Seu plano de jejum, do jeito que você deixou.';

  @override
  String get signUpTitle => 'Comece seu ritmo.';

  @override
  String get signUpSubtitle => 'Crie uma conta para acompanhar seus jejuns.';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get emailHint => 'voce@exemplo.com';

  @override
  String get passwordLabel => 'Senha';

  @override
  String passwordHint(int count) {
    return 'Pelo menos $count caracteres';
  }

  @override
  String get confirmPasswordLabel => 'Confirmar senha';

  @override
  String get confirmPasswordHint => 'Repita sua senha';

  @override
  String get showPassword => 'Mostrar senha';

  @override
  String get hidePassword => 'Ocultar senha';

  @override
  String get forgotPassword => 'Esqueceu a senha?';

  @override
  String get logIn => 'Entrar';

  @override
  String get signingIn => 'Entrando...';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get creatingAccount => 'Criando conta...';

  @override
  String get newToMamba => 'Novo por aqui?';

  @override
  String get createAnAccount => 'Criar uma conta';

  @override
  String get alreadyHaveAnAccount => 'Já tem uma conta?';

  @override
  String get resetPasswordTitle => 'Redefinir sua senha';

  @override
  String get resetPasswordBody =>
      'Vamos enviar um link por e-mail para você criar uma nova senha.';

  @override
  String get sendResetLink => 'Enviar link';

  @override
  String get sending => 'Enviando...';

  @override
  String get resetLinkSent =>
      'Se existir uma conta com esse e-mail, o link já está a caminho.';

  @override
  String get errorEmailRequired => 'Digite seu e-mail.';

  @override
  String get errorEmailInvalid => 'Esse e-mail não parece certo.';

  @override
  String get errorPasswordRequired => 'Digite sua senha.';

  @override
  String errorPasswordTooShort(int count) {
    return 'A senha precisa ter pelo menos $count caracteres.';
  }

  @override
  String get errorConfirmPasswordRequired => 'Repita sua senha.';

  @override
  String get errorPasswordsDoNotMatch => 'As senhas não são iguais.';

  @override
  String get authInvalidCredentials => 'E-mail ou senha incorretos.';

  @override
  String get authEmailInUse =>
      'Já existe uma conta com esse e-mail. Faça login.';

  @override
  String get authWeakPassword => 'Escolha uma senha mais forte.';

  @override
  String get authInvalidEmail => 'Esse e-mail não parece certo.';

  @override
  String get authTooManyAttempts =>
      'Muitas tentativas. Tente de novo em alguns minutos.';

  @override
  String get authNetwork =>
      'Sem conexão. Verifique sua internet e tente de novo.';

  @override
  String get authDisabled => 'Esta conta foi desativada.';

  @override
  String get authNotEnabled => 'O login por e-mail não está disponível agora.';

  @override
  String get authUnknown => 'Algo deu errado. Tente de novo.';

  @override
  String get yourNextFast => 'Seu próximo jejum';

  @override
  String fastingSplit(int fasting, int eating) {
    return '${fasting}h de jejum / ${eating}h de alimentação';
  }

  @override
  String get now => 'Agora';

  @override
  String get ifYouStart => 'Se começar';

  @override
  String get youFinish => 'Você termina';

  @override
  String get startFast => 'Começar jejum';

  @override
  String get starting => 'Começando...';

  @override
  String get changeProtocol => 'Trocar protocolo';

  @override
  String get fastingNow => 'Em jejum';

  @override
  String get paused => 'Pausado';

  @override
  String get pausedLowercase => 'pausado';

  @override
  String get goalReached => 'Meta atingida';

  @override
  String get timeElapsed => 'Tempo decorrido';

  @override
  String get remainingSuffix => ' restantes';

  @override
  String get endWheneverReady => 'Você pode encerrar o jejum quando quiser.';

  @override
  String percentOfGoal(int percent, int hours) {
    return '$percent% da meta de ${hours}h';
  }

  @override
  String get startedLabel => 'Começou';

  @override
  String get endsLabel => 'Termina';

  @override
  String get pause => 'Pausar';

  @override
  String get resume => 'Retomar';

  @override
  String get endFast => 'Encerrar jejum';

  @override
  String get sessionSavesHint => 'Seu jejum é salvo sempre que você encerra.';

  @override
  String get couldNotUpdateFast =>
      'Não foi possível atualizar o jejum. Tente de novo.';

  @override
  String get couldNotLoadFast => 'Não foi possível carregar seu jejum.';

  @override
  String notFastingSemantics(int hours) {
    return 'Sem jejum. Duração planejada de $hours horas.';
  }

  @override
  String elapsedSemantics(String time) {
    return 'Decorrido $time';
  }

  @override
  String progressSemantics(String elapsed, String remaining) {
    return '$elapsed decorridos, $remaining restantes.';
  }

  @override
  String get endThisFast => 'Encerrar este jejum?';

  @override
  String get endSheetBody => 'Seu jejum será salvo no histórico.';

  @override
  String endSheetWarning(String time, int hours) {
    return 'Faltam $time para a sua meta de ${hours}h. Encerrar agora marca hoje como “meta não atingida”.';
  }

  @override
  String get fastedSoFar => 'Jejum até agora';

  @override
  String get keepFasting => 'Continuar';

  @override
  String get fastComplete => 'Jejum concluído.';

  @override
  String get sessionIsSaved => 'Seu jejum foi salvo';

  @override
  String get timeFasted => 'Tempo de jejum';

  @override
  String get endedEarly => 'Encerrado antes';

  @override
  String goalWithHours(int hours) {
    return 'Meta de ${hours}h';
  }

  @override
  String percentOfHours(int percent, int hours) {
    return '$percent% de ${hours}h';
  }

  @override
  String get endedLabel => 'Terminou';

  @override
  String get eatingWindow => 'Janela de alimentação';

  @override
  String untilTime(String time) {
    return 'Até $time';
  }

  @override
  String untilTimeOnDay(String time, String day) {
    return 'Até $time de $day';
  }

  @override
  String get backToToday => 'Voltar para Hoje';

  @override
  String get logAMeal => 'Registrar refeição';

  @override
  String get close => 'Fechar';

  @override
  String fastedOfGoalSemantics(String time, int hours) {
    return '$time de jejum em uma meta de $hours horas.';
  }

  @override
  String get findYourRhythm => 'Encontre seu ritmo.';

  @override
  String get protocolLead =>
      'Uma janela de jejum que cabe no seu dia. Troque quando precisar.';

  @override
  String get protocolTagGentle => 'Tranquilo';

  @override
  String get protocolTagPopular => 'Popular';

  @override
  String get protocolTagAdvanced => 'Avançado';

  @override
  String get protocolTagCustom => 'Personalizado';

  @override
  String get protocolDescriptionGentle =>
      'Um começo tranquilo. Corte a beliscada da madrugada e coma normalmente durante o dia.';

  @override
  String get protocolDescriptionPopular =>
      'Pule o café da manhã ou o jantar. O ritmo diário mais comum.';

  @override
  String get protocolDescriptionAdvanced =>
      'Uma janela mais apertada, para quem já tem prática.';

  @override
  String get protocolCustomName => 'Personalizado';

  @override
  String get protocolCustomEmptyDescription =>
      'Defina suas próprias horas de jejum e de alimentação.';

  @override
  String get protocolCustomDescription => 'Suas horas, toque para editar';

  @override
  String protocolSemanticsPreset(String name, String tag) {
    return '$name, $tag';
  }

  @override
  String get protocolSemanticsCustomEmpty =>
      'Protocolo personalizado, defina suas horas';

  @override
  String protocolSemanticsCustom(String name) {
    return 'Protocolo personalizado $name, toque para editar';
  }

  @override
  String get saveProtocol => 'Salvar protocolo';

  @override
  String get saving => 'Salvando...';

  @override
  String get protocolSaveError =>
      'Não foi possível salvar o protocolo. Tente de novo.';

  @override
  String get customProtocolTitle => 'Protocolo personalizado';

  @override
  String get customProtocolLead =>
      'Um dia tem 24 horas. Defina um lado e o outro se ajusta.';

  @override
  String fastingHoursLabel(int hours) {
    return '${hours}h de jejum';
  }

  @override
  String eatingHoursLabel(int hours) {
    return '${hours}h de alimentação';
  }

  @override
  String fastHoursShort(int hours) {
    return '${hours}h de jejum';
  }

  @override
  String get fasting => 'Jejum';

  @override
  String get eating => 'Alimentação';

  @override
  String hoursRange(int min, int max) {
    return '$min a $max horas';
  }

  @override
  String decreaseHours(String title) {
    return 'Diminuir horas de $title';
  }

  @override
  String increaseHours(String title) {
    return 'Aumentar horas de $title';
  }

  @override
  String get longFastNote =>
      'Jejuns acima de 20 horas não são recomendados sem acompanhamento médico. O app continua registrando.';

  @override
  String get useThisProtocol => 'Usar este protocolo';

  @override
  String get mealsToday => 'HOJE';

  @override
  String get nothingLoggedYet => 'Nada registrado ainda';

  @override
  String mealsMeta(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count refeições · última às $time',
      one: '1 refeição · última às $time',
    );
    return '$_temp0';
  }

  @override
  String get noMealsYet => 'Nenhuma refeição ainda';

  @override
  String get noMealsBody =>
      'Registre o que você come na sua janela de alimentação.\nO horário é gravado automaticamente.';

  @override
  String get addMeal => 'Adicionar';

  @override
  String editMealNamed(String name) {
    return 'Editar $name';
  }

  @override
  String get mealAdded => 'Refeição adicionada';

  @override
  String get mealUpdated => 'Refeição atualizada';

  @override
  String get mealDeleted => 'Refeição excluída';

  @override
  String get mealDeleteError =>
      'Não foi possível excluir a refeição. Tente de novo.';

  @override
  String get couldNotLoadMeals => 'Não foi possível carregar suas refeições.';

  @override
  String get kcal => 'kcal';

  @override
  String kcalWithValue(String value) {
    return '$value kcal';
  }

  @override
  String get editMealTitle => 'Editar refeição';

  @override
  String mealTimeRecorded(String time) {
    return 'Horário $time · gravado automaticamente';
  }

  @override
  String get mealNameLabel => 'Nome da refeição';

  @override
  String get mealNameHint => 'ex.: Salada de frango grelhado';

  @override
  String get caloriesLabel => 'Calorias';

  @override
  String get caloriesHelper => 'Números inteiros, até 5.000';

  @override
  String get saveMeal => 'Salvar refeição';

  @override
  String get saveChanges => 'Salvar alterações';

  @override
  String get deleteMeal => 'Excluir refeição';

  @override
  String get deleteThisMeal => 'Excluir esta refeição?';

  @override
  String deleteMealBody(String name) {
    return '“$name” será removida de hoje. Isso não pode ser desfeito.';
  }

  @override
  String get mealSaveError =>
      'Não foi possível salvar a refeição. Tente de novo.';

  @override
  String get errorMealName => 'Dê um nome para a refeição.';

  @override
  String errorMealNameTooLong(int count) {
    return 'Use no máximo $count caracteres.';
  }

  @override
  String errorMealCalories(String max) {
    return 'Digite um número inteiro entre 1 e $max.';
  }

  @override
  String get yourDay => 'Seu dia';

  @override
  String get withinGoal => 'Dentro da meta';

  @override
  String get outsideGoal => 'Fora da meta';

  @override
  String get inProgress => 'Em andamento';

  @override
  String get calories => 'Calorias';

  @override
  String get fastedToday => 'Jejum hoje';

  @override
  String get changeCalorieLimit => 'Alterar limite de calorias';

  @override
  String calorieLimitUnit(String limit) {
    return '/ $limit kcal';
  }

  @override
  String get dayWithinMessage =>
      'Calorias dentro do limite e meta de jejum atingida.';

  @override
  String dayInProgressMessage(String limit) {
    return 'Fique em até $limit kcal e alcance sua meta de jejum.';
  }

  @override
  String dayOverCaloriesMessage(String amount) {
    return 'Passou $amount kcal do seu limite.';
  }

  @override
  String get dayFastShortMessage => 'O jejum de hoje terminou antes da meta.';

  @override
  String get couldNotLoadDay => 'Não foi possível carregar seu dia.';

  @override
  String get calorieLimitTitle => 'Limite diário de calorias';

  @override
  String get calorieLimitBody =>
      'O dia fica dentro da meta quando as calorias ficam neste limite ou abaixo e um jejum atinge a meta.';

  @override
  String calorieLimitHelper(String min, String max) {
    return 'Números inteiros, $min a $max';
  }

  @override
  String get saveLimit => 'Salvar limite';

  @override
  String get limitSaveError =>
      'Não foi possível salvar o limite. Tente de novo.';

  @override
  String errorCalorieLimit(String min, String max) {
    return 'Digite um número inteiro entre $min e $max.';
  }

  @override
  String get days => 'Dias';

  @override
  String get week => 'Semana';

  @override
  String get last7Days => 'Últimos 7 dias';

  @override
  String get goalsOutOfSeven => '/7 metas';

  @override
  String get averageFast => 'Jejum médio';

  @override
  String get nothingHereYet => 'Nada por aqui ainda';

  @override
  String get historyEmptyBody =>
      'Seus jejuns concluídos e as calorias de cada dia aparecem aqui, uma linha por dia.';

  @override
  String get couldNotLoadHistory => 'Não foi possível carregar seu histórico.';

  @override
  String get thisWeek => 'ESTA SEMANA';

  @override
  String get lastWeek => 'SEMANA PASSADA';

  @override
  String get earlier => 'ANTES';

  @override
  String get noFast => 'Sem jejum';

  @override
  String fastOfDuration(String time) {
    return '$time de jejum';
  }

  @override
  String protocolAndCalories(String protocol, String calories) {
    return '$protocol · $calories kcal';
  }

  @override
  String get dayReasonWithin =>
      'Calorias dentro do limite e um jejum atingiu a meta.';

  @override
  String dayReasonOverLimit(String amount) {
    return 'passou $amount kcal do limite';
  }

  @override
  String get dayReasonsJoin => ' e ';

  @override
  String get dayReasonNoFastEnded => 'nenhum jejum terminou';

  @override
  String get dayReasonNoFastReached => 'nenhum jejum atingiu a meta';

  @override
  String get fastingSession => 'JEJUM';

  @override
  String percentOfTarget(int percent) {
    return '$percent% da meta';
  }

  @override
  String startedWithTime(String time) {
    return 'Começou $time';
  }

  @override
  String endedWithTime(String time) {
    return 'Terminou $time';
  }

  @override
  String get protocolLabel => 'Protocolo';

  @override
  String get targetLabel => 'Meta';

  @override
  String get resultLabel => 'Resultado';

  @override
  String hoursShort(int hours) {
    return '${hours}h';
  }

  @override
  String get mealsSection => 'Refeições';

  @override
  String caloriesOfLimit(String calories, String limit) {
    return '$calories / $limit kcal';
  }

  @override
  String get noFastEndedOnThisDay => 'Nenhum jejum terminou neste dia.';

  @override
  String get noMealsLogged => 'Nenhuma refeição registrada.';

  @override
  String get fastingHoursPerDay => 'Horas de jejum por dia';

  @override
  String get legendGoalReached => 'Meta atingida';

  @override
  String get legendShort => 'Abaixo';

  @override
  String dailyGoal(int hours) {
    return 'Meta diária: ${hours}h';
  }

  @override
  String get perFast => 'por jejum';

  @override
  String get goalCompletion => 'Metas batidas';

  @override
  String goalCompletionValue(int count) {
    return '$count/7';
  }

  @override
  String percentOfDays(int percent) {
    return '$percent% dos dias';
  }

  @override
  String get bestDay => 'Melhor dia';

  @override
  String get noFasts => 'Sem jejuns';

  @override
  String withinGoalOnDays(int count) {
    return 'Você ficou dentro da meta em $count dos últimos 7 dias.';
  }

  @override
  String chartSemantics(int hours) {
    return 'Horas de jejum de cada um dos últimos sete dias em relação à meta de $hours horas';
  }

  @override
  String barSemantics(String day, String description) {
    return '$day: $description';
  }

  @override
  String barGoalReached(String time) {
    return '$time, meta atingida';
  }

  @override
  String barShort(String time) {
    return '$time, abaixo da meta';
  }

  @override
  String get barNoFast => 'sem jejum';

  @override
  String get notificationStartedTitle => 'Jejum iniciado';

  @override
  String get notificationStartedBody => 'Seu cronômetro de jejum está rodando.';

  @override
  String get notificationGoalTitle => 'Meta de jejum atingida';

  @override
  String get notificationGoalBody => 'Sua janela de jejum planejada terminou.';

  @override
  String get notificationFastingTitle => 'Em jejum';

  @override
  String get notificationPausedTitle => 'Jejum pausado';

  @override
  String notificationPausedBody(String time, int hours) {
    return '$time de jejum · meta de ${hours}h';
  }
}
