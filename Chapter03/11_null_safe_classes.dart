void main() {
  // Using the constructor
  var bruce = Person('Bruce', 'Wayne', age: 42);

  // Using null-coalescing for nullable fields
  if ((bruce.age ?? 0) < 18) {
    print('Minor');
  } else {
    print('Adult');
  }

  // Null-aware access operator (?.)
  Person? person;
  print('Person name: ${person?.name}');

  // Forced access operator (!) - will throw runtime error
  try {
    print('Forced name: ${person!.name}');
  } catch (e) {
    print('Caught expected null error: $e');
  }
}

class Person {
  // Marked as late: promised to initialize before use
  late String name;
  late String surname;
  int? age;

  Person(this.name, this.surname, {this.age});

  // Named constructor from a Map
  Person.fromMap(Map<String, dynamic> map) {
    name = map['name'];
    surname = map['surname'];
  }
}
