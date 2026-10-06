import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/widgets/buttons/stitch_primary_button.dart';
import '../../../../shared/widgets/feedback/custom_snackbar.dart';
import '../../../../shared/widgets/inputs/stitch_text_field.dart';
import '../blocs/support_bloc.dart';

class CreateTicketScreen extends StatefulWidget {
  final String? initialCategory;

  const CreateTicketScreen({super.key, this.initialCategory});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  late String _category;
  final String _priority = 'medium';
  File? _attachment;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory ?? 'payment_payout_issue';
  }

  Future<void> _pickAttachment() async {
    final picked = await _picker.pickImage(
        source: ImageSource.gallery, maxWidth: 1920, imageQuality: 80);
    if (picked != null) {
      setState(() => _attachment = File(picked.path));
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<SupportBloc>().add(CreateTicketEvent(
          category: _category,
          subject: _subjectCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          priority: _priority,
          attachment: _attachment,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Raise Support Ticket')),
      body: BlocConsumer<SupportBloc, SupportState>(
        listener: (context, state) {
          if (state is TicketCreatedSuccess) {
            CustomSnackbar.showSuccess(
                context, 'Ticket #${state.ticket.ticketNumber} created.');
            Navigator.pop(context);
          } else if (state is SupportError) {
            CustomSnackbar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is SupportLoading;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration:
                      const InputDecoration(labelText: 'Grievance Category'),
                  items: const [
                    DropdownMenuItem(
                        value: 'payment_payout_issue',
                        child: Text('Payment / Earnings / Payout Issue')),
                    DropdownMenuItem(
                        value: 'vendor_pickup_issue',
                        child: Text('Vendor Store Pickup Delay')),
                    DropdownMenuItem(
                        value: 'customer_issue',
                        child: Text('Customer Delivery / Address Issue')),
                    DropdownMenuItem(
                        value: 'emergency_support',
                        child: Text('Emergency Operational Support')),
                    DropdownMenuItem(
                        value: 'app_technical_issue',
                        child: Text('Mobile App Bug / Technical Error')),
                    DropdownMenuItem(
                        value: 'other', child: Text('Other Query')),
                  ],
                  onChanged: (v) =>
                      setState(() => _category = v ?? 'payment_payout_issue'),
                ),
                const SizedBox(height: 16),
                StitchTextField(
                  controller: _subjectCtrl,
                  labelText: 'Subject / Title',
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                StitchTextField(
                  controller: _descCtrl,
                  labelText: 'Detailed Explanation',
                  maxLines: 5,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.attach_file),
                  title: Text(_attachment != null
                      ? 'Screenshot Attached'
                      : 'Attach Screenshot (Optional)'),
                  trailing: TextButton(
                    onPressed: _pickAttachment,
                    child: Text(_attachment != null ? 'Change' : 'Upload'),
                  ),
                ),
                const SizedBox(height: 32),
                StitchPrimaryButton(
                  text: 'Submit Ticket',
                  isLoading: isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
