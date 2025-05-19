import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:html' as html;
import 'dart:convert';

class ListaNominaScreen extends StatefulWidget {
  @override
  _ListaNominaScreenState createState() => _ListaNominaScreenState();
}

class _ListaNominaScreenState extends State<ListaNominaScreen> {
  List<Map<String, dynamic>> nominas = [];

  @override
  void initState() {
    super.initState();
    obtenerNominas();
  }

  Future<void> obtenerNominas() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('NominaUnapec')
        .orderBy('creado', descending: true)
        .get();

    setState(() {
      nominas = querySnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  void descargarArchivoTxt(String nombreArchivo, String contenido) {
    final bytes = utf8.encode(contenido);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", nombreArchivo)
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  void exportarNominaComoTxt() {
    if (nominas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay nóminas para exportar")),
      );
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln("LISTADO DE NÓMINAS\n");

    for (var n in nominas) {
      buffer.writeln("RNC Empresa: ${n['rnc'] ?? ''}");
      buffer.writeln("Fecha: ${n['fecha'] ?? ''}");
      buffer.writeln("Código Cliente: ${n['codigoCliente'] ?? ''}");
      buffer.writeln("Moneda: ${n['moneda'] ?? ''}");
      buffer.writeln("Cuenta Empresa: ${n['cuentaEmpresa'] ?? ''}");
      buffer.writeln("Cuenta Empleado: ${n['cuentaEmpleado'] ?? ''}");
      buffer.writeln("Cédula Empleado: ${n['cedulaEmpleado'] ?? ''}");
      buffer.writeln("Monto a Pagar: ${n['monto'] ?? ''}");
      buffer.writeln("Referencia: ${n['referencia'] ?? ''}");
      buffer.writeln("-" * 40);
    }

    descargarArchivoTxt("NominaUnapec.txt", buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Listado de Nómina")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: exportarNominaComoTxt,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Descargar Nómina"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: nominas.length,
              itemBuilder: (context, index) {
                final n = nominas[index];
                return ListTile(
                  title: Text("Empleado: ${n['cedulaEmpleado'] ?? ''}"),
                  subtitle: Text("Monto: ${n['monto'] ?? ''} - Fecha: ${n['fecha'] ?? ''}"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
