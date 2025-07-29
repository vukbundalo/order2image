import 'package:flutter/material.dart';
import 'package:order2image/providers/order_provider.dart';
import 'services/database_service.dart';
import 'package:provider/provider.dart';
import 'providers/patient_provider.dart';
import 'ui/widgets/order_form.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the SQLite database
  await DatabaseService.instance.db;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PatientProvider()..loadPatients(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider()..loadPendingOrders(),
        ),
      ],
      child: const Order2ImageApp(),
    ),
  );
}

class Order2ImageApp extends StatelessWidget {
  const Order2ImageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order2Image',
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order2Image')),
      body: Column(
        children: [
          // Top: Doctor and Imaging panes
          Expanded(
            flex: 2,
            child: Row(
              children: [
                // Doctor Pane
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    color: Colors.blue.shade50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Doctor Dashboard',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Consumer<PatientProvider>(
                            builder: (context, provider, child) {
                              final patients = provider.patients;
                              final selected = provider.selectedPatient;

                              if (patients.isEmpty) {
                                return const Center(
                                  child: Text('No patients found.'),
                                );
                              }

                              return ListView.builder(
                                itemCount: patients.length,
                                itemBuilder: (context, index) {
                                  final patient = patients[index];
                                  final isSelected =
                                      selected?.patientID == patient.patientID;

                                  return ListTile(
                                    title: Text(
                                      '${patient.firstName} ${patient.lastName}',
                                    ),
                                    subtitle: Text(
                                      'MRN: ${patient.mrn}  DOB: ${patient.dob}',
                                    ),
                                    selected: isSelected,
                                    selectedTileColor: Colors.blue.shade100,
                                    onTap: () =>
                                        provider.selectPatient(patient),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        OrderForm(),
                      ],
                    ),
                  ),
                ),
                // Imaging Pane
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    color: Colors.green.shade50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Imaging Dashboard',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Expanded(
                          child: Consumer<OrderProvider>(
                            builder: (context, provider, _) {
                              final orders = provider.orders;

                              if (orders.isEmpty) {
                                return const Center(
                                  child: Text('No pending imaging orders.'),
                                );
                              }

                              return ListView.builder(
                                itemCount: orders.length,
                                itemBuilder: (context, index) {
                                  final order = orders[index];
                                  return ListTile(
                                    title: Text('${order.procedureCode}'),
                                    subtitle: Text(
                                      'Patient: ${order.patientName}',
                                    ),
                                    trailing: Text(
                                      order.orderDateTime.substring(0, 16),
                                    ),
                                    onTap: () {
                                      // TODO: Capture Image logic goes here
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom: Audit Panel
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              color: Colors.grey.shade200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Audit & Timeline',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: Center(child: Text('Live event log goes here')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
