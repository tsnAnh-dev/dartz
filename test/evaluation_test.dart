import 'package:test/test.dart';
//import 'package:propcheck/propcheck.dart';
import 'package:dart3z/dartz.dart';
import 'dart:async';
//import 'laws.dart';

void main() {
  //final qc = QuickCheck(maxSize: 300, seed: 42);

  test("demo", () async {
    final EvaluationMonad<String, String, Tuple2<IList<String>, String>, int> M = EvaluationMonad(tuple2Monoid(ilistMi(), StringMi));

    final inc =
        M.get().bind((oldState) {
          final newState = oldState+1;
          return M.put(newState).andThen(M.write(Tuple2(ilist(["State transition from $oldState to $newState"]), "!")));
        });

    final Evaluation p =
        inc.andThen(
          M.pure("hej").bind((v) =>
         inc.andThen(M.get().bind((s) => (s == 7) ? M.asks((suffix) => v + suffix) : M.raiseError("Gaah! State wasn't 7!!!"))))
        ).bind((a) => inc.replace(a));

    expect(await p.run("!", 5), right(tuple3(tuple2(ilist(["State transition from 5 to 6", "State transition from 6 to 7", "State transition from 7 to 8"]), "!!!"), 8, "hej!")));
    expect(await p.run("!", 6), left("Gaah! State wasn't 7!!!"));
  });

  group("EvaluationM", () {
    // TODO: async law checks
    // checkMonadLaws(qc, EvaluationMonad(IListMi));
  });

  test("stack safety", () async {
    final M = EvaluationMonad<Unit, Unit, Unit, int>(UnitMi);
    final deep = M.modify((i) => i+1).replicate_(10000);
    expect(await deep.state(unit, 0), right(10000));
  });

  test("liftFuture", () async {
    final M = EvaluationMonad<Unit, String, Unit, Unit>(UnitMi);

    Future<String> expensiveComputation(String input) => Future(() => input.toUpperCase());

    final ev = M.ask().bind((s) => M.liftFuture(expensiveComputation(s)));

    expect(await ev.value("hello", unit), right("HELLO"));
  });

  test("liftEither", () async {
    final M = EvaluationMonad<String, IList<int>, Unit, Unit>(UnitMi);

    Either<String, int> first(IList<int> l) => l.headOption.toEither(() => "Empty list");

    final ev = M.ask().bind((l) => M.liftEither(first(l)));

    expect(await ev.value(nil(), unit), left("Empty list"));
    expect(await ev.value(ilist([1,2,3]), unit), right(1));
  });

}