part of dartz;

class ISet<A> extends FoldableOps<ISet, A> {
  final AVLTree<A> _tree;

  ISet(this._tree);
  factory ISet.emptyWithOrder(Order<A> order) => new ISet(new AVLTree<A>(order, emptyAVLNode()));
  factory ISet.empty() => new ISet<A>.emptyWithOrder(comparableOrder());
  factory ISet.fromFoldableWithOrder(Order<A> order, Foldable foldable, fa) => foldable.foldLeft(fa, new ISet.emptyWithOrder(order), (p, a) => p.insert(a as dynamic/*=A*/));
  factory ISet.fromFoldable(Foldable foldable, fa) => new ISet<A>.fromFoldableWithOrder(comparableOrder(), foldable, fa);
  factory ISet.fromIListWithOrder(Order<A> order, IList<A> l) => new ISet.fromFoldableWithOrder(order, IListTr, l);
  factory ISet.fromIList(IList<A> l) => new ISet<A>.fromIListWithOrder(comparableOrder(), l);

  @override /*=B*/ foldMap/*<B>*/(Monoid/*<B>*/ bMonoid, /*=B*/ f(A a)) => _tree.foldMap(bMonoid, f);
  @override /*=B*/ foldLeft/*<B>*/(/*=B*/ z, /*=B*/ f(/*=B*/ previous, A a)) => _tree.foldLeft(z, f);
  @override /*=B*/ foldRight/*<B>*/(/*=B*/ z, /*=B*/ f(A a, /*=B*/ previous)) => _tree.foldRight(z, f);

  ISet<A> insert(A a) => new ISet(_tree.insert(a));

  ISet<A> remove(A a) => new ISet(_tree.remove(a));

  bool contains(A a) => _tree.get(a) != none();

  ISet<A> union(ISet<A> other) => other._tree.foldLeft(this, (ISet<A> p, A a) => p.insert(a));
  ISet<A> operator |(ISet<A> other) => union(other);
  ISet<A> operator +(ISet<A> other) => union(other);

  ISet<A> intersection(ISet<A> other) => other._tree.foldLeft(new ISet<A>.emptyWithOrder(_tree._order), (ISet<A> p, A a) => contains(a) ? p.insert(a) : p);
  ISet<A> operator &(ISet<A> other) => intersection(other);

  ISet<A> difference(ISet<A> other) => other._tree.foldLeft(this, (ISet<A> p, A a) => p.remove(a));
  ISet<A> operator -(ISet<A> other) => difference(other);

  IList<A> toIList() => _tree.toIList();

  @override bool operator ==(other) => identical(this, other) || (other is ISet && _tree == other._tree);

  @override String toString() => "iset<${_tree.toIList().map((a) => a.toString()).intercalate(StringMi, ", ")}>";
}

final Foldable<ISet> ISetFo = new FoldableOpsFoldable<ISet>();

ISet/*<A>*/ iset/*<A>*/(Iterable/*<A>*/ l) => new ISet.fromIList(ilist(l));

class ISetMonoid<A> extends Monoid<ISet<A>> {
  final Order<A> _aOrder;

  ISetMonoid(this._aOrder);

  @override ISet<A> zero() => new ISet<A>.emptyWithOrder(_aOrder);
  @override ISet<A> append(ISet<A> a1, ISet<A> a2) => a1.union(a2);
}

Monoid<ISet/*<A>*/> isetMi/*<A>*/(Order/*<A>*/ o) => new ISetMonoid/*<A>*/(o);
