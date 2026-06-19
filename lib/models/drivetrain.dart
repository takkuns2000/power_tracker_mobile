enum Drivetrain {
  fwd,
  rwd,
  awd;

  String get label => switch (this) {
        Drivetrain.fwd => 'FWD',
        Drivetrain.rwd => 'RWD',
        Drivetrain.awd => 'AWD',
      };
}
