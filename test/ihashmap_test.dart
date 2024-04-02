import "package:test/test.dart";
//import 'package:enumerators/combinators.dart' as c;
import 'combinators_stubs.dart' as c;
import 'package:dart3z/dartz.dart';
import 'laws.dart';
//import 'package:propcheck/propcheck.dart';
import 'propcheck_stubs.dart';

void main() {
  final qc = QuickCheck(maxSize: 300, seed: 42);
  final intMaps = c.mapsOf(c.ints, c.ints);
  final intIHashMaps = intMaps.map((m) => IHashMap.from(m));

  test("create from Map", () {
    qc.check(forall(intMaps, (dynamicM) {
      final m = dynamicM;
      final IHashMap<int, int> im = IHashMap.from(m);
      return m.length == im.length() &&  m.keys.every((i) => some(m[i]) == im[i]);
    }));
  });

  test("create from pairs", () => qc.check(forall(intIHashMaps, (dynamicM) {
    final m = dynamicM;
    final mPairs = ivector(m.pairIterable());
    final mFromPairs = IHashMap.fromPairs(mPairs, comparableOrder());
    return m == mFromPairs;
  })));

  test("deletion", () {
    qc.check(forall2(intMaps, intMaps, (dynamicM1, dynamicM2) {
      final m1 = dynamicM1;
      final m2 = dynamicM2;
      final Map<int, int> expected = Map.from(m1);
      m2.keys.forEach((i) => expected.remove(i));
      final actual = m2.keys.fold(IHashMap.from(m1), (IHashMap<int, int> p, k) => p.remove(k));
      return expected.keys.length == actual.length() && expected.keys.every((i) => some(expected[i]) == actual[i]);
    }));
  });

  test("pair iterable", () => qc.check(forall(intIHashMaps, (IHashMap<int, int> m) => m.foldRightKV<IList<Tuple2<int, int>>>(nil<Tuple2<int, int>>(), (k, v, IList<Tuple2<int, int>> p) => cons(tuple2(k, v), p)) == ilist(m.pairIterable()))));

  test("key iterable", () => qc.check(forall(intIHashMaps, (IHashMap<int, int> m) => m.foldRightKV<IList<int>>(nil<int>(), (k, v, IList<int> p) => cons(k, p)) == ilist(m.keyIterable()))));

  test("value iterable", () => qc.check(forall(intIHashMaps, (IHashMap<int, int> m) => m.foldRightKV<IList<int>>(nil<int>(), (k, v, IList<int> p) => cons(v, p)) == ilist(m.valueIterable()))));

  group("IHashMapTr", () => checkTraversableLaws(IHashMapTr, intIHashMaps));

  group("IHashMap FoldableOps", () => checkFoldableOpsProperties(intIHashMaps));
}