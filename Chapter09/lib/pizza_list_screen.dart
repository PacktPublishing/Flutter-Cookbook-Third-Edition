import 'package:flutter/material.dart';
import './dio_helper.dart';
import './pizza.dart';

class PizzaListScreen extends StatefulWidget {
  const PizzaListScreen({super.key});

  @override
  State<PizzaListScreen> createState() => _PizzaListScreenState();
}

class _PizzaListScreenState extends State<PizzaListScreen> {
  DioHelper helper = DioHelper();
  String adminResult = '';

  @override
  void initState() {
    super.initState();
    helper.getPizzaList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pizza List'),
        actions: [
          IconButton(
            onPressed: _checkAdminEndpoint,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPizzaDialog(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (adminResult.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: Text(
                adminResult,
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Expanded(
            child: FutureBuilder(
              future: helper.getPizzaList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    final List<Pizza> pizzas = snapshot.data!;
                    return ListView.builder(
                      itemCount: pizzas.length,
                      itemBuilder: (context, index) {
                        final Pizza pizza = pizzas[index];

                        return Dismissible(
                          key: ValueKey(pizza.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) async {
                            final removedPizza = pizza;
                            final removedIndex = index;

                            setState(() {
                              pizzas.removeAt(removedIndex);
                            });

                            try {
                              await helper.deletePizza(removedPizza.id);
                            } catch (e) {
                              if (!mounted) return;

                              setState(() {
                                pizzas.insert(removedIndex, removedPizza);
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Could not delete the pizza. Please try again.',
                                  ),
                                ),
                              );
                            }
                          },
                          child: ListTile(
                            title: Text(pizza.pizzaName),
                            subtitle: Text(pizza.description),
                            trailing: Text('\$${pizza.price}'),
                            onTap: () => _showPizzaDialog(pizza),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No data'));
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkAdminEndpoint() async {
    final result = await helper.getAdminMappings();
    if (!mounted) return;
    setState(() {
      adminResult = result;
    });
  }

  Future<void> _showPizzaDialog([Pizza? pizza]) async {
    final nameController = TextEditingController(text: pizza?.pizzaName ?? '');
    final descController = TextEditingController(
      text: pizza?.description ?? '',
    );
    final priceController = TextEditingController(
      text: pizza?.price.toString() ?? '',
    );

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(pizza == null ? 'Add Pizza' : 'Edit Pizza'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              String result;
              final newPizza = Pizza(
                id: pizza?.id ?? 0,
                pizzaName: nameController.text,
                description: descController.text,
                price: double.tryParse(priceController.text) ?? 0,
              );

              if (pizza == null) {
                result = await helper.postPizza(newPizza);
              } else {
                result = await helper.putPizza(newPizza);
              }
              debugPrint(result);
              Navigator.pop(context);
              if (!mounted) return;
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
