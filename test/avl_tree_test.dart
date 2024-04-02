import 'package:test/test.dart';
//import 'package:enumerators/combinators.dart' as c;
import 'combinators_stubs.dart' as c;
//import 'package:propcheck/propcheck.dart';
import 'propcheck_stubs.dart';
import 'package:dart3z/dartz.dart';
import 'laws.dart';

void main() {
  final qc = QuickCheck(maxSize: 300, seed: 42);
  final intTrees = c.listsOf(c.ints).map((l) =>  AVLTree.fromIList(NumOrder, ilist(l)));

  test("min", () {
    qc.check(forall(intTrees,
        (AVLTree<num> t) => t.concatenateO(NumMinSi) == t.min()));
  });

  test("max", () {
    qc.check(forall(intTrees,
        (AVLTree<num> t) => t.concatenateO(NumMaxSi) == t.max()));
  });

  test("demo", () {
    final AVLTree<num> t = AVLTree<num>.fromIList(NumOrder, ilist([5,1,6,7,3,6]));
    expect(t.get(3), some(3));
    expect(t.get(4), none());
    expect(t.toIList(), ilist([1,3,5,6,7]));
  });

  group("AVLTreeMonoid", () => checkMonoidLaws(AVLTreeMonoid(NumOrder), intTrees));

  group("AVLTreeFo", () => checkFoldableLaws(AVLTreeFo, intTrees));

  group("equality", () {
    test("equality", () {
      qc.check(forall2(intTrees, intTrees,
          (AVLTree<num> t1, AVLTree<num> t2) =>
          (t1 == t1) &&
              (t2 == t2) &&
              (t1.insert((t1.max()|0) + 1) != t1) &&
              ((t1 == t2) == (t1.toString() == t2.toString()))));
    });
  });

  group("AVLTree FoldableOps", () => checkFoldableOpsProperties(intTrees));

  test("iterable", () => qc.check(forall(intTrees, (AVLTree<num> t) => t.toIList() == ilist(t.toIterable()))));

  test("isEmpty", () => qc.check(forall(intTrees, (AVLTree<num> t) => (t.length() == 0) == t.isEmpty)));
}