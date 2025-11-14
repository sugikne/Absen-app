import 'package:flutter/material.dart';

import '../models/absensi_request.dart';
import '../services/absensi_service.dart';
import '../widgets/custom_text_field.dart';

class AbsensiScreen extends StatefulWidget {
  const AbsensiScreen({super.key});

  @override
  State<AbsensiScreen> createState() => _AbsensiScreenState();
}

class _AbsensiScreenState extends State<AbsensiScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final namaC = TextEditingController();
  final nimC = TextEditingController();
  final kelasC = TextEditingController();
  final deviceC = TextEditingController();
  String jenisKelamin = "Laki-Laki";
  bool _loading = false;

  final absensiService = AbsensiService();

  @override
  void dispose() {
    namaC.dispose();
    nimC.dispose();
    kelasC.dispose();
    deviceC.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final req = AbsensiRequest(
      nama: namaC.text.trim(),
      nim: nimC.text.trim(),
      kelas: kelasC.text.trim(),
      jenisKelamin: jenisKelamin,
      device: deviceC.text.trim(),
    );

    try {
      final result = await absensiService.submitAbsensi(req);
      if (!mounted) return;

      final success = result["status"] == "success";
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(success ? "Absensi Berhasil" : "Terjadi Kesalahan"),
          content: Text(result["message"].toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      if (success) {
        // clear controllers and reset dropdown
        namaC.clear();
        nimC.clear();
        kelasC.clear();
        deviceC.clear();
        setState(() => jenisKelamin = "Laki-Laki");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.9),
              theme.colorScheme.secondary.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Card(
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 36,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Form Absensi',
                                style: theme.textTheme.headlineSmall,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Isi data berikut untuk melakukan absensi',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 18),

                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              CustomTextField(
                                controller: namaC,
                                label: 'Nama',
                                icon: Icons.person,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Nama harus diisi'
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              CustomTextField(
                                controller: nimC,
                                label: 'NIM',
                                icon: Icons.badge,
                                keyboardType: TextInputType.number,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'NIM harus diisi'
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              CustomTextField(
                                controller: kelasC,
                                label: 'Kelas',
                                icon: Icons.class_,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Kelas harus diisi'
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: jenisKelamin,
                                items: ["Laki-Laki", "Perempuan"]
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => setState(
                                  () => jenisKelamin = v ?? jenisKelamin,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Jenis Kelamin',
                                  filled: true,
                                  fillColor: theme.colorScheme.surfaceVariant,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              CustomTextField(
                                controller: deviceC,
                                label: 'Device',
                                icon: Icons.devices,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Device harus diisi'
                                    : null,
                              ),
                              const SizedBox(height: 18),

                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : submit,
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Kirim Absensi',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
