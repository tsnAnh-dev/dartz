//import 'package:test/test.dart';
//import 'package:dart3z/dart3z.dart';
//import 'laws.dart';

void main() {
  /*
  final Monad<Either<String, IList>> M = EitherM.composeM(IListMP, IListTr) as Monad<Either<String, IList>>;

  group("Monad composition", () {
    test("succeed", () {
      expect(M.bind(M.pure("hello"), (a) => M.bind(right(ilist(["functor", "applicative", "monad"])), (b) => M.map(M.pure(b + "!"), (c) => a+" "+c))),
          right(ilist(["hello functor!", "hello applicative!", "hello monad!"])));
    });

    test("fail", () {
      expect(M.bind(M.pure("hello"), (a) => M.bind(right(ilist(["functor", "applicative", "monad"])), (b) => M.map(left("out of exclamation marks..."), (c) => a+" "+c))),
          left("out of exclamation marks..."));
    });

    group("EitherM composed with IListM/IListTr", () => checkMonadLaws(M));
  });
  */
}