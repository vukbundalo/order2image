import 'package:flutter/material.dart';
import 'package:order2image/models/audit_provider.dart';
import 'package:order2image/providers/order_provider.dart';
import 'package:order2image/services/database_service.dart';
import 'package:provider/provider.dart';
import '../../providers/patient_provider.dart';

class OrderForm extends StatefulWidget {
  const OrderForm({super.key});

  @override
  State<OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  String? selectedProcedure;
  String? selectedPriority;

  final procedures = ['CT Abdomen', 'Chest X-Ray', 'Brain MRI'];

  final priorities = ['Routine', 'STAT'];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PatientProvider>(context);
    final selectedPatient = provider.selectedPatient;

    if (selectedPatient == null) {
      return const Text('Select a patient to request an exam.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Request Imaging for ${selectedPatient.firstName} ${selectedPatient.lastName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Procedure'),
          items: procedures
              .map((proc) => DropdownMenuItem(value: proc, child: Text(proc)))
              .toList(),
          value: selectedProcedure,
          onChanged: (value) => setState(() => selectedProcedure = value),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Priority'),
          items: priorities
              .map((prio) => DropdownMenuItem(value: prio, child: Text(prio)))
              .toList(),
          value: selectedPriority,
          onChanged: (value) => setState(() => selectedPriority = value),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
  onPressed: () async {
    final patient = provider.selectedPatient!;
    final orderId = 'O${DateTime.now().millisecondsSinceEpoch}';

    await DatabaseService.instance.insertOrder(
      orderId: orderId,
      patientId: patient.patientID,
      procedureCode: selectedProcedure!,
      orderDateTime: DateTime.now().toIso8601String(),
    );

    await DatabaseService.instance.logAudit('ORDER_CREATED', orderId);

    // ✅ Refresh audit and imaging (order) views
    Provider.of<AuditProvider>(context, listen: false).refresh();
    Provider.of<OrderProvider>(context, listen: false).refresh();

    print('Order $orderId for ${patient.firstName} submitted.');

    setState(() {
      selectedProcedure = null;
      selectedPriority = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order submitted successfully.')),
    );
  },
  child: const Text('Send Order'),
)

      ],
    );
  }
}
