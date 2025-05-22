class ExpenseData {
  // ID is the unique identifier for the object
  String id;

  // Description is the name of the expense
  String description;

  // Cost of the expense
  double cost;

  // Date is the date the expense occurred
  DateTime date;

  // Category is the type of expense
  String category;

  // Constructor
  ExpenseData({
    this.id = '',
    required this.description,
    required this.cost,
    required this.date,
    required this.category,
  });

  // Empty constructor
  ExpenseData.empty()
      : id = "",
        description = "",
        cost = 0,
        date = DateTime.now(),
        category = "";

  // Converts the object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'cost': cost,
      'date': date,
      'category': category,
    };
  }

  ExpenseData.fromMap(Map<String, dynamic> map)
      : this(
          id: map['id'],
          description: map['description'],
          cost: double.parse(map['cost']),
          date: DateTime.parse(map['date'].toString()),
          category: map['category'].asString,
        );

  // Converts the object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'cost': cost,
      'date': date,
      'category': category,
    };
  }

  // Constructor to create an object from a map
  ExpenseData.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        description = json['description'],
        cost = json['cost'],
        date = json['date'],
        category = json['category'];

  // Returns a copy of the object
  ExpenseData copy() {
    return ExpenseData(
      id: id,
      description: description,
      cost: cost,
      date: date,
      category: category,
    );
  }

  // Returns a string representation of the object
  @override
  String toString() {
    return 'ExpenseData{id: $id, description: $description, cost: $cost, date: $date, category: $category}';
  }
}
