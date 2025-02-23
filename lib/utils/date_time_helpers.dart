String getFinancialYear(DateTime date) {
  int startYear;
  if (date.month < 4) {
    startYear = date.year - 1;
  } else {
    startYear = date.year;
  }
  return "$startYear-${startYear + 1}";
}
