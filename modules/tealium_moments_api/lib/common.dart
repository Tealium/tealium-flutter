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
  final MomentsApiRegion momentsApiRegion;
  final String? momentsApiReferrer;

  MomentsApiConfig({
    required this.momentsApiRegion,
    required this.momentsApiReferrer
  });

  Map <String, dynamic> toMap() {
    return {
      'momentsApiRegion': momentsApiRegion.name,
      'momentsApiReferrer': momentsApiReferrer,
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