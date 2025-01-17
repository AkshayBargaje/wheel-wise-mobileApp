String formatMonth(String dateTimeString) {
  // Parse the input string into a DateTime object
  DateTime dateTime = DateTime.parse(dateTimeString);

  // Extract day and month
  int day = dateTime.day;
  int month = dateTime.month;

  // List of month names
  List<String> monthNames = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
    "Jul", "Aug", "Sept", "Oct", "Nov", "Dec"
  ];

  // Format the date manually
  return "${monthNames[month - 1]}";
}

String formatDay(String dateTimeString) {
  // Parse the input string into a DateTime object
  DateTime dateTime = DateTime.parse(dateTimeString);

  // Extract day and month
  int day = dateTime.day;
  int month = dateTime.month;

  // List of month names
  List<String> monthNames = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
    "Jul", "Aug", "Sept", "Oct", "Nov", "Dec"
  ];

  // Format the date manually
  return "$day";
}

DateTime formatDate(String dateTimeString) {
  // Parse the input string into a DateTime object
  DateTime dateTime = DateTime.parse(dateTimeString);

  // Extract day and month
  // int day = dateTime.day;
  // int month = dateTime.month;

  // // List of month names
  // List<String> monthNames = [
  //   "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
  //   "Jul", "Aug", "Sept", "Oct", "Nov", "Dec"
  // ];

  // Format the date manually
  return dateTime;
}
