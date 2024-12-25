import 'package:flutter/material.dart';
import 'add_transaction.dart';
import 'people_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'إدارة العمليات المالية',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Cairo',
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double totalBalance = 0;
  List<Transaction> transactions = [];
  List<Person> people = [];
  int _selectedIndex = 0;
  TransactionType _filterType = TransactionType.credit;
  bool _showFilter = false;

  void _addTransaction(Transaction transaction) {
    setState(() {
      transactions.add(transaction);
      if (transaction.type == TransactionType.credit) {
        totalBalance += transaction.amount;
      } else {
        totalBalance -= transaction.amount;
      }
    });
  }

  void _addPerson(Person person) {
    setState(() {
      people.add(person);
    });
  }

  void _deletePerson(Person person) {
    // التحقق من عدم وجود معاملات للشخص
    final hasTransactions = transactions.any((t) => t.person == person);
    if (hasTransactions) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('لا يمكن الحذف'),
          content: const Text('لا يمكن حذف شخص لديه معاملات'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      people.remove(person);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          _selectedIndex == 0 ? 'المعاملات المالية' : 'إدارة الأشخاص',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      _showFilter = !_showFilter;
                    });
                  },
                ),
              ]
            : null,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // شاشة المعاملات
          Column(
            children: [
              if (_showFilter)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: SegmentedButton<TransactionType>(
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
                    selected: {_filterType},
                    onSelectionChanged: (Set<TransactionType> newSelection) {
                      setState(() {
                        _filterType = newSelection.first;
                      });
                    },
                  ),
                ),
              // الرصيد الإجمالي
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    const Text(
                      'الرصيد الإجمالي',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$totalBalance ج.م',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: totalBalance >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              // قائمة المعاملات
              Expanded(
                child: transactions.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد معاملات',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          if (_showFilter && transaction.type != _filterType) {
                            return const SizedBox.shrink();
                          }
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: transaction.type == TransactionType.credit
                                    ? Colors.green
                                    : Colors.red,
                                child: Icon(
                                  transaction.type == TransactionType.credit
                                      ? Icons.arrow_circle_up
                                      : Icons.arrow_circle_down,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(transaction.description),
                              subtitle: Text(
                                '${transaction.person.name} - ${_formatDate(transaction.date)}',
                              ),
                              trailing: Text(
                                '${transaction.type == TransactionType.credit ? '+' : '-'} ${transaction.amount} ج.م',
                                style: TextStyle(
                                  color: transaction.type == TransactionType.credit
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          // شاشة الأشخاص
          PeopleScreen(
            people: people,
            onAdd: _addPerson,
            onDelete: _deletePerson,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.swap_horiz),
            label: 'المعاملات',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'الأشخاص',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                _showAddTransactionDialog();
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

  void _showAddTransactionDialog() {
    if (people.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تنبيه'),
          content: const Text('الرجاء إضافة شخص أولاً'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showAddPersonDialog();
              },
              child: const Text('إضافة شخص'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(
        people: people,
        onAdd: _addTransaction,
      ),
    );
  }

  void _showAddPersonDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة شخص جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'الاسم',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف (اختياري)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _addPerson(
                  Person(
                    name: nameController.text,
                    phone: phoneController.text.isEmpty ? null : phoneController.text,
                  ),
                );
                Navigator.pop(context);
                _showAddTransactionDialog();
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}

// نموذج المعاملة
class Transaction {
  final String description;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final Person person;

  Transaction({
    required this.description,
    required this.amount,
    required this.type,
    required this.person,
  }) : date = DateTime.now();
}

// نوع المعاملة
enum TransactionType {
  credit, // دائن
  debit, // مدين
}

// نموذج الشخص
class Person {
  final String name;
  final String? phone;

  Person({
    required this.name,
    this.phone,
  });
}
