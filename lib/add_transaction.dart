import 'package:flutter/material.dart';
import 'main.dart';

class AddTransactionDialog extends StatefulWidget {
  final List<Person> people;
  final Function(Transaction) onAdd;

  const AddTransactionDialog({
    super.key,
    required this.people,
    required this.onAdd,
  });

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  TransactionType _type = TransactionType.credit;
  Person? _selectedPerson;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة معاملة جديدة'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // نوع المعاملة
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.credit,
                    label: Text('دائن'),
                    icon: Icon(Icons.arrow_circle_up),
                  ),
                  ButtonSegment(
                    value: TransactionType.debit,
                    label: Text('مدين'),
                    icon: Icon(Icons.arrow_circle_down),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (Set<TransactionType> newSelection) {
                  setState(() {
                    _type = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              // الوصف
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'الوصف',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال وصف للمعاملة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // المبلغ
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'المبلغ',
                  border: OutlineInputBorder(),
                  suffixText: 'ج.م',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال المبلغ';
                  }
                  if (double.tryParse(value) == null) {
                    return 'الرجاء إدخال رقم صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // اختيار الشخص
              DropdownButtonFormField<Person>(
                decoration: const InputDecoration(
                  labelText: 'الشخص',
                  border: OutlineInputBorder(),
                ),
                value: _selectedPerson,
                items: widget.people.map((person) {
                  return DropdownMenuItem(
                    value: person,
                    child: Text(person.name),
                  );
                }).toList(),
                onChanged: (Person? value) {
                  setState(() {
                    _selectedPerson = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'الرجاء اختيار شخص';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final transaction = Transaction(
                description: _descriptionController.text,
                amount: double.parse(_amountController.text),
                type: _type,
                person: _selectedPerson!,
              );
              widget.onAdd(transaction);
              Navigator.pop(context);
            }
          },
          child: const Text('إضافة'),
        ),
      ],
    );
  }
}
