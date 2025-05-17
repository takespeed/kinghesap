import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

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
  @override
  State<KingScorePage> createState() => _KingScorePageState();
}

class _KingScorePageState extends State<KingScorePage> {
  // 4 oyuncu, 16 ceza, 8 koz, diğer eller
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

  File? _image;
  String? _ocrResult;

  Future<void> pickImageAndReadText() async {
    final picker = ImagePicker();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('King Skor Hesaplama')),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
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
