part of dartz;

// TODO: unify with Free?

abstract class Trampoline<A> implements MonadOps<Trampoline, A> {
  Trampoline<B> pure<B>(B b) => _TPure(b);
  @override Trampoline<B> map<B>(B f(A a)) => bind((a) => pure(f(a)));
  @override Trampoline<B> bind<B>(Function1<A, Trampoline<B>> f) => _TBind<B, A>(this, cast(f));

  @override Trampoline<Tuple2<B, A>> strengthL<B>(B b) => map((a) => tuple2(b, a));

  @override Trampoline<Tuple2<A, B>> strengthR<B>(B b) => map((a) => tuple2(a, b));

  A run() {
    _TBind? current = cast(_unsafeGetTBind());
    if (current == null) {
      return _unsafeGetTPure()!._a;
    }
    while(true) {
      final fa = current!._fa;
      final f = current._f;
      final fabind = fa._unsafeGetTBind();
      if (fabind != null) {
        final fa2 = fabind._fa;
        final f2 = fabind._f;
        current = _TBind(cast(fa2), (a2) => _TBind(f2(a2), f));
      } else {
        final res = f(cast(fa._unsafeGetTPure()!._a));
        current = res._unsafeGetTBind();
        if (current == null) {
          return cast(res._unsafeGetTPure()!._a);
        }
      }
    }
  }

  @override Trampoline<B> andThen<B>(Trampoline<B> next) => bind((_) => next);

  @override Trampoline<B> ap<B>(Trampoline<Function1<A, B>> ff) => ff.bind((f) => map(f)); // TODO: optimize

  @override Trampoline<B> flatMap<B>(Function1<A, Trampoline<B>> f) => _TBind(this, cast(f));

  @override Trampoline<B> replace<B>(B replacement) => map((_) => replacement);

  _TPure<A>? _unsafeGetTPure();

  _TBind<A, dynamic>? _unsafeGetTBind();
}

class _TPure<A> extends Trampoline<A> {
  final A _a;
  _TPure(this._a);

  @override _TPure<A>? _unsafeGetTPure() => this;
  _TBind<A, dynamic>? _unsafeGetTBind() => null;
}

class _TBind<A, B> extends Trampoline<A> {
  final Trampoline<B> _fa;
  final Function1<dynamic, Trampoline<dynamic>> _f;
  _TBind(this._fa, this._f);

  _TPure<A>? _unsafeGetTPure() => null;
  _TBind<A, B>? _unsafeGetTBind() => this;
}

final Monad<Trampoline> TrampolineM = MonadOpsMonad((a) => _TPure(a));

Trampoline<T> treturn<T>(T t) => _TPure(t);

final Trampoline<Unit> tunit = _TPure(unit);
Trampoline<T> tcall<T>(Function0<Trampoline<T>> thunk) => _TBind(cast(tunit), (_) => cast(thunk()));
