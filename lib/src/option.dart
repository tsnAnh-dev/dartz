part of dartz;

abstract class Option<A> implements TraversableMonadPlusOps<Option, A> {
  const Option();

  B fold<B>({required B ifNone(), required B ifSome(A a)});

  B cata<B, B2 extends B>(B ifNone(), B2 ifSome(A a)) =>
      fold(ifNone: ifNone, ifSome: ifSome);

  Option<A> orElse(Option<A> other()) =>
      fold(ifNone: other, ifSome: (_) => this);

  A getOrElse(A dflt()) => fold(ifNone: dflt, ifSome: (a) => a);

  Either<B, A> toEither<B>(B ifNone()) =>
      fold(ifNone: () => left(ifNone()), ifSome: (a) => right(a));

  Either<dynamic, A> operator %(ifNone) => toEither(() => ifNone);
  A operator |(A dflt) => getOrElse(() => dflt);

  @override
  Option<B> map<B>(B f(A a)) => fold(ifNone: none, ifSome: (A a) => some(f(a)));

  @override
  Option<B> ap<B>(Option<Function1<A, B>> ff) => fold(
      ifNone: none,
      ifSome: (A a) =>
          ff.fold(ifNone: none, ifSome: (Function1<A, B> f) => some(f(a))));

  @override
  Option<B> bind<B>(Function1<A, Option<B>> f) => fold(ifNone: none, ifSome: f);

  @override
  Option<B> flatMap<B>(Function1<A, Option<B>> f) =>
      fold(ifNone: none, ifSome: f);

  @override
  Option<B> andThen<B>(Option<B> next) =>
      fold(ifNone: none, ifSome: (_) => next);

  IList<Option<B>> traverseIList<B>(IList<B> f(A a)) =>
      fold(ifNone: () => cons(none(), nil()), ifSome: (a) => f(a).map(some));

  IVector<Option<B>> traverseIVector<B>(IVector<B> f(A a)) => fold(
      ifNone: () => emptyVector<Option<B>>().appendElement(none()),
      ifSome: (a) => f(a).map(some));

  Future<Option<B>> traverseFuture<B>(Future<B> f(A a)) => fold(
      ifNone: () => Future.microtask(none), ifSome: (a) => f(a).then(some));

  State<S, Option<B>> traverseState<S, B>(State<S, B> f(A a)) => fold(
      ifNone: () => State((s) => tuple2(none(), s)),
      ifSome: (a) => f(a).map(some));

  Task<Option<B>> traverseTask<B>(Task<B> f(A a)) =>
      fold(ifNone: () => Task.value(none()), ifSome: (a) => f(a).map(some));

  Free<F, Option<B>> traverseFree<F, B>(Free<F, B> f(A a)) =>
      fold(ifNone: () => Pure(none()), ifSome: (a) => f(a).map(some));

  static IList<Option<A>> sequenceIList<A>(Option<IList<A>> ola) =>
      ola.traverseIList(id);
  static IVector<Option<A>> sequenceIVector<A>(Option<IVector<A>> ova) =>
      ova.traverseIVector(id);
  static Future<Option<A>> sequenceFuture<A>(Option<Future<A>> ofa) =>
      ofa.traverseFuture(id);
  static State<S, Option<A>> sequenceState<S, A>(Option<State<S, A>> osa) =>
      osa.traverseState(id);
  static Task<Option<A>> sequenceTask<A>(Option<Task<A>> ofa) =>
      ofa.traverseTask(id);
  static Free<F, Option<A>> sequenceFree<F, A>(Option<Free<F, A>> ofa) =>
      ofa.traverseFree(id);

  static Option<A> when<A>(bool test, A value) => option(test, value);
  static Option<A> unless<A>(bool test, A value) => option(!test, value);

  @override
  Option<A> plus(Option<A> o2) => orElse(() => o2);

  @override
  Option<A> filter(bool predicate(A a)) =>
      fold(ifNone: none, ifSome: (a) => predicate(a) ? this : none());

  @override
  Option<A> where(bool predicate(A a)) => filter(predicate);

  @override
  bool all(bool f(A a)) => map(f) | true;

  @override
  bool every(bool f(A a)) => all(f);

  @override
  bool any(bool f(A a)) => map(f) | false;

  @override
  Option<A> appendElement(A a) => orElse(() => some(a));

  @override
  A concatenate(Monoid<A> mi) => getOrElse(mi.zero);

  @override
  Option<A> concatenateO(Semigroup<A> si) => this;

  @override
  B foldLeft<B>(B z, B f(B previous, A a)) =>
      fold(ifNone: () => z, ifSome: (a) => f(z, a));

  @override
  B foldLeftWithIndex<B>(B z, B f(B previous, int i, A a)) =>
      fold(ifNone: () => z, ifSome: (a) => f(z, 0, a));

  @override
  B foldMap<B>(Monoid<B> bMonoid, B f(A a)) =>
      fold(ifNone: bMonoid.zero, ifSome: f);

  @override
  Option<B> foldMapO<B>(Semigroup<B> si, B f(A a)) => map(f);

  @override
  B foldRight<B>(B z, B f(A a, B previous)) =>
      fold(ifNone: () => z, ifSome: (a) => f(a, z));

  @override
  B foldRightWithIndex<B>(B z, B f(int i, A a, B previous)) =>
      fold(ifNone: () => z, ifSome: (a) => f(0, a, z));

  @override
  A intercalate(Monoid<A> mi, A a) => fold(ifNone: mi.zero, ifSome: id);

  @override
  int length() => fold(ifNone: () => 0, ifSome: (_) => 1);

  @override
  Option<B> mapWithIndex<B>(B f(int i, A a)) => map((a) => f(0, a));

  @override
  Option<A> maximum(Order<A> oa) => this;

  @override
  Option<A> minimum(Order<A> oa) => this;

  Tuple2<Option<A>, Option<A>> partition(bool f(A a)) =>
      map(f) | false ? tuple2(this, none()) : tuple2(none(), this);

  @override
  Option<A> prependElement(A a) => some(a).orElse(() => this);

  @override
  Option<B> replace<B>(B replacement) => map((_) => replacement);

  Option<A> reverse() => this;

  @override
  Option<Tuple2<B, A>> strengthL<B>(B b) => map((a) => tuple2(b, a));

  @override
  Option<Tuple2<A, B>> strengthR<B>(B b) => map((a) => tuple2(a, b));

  @override
  Option<Tuple2<int, A>> zipWithIndex() => map((a) => tuple2(0, a));

  bool isSome() => fold(ifNone: () => false, ifSome: (_) => true);

  bool isNone() => !isSome();

  static Option<C> map2<A, A2 extends A, B, B2 extends B, C>(
          Option<A2> fa, Option<B2> fb, C fun(A a, B b)) =>
      fa.fold(
          ifNone: none,
          ifSome: (a) => fb.fold(ifNone: none, ifSome: (b) => some(fun(a, b))));

  static Option<D> map3<A, A2 extends A, B, B2 extends B, C, C2 extends C, D>(
          Option<A2> fa, Option<B2> fb, Option<C2> fc, D fun(A a, B b, C c)) =>
      fa.fold(
          ifNone: none,
          ifSome: (a) => fb.fold(
              ifNone: none,
              ifSome: (b) =>
                  fc.fold(ifNone: none, ifSome: (c) => some(fun(a, b, c)))));

  static Option<E> map4<A, A2 extends A, B, B2 extends B, C, C2 extends C, D,
              D2 extends D, E>(Option<A2> fa, Option<B2> fb, Option<C2> fc,
          Option<D2> fd, E fun(A a, B b, C c, D d)) =>
      fa.fold(
          ifNone: none,
          ifSome: (a) => fb.fold(
              ifNone: none,
              ifSome: (b) => fc.fold(
                  ifNone: none,
                  ifSome: (c) => fd.fold(
                      ifNone: none, ifSome: (d) => some(fun(a, b, c, d))))));

// Continue with map5-map20 similarly...

  static Option<C> mapM2<A, A2 extends A, B, B2 extends B, C>(
          Option<A2> fa, Option<B2> fb, Option<C> f(A a, B b)) =>
      fa.bind((a) => fb.bind((b) => f(a, b)));

  static Function1<Option<A>, Option<B>> lift<A, B>(B f(A a)) =>
      ((Option<A> oa) => oa.map(f));
  static Function2<Option<A>, Option<B>, Option<C>> lift2<A, B, C>(
          C f(A a, B b)) =>
      (Option<A> fa, Option<B> fb) => map2(fa, fb, f);
  static Function3<Option<A>, Option<B>, Option<C>, Option<D>>
      lift3<A, B, C, D>(D f(A a, B b, C c)) =>
          (Option<A> fa, Option<B> fb, Option<C> fc) => map3(fa, fb, fc, f);
// Continue with lift4-lift20...

  @override
  String toString() => fold(ifNone: () => 'None', ifSome: (a) => 'Some($a)');

// PURISTS BEWARE: side effecty stuff below -- proceed with caution!

  Iterable<A> toIterable() => fold(
      ifNone: () => const Iterable.empty(),
      ifSome: (a) => _SingletonIterable(a));

  Iterator<A> iterator() => toIterable().iterator;

  void forEach(void sideEffect(A a)) =>
      fold(ifNone: () => null, ifSome: sideEffect);

  A? toNullable() => fold(ifNone: () => null, ifSome: id);
}

class Some<A> extends Option<A> {
  final A _a;
  const Some(this._a);
  A get value => _a;
  @override
  B fold<B>({required B ifNone(), required B ifSome(A a)}) => ifSome(_a);
  @override
  bool operator ==(other) => other is Some && other._a == _a;
  @override
  int get hashCode => _a.hashCode;
}

class None<A> extends Option<A> {
  const None();
  @override
  B fold<B>({required B ifNone(), required B ifSome(A a)}) => ifNone();
  @override
  bool operator ==(other) => other is None;
  @override
  int get hashCode => 0;
}

Option<A> none<A>() => None();
Option<A> some<A>(A a) => Some(a);
Option<A> option<A>(bool test, A value) => test ? some(value) : none();
Option<A> optionOf<A>(A? value) => value != null ? some(value) : none();

class OptionMonadPlus extends MonadPlus<Option>
    with
        Monad<Option>,
        ApplicativePlus<Option>,
        Applicative<Option>,
        Functor<Option>,
        PlusEmpty<Option>,
        Plus<Option> {
  @override
  Option<B> map<A, B>(covariant Option<A> fa, B f(A a)) => fa.map(f);
  @override
  Option<B> ap<A, B>(
          covariant Option<A> fa, covariant Option<Function1<A, B>> ff) =>
      fa.ap(ff);
  @override
  Option<B> bind<A, B>(
          covariant Option<A> fa, covariant Function1<A, Option<B>> f) =>
      fa.bind(f);
  @override
  Option<A> empty<A>() => none();
  @override
  Option<A> plus<A>(covariant Option<A> f1, covariant Option<A> f2) =>
      f1.plus(f2);
  @override
  Option<A> pure<A>(A a) => some(a);
}

class OptionTraversable extends Traversable<Option> {
  @override
  B foldMap<A, B>(Monoid<B> bMonoid, covariant Option<A> fa, B f(A a)) =>
      fa.foldMap(bMonoid, f);
  @override
  Option<B> map<A, B>(covariant Option<A> fa, B f(A a)) => fa.map(f);
}

class OptionMonoid<A> extends Monoid<Option<A>> {
  final Semigroup<A> _tSemigroup;

  OptionMonoid(this._tSemigroup);

  @override
  Option<A> zero() => none();

  @override
  Option<A> append(Option<A> oa1, Option<A> oa2) => oa1.fold(
      ifNone: () => oa2,
      ifSome: (a1) => oa2.fold(
          ifNone: () => oa1, ifSome: (a2) => some(_tSemigroup.append(a1, a2))));
}

Monoid<Option<A>> optionMi<A>(Semigroup<A> si) => OptionMonoid(si);

class _SingletonIterable<A> extends Iterable<A> {
  final A _singleton;
  _SingletonIterable(this._singleton);
  @override
  Iterator<A> get iterator => _SingletonIterator(_singleton);
}

class _SingletonIterator<A> implements Iterator<A> {
  final A _singleton;
  int _moves = 0;
  _SingletonIterator(this._singleton);
  @override
  A get current =>
      _moves == 1 ? _singleton : null!; // ignore: null_check_always_fails
  @override
  bool moveNext() => ++_moves == 1;
}
