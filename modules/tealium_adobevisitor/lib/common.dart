class AdobeVisitor {
  final String experienceCloudId;
  final int idSyncTtl;
  final int region;
  final String blob;
  final int nextRefresh;
  
  AdobeVisitor(
    this.experienceCloudId,
    this.idSyncTtl,
    this.region,
    this.blob,
    this.nextRefresh
  );

  AdobeVisitor.fromJson(Map<String, dynamic> json)
      : experienceCloudId = json["experienceCloudId"],
        idSyncTtl = json["idSyncTtl"],
        region = json["region"],
        blob = json["blob"], 
        nextRefresh = json["nextRefresh"];

  Map<String, dynamic> toJson() {
    return {
      'experienceCloudId': experienceCloudId,
      'idSyncTtl': idSyncTtl,
      'region': region,
      'blob': blob,
      'nextRefresh': nextRefresh,
    };
  }
}

enum AuthState {
  unknown(0),
  authenticated(1),
  loggedOut(2);

  const AuthState(this.intValue);
  final int intValue;

  static AuthState? fromIntValue(int intValue) {
    try {
      return AuthState.values
            .firstWhere((authState) => authState.intValue == intValue);
    } catch (e) {
      return null;
    }
  }
}

class AdobeVisitorConfig {
  final String adobeVisitorOrgId;
  final String? adobeVisitorExistingEcid;
  final int? adobeVisitorRetries;

  final AuthState? adobeVisitorAuthState;
  final String? adobeVisitorDataProviderId;
  final String? adobeVisitorCustomVisitorId;
  
  
  AdobeVisitorConfig(
    this.adobeVisitorOrgId,
    {
      this.adobeVisitorExistingEcid,
      this.adobeVisitorRetries,
      this.adobeVisitorAuthState,
      this.adobeVisitorDataProviderId,
      this.adobeVisitorCustomVisitorId,
    }
  );
}