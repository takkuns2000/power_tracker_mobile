enum Drivetrain {
  fwd,
  rwd,
  awd;

  String get label => switch (this) {
        Drivetrain.fwd => 'FWD',
        Drivetrain.rwd => 'RWD',
        Drivetrain.awd => 'AWD',
      };

  /// ドライブトレイン効率 η（損失: FWD=10%, RWD=15%, AWD=20%）
  double get driveEfficiency => switch (this) {
        Drivetrain.fwd => 0.90,
        Drivetrain.rwd => 0.85,
        Drivetrain.awd => 0.80,
      };
}
