part of dartz_streaming;

enum BothDirection { LEFT, RIGHT }

class Both<L, R> {
  final BothDirection direction;

  const Both(this.direction);
}

class Tee {
  //static final Both _getL = Both();
  //static final Both _getR = Both();

  static Conveyor<Both<L, R>, O> produce<L, R, O>(O h,
          [Conveyor<Both<L, R>, O>? t]) =>
      Conveyor.produce(h, t);

  static Conveyor<Both<L, R>, O> consumeL<L, R, O>(
          Function1<L, Conveyor<Both<L, R>, O>> recv,
          [Function0<Conveyor<Both<L, R>, O>>? fallback]) =>
      Conveyor.consume(
          Both(BothDirection.LEFT),
          (Either<Object, L> ea) => ea.fold(
              ifLeft: (err) => err == Conveyor.End
                  ? (fallback == null ? halt() : fallback())
                  : Conveyor.halt(err),
              ifRight: (L l) => Conveyor.Try(() => recv(l))));

  static Conveyor<Both<L, R>, O> consumeR<L, R, O>(
          Function1<R, Conveyor<Both<L, R>, O>> recv,
          [Function0<Conveyor<Both<L, R>, O>>? fallback]) =>
      Conveyor.consume(
          Both(BothDirection.RIGHT),
          (Either<Object, R> ea) => ea.fold(
              ifLeft: (err) => err == Conveyor.End
                  ? (fallback == null ? halt() : fallback())
                  : Conveyor.halt(err),
              ifRight: (R r) => Conveyor.Try(() => recv(r))));

  static Conveyor<Both<L, R>, O> halt<L, R, O>() => Conveyor.halt(Conveyor.End);

  static Conveyor<Both<L, R>, O> zipWith<L, R, O>(Function2<L, R, O> f) =>
      consumeL<L, R, O>((L l) => consumeR((R r) => produce(f(l, r))))
          .repeatUntilExhausted();

  static Conveyor<Both<L, R>, Tuple2<L, R>> zip<L, R>() => zipWith(tuple2);

  static Conveyor<Both<I, I>, I> interleave<I>() =>
      consumeL<I, I, I>((I i1) => consumeR((I i2) => produce(i1, produce(i2))))
          .repeatUntilExhausted();
}
