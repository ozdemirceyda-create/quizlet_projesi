import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const QuizletApp());
}

class QuizletApp extends StatelessWidget {
  const QuizletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quizlet Projesi',
      // Webde fareyle kaydırmak için
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
      ),
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const ListelerEkran(),
    );
  }
}

class ListelerEkran extends StatefulWidget {
  const ListelerEkran({super.key});

  @override
  State<ListelerEkran> createState() => _ListelerEkranState();
}

class _ListelerEkranState extends State<ListelerEkran> {
  List<dynamic> kelimeListeleri = [];
  bool yukleniyor = true;

  @override
  void initState() {
    super.initState();
    listeleriGetir();
  }

  Future<void> listeleriGetir() async {
    final url = Uri.parse('http://127.0.0.1:8000/api/listeler/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          kelimeListeleri = json.decode(response.body);
          yukleniyor = false;
        });
      }
    } catch (e) {
      print("Liste çekme hatası: $e");
      setState(() { yukleniyor = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelime Listelerim', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
      ),
      body: yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : kelimeListeleri.isEmpty
              ? const Center(child: Text('Kayıtlı liste yok.'))
              : ListView.builder(
                  itemCount: kelimeListeleri.length,
                  itemBuilder: (context, index) {
                    final liste = kelimeListeleri[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: const Icon(Icons.folder, color: Colors.indigo),
                        title: Text(liste['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Liste ID: ${liste['id']}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => KelimeKartlariEkran(
                                listeId: liste['id'],
                                listeAdi: liste['name'],
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

class KelimeKartlariEkran extends StatefulWidget {
  final int listeId;
  final String listeAdi;

  const KelimeKartlariEkran({super.key, required this.listeId, required this.listeAdi});

  @override
  State<KelimeKartlariEkran> createState() => _KelimeKartlariEkranState();
}

class _KelimeKartlariEkranState extends State<KelimeKartlariEkran> {
  List<dynamic> kelimeler = [];
  bool yukleniyor = true;
  int aktifIndex = 0;
  bool ceviriyiGoster = false;
  final PageController _sayfaKontrolcusu = PageController();

  @override
  void initState() {
    super.initState();
    kelimeleriGetir();
  }

  Future<void> kelimeleriGetir() async {
    final url = Uri.parse('http://127.0.0.1:8000/api/kelimeler/${widget.listeId}/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          kelimeler = json.decode(response.body);
          yukleniyor = false;
        });
      }
    } catch (e) {
      print("Kelimeler gelmedi: $e");
      setState(() { yukleniyor = false; });
    }
  }

  Future<void> durumGuncelle(int kelimeId, bool durum) async {
    final url = Uri.parse('http://127.0.0.1:8000/api/kelime-guncelle/$kelimeId/');
    try {
      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"is_learned": durum}),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(durum ? 'Kelime öğrenildi' : 'Tekrar edilecek'),
          duration: const Duration(milliseconds: 600),
        ),
      );

      if (aktifIndex < kelimeler.length - 1) {
        _sayfaKontrolcusu.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
      }
    } catch (e) {
      print("Post hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listeAdi, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : kelimeler.isEmpty
              ? const Center(child: Text('Bu listede kelime yok.'))
              : Column(
                  children: [
                    const SizedBox(height: 20),
                    Text('${aktifIndex + 1} / ${kelimeler.length}', style: const TextStyle(fontSize: 18)),
                    
                    Expanded(
                      child: PageView.builder(
                        controller: _sayfaKontrolcusu,
                        itemCount: kelimeler.length,
                        onPageChanged: (index) {
                          setState(() {
                            aktifIndex = index;
                            ceviriyiGoster = false;
                          });
                        },
                        itemBuilder: (context, index) {
                          final kelime = kelimeler[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() { ceviriyiGoster = !ceviriyiGoster; });
                            },
                            child: Container(
                              margin: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: ceviriyiGoster ? Colors.green[50] : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      ceviriyiGoster ? kelime['tr'] : kelime['eng'],
                                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(ceviriyiGoster ? "Türkçesi" : "İngilizcesi", style: const TextStyle(color: Colors.grey)),
                                    if (kelime['example'] != null) ...[
                                      const SizedBox(height: 20),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Text('"${kelime['example']}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                                      )
                                    ]
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
                          onPressed: () => durumGuncelle(kelimeler[aktifIndex]['id'], false),
                          child: const Text("Bilemedim", style: TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green[500]),
                          onPressed: () => durumGuncelle(kelimeler[aktifIndex]['id'], true),
                          child: const Text("Öğrendim", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
    );
  }
}