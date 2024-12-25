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
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFFFB74D),
          secondary: const Color(0xFF64B5F6),
          surface: const Color(0xFF1E1E1E),
          background: const Color(0xFF121212),
          error: const Color(0xFFCF6679),
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.white,
          onBackground: Colors.white,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? 'الرئيسية' : 'الأشخاص',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // شاشة المعاملات
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // بطاقة الرصيد
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'الرصيد الكلي',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$totalBalance ج.م',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildQuickAction(
                                context,
                                icon: Icons.add,
                                label: 'إضافة معاملة',
                                onTap: _showAddTransactionDialog,
                              ),
                              _buildQuickAction(
                                context,
                                icon: Icons.person_add,
                                label: 'إضافة شخص',
                                onTap: _showAddPersonDialog,
                              ),
                              _buildQuickAction(
                                context,
                                icon: Icons.filter_list,
                                label: 'تصفية',
                                onTap: () {
                                  setState(() {
                                    _showFilter = !_showFilter;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_showFilter)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: SegmentedButton<TransactionType>(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                              (states) {
                                if (states.contains(MaterialState.selected)) {
                                  return Theme.of(context).colorScheme.primary;
                                }
                                return Theme.of(context).colorScheme.surface;
                              },
                            ),
                          ),
                          segments: const [
                            ButtonSegment(
                              value: TransactionType.credit,
                              label: Text('دائن'),
                              icon: Icon(Icons.arrow_upward),
                            ),
                            ButtonSegment(
                              value: TransactionType.debit,
                              label: Text('مدين'),
                              icon: Icon(Icons.arrow_downward),
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
                  const SizedBox(height: 24),
                  const Text(
                    'العملاء',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // كروت العملاء
                  people.isEmpty
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
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.85,
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
                              child: InkWell(
                                onTap: () {
                                  // TODO: عرض تفاصيل العميل
                                },
                                borderRadius: BorderRadius.circular(24),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            person.name[0],
                                            style: TextStyle(
                                              fontSize: 24,
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
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: (balance >= 0 ? Colors.green : Colors.red).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          '${balance.abs()} ج.م',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: balance >= 0 ? Colors.green : Colors.red,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        balance >= 0 ? 'دائن' : 'مدين',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_rounded),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_rounded),
            label: 'الأشخاص',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
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
