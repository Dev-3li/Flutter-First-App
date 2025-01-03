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
  ThemeMode _themeMode = ThemeMode.dark;

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
          seedColor: const Color(0xFFFFB74D),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Cairo',
      ),
      darkTheme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFB74D),
          secondary: Color(0xFF64B5F6),
          surface: Color(0xFF1E1E1E),
          error: Color(0xFFCF6679),
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.white,
          onError: Colors.black,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: const CardTheme(
          color: Color(0xFF1E1E1E),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          selectedItemColor: Color(0xFFFFB74D),
          unselectedItemColor: Colors.grey,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFFB74D),
          foregroundColor: Colors.black,
        ),
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
  bool _showFilter = false;
  TransactionType _filterType = TransactionType.credit;
  final List<Transaction> transactions = [];
  final List<Person> people = [];

  double get totalBalance {
    double total = 0;
    for (var transaction in transactions) {
      if (transaction.type == TransactionType.credit) {
        total += transaction.amount;
      } else {
        total -= transaction.amount;
      }
    }
    return total;
  }

  void _addTransaction(Transaction transaction) {
    setState(() {
      transactions.add(transaction);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'المحفظة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark 
                  ? Icons.light_mode 
                  : Icons.dark_mode,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الرصيد الكلي',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.person_add),
                          onPressed: () => _showAddPersonDialog(),
                          tooltip: 'إضافة شخص',
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _showAddTransactionDialog,
                          tooltip: 'إضافة معاملة',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${totalBalance.abs()} ج.م ${totalBalance >= 0 ? 'دائن' : 'مدين'}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: totalBalance >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'الأشخاص',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${people.length}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showFilter = !_showFilter;
                    });
                  },
                  icon: const Icon(Icons.filter_list),
                  label: const Text('تصفية'),
                ),
              ],
            ),
          ),
          if (_showFilter)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SegmentedButton<TransactionType>(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (states) {
                        if (states.contains(WidgetState.selected)) {
                          return Theme.of(context).colorScheme.primary;
                        }
                        return Theme.of(context).colorScheme.surface;
                      },
                    ),
                  ),
                  segments: const [
                    ButtonSegment<TransactionType>(
                      value: TransactionType.credit,
                      label: Text('دائن'),
                    ),
                    ButtonSegment<TransactionType>(
                      value: TransactionType.debit,
                      label: Text('مدين'),
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
                          'لا يوجد أشخاص',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _showAddPersonDialog(),
                          icon: const Icon(Icons.person_add),
                          label: const Text('إضافة شخص'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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

                      if (_showFilter) {
                        if (_filterType == TransactionType.credit && balance < 0) {
                          return const SizedBox.shrink();
                        }
                        if (_filterType == TransactionType.debit && balance > 0) {
                          return const SizedBox.shrink();
                        }
                      }

                      return Card(
                        child: InkWell(
                          onTap: () {
                            _showPersonDetails(person);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      person.name[0],
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        person.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (person.phone != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          person.phone!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${balance.abs()} ج.م',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: balance >= 0 ? Colors.green : Colors.red,
                                      ),
                                    ),
                                    Text(
                                      balance >= 0 ? 'دائن' : 'مدين',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        child: const Icon(Icons.add),
      ),
    );
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
                setState(() {
                  people.add(
                    Person(
                      name: nameController.text,
                      phone: phoneController.text.isEmpty ? null : phoneController.text,
                    ),
                  );
                });
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

  void _showPersonDetails(Person person) {
    final personTransactions = transactions.where((t) => t.person == person).toList();
    double balance = 0;
    for (var transaction in personTransactions) {
      if (transaction.type == TransactionType.credit) {
        balance += transaction.amount;
      } else {
        balance -= transaction.amount;
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        person.name[0],
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    person.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (person.phone != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      person.phone!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: (balance >= 0 ? Colors.green : Colors.red).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${balance.abs()} ج.م ${balance >= 0 ? 'دائن' : 'مدين'}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: balance >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: personTransactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد معاملات',
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: personTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = personTransactions[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: transaction.type == TransactionType.credit
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              child: Icon(
                                transaction.type == TransactionType.credit
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: transaction.type == TransactionType.credit
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            title: Text(transaction.description),
                            subtitle: Text(
                              _formatDateTime(transaction.date),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
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
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute}';
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
