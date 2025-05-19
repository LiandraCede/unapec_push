import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unapec_push/pantalla_lista_nomina.dart';
import 'package:unapec_push/pantalla_subir_nombila.dart';

class CrearNominaScreen extends StatefulWidget {
  @override
  _CrearNominaScreenState createState() => _CrearNominaScreenState();
}

class _CrearNominaScreenState extends State<CrearNominaScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {
    "rnc": TextEditingController(),
    "fecha": TextEditingController(),
    "codigoCliente": TextEditingController(),
    "moneda": TextEditingController(),
    "cuentaEmpresa": TextEditingController(),
    "cuentaEmpleado": TextEditingController(),
    "cedulaEmpleado": TextEditingController(),
    "monto": TextEditingController(),
    "referencia": TextEditingController(),
  };

  Future<void> guardarNomina() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        "rnc": controllers["rnc"]!.text,
        "fecha": controllers["fecha"]!.text,
        "codigoCliente": controllers["codigoCliente"]!.text,
        "moneda": controllers["moneda"]!.text,
        "cuentaEmpresa": controllers["cuentaEmpresa"]!.text,
        "cuentaEmpleado": controllers["cuentaEmpleado"]!.text,
        "cedulaEmpleado": controllers["cedulaEmpleado"]!.text,
        "monto": controllers["monto"]!.text,
        "referencia": controllers["referencia"]!.text,
        "creado": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('NominaUnapec').add(data);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nómina creada exitosamente')),
      );

      controllers.forEach((_, c) => c.clear());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text(
          "Crear Nueva Nómina",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Center(
            child: SizedBox(
              width: 600.0,
              child: ListView(
                children: [
                  buildTextField("RNC Empresa", "rnc"),
                  buildTextField("Fecha (dd/mm/yyyy)", "fecha", isDate: true),
                  buildTextField("Código Cliente", "codigoCliente"),
                  buildTextField("Moneda", "moneda"),
                  buildTextField("Cuenta Bancaria Empresa", "cuentaEmpresa"),
                  buildTextField("Cuenta Bancaria Empleado", "cuentaEmpleado"),
                  buildTextField("Cédula Empleado", "cedulaEmpleado"),
                  buildTextField("Monto a Pagar", "monto", keyboardType: TextInputType.number),
                  buildTextField("Referencia", "referencia"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: guardarNomina,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("Crear Nómina"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListaNominaScreen()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Listado de nomina Unapec"),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SubirNominaScreen()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text("Subir nomina al Popular"),
            )
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, String key,
      {bool isDate = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controllers[key],
        keyboardType: keyboardType ??
            (key == 'monto' || key == 'rnc' || key == 'cedulaEmpleado'
                ? TextInputType.number
                : TextInputType.text),
        readOnly: isDate,
        onTap: isDate
            ? () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            controllers[key]!.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
          }
        }
            : null,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF1C1F26),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Campo requerido';

          if (key == 'rnc') {
            final isValid = RegExp(r'^\d{9}$').hasMatch(value);
            if (!isValid) return 'Debe tener exactamente 9 dígitos numéricos';
          }

          if (key == 'monto') {
            final isValid = RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value);
            if (!isValid) return 'Solo números, máximo 2 decimales';
          }

          if (key == 'cedulaEmpleado') {
            final isValid = RegExp(r'^\d{11}$').hasMatch(value);
            if (!isValid) return 'Debe tener exactamente 11 dígitos numéricos';
          }

          if (key == 'moneda') {
            final isValid = RegExp(r'^[a-zA-Z]+$').hasMatch(value);
            if (!isValid) return 'Solo letras (ej. DOP, USD)';
          }

          return null;
        },
      ),
    );
  }
}
