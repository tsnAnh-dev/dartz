import 'package:test/test.dart';
import 'package:dart3z/dartz.dart';
import 'laws.dart';

void main() {
  test("demo", () {
    final M = stateM<num>();
    final State st = M.pure("hej");
    final State inc = M.modify((n) => n+1);
    expect((inc.andThen(inc).andThen(st)).map((v) => "$v!").run(5), tuple2("hej!", 7));
  });

  group("StateM", () => checkMonadLaws(StateM, equality: (a, b) => a.run(0) == b.run(0)));

  //group("StateTMonad+Id", () => checkMonadLaws(StateTMonad(IdM), equality: (a, b) => a.run(0) == b.run(0)));

  //group("StateTMonad+Trampoline", () => checkMonadLaws(StateTMonad(TrampolineM), equality: (a, b) => a.run(0).run() == b.run(0).run()));

  /*
  test("StateTMonad+Trampoline stack safety", () {
    final StateTMonad<Trampoline, int> M = StateTMonad(TrampolineM);

    final StateT<Trampoline, int, dynamic> inc20k = M.replicate_(20000, M.modify((i) => i+1));
    expect(inc20k.state(17).run(), 20017);
  });
  */
}