part of dartz;

final class Unit {
  const Unit._internal();
  @override String toString() => "()";
}

const Unit unit = const Unit._internal();

final class UnitMonoid extends Monoid<Unit> {
  @override Unit zero() => unit;

  @override Unit append(Unit u1, Unit u2) => unit;
}

final Monoid<Unit> UnitMi = UnitMonoid();
