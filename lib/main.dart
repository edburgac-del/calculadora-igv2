import 'package:flutter/material.dart';

void main() {
  runApp(const CalculadoraApp());
}

class CalculadoraApp extends StatelessWidget {
  const CalculadoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculadora de Precios',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const CalculadoraScreen(),
    );
  }
}

class CalculadoraScreen extends StatefulWidget {
  const CalculadoraScreen({super.key});

  @override
  State<CalculadoraScreen> createState() => _CalculadoraScreenState();
}

class _CalculadoraScreenState extends State<CalculadoraScreen> {
  final TextEditingController _costoController = TextEditingController();
  final TextEditingController _margenController = TextEditingController();

  double _valorVenta = 0.0;
  double _montoIgv = 0.0;
  double _precioFinal = 0.0;
  double _gananciaNeta = 0.0;

  void _calcular() {
    final double costo = double.tryParse(_costoController.text) ?? 0.0;
    final double margen = double.tryParse(_margenController.text) ?? 0.0;

    if (costo <= 0) {
      setState(() {
        _valorVenta = 0.0;
        _montoIgv = 0.0;
        _precioFinal = 0.0;
        _gananciaNeta = 0.0;
      });
      return;
    }

    // Cálculo comercial (Markup)
    final double valorVenta = costo * (1 + (margen / 100));
    final double igv = valorVenta * 0.18;
    final double total = valorVenta + igv;
    final double ganancia = valorVenta - costo;

    setState(() {
      _valorVenta = valorVenta;
      _montoIgv = igv;
      _precioFinal = total;
      _gananciaNeta = ganancia;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cálculo de Precios con IGV'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _costoController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Costo sin IGV (S/)',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _calcular(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _margenController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Margen de ganancia (%)',
                prefixIcon: Icon(Icons.percent),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _calcular(),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildRow('Ganancia neta:', 'S/ ${_gananciaNeta.toStringAsFixed(2)}'),
                    const Divider(height: 24),
                    _buildRow('Subtotal (Venta sin IGV):', 'S/ ${_valorVenta.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    _buildRow('IGV (18%):', 'S/ ${_montoIgv.toStringAsFixed(2)}'),
                    const Divider(height: 24),
                    _buildRow(
                      'Precio Final al Público:',
                      'S/ ${_precioFinal.toStringAsFixed(2)}',
                      isHighlight: true,
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

  Widget _buildRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isHighlight ? 18 : 15,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 20 : 15,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            color: isHighlight ? Colors.indigo : Colors.black87,
          ),
        ),
      ],
    );
  }
}
