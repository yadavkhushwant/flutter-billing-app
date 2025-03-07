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