class HistoricalStats {
  late String date;
  double averagePower = 0;
  late String timeElapsed;
  double averageCadance = 0;
  double averageSpeed = 0;
  int powerCount = 0;
  int cadanceCount = 0;
  int speedCount = 0;

  setTimeElapse(value) {
    timeElapsed = value;
  }

  setDate(value) {
    date = value;
  }

  double calculateAverage(count, currentAverage, newValue) {
    double newAverage;
    newAverage = ((currentAverage * count) + newValue) / (count + 1);

    return newAverage;
  }

  setAveragePower(value) {
    powerCount++;
    averagePower = calculateAverage(powerCount, averagePower, value);
  }

  setAverageSpeed(value) {
    speedCount++;
    averageSpeed = calculateAverage(speedCount, averageSpeed, value);
  }

  setAverageCadance(value) {
    cadanceCount++;
    averageCadance = calculateAverage(cadanceCount, averageCadance, value);
  }
}
