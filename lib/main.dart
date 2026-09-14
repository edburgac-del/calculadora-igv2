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
      title: 'Calculadora Comercial',
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
  final TextEditingController _tcController = TextEditingController(text: '3.75');

  bool _costoIncluyeIgv = false; // true = Con IGV, false = Sin IGV
  String _moneda = 'PEN'; // 'PEN' o 'USD'

  double _costoBaseSoles = 0.0;
  double _gananciaNeta = 0.0;
  double _valorVenta = 0.0;
  double _montoIgv = 0.0;
  double _precioFinal = 0.0;

  void _calcular() {
    final double costoIngresado = double.tryParse(_costoController.text) ?? 0.0;
    final double margen = double.tryParse(_margenController.text) ?? 0.0;
    final double tipoCambio = double.tryParse(_tcController.text) ?? 1.0;

    if (costoIngresado <= 0) {
      setState(() {
        _costoBaseSoles = 0.0;
        _gananciaNeta = 0.0;
        _valorVenta = 0.0;
        _montoIgv = 0.0;
        _precioFinal = 0.0;
      });
      return;
    }

    // 1. Convertir a Soles si la moneda seleccionada es Dólares
    double costoEnSoles = _moneda == 'USD' ? (costoIngresado * tipoCambio) : costoIngresado;

    // 2. Extraer el costo base neto (sin IGV) si se ingresó con IGV
    double baseSinIgv = _costoIncluyeIgv ? (costoEnSoles / 1.18) : costoEnSoles;

    // 3. Aplicar margen comercial sobre el costo neto
    double subtotalVenta = baseSinIgv * (1 + (margen / 100));
    double igvVenta = subtotalVenta * 0.18;
    double totalPVP = subtotalVenta + igvVenta;
    double ganancia = subtotalVenta - baseSinIgv;

    setState(() {
      _costoBaseSoles = baseSinIgv;
      _gananciaNeta = ganancia;
      _valorVenta = subtotalVenta;
      _montoIgv = igvVenta;
      _precioFinal = totalPVP;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Precios e IGV'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selección de Moneda y Tipo de Cambio
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'PEN', label: Text('Soles (S/)')),
                      ButtonSegment(value: 'USD', label: Text('Dólares (\$)')),
                    ],
                    selected: {_moneda},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _moneda = newSelection.first;
                      });
                      _calcular();
                    },
                  ),
                ),
                if (_moneda == 'USD') ...[
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _tcController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'T.C. (S/)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (_) => _calcular(),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Selector: Sin IGV vs Con IGV
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Costo Sin IGV')),
                ButtonSegment(value: true, label: Text('Costo Con IGV')),
              ],
              selected: {_costoIncluyeIgv},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  _costoIncluyeIgv = newSelection.first;
                });
                _calcular();
              },
            ),
            const SizedBox(height: 16),

            // Inputs de datos
            TextField(
              controller: _costoController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: _moneda == 'USD'
                    ? 'Costo ingresado (USD \$)'
                    : 'Costo ingresado (Soles S/)',
                prefixIcon: Icon(_moneda == 'USD' ? Icons.attach_money : Icons.monetization_on_outlined),
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => _calcular(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _margenController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Margen de ganancia (%)',
                prefixIcon: Icon(Icons.percent),
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => _calcular(),
            ),
            const SizedBox(height: 20),

            // Resumen de cálculos en Soles
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    if (_moneda == 'USD') ...[
                      _buildRow('Costo Base Neto (en S/):', 'S/ ${_costoBaseSoles.toStringAsFixed(2)}'),
                      const SizedBox(height: 6),
                    ],
                    _buildRow('Ganancia neta estimada:', 'S/ ${_gananciaNeta.toStringAsFixed(2)}'),
                    const Divider(height: 22),
                    _buildRow('Subtotal Venta (sin IGV):', 'S/ ${_valorVenta.toStringAsFixed(2)}'),
                    const SizedBox(height: 6),
                    _buildRow('IGV a trasladar (18%):', 'S/ ${_montoIgv.toStringAsFixed(2)}'),
                    const Divider(height: 22),
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
            fontSize: isHighlight ? 17 : 14,
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
