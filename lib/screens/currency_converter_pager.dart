import 'package:flutter/material.dart';
import '../services/currency_service.dart';

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  State<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  final controller = TextEditingController();

  String from = "Gold";
  String to = "IDR";

  double result = 0;
  bool hasConverted = false;
  bool isLoading = false;

  Map<String, double> rates = {};

  static const double goldValueUsd = 0.10;

  static const Map<String, String> currencySymbols = {
    'Gold': '🪙',
    'USD': '\$',
    'IDR': 'Rp',
    'JPY': '¥',
  };

  static const Map<String, String> currencyNames = {
    'Gold': 'Gold (In-app)',
    'USD': 'US Dollar',
    'IDR': 'Indonesian Rupiah',
    'JPY': 'Japanese Yen',
  };

  @override
  void initState() {
    super.initState();
    loadRates();
  }

  Future<void> loadRates() async {
    setState(() => isLoading = true);
    rates = await CurrencyService.instance.getRates();
    setState(() => isLoading = false);
  }

  Future<void> convert() async {
    if (controller.text.isEmpty) return;
    if (from == to) {
      setState(() {
        result = double.tryParse(controller.text) ?? 0;
        hasConverted = true;
      });
      return;
    }

    double amount = double.tryParse(controller.text) ?? 0;
    double usdValue = 0;

    if (from == "Gold") {
      usdValue = amount * goldValueUsd;
    } else {
      if (rates.isEmpty || !rates.containsKey(from)) return;
      usdValue = amount / rates[from]!;
    }

    double computed = 0;
    if (to == "Gold") {
      computed = usdValue / goldValueUsd;
    } else {
      if (rates.isEmpty || !rates.containsKey(to)) return;
      computed = usdValue * rates[to]!;
    }

    setState(() {
      result = computed;
      hasConverted = true;
    });
  }

  String formatResult(double value, String currency) {
    if (currency == 'JPY') return value.toStringAsFixed(0);
    if (currency == 'IDR') return value.toStringAsFixed(0);
    if (currency == 'Gold') return value.toStringAsFixed(2);
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final currencies = ['Gold', 'USD', 'IDR', 'JPY'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Konversi Mata Uang"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: Color(0xFF10B981), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isLoading
                          ? "Memuat nilai tukar terkini..."
                          : rates.isEmpty
                              ? "Menggunakan nilai tukar offline"
                              : "Nilai tukar berhasil dimuat ✓",
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Amount input
            const Text("Jumlah",
                style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              onChanged: (_) => setState(() => hasConverted = false),
              decoration: InputDecoration(
                hintText: "Masukkan jumlah...",
                hintStyle: const TextStyle(color: Colors.white24, fontSize: 16),
                prefixIcon: const Icon(Icons.calculate_outlined),
                suffixText:
                    currencySymbols[from] ?? from,
                suffixStyle: const TextStyle(
                    color: Color(0xFF7C3AED),
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),

            // From / To selectors
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Dari",
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                      const SizedBox(height: 8),
                      _buildDropdown(currencies, from, (v) {
                        setState(() {
                          from = v!;
                          hasConverted = false;
                        });
                      }),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: IconButton(
                    onPressed: () => setState(() {
                      final tmp = from;
                      from = to;
                      to = tmp;
                      hasConverted = false;
                    }),
                    icon: const Icon(Icons.swap_horiz_rounded,
                        color: Color(0xFF7C3AED), size: 28),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Ke",
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                      const SizedBox(height: 8),
                      _buildDropdown(currencies, to, (v) {
                        setState(() {
                          to = v!;
                          hasConverted = false;
                        });
                      }),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : convert,
                icon: const Icon(Icons.currency_exchange_rounded),
                label: const Text("Konversi",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 24),

            // Result card
            AnimatedOpacity(
              opacity: hasConverted ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF7C3AED).withOpacity(0.2),
                      const Color(0xFF10B981).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFF7C3AED).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      hasConverted ? "Hasil Konversi" : "Masukkan jumlah",
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.55), fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      hasConverted
                          ? "${currencySymbols[to] ?? to} ${formatResult(result, to)}"
                          : "--",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (hasConverted)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          "${currencyNames[to] ?? to}",
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
      List<String> items, String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: const Color(0xFF1A1A2E),
        style: const TextStyle(color: Colors.white, fontSize: 15),
        items: items
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Row(
                    children: [
                      Text(currencySymbols[e] ?? '💱',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(e),
                    ],
                  ),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}