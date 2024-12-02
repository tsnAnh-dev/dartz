part of dartz;

// Prestacked Future<Either<E, Reader<R> + Writer<W> + State<S>>> monad.
// Binds are stack safe but relatively expensive, because of Future chaining.

class Evaluation<E, R, W, S, A>
    implements MonadOps<Evaluation<E, R, W, S, dynamic>, A> {
  final Monoid<W> _W;
  final Function2<R, S, Future<Either<E, Tuple3<W, S, A>>>> _run;

  Evaluation(this._W, this._run);

  Evaluation<E, R, W, S, B> pure<B>(B b) =>
      Evaluation(_W, (r, s) => Future.value(Right(Tuple3(_W.zero(), s, b))));

  Evaluation<E, R, W, S, B> map<B>(B f(A a)) => Evaluation(
      _W,
      (r, s) => run(r, s).then((leftOrRight) =>
          leftOrRight.map((t) => Tuple3(t.value1, t.value2, f(t.value3)))));

  Evaluation<E, R, W, S, B> bind<B>(Function1<A, Evaluation<E, R, W, S, B>> f) {
    return Evaluation(_W, (r, s) {
      return Future.microtask(() {
        return run(r, s).then((leftOrRight) {
          return leftOrRight.fold(
              ifLeft: (e) => Future.value(Left(e)),
              ifRight: (t) {
                final w1 = t.value1;
                final s2 = t.value2;
                final a = t.value3;
                return f(a).run(r, s2).then((leftOrRight2) {
                  return leftOrRight2.map((t2) {
                    final w2 = t2.value1;
                    final s3 = t2.value2;
                    final b = t2.value3;
                    return Tuple3(_W.append(w1, w2), s3, b);
                  });
                });
              });
        });
      });
    });
  }

  Evaluation<E, R, W, S, B> flatMap<B>(
          Function1<A, Evaluation<E, R, W, S, B>> f) =>
      bind(f);

  Evaluation<E, R, W, S, A> handleError(
      Evaluation<E, R, W, S, A> onError(E err)) {
    return Evaluation(_W, (R r, S s) {
      return run(r, s).then((e) {
        return e.fold(
          ifLeft: (l) => onError(l).run(r, s),
          ifRight: (r) => Future.value(right(r)),
        );
      });
    });
  }

  Evaluation<E, R, W, S, B> andThen<B>(Evaluation<E, R, W, S, B> next) =>
      bind((_) => next);

  Future<Either<E, Tuple3<W, S, A>>> run(R r, S s) => _run(r, s);

  Future<Either<E, W>> written(R r, S s) =>
      run(r, s).then((e) => e.map((t) => t.value1));

  Future<Either<E, S>> state(R r, S s) =>
      run(r, s).then((e) => e.map((t) => t.value2));

  Future<Either<E, A>> value(R r, S s) =>
      run(r, s).then((e) => e.map((t) => t.value3));

  @override
  Evaluation<E, R, W, S, B> replace<B>(B replacement) =>
      map((_) => replacement);

  Evaluation<E, R, W, S, Unit> replicate_(int n) =>
      n > 0 ? flatMap((_) => replicate_(n - 1)) : pure(unit);

  @override
  Evaluation<E, R, W, S, Tuple2<B, A>> strengthL<B>(B b) =>
      map((a) => tuple2(b, a));

  @override
  Evaluation<E, R, W, S, Tuple2<A, B>> strengthR<B>(B b) =>
      map((a) => tuple2(a, b));

  @override
  Evaluation<E, R, W, S, B> ap<B>(Evaluation<E, R, W, S, Function1<A, B>> ff) =>
      ff.bind((f) => map(f)); // TODO: optimize
}

class EvaluationMonad<E, R, W, S> extends Object
    with
        Functor<Evaluation<E, R, W, S, dynamic>>,
        Applicative<Evaluation<E, R, W, S, dynamic>>,
        Monad<Evaluation<E, R, W, S, dynamic>> {
  final Monoid<W> _W;

  EvaluationMonad(this._W);

  @override
  Evaluation<E, R, W, S, B> map<A, B>(
          covariant Evaluation<E, R, W, S, A> fa, covariant B f(A a)) =>
      fa.map(f);

  @override
  Evaluation<E, R, W, S, B> bind<A, B>(covariant Evaluation<E, R, W, S, A> fa,
          covariant Function1<A, Evaluation<E, R, W, S, B>> f) =>
      fa.bind(f);

  @override
  Evaluation<E, R, W, S, A> pure<A>(A a) => Evaluation(_W, (r, s) {
        return Future.value(Right(Tuple3(_W.zero(), s, a)));
      });

  Evaluation<E, R, W, S, A> liftFuture<A>(Future<A> fut) =>
      Evaluation(_W, (r, s) {
        return fut.then((ta) => Right(Tuple3(_W.zero(), s, ta)));
      });

  Evaluation<E, R, W, S, A> liftEither<A>(Either<E, A> either) =>
      either.fold(ifLeft: raiseError, ifRight: pure);

  Evaluation<E, R, W, S, A> liftOption<A>(Option<A> oa, E ifNone()) =>
      liftEither(oa.toEither(ifNone));

  Evaluation<E, R, W, S, S> get() =>
      Evaluation(_W, (r, s) => Future.value(Right(Tuple3(_W.zero(), s, s))));

  Evaluation<E, R, W, S, A> gets<A>(A f(S s)) =>
      Evaluation(_W, (r, s) => Future.value(Right(Tuple3(_W.zero(), s, f(s)))));

  Evaluation<E, R, W, S, Unit> put(S s) =>
      Evaluation(_W, (r, _) => Future.value(Right(Tuple3(_W.zero(), s, unit))));

  Evaluation<E, R, W, S, Unit> modify(S f(S s)) => Evaluation(
      _W, (r, s) => Future.value(Right(Tuple3(_W.zero(), f(s), unit))));

  Evaluation<E, R, W, S, Unit> modifyE(Either<E, S> f(S s)) => Evaluation(_W,
      (r, s) => Future.value(f(s).map((s2) => Tuple3(_W.zero(), s2, unit))));

  Evaluation<E, R, W, S, Unit> write(W w) =>
      Evaluation(_W, (_, s) => Future.value(Right(Tuple3(w, s, unit))));

  Evaluation<E, R, W, S, R> ask() =>
      Evaluation(_W, (r, s) => Future.value(Right(Tuple3(_W.zero(), s, r))));

  Evaluation<E, R, W, S, A> asks<A>(A f(R r)) => ask().map(f);

  Evaluation<E, R, W, S, A> local<A>(R f(R r), Evaluation<E, R, W, S, A> fa) =>
      Evaluation(_W, (r, s) => fa.run(f(r), s));

  Evaluation<E, R, W, S, A> scope<A>(R scopedR, Evaluation<E, R, W, S, A> fa) =>
      Evaluation(_W, (_, s) => fa.run(scopedR, s));

  Evaluation<E, R, W, S, A> raiseError<A>(E err) =>
      Evaluation(_W, (r, s) => Future.value(Left(err)));

  Evaluation<E, R, W, S, A> handleError<A>(Evaluation<E, R, W, S, A> ev,
          Evaluation<E, R, W, S, A> onError(E e)) =>
      ev.handleError(onError);
}
