import 'package:flutter/material.dart';

import '../services/currency_service.dart';

class CurrencyConverterPage
    extends StatefulWidget {
  const CurrencyConverterPage({
    super.key,
  });

  @override
  State<CurrencyConverterPage>
      createState() =>
          _CurrencyConverterPageState();
}

class _CurrencyConverterPageState
    extends State<
        CurrencyConverterPage> {
  final controller =
      TextEditingController();

  String from = "Gold";
  String to = "IDR";

  double result = 0;

  Map<String, double> rates = {};

  static const double
      goldValueUsd = 0.10;

  @override
  void initState() {
    super.initState();
    loadRates();
  }

  Future<void> loadRates() async {
    rates =
        await CurrencyService.instance
            .getRates();

    setState(() {});
  }

  Future<void> convert() async {
    if (controller.text.isEmpty) return;

    double amount =
        double.parse(
      controller.text,
    );

    double usdValue = 0;

    if (from == "Gold") {
      usdValue =
          amount * goldValueUsd;
    } else {
      usdValue =
          amount / rates[from]!;
    }

    if (to == "Gold") {
      result =
          usdValue / goldValueUsd;
    } else {
      result =
          usdValue * rates[to]!;
    }

    setState(() {});
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Currency Converter",
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(
          16,
        ),
        child: Column(
          children: [
            TextField(
              controller: controller,
              keyboardType:
                  TextInputType.number,
              decoration:
                  const InputDecoration(
                labelText:
                    "Amount",
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            DropdownButton<String>(
              value: from,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: "Gold",
                  child: Text(
                    "Gold",
                  ),
                ),
                DropdownMenuItem(
                  value: "USD",
                  child: Text(
                    "USD",
                  ),
                ),
                DropdownMenuItem(
                  value: "IDR",
                  child: Text(
                    "IDR",
                  ),
                ),
                DropdownMenuItem(
                  value: "JPY",
                  child: Text(
                    "JPY",
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  from = value!;
                });
              },
            ),

            const SizedBox(
              height: 10,
            ),

            DropdownButton<String>(
              value: to,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: "Gold",
                  child: Text(
                    "Gold",
                  ),
                ),
                DropdownMenuItem(
                  value: "USD",
                  child: Text(
                    "USD",
                  ),
                ),
                DropdownMenuItem(
                  value: "IDR",
                  child: Text(
                    "IDR",
                  ),
                ),
                DropdownMenuItem(
                  value: "JPY",
                  child: Text(
                    "JPY",
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  to = value!;
                });
              },
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton(
              onPressed: convert,
              child: const Text(
                "Convert",
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              result.toStringAsFixed(
                2,
              ),
              style:
                  const TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}