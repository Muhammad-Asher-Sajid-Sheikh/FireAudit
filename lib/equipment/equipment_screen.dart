import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/api_clinet.dart';
import '../core/format.dart';
import '../models/extinguisher.dart';
import '../services/extinguisher_service.dart';
import '../widgets/appcolors.dart';
import '../widgets/error_banner.dart';
import '../widgets/status_chip.dart';

/// Fire Equipment page: list, add, edit and delete extinguisher batches.
/// The dashboard owns the data; this page asks it to reload after every change.
class EquipmentScreen extends StatefulWidget {
  final List<Extinguisher> items;
  final bool loading;
  final String? error;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onUnauthorized;

  const EquipmentScreen({
    super.key,
    required this.items,
    required this.loading,
    required this.error,
    required this.onRefresh,
    required this.onUnauthorized,
  });

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  final _service = ExtinguisherService.instance;
  bool _busy = false;

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _run(Future<void> Function() action, String successMessage) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      _toast(successMessage);
      await widget.onRefresh();
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.isAuthError) {
        await widget.onUnauthorized();
      } else {
        _toast(e.message);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openForm([Extinguisher? existing]) async {
    final result = await showDialog<_FormResult>(
      context: context,
      builder: (_) => _EquipmentDialog(existing: existing),
    );
    if (result == null) return;

    if (existing == null) {
      await _run(
            () => _service.create(
          model: result.model,
          batchSize: result.batchSize,
          expiryDate: result.expiryDate,
          isExpired: result.isExpired,
        ),
        'Batch added.',
      );
    } else {
      await _run(
            () => _service.update(
          existing.batchId,
          model: result.model,
          batchSize: result.batchSize,
          expiryDate: result.expiryDate,
          isExpired: result.isExpired,
        ),
        'Batch updated.',
      );
    }
  }

  Future<void> _confirmDelete(Extinguisher e) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete batch?'),
        content: Text('"${e.model}" (${e.batchSize} units) will be removed permanently.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    await _run(() => _service.delete(e.batchId), 'Batch deleted.');
  }

  @override
  Widget build(BuildContext context) {
    final busy = _busy || widget.loading;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fire Equipment',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy)),
                    SizedBox(height: 2),
                    Text('Fire extinguisher batches and their expiry dates',
                        style: TextStyle(color: AppColors.grey)),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: busy ? null : widget.onRefresh,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.navy,
                    side: const BorderSide(color: AppColors.border)),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: busy ? null : () => _openForm(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Batch'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (busy)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(minHeight: 3, color: AppColors.red),
            ),
          if (widget.error != null)
            ErrorBanner(message: widget.error!, onRetry: widget.onRefresh),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withOpacity(0.6)),
              ),
              child: widget.items.isEmpty
                  ? Center(
                child: Text(
                  widget.loading
                      ? 'Loading...'
                      : 'No extinguisher batches yet. Click "Add Batch" to create one.',
                  style: const TextStyle(color: AppColors.grey),
                ),
              )
                  : _table(busy),
            ),
          ),
        ],
      ),
    );
  }

  Widget _table(bool busy) {
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: c.maxWidth),
            child: DataTable(
              headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.w800, color: AppColors.navy),
              columns: const [
                DataColumn(label: Text('Model')),
                DataColumn(label: Text('Batch Size'), numeric: true),
                DataColumn(label: Text('Expiry Date')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Added')),
                DataColumn(label: Text('Actions')),
              ],
              rows: [
                for (final e in widget.items)
                  DataRow(cells: [
                    DataCell(Text(e.model,
                        style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text('${e.batchSize}')),
                    DataCell(Text(formatDate(e.expiryDate))),
                    DataCell(StatusChip(e.status)),
                    DataCell(Text(timeAgo(e.createdAt),
                        style: const TextStyle(color: AppColors.grey))),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Edit',
                          icon: const Icon(Icons.edit_outlined,
                              color: AppColors.navy, size: 20),
                          onPressed: busy ? null : () => _openForm(e),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.red, size: 20),
                          onPressed: busy ? null : () => _confirmDelete(e),
                        ),
                      ],
                    )),
                  ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FormResult {
  final String model;
  final int batchSize;
  final DateTime expiryDate;
  final bool isExpired;
  const _FormResult(this.model, this.batchSize, this.expiryDate, this.isExpired);
}

class _EquipmentDialog extends StatefulWidget {
  final Extinguisher? existing;
  const _EquipmentDialog({this.existing});

  @override
  State<_EquipmentDialog> createState() => _EquipmentDialogState();
}

class _EquipmentDialogState extends State<_EquipmentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _model;
  late final TextEditingController _size;
  DateTime? _expiry;
  bool _isExpired = false;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _model = TextEditingController(text: e?.model ?? '');
    _size = TextEditingController(text: e == null ? '' : '${e.batchSize}');
    _expiry = e?.expiryDate;
    _isExpired = e?.isExpired ?? false;
  }

  @override
  void dispose() {
    _model.dispose();
    _size.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _expiry == null
        ? DateTime(now.year + 1, now.month, now.day)
        : DateTime(_expiry!.year, _expiry!.month, _expiry!.day);
    final d = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) {
      setState(() {
        _expiry = DateTime.utc(d.year, d.month, d.day);
        _dateError = null;
      });
    }
  }

  void _submit() {
    final formOk = _formKey.currentState!.validate();
    if (_expiry == null) {
      setState(() => _dateError = 'Pick an expiry date');
      return;
    }
    if (!formOk) return;
    Navigator.of(context).pop(_FormResult(
      _model.text.trim(),
      int.parse(_size.text.trim()),
      _expiry!,
      _isExpired,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return AlertDialog(
      title: Text(editing ? 'Edit Batch' : 'Add Batch'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _model,
                decoration: const InputDecoration(
                    labelText: 'Model', border: OutlineInputBorder()),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter the model' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _size,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                    labelText: 'Batch size (units)',
                    border: OutlineInputBorder()),
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  if (n == null || n <= 0) return 'Enter a number greater than 0';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Expiry date',
                    border: const OutlineInputBorder(),
                    errorText: _dateError,
                    suffixIcon: const Icon(Icons.calendar_today, size: 18),
                  ),
                  child: Text(
                      _expiry == null ? 'Select date' : formatDate(_expiry!)),
                ),
              ),
              const SizedBox(height: 6),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Mark as expired'),
                value: _isExpired,
                onChanged: (v) => setState(() => _isExpired = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red, foregroundColor: Colors.white),
          child: Text(editing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
