import 'package:flutter/material.dart';
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

  final procedures = [
    'CT Abdomen',
    'Chest X-Ray',
    'Brain MRI',
  ];

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
        Text('Request Imaging for ${selectedPatient.firstName} ${selectedPatient.lastName}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
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
          onPressed: (selectedProcedure != null && selectedPriority != null)
              ? () {
                  // TODO: Save order to DB + trigger HL7 generation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order submitted (not yet wired).')),
                  );
                }
              : null,
          child: const Text('Send Order'),
        ),
      ],
    );
  }
}
