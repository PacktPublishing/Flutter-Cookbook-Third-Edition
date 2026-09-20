void main() {
  int dayOfWeek = 7;

  // Traditional switch statement
  String myDay = getDay(dayOfWeek);
  print('Traditional: $myDay');

  // Modern switch expression (Dart 3)
  var myDayExpr = switch (dayOfWeek) {
    1 => 'Monday',
    2 => 'Tuesday',
    3 => 'Wednesday',
    4 => 'Thursday',
    5 => 'Friday',
    6 => 'Saturday',
    7 => 'Sunday',
    _ => 'Invalid day',
  };
  print('Expression: $myDayExpr');

  // Records and Patterns
  var person = (name: 'Clark', age: 42);
  print('Record: ${person.name}, ${person.age}');

  // Destructuring record with patterns
  var (:String name, :int age) = person;
  print('Destructured: $name is $age years old.');

  // Record from a function
  var personData = getPerson({'name': 'Clark', 'age': 42});
  var (String n, int a) = personData;
  print('Function Record: $n is $a years old.');
}

String getDay(int day) {
  switch (day) {
    case 1: return 'Monday';
    case 2: return 'Tuesday';
    case 3: return 'Wednesday';
    case 4: return 'Thursday';
    case 5: return 'Friday';
    case 6: return 'Saturday';
    case 7: return 'Sunday';
    default: return 'Invalid day';
  }
}

(String, int) getPerson(Map<String, dynamic> json) {
  return (json['name'] as String, json['age'] as int);
}
