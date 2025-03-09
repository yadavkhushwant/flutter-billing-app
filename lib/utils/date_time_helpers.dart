String getFinancialYear(DateTime date) {
  int startYear;
  if (date.month < 4) {
    startYear = date.year - 1;
  } else {
    startYear = date.year;
  }
  return "$startYear-${startYear + 1}";
}


String getFormattedDate(String date) {
  try{
    final DateTime dateTime = DateTime.parse(date);
    return "${dateTime.day}-${dateTime.month}-${dateTime.year}";
  } catch(e){
    return date;
  }
}

final Map<int, String> monthNames = {
  1: "January",
  2: "February",
  3: "March",
  4: "April",
  5: "May",
  6: "June",
  7: "July",
  8: "August",
  9: "September",
  10: "October",
  11: "November",
  12: "December",
};

final int currentYear = DateTime.now().year;
final List<int> yearList = List.generate((currentYear + 1) - 2024 + 1, (index) => 2024 + index);