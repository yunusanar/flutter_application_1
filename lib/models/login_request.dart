class LoginRequest {
  final String email;
  final String sifre;

  LoginRequest({required this.email, required this.sifre});

  // Veriyi API'ye gönderirken JSON'a çevirir
  Map<String, dynamic> toJson() {
    return {'email': email, 'sifre': sifre};
  }
}
