class ServiceAction {
  final int serviceRequestId;
  final String islemAdi;
  final double ucret;

  ServiceAction({
    required this.serviceRequestId,
    required this.islemAdi,
    required this.ucret,
  });

  Map<String, dynamic> toJson() {
    return {
      "serviceRequestId": serviceRequestId,
      "islemAdi": islemAdi,
      "ucret": ucret,
    };
  }
}
