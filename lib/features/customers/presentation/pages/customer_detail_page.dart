import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/customer.dart';
import '../cubit/customer_detail_cubit.dart';

class CustomerDetailPage extends StatefulWidget {
  final Customer customer;

  const CustomerDetailPage({
    super.key,
    required this.customer,
  });

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.customer.phone);
    _phoneController.addListener(() {
      final isChanged = _phoneController.text.trim() != widget.customer.phone;
      if (isChanged != _hasChanges) {
        setState(() {
          _hasChanges = isChanged;
        });
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onSavePressed(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      context.read<CustomerDetailCubit>().updatePhone(_phoneController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomerDetailCubit, CustomerDetailState>(
      listener: (context, state) {
        if (state is CustomerDetailSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phone number updated successfully!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        } else if (state is CustomerDetailFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isSaving = state is CustomerDetailSaving;
        final currentCustomer = state.customer;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Customer Details'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Header Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor:
                                AppColors.primaryLight.withValues(alpha: 0.15),
                            child: Text(
                              currentCustomer.name.isNotEmpty
                                  ? currentCustomer.name[0].toUpperCase()
                                  : 'C',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentCustomer.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentCustomer.city,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Detail Fields
                  const Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Editable Phone Field
                  TextFormField(
                    controller: _phoneController,
                    enabled: !isSaving,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_outlined),
                      helperText: 'Tap to edit customer phone number',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Phone number cannot be empty';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Read-only Email Field
                  TextFormField(
                    initialValue: currentCustomer.email.isNotEmpty
                        ? currentCustomer.email
                        : 'No email provided',
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Read-only Address Field
                  TextFormField(
                    initialValue: currentCustomer.address.isNotEmpty
                        ? '${currentCustomer.address}, ${currentCustomer.city}'
                        : currentCustomer.city,
                    readOnly: true,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  ElevatedButton(
                    onPressed: (isSaving || !_hasChanges)
                        ? null
                        : () => _onSavePressed(context),
                    child: isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save Phone Number'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
