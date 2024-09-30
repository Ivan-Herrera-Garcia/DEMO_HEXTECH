import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grid Productos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}

// Pantalla de Splash
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => GridProductos()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Aquí puedes poner el logo X
            Icon(Icons.ac_unit, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text('Mi Logo', style: TextStyle(fontSize: 24, color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}

class GridProductos extends StatefulWidget {
  @override
  _GridProductosState createState() => _GridProductosState();
}

class _GridProductosState extends State<GridProductos> {
  // Precios de cada producto
  List<double> precios = [1.0, 2.0, 3.0, 4.0];

  // Cantidades seleccionadas de cada producto
  List<int> cantidades = [0, 0, 0, 0];

  // Estado para ocultar o mostrar el contenido de la grid
  bool mostrarGrid = true;

  // Cantidad total a pagar
  double totalPagar = 0.0;

  // Cantidad ingresada por el usuario para pagar
  final TextEditingController cantidadController = TextEditingController();

  // Función para calcular el total
  void calcularTotal() {
    totalPagar = 0.0;
    for (int i = 0; i < cantidades.length; i++) {
      totalPagar += cantidades[i] * precios[i];
    }
  }

  // Función para guardar el pago en un archivo de texto
  Future<void> guardarPago(double cantidad) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/pagos.txt';
    final file = File(filePath);

    final DateTime now = DateTime.now();
    final String formattedDate =
        '${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}:${now.second}';

    String pagoInfo =
        'Fecha: $formattedDate, Cantidad Pagada: \$${cantidad.toStringAsFixed(2)}\n';

    await file.writeAsString(pagoInfo, mode: FileMode.append);
    print('Pago guardado en $filePath');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecciona Productos'),
      ),
      body: mostrarGrid ? buildGrid() : buildResumenPago(),
    );
  }

  // Widget para mostrar la grid de productos
  Widget buildGrid() {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(10.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.0,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return buildProductoCard(index);
            },
          ),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              calcularTotal();
              mostrarGrid = false;
            });
          },
          child: Text('Pagar'),
        ),
      ],
    );
  }

  // Widget para cada producto en la grid
  Widget buildProductoCard(int index) {
    return Card(
      elevation: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Image.asset('assets/product${index + 1}.png'),
          ),
          Text('Producto ${index + 1}', style: TextStyle(fontSize: 18)),
          Text('Precio: \$${precios[index]}', style: TextStyle(fontSize: 16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    if (cantidades[index] > 0) {
                      cantidades[index]--;
                    }
                  });
                },
                icon: Icon(Icons.remove),
              ),
              Text('${cantidades[index]}'),
              IconButton(
                onPressed: () {
                  setState(() {
                    cantidades[index]++;
                  });
                },
                icon: Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget para mostrar el resumen del pago
  Widget buildResumenPago() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Total a pagar: \$${totalPagar.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          TextField(
            controller: cantidadController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Cantidad a pagar',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              double cantidadIngresada =
                  double.tryParse(cantidadController.text) ?? 0.0;
              if (cantidadIngresada >= totalPagar) {
                double cambio = cantidadIngresada - totalPagar;
                guardarPago(totalPagar); // Guardar el pago en el archivo

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Pago realizado'),
                    content: Text(
                        '¡Pago exitoso! Tu cambio es: \$${cambio.toStringAsFixed(2)}'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            cantidades = [0, 0, 0, 0];
                            mostrarGrid = true;
                            cantidadController.clear();
                          });
                          Navigator.pop(context);
                        },
                        child: Text('Aceptar'),
                      ),
                    ],
                  ),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Pago insuficiente'),
                    content: Text(
                        'La cantidad ingresada es menor al total. Por favor, ingresa una cantidad válida.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Aceptar'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: Text('Confirmar Pago'),
          ),
        ],
      ),
    );
  }
}
