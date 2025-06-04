class RecurringSchedule {
  // ID is the unique identifier for the object
  String id;

  // Description is the name of the expense
  String description;

  // Cost of the expense
  double cost;

  // Category is the type of expense
  String category;

  // Recurence rule for the expense
  String recurrenceRule;

  // Last executed date for the rule
  DateTime lastExecuted;

  // Constructor
  RecurringSchedule({
    this.id = '',
    required this.description,
    required this.cost,
    required this.category,
    required this.recurrenceRule,
    required this.lastExecuted,
  });

  RecurringSchedule.fromMap(Map<String, dynamic> map)
      : this(
          id: map['id'],
          description: map['description'],
          cost: double.parse(map['cost'].toString()),
          category: map['category'].asString,
          recurrenceRule: map['recurrence_rule'],
          lastExecuted: DateTime.parse(map['last_executed'].toString()),
        );

  RecurringSchedule copy() {
    return RecurringSchedule(
      id: id,
      description: description,
      cost: cost,
      category: category,
      recurrenceRule: recurrenceRule,
      lastExecuted: lastExecuted,
    );
  }

  // Returns a string representation of the object
  @override
  String toString() {
    return 'RecurringSchedule{id: $id, description: $description, cost: $cost, category: $category, recurrenceRule: $recurrenceRule, lastExecuted: $lastExecuted}';
  }
}
