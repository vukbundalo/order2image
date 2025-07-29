import 'package:flutter/material.dart';
import 'package:order2image/models/audit_provider.dart';
import 'package:provider/provider.dart';

class AuditPane extends StatefulWidget {
  const AuditPane({super.key});

  @override
  State<AuditPane> createState() => _AuditPaneState();
}

class _AuditPaneState extends State<AuditPane> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        color: Colors.grey.shade200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audit & Timeline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Consumer<AuditProvider>(
                builder: (context, provider, child) {
                  final logs = provider.events;

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                    }
                  });

                  if (logs.isEmpty) {
                    return const Center(
                      child: Text('No audit events yet.'),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return ListTile(
                        dense: true,
                        leading: Text(
                          log.time.substring(11, 19),
                        ),
                        title: Text('${log.eventType} → ${log.refId}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
