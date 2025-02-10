// ignore_for_file: constant_identifier_names

enum MomentsApiRegion {
  GERMANY,
  US_EAST,
  SYDNEY,
  OREGON,
  TOKYO,
  HONG_KONG;
}

class MomentsApiConfig {
  final String _momentsApiRegion;
  final String? _momentsApiReferrer;

  MomentsApiConfig(MomentsApiRegion momentsApiRegion, String? momentsApiReferrer) : this._(momentsApiRegion.name, momentsApiReferrer);

  MomentsApiConfig._(this._momentsApiRegion, this._momentsApiReferrer);

  MomentsApiConfig.withCustomRegion(String momentsApiRegion, String? momentsApiReferrer) : this._(momentsApiRegion, momentsApiReferrer);

  Map <String, dynamic> toMap() {
    return {
      'momentsApiRegion': _momentsApiRegion,
      'momentsApiReferrer': _momentsApiReferrer,
    };
  }
}

class EngineResponse {
  final List<String>? audiences;
  final List<String>? badges;
  final Map<String, String>? strings;
  final Map<String, bool>? booleans;
  final Map<String, int>? dates;
  final Map<String, double>? numbers;

  EngineResponse({
    this.audiences,
    this.badges,
    this.strings,
    this.booleans,
    this.dates,
    this.numbers,
  });

  factory EngineResponse.fromJson(Map<String,dynamic> json) {
    return EngineResponse(
      audiences: json['audiences']?.cast<String>(),
      badges: json['badges']?.cast<String>(),
      strings: json['strings']?.cast<String, String>(),
      booleans: json['booleans']?.cast<String, bool>(),
      dates: json['dates']?.cast<String, int>(),
      numbers: json['numbers']?.cast<String, double>(),
    );
  }
}