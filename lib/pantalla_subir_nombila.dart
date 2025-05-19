import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubirNominaScreen extends StatefulWidget {
  @override
  _SubirNominaScreenState createState() => _SubirNominaScreenState();
}

class _SubirNominaScreenState extends State<SubirNominaScreen> {
  String? contenidoArchivo;

  void seleccionarArchivo() {
    final uploadInput = html.FileUploadInputElement()..accept = '.txt';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final file = uploadInput.files!.first;
      final reader = html.FileReader();

      reader.onLoadEnd.listen((e) {
        setState(() {
          contenidoArchivo = reader.result as String;
        });
        procesarYGuardar(reader.result as String);
      });

      reader.readAsText(file);
    });
  }

  void procesarYGuardar(String contenido) {
    final bloques = contenido.split(RegExp(r'-{10,}')); // Separar por líneas de guiones
    for (var bloque in bloques) {
      final lineas = bloque.trim().split('\n');
      final data = <String, String>{};

      for (var linea in lineas) {
        final partes = linea.split(':');
        if (partes.length >= 2) {
          final campo = partes[0].trim();
          final valor = partes.sublist(1).join(':').trim();
          switch (campo) {
            case 'RNC Empresa':
              data['rnc'] = valor;
              break;
            case 'Fecha':
              data['fecha'] = valor;
              break;
            case 'Código Cliente':
              data['codigoCliente'] = valor;
              break;
            case 'Moneda':
              data['moneda'] = valor;
              break;
            case 'Cuenta Empresa':
              data['cuentaEmpresa'] = valor;
              break;
            case 'Cuenta Empleado':
              data['cuentaEmpleado'] = valor;
              break;
            case 'Cédula Empleado':
              data['cedulaEmpleado'] = valor;
              break;
            case 'Monto a Pagar':
              data['monto'] = valor;
              break;
            case 'Referencia':
              data['referencia'] = valor;
              break;
          }
        }
      }

      if (data.isNotEmpty) {
        FirebaseFirestore.instance.collection('BancoPopular').add({
          ...data,
          'importado': FieldValue.serverTimestamp(),
        });
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Archivo procesado y datos guardados.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Importar Nómina - Banco Popular")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: seleccionarArchivo,
              child: Text("Seleccionar archivo .txt"),
            ),
            SizedBox(height: 20),
            if (contenidoArchivo != null)
              Text(
                "Archivo cargado:\n\n${contenidoArchivo!.substring(0, contenidoArchivo!.length.clamp(0, 500))}...",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              )
          ],
        ),
      ),
    );
  }
}
