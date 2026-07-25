import 'package:flutter/material.dart';
import '../services/request_service.dart';
import 'route_details_screen.dart';

class RouteSummariesScreen extends StatefulWidget {
  const RouteSummariesScreen({Key? key}) : super(key: key);

  @override
  _RouteSummariesScreenState createState() => _RouteSummariesScreenState();
}

class _RouteSummariesScreenState extends State<RouteSummariesScreen> {
  final RequestService _requestService = RequestService();
  List<dynamic> rotalar = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _rotalariGetir();
  }

  Future<void> _rotalariGetir() async {
    var veriler = await _requestService.getRouteSummaries();
    setState(() {
      rotalar = veriler;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Temamızdaki renk paletini çekiyoruz (Gece Mavisi ve Turkuaz)
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Planlanmış Rotalarım"),
        // Arka plan ve yazı renkleri artık otomatik olarak main.dart'tan geliyor
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : rotalar.isEmpty
          ? const Center(
              child: Text(
                "Henüz oluşturulmuş bir rota yok.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: rotalar.length,
              itemBuilder: (context, index) {
                var rota = rotalar[index];
                String hamTarih = rota['routeDate'] ?? "";
                String kisaTarih = hamTarih.isNotEmpty
                    ? hamTarih.split('T')[0]
                    : "Tarih Yok";

                int isSayisi = rota['totalJobs'] ?? 0;

                // C# API'mizden gelen Ekip Adı (Eğer API'den küçük harfle 'teamName' geliyorsa bu şekilde kalmalı)
                String ekipAdi =
                    rota['teamName'] ?? rota['TeamName'] ?? 'Ekip 1';

                return Card(
                  // Card tasarımı (gölge, kenarlık) main.dart'taki global CardTheme'den geliyor
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withOpacity(
                          0.1,
                        ), // Turkuazın şeffaf hali
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.calendar_month,
                        color: theme.colorScheme.secondary, // Canlı Turkuaz
                        size: 26,
                      ),
                    ),
                    title: Text(
                      "$kisaTarih Rotası",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          // Ekip adını gösteren şık bir etiket (Chip) tasarımı
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(
                                0.05,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.group,
                                  size: 14,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  ekipAdi,
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "$isSayisi İş Emri",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      // BOŞ EKRAN ÇÖZÜMÜ: Artık sadece tarihi değil, ekip adını da gönderiyoruz
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RouteDetailsScreen(
                            tarih: kisaTarih,
                            teamName: ekipAdi,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
