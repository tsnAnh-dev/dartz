part of dartz;

abstract mixin class TraversableMonad<F> implements Traversable<F>, Monad<F> {
  //G traverseM<G>(Applicative<G> gApplicative, F fa, G /** really G<F<A>> **/ f(a)) => gApplicative.map(traverse(gApplicative, fa, f), (F ffb) => join(ffb));
}

abstract mixin class TraversableMonadOps<F, A> implements TraversableOps<F, A>, MonadOps<F, A> {
  //G traverseM<G>(Applicative<G> gApplicative, G /** really G<F<A>> **/ f(A a)) => gApplicative.map(traverse(gApplicative, f), (F ffb) => cast<MonadOps>(ffb).join());
}
