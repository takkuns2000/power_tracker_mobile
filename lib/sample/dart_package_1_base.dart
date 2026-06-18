// 馬力計算ロジックの最終コードです。このファイルは一切変更しないこと
// 使用する時はこのコードを参考にして、同じロジックで構築してください


import 'dart:math';

// 定数: ギア比 (例: 1速) とタイヤ外径 (メートル)
const double gearRatio = 1.0; // 5速
const double finalGearRatio = 4.1;
const double tireDiameter = 0.625; // 例としてタイヤ外径を設定。単位はメートル。実際の値は車種によって異なる。

// 車両の質量 (kg)
double vehicleMass = 1090.0; // 例として1500kgを設定。

// 駆動効率(割合)
double driveEfficiency = 0.85;


List<Map<String, double>> gpsData = [
  {'speed': 10.0, 'time': 0.0, 'altitude': 0},
  {'speed': 10.0, 'time': 1.0, 'altitude': 0.0},
  {'speed': 17.0, 'time': 2.0, 'altitude': 0},
  {'speed': 35.0, 'time': 3.0, 'altitude': 0},
  {'speed': 45.0, 'time': 4.0, 'altitude': 0},
  {'speed': 65.0, 'time': 5.0, 'altitude': 0},
  {'speed': 85.0, 'time': 6.0, 'altitude': 0},
  {'speed': 105.0, 'time': 7.0, 'altitude': 0},
  {'speed': 80, 'time':8.0, 'altitude': 0},
  {'speed': 90, 'time':11.7, 'altitude': 0}
];




// 仕事量を計算する関数
double calculateWork(List<Map<String, double>> gpsData, double vehicleMass) {
  double totalWork = 0.0;
  double prevSpeed = 0.0;
  double tireRadius = tireDiameter / 2;

  for (var i = 1; i < gpsData.length; i++) {
    double speed1 = gpsData[i - 1]['speed']!;
    double speed2 = gpsData[i]['speed']!;
    double time1 = gpsData[i - 1]['time']!;
    double time2 = gpsData[i]['time']!;
    double deltaTime = time2 - time1;
    double altitude1 = gpsData[i - 1]['altitude']!;
    double altitude2 = gpsData[i]['altitude']!;

    // // 平均速度
    double avgSpeedKmh = (speed1 + speed2) / 2;
    // // 秒速変換
    double avgSpeedms = avgSpeedKmh * 1000 / 3600;


    // // 加速度の計算（単純化のため、平均加速度を用いる）
    double acceleration = (speed2 * 1000 / 3600 - speed1*1000/3600) / deltaTime;

    // // 移動距離の計算
    double distance = avgSpeedms * deltaTime;

    //　位置エネルギーの計算
    double potentialEnergy = calculatePotentialEnergy(vehicleMass, altitude1, altitude2);


    // エンジン出力による仕事量を推定
    // double engineWork = vehicleMass * acceleration * distance; //これはあくまでエンジンの仕事量の一部の近似値

    double engineWork = vehicleMass * pow(speed2 * 1000 / 3600, 2) / 19.6 / driveEfficiency - vehicleMass * pow(speed1 * 1000 / 3600, 2) / 19.6;  
    
    int rpm = (speed2*1000/60 / (pi*tireDiameter) * finalGearRatio * gearRatio).toInt();

    totalWork += engineWork+potentialEnergy;
    print("区間馬力：${calculateHorsepower(engineWork + potentialEnergy, deltaTime)} 回転数（rpm）: $rpm");
  }
  return totalWork;
}

// 仕事量から馬力を計算する関数
double calculateHorsepower(double work, double time) {
  // const double wattsToHorsepower = 735.5; // ワットから馬力への換算係数
  const double wattsToHorsepower = 75; 
  double power = work / time;
  return power / wattsToHorsepower;

}


double calculatePotentialEnergy(double vehicleMass, double altitude1, double altitude2){
  // 位置エネルギー計算
  double potentialEnergy = vehicleMass * 9.8 * (altitude2-altitude1);
  return potentialEnergy;
}



double calculateWorkBetweenGps(Map<String, double> beforeGpsData,Map<String, double> afterGpsData, double vehicleMass) {
  double prevSpeed = 0.0;
  double tireRadius = tireDiameter / 2;

  double speed1 = beforeGpsData['speed']!;
  double speed2 = afterGpsData['speed']!;
  double time1 = beforeGpsData['time']!;
  double time2 = afterGpsData['time']!;
  double deltaTime = time2 - time1;

  // 平均速度
  double avgSpeed = (speed1 + speed2) / 2;

  // 加速度の計算（単純化のため、平均加速度を用いる）
  double acceleration = (speed2 - speed1) / deltaTime;

  // 移動距離の計算
  double distance = avgSpeed * deltaTime;


  // エンジン出力による仕事量を推定（ギア比とタイヤ外径を考慮）
  double engineWork = vehicleMass * acceleration * distance; //これはあくまでエンジンの仕事量の一部の近似値

  return engineWork;
}


