enum TimePeriod {
  thirtyDays,
  sixMonths,
  oneYear,
  fiveYears,
  all,
}

/// Returns the label for the time period (e.g., "30d", "6m")
String getTimePeriodLabel(TimePeriod period) {
  switch (period) {
    case TimePeriod.thirtyDays:
      return '30d';
    case TimePeriod.sixMonths:
      return '6m';
    case TimePeriod.oneYear:
      return '1y';
    case TimePeriod.fiveYears:
      return '5y';
    case TimePeriod.all:
      return 'All';
  }
}
