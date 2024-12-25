import 'package:flutter/material.dart';
import 'add_transaction.dart';
import 'people_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'إدارة العمليات المالية',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Cairo',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.dark,
          background: const Color(0xFF1A1A1A),
          surface: const Color(0xFF252525),
          primary: const Color(0xFF4CAF50),
          secondary: const Color(0xFF66BB6A),
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        useMaterial3: true,
        fontFamily: 'Cairo',
      ),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: HomePage(toggleTheme: toggleTheme),
    );
  }
}

class HomePage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const HomePage({
    super.key,
    required this.toggleTheme,
  });

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          _selectedIndex == 0 ? 'المعاملات المالية' : 'إدارة الأشخاص',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: widget.toggleTheme,
          ),
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: () {
                setState(() {
                  _showFilter = !_showFilter;
                });
              },
            ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
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
              Expanded(
                child: people.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا يوجد عملاء',
                              style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: people.length,
                        itemBuilder: (context, index) {
                          final person = people[index];
                          final personTransactions = transactions.where((t) => t.person == person).toList();
                          double balance = 0;
                          for (var transaction in personTransactions) {
                            if (transaction.type == TransactionType.credit) {
                              balance += transaction.amount;
                            } else {
                              balance -= transaction.amount;
                            }
                          }

                          return Card(
                            elevation: 4,
                            child: InkWell(
                              onTap: () {
                                // TODO: عرض تفاصيل العميل
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      child: Text(
                                        person.name[0],
                                        style: TextStyle(
                                          fontSize: 24,
                                          color: Theme.of(context).colorScheme.onPrimary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      person.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (person.phone != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        person.phone!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Text(
                                      '${balance.abs()} ج.م',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: balance >= 0 ? Colors.green : Colors.red,
                                      ),
                                    ),
                                    Text(
                                      balance >= 0 ? 'دائن' : 'مدين',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
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
            icon: Icon(Icons.dashboard),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'الأشخاص',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedIndex == 0) {
            _showAddTransactionDialog();
          } else {
            _showAddPersonDialog();
          }
        },
        child: Icon(_selectedIndex == 0 ? Icons.add : Icons.person_add),
      ),
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

enum TransactionType {
  credit,
  debit,
}

class Person {
  final String name;
  final String? phone;

  Person({
    required this.name,
    this.phone,
  });
}
