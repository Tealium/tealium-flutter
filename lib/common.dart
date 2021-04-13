class EventListenerNames {
  static const name = 'emitterName';
  static const visitor = 'TealiumFlutter.VisitorServiceEvent';
  static const remoteCommand = 'TealiumFlutter.RemoteCommandEvent';
  static const consentExpired = 'TealiumFlutter.ConsentExpiredEvent';
}

class Collectors {
  final String _name;

  const Collectors._(this._name);

  @override
  String toString() {
    return _name;
  }

  static const Collectors AppData = Collectors._('AppData');
  static const Collectors Connectivity = Collectors._('Connectivity');
  static const Collectors DeviceData = Collectors._('DeviceData');
  static const Collectors Lifecycle = Collectors._('Lifecycle');
}

class Dispatchers {
  final String _name;

  const Dispatchers._(this._name);

  @override
  String toString() {
    return _name;
  }

  static const Dispatchers Collect = Dispatchers._('Collect');
  static const Dispatchers TagManagement = Dispatchers._('TagManagement');
  static const Dispatchers RemoteCommands = Dispatchers._('RemoteCommands');
}

class Expiry {
  final String _name;

  const Expiry._(this._name);

  @override
  String toString() {
    return _name;
  }

  static const Expiry forever = Expiry._('forever');
  static const Expiry untilRestart = Expiry._('untilRestart');
  static const Expiry session = Expiry._('session');
}

class ConsentPolicy {
  final String _name;

  const ConsentPolicy._(this._name);

  @override
  String toString() {
    return _name;
  }

  static const ConsentPolicy GDPR = ConsentPolicy._('gdpr');
  static const ConsentPolicy CCPA = ConsentPolicy._('ccpa');
}

abstract class TealiumDispatch {
  Map<String, Object>? dataLayer;
  late String type;
}

class TealiumView implements TealiumDispatch {
  late String type;
  late String viewName;
  Map<String, Object>? dataLayer;
  TealiumView(String viewName, Map<String, Object> dataLayer,
      {String type = 'view'}) {
    this.type = type;
    this.viewName = viewName;
    this.dataLayer = dataLayer;
  }
}

class TealiumEvent implements TealiumDispatch {
  late String type;
  late String eventName;
  Map<String, Object>? dataLayer;
  TealiumEvent(String eventName, Map<String, Object> dataLayer,
      {String type = 'event'}) {
    this.type = type;
    this.eventName = eventName;
    this.dataLayer = dataLayer;
  }
}

class ConsentStatus {
  final String _name;

  const ConsentStatus._(this._name);

  @override
  String toString() {
    return _name;
  }

  static const consented = ConsentStatus._('consented');
  static const notConsented = ConsentStatus._('notConsented');
  static const unknown = ConsentStatus._('unknown');
}

class LogLevel {
  final String _name;

  const LogLevel._(this._name);

  @override
  String toString() {
    return _name;
  }

  static const LogLevel DEV = LogLevel._('dev');
  static const LogLevel QA = LogLevel._('qa');
  static const LogLevel PROD = LogLevel._('prod');
  static const LogLevel SILENT = LogLevel._('silent');
}

class TealiumEnvironment {
  final String _name;

  const TealiumEnvironment._(this._name);

  @override
  String toString() {
    return _name;
  }

  static const TealiumEnvironment dev = TealiumEnvironment._('dev');
  static const TealiumEnvironment qa = TealiumEnvironment._('qa');
  static const TealiumEnvironment prod = TealiumEnvironment._('prod');
}

class ConsentCategories {
  final String _name;

  const ConsentCategories._(this._name);

  @override
  String toString() {
    return _name;
  }

  static const ConsentCategories analytics = ConsentCategories._('analytics');
  static const ConsentCategories affiliates = ConsentCategories._('affiliates');
  static const ConsentCategories displayAds =
      ConsentCategories._('display_ads');
  static const ConsentCategories email = ConsentCategories._('email');
  static const ConsentCategories personalization =
      ConsentCategories._('personalization');
  static const ConsentCategories search = ConsentCategories._('search');
  static const ConsentCategories social = ConsentCategories._('social');
  static const ConsentCategories bigData = ConsentCategories._('big_data');
  static const ConsentCategories mobile = ConsentCategories._('mobile');
  static const ConsentCategories engagement = ConsentCategories._('engagement');
  static const ConsentCategories monitoring = ConsentCategories._('monitoring');
  static const ConsentCategories crm = ConsentCategories._('crm');
  static const ConsentCategories cdp = ConsentCategories._('cdp');
  static const ConsentCategories cookieMatch =
      ConsentCategories._('cookiematch');
  static const ConsentCategories misc = ConsentCategories._('misc');
}

class ConsentExpiry {
  late int time;
  late TimeUnit unit;
  ConsentExpiry(int time, TimeUnit unit) {
    this.time = time;
    this.unit = unit;
  }

  Map<String, dynamic> toJson() =>
      {'time': this.time, 'unit': this.unit.toString()};
}

class TimeUnit {
  final String _name;

  const TimeUnit._(this._name);

  @override
  String toString() {
    return _name;
  }

  static const TimeUnit MINUTES = TimeUnit._('minutes');
  static const TimeUnit HOURS = TimeUnit._('hours');
  static const TimeUnit MONTHS = TimeUnit._('months');
  static const TimeUnit DAYS = TimeUnit._('days');
}

class TealiumConfig {
  late String account;
  late String profile;
  late String environment;
  late List<String> collectors;
  late List<String> dispatchers;
  String? dataSource;
  String? customVisitorId;
  bool? memoryReportingEnabled;
  String? overrideCollectURL;
  String? overrideCollectBatchURL;
  String? overrideCollectDomain;
  String? overrideLibrarySettingsURL;
  String? overrideTagManagementURL;
  bool? deepLinkTrackingEnabled;
  bool? qrTraceEnabled;
  String? logLevel;
  bool? consentLoggingEnabled;
  String? consentPolicy;
  Map? consentExpiry;
  bool? batchingEnabled;
  bool? lifecycleAutotrackingEnabled;
  bool? useRemoteLibrarySettings;
  bool? visitorServiceEnabled;
  //Function()? onConsentExpiration;

  TealiumConfig(
    String account,
    String profile,
    TealiumEnvironment environment,
    List<Collectors> collectors,
    List<Dispatchers> dispatchers,
    // Optional TealiumConfig Parameters
    {
    String? dataSource,
    String? customVisitorId,
    bool? memoryReportingEnabled,
    String? overrideCollectURL,
    String? overrideCollectBatchURL,
    String? overrideCollectDomain,
    String? overrideLibrarySettingsURL,
    String? overrideTagManagementURL,
    bool? deepLinkTrackingEnabled,
    bool? qrTraceEnabled,
    LogLevel? loglevel,
    bool? consentLoggingEnabled,
    ConsentPolicy? consentPolicy,
    ConsentExpiry? consentExpiry,
    bool? batchingEnabled,
    bool? lifecycleAutotrackingEnabled,
    bool? useRemoteLibrarySettings,
    bool? visitorServiceEnabled,
    /*Function()? onConsentExpiration*/
  }) {
    this.account = account;
    this.profile = profile;
    this.environment = environment.toString();
    this.collectors = collectors.map((item) => item.toString()).toList();
    this.dispatchers = dispatchers.map((item) => item.toString()).toList();
    this.dataSource = dataSource;
    this.customVisitorId = customVisitorId;
    this.memoryReportingEnabled = memoryReportingEnabled;
    this.overrideCollectURL = overrideCollectURL;
    this.overrideCollectBatchURL = overrideCollectBatchURL;
    this.overrideCollectDomain = overrideCollectDomain;
    this.overrideLibrarySettingsURL = overrideLibrarySettingsURL;
    this.overrideTagManagementURL = overrideTagManagementURL;
    this.deepLinkTrackingEnabled = deepLinkTrackingEnabled;
    this.qrTraceEnabled = qrTraceEnabled;
    this.logLevel = logLevel?.toString();
    this.consentLoggingEnabled = consentLoggingEnabled;
    this.consentPolicy = consentPolicy?.toString();
    this.consentExpiry = consentExpiry?.toJson();
    this.batchingEnabled = batchingEnabled;
    this.lifecycleAutotrackingEnabled = lifecycleAutotrackingEnabled;
    this.useRemoteLibrarySettings = useRemoteLibrarySettings;
    this.visitorServiceEnabled = visitorServiceEnabled;
    // this.onConsentExpiration = onConsentExpiration;
  }
}
