import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: KingScorePage(),
    );
  }
}

class KingScorePage extends StatefulWidget {
  const KingScorePage({super.key});

  @override
  State<KingScorePage> createState() => _KingScorePageState();
}

class _KingScorePageState extends State<KingScorePage> {
  final List<String> players = ['Oyuncu 1', 'Oyuncu 2', 'Oyuncu 3', 'Oyuncu 4'];
  final List<String> cezaAdlari = [
    'EL ALMAZ 1',
    'EL ALMAZ 2',
    'KUPA ALMAZ 1',
    'KUPA ALMAZ 2',
    'KIZ ALMAZ 1',
    'KIZ ALMAZ 2',
    'ERKEK ALMAZ 1',
    'ERKEK ALMAZ 2',
    'SON İKİ 1',
    'SON İKİ 2',
    'RIFKI 1',
    'RIFKI 2',
  ];

  List<List<int?>> cezalar = List.generate(12, (_) => List.filled(4, null));
  List<List<int?>> kozlar = List.generate(8, (_) => List.filled(4, null));

  List<int> cezaToplamlari = List.filled(4, 0);
  List<int> kozToplamlari = List.filled(4, 0);

  File? _imageFile;

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100, // En yüksek kalite
    );
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      
      // Fotoğraf çekildikten sonra OCR başlat
      String? ocrText = await ocrFromImage(_imageFile!);
      if (ocrText != null) {
        // Önce sonuçları kullanıcıya göster ve onay al
        bool? shouldImport = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Okunan Metin'),
            content: SingleChildScrollView(child: Text(ocrText)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Tabloya Aktar'),
              ),
            ],
          ),
        );
        
        if (shouldImport == true) {
          parseOcrResultToTables(ocrText);
        }
      }
    }
  }

  Future<String?> ocrFromImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    
    // Text recognizer'ı yapılandırılmış şekilde oluştur
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    
    // OCR işlemini gerçekleştir
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();
    
    return recognizedText.text;
  }

  void parseOcrResultToTables(String ocrText) {
    // Kullanıcıya tanıma sonuçlarını gösterip onay al
    print("OCR Sonucu: $ocrText"); // Debug için

    // Satırları ayır
    List<String> lines = ocrText.split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    // Her bir satırı işle
    List<List<int>> parsedRows = [];
    
    for (String line in lines) {
      // Satırdaki sayıları bul
      final matches = RegExp(r'\d+').allMatches(line);
      List<int> row = [];
      
      for (var match in matches) {
        int? number = int.tryParse(match.group(0)!);
        if (number != null) {
          row.add(number);
        }
      }
      
      // Eğer satırda tam olarak 4 sayı varsa (4 oyuncu) ekle
      if (row.length == 4) {
        parsedRows.add(row);
      }
    }

    // Eğer yeteri kadar satır bulunamadıysa uyarı göster
    if (parsedRows.length < 12) {
      print("Dikkat: Yeterli sayıda satır bulunamadı! (${parsedRows.length} satır bulundu, en az 12 gerekli)");
      return;
    }

    // Verileri tabloya aktar
    for (int i = 0; i < Math.min(12, parsedRows.length); i++) {
      for (int j = 0; j < 4; j++) {
        if (j < parsedRows[i].length) {
          cezalar[i][j] = parsedRows[i][j];
        }
      }
    }
    
    // Kozlar için yeteri kadar satır varsa
    if (parsedRows.length >= 20) { // 12 ceza + 8 koz
      for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 4; j++) {
          if (j < parsedRows[i+12].length) {
            kozlar[i][j] = parsedRows[i+12][j];
          }
        }
      }
    }
    
    // Değişiklikleri yansıt
    setState(() {});
  }

  void hesapla() {
    for (int i = 0; i < 4; i++) {
      cezaToplamlari[i] = cezalar.fold(0, (sum, row) => sum + (row[i] ?? 0));
      kozToplamlari[i] = kozlar.fold(0, (sum, row) => sum + (row[i] ?? 0));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('King Skor Hesaplama')),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _takePhoto,
              child: const Text('Fotoğraf Çek'),
            ),
            const SizedBox(height: 10),
            if (_imageFile != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(_imageFile!, height: 200),
              ),
            const SizedBox(height: 10),
            Text('Cezalar', style: Theme.of(context).textTheme.titleLarge),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                columns: [
                  const DataColumn(label: Text('Ceza')),
                  ...players.map((p) => DataColumn(label: Text(p))),
                ],
                rows: List.generate(12, (row) {
                  return DataRow(
                    cells: [
                      DataCell(Text(cezaAdlari[row])),
                      ...List.generate(4, (col) {
                        return DataCell(
                          SizedBox(
                            width: 60,
                            child: TextFormField(
                              initialValue: cezalar[row][col]?.toString() ?? '',
                              keyboardType: TextInputType.number,
                              onChanged: (val) {
                                cezalar[row][col] = int.tryParse(val) ?? 0;
                              },
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 10),
            Text('Kozlar', style: Theme.of(context).textTheme.titleLarge),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                columns: [
                  const DataColumn(label: Text('Koz')),
                  ...players.map((p) => DataColumn(label: Text(p))),
                ],
                rows: List.generate(8, (row) {
                  return DataRow(
                    cells: [
                      DataCell(Text('KOZ ${row + 1}')),
                      ...List.generate(4, (col) {
                        return DataCell(
                          SizedBox(
                            width: 60,
                            child: TextFormField(
                              initialValue: kozlar[row][col]?.toString() ?? '',
                              keyboardType: TextInputType.number,
                              onChanged: (val) {
                                kozlar[row][col] = int.tryParse(val) ?? 0;
                              },
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: hesapla,
              child: const Text('Hesapla'),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  const DataColumn(label: Text('')),
                  ...players.map((p) => DataColumn(label: Text(p))),
                ],
                rows: [
                  DataRow(
                    cells: [
                      const DataCell(Text('CEZALAR')),
                      ...cezaToplamlari.map((v) => DataCell(Text('$v'))),
                    ],
                  ),
                  DataRow(
                    cells: [
                      const DataCell(Text('KOZLAR')),
                      ...kozToplamlari.map((v) => DataCell(Text('$v'))),
                    ],
                  ),
                  DataRow(
                    cells: [
                      const DataCell(Text('SONUÇ')),
                      ...List.generate(4, (i) => DataCell(Text('${kozToplamlari[i] - cezaToplamlari[i]}'))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
