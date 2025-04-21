import 'package:hooks_riverpod/hooks_riverpod.dart';

/// An extension that groups some [AsyncValue]s into a single [AsyncValue].
extension AsyncValueGroup on AsyncValue<dynamic> {
  static AsyncValue<(T1, T2)> group2<T1, T2>(
    AsyncValue<T1> t1,
    AsyncValue<T2> t2,
  ) {
    if (t1 is AsyncLoading || t2 is AsyncLoading) {
      return const AsyncLoading();
    }
    try {
      return AsyncData((t1.value as T1, t2.value as T2));
    } on Exception catch (e, st) {
      return AsyncError(e, st);
    }
  }

  static AsyncValue<(T1, T2, T3)> group3<T1, T2, T3>(
    AsyncValue<T1> t1,
    AsyncValue<T2> t2,
    AsyncValue<T3> t3,
  ) {
    if (t1 is AsyncLoading || t2 is AsyncLoading || t3 is AsyncLoading) {
      return const AsyncLoading();
    }
    try {
      return AsyncData((t1.value as T1, t2.value as T2, t3.value as T3));
    } on Exception catch (e, st) {
      return AsyncError(e, st);
    }
  }

  static AsyncValue<(T1, T2, T3, T4)> group4<T1, T2, T3, T4>(
    AsyncValue<T1> t1,
    AsyncValue<T2> t2,
    AsyncValue<T3> t3,
    AsyncValue<T4> t4,
  ) {
    if (t1 is AsyncLoading ||
        t2 is AsyncLoading ||
        t3 is AsyncLoading ||
        t4 is AsyncLoading) {
      return const AsyncLoading();
    }
    try {
      return AsyncData(
        (t1.value as T1, t2.value as T2, t3.value as T3, t4.value as T4),
      );
    } on Exception catch (e, st) {
      return AsyncError(e, st);
    }
  }

  static AsyncValue<(T1, T2, T3, T4, T5)> group5<T1, T2, T3, T4, T5>(
    AsyncValue<T1> t1,
    AsyncValue<T2> t2,
    AsyncValue<T3> t3,
    AsyncValue<T4> t4,
    AsyncValue<T5> t5,
  ) {
    if (t1 is AsyncLoading ||
        t2 is AsyncLoading ||
        t3 is AsyncLoading ||
        t4 is AsyncLoading ||
        t5 is AsyncLoading) {
      return const AsyncLoading();
    }
    try {
      return AsyncData(
        (
          t1.value as T1,
          t2.value as T2,
          t3.value as T3,
          t4.value as T4,
          t5.value as T5,
        ),
      );
    } on Exception catch (e, st) {
      return AsyncError(e, st);
    }
  }

  static AsyncValue<(T1, T2, T3, T4, T5, T6)> group6<T1, T2, T3, T4, T5, T6>(
    AsyncValue<T1> t1,
    AsyncValue<T2> t2,
    AsyncValue<T3> t3,
    AsyncValue<T4> t4,
    AsyncValue<T5> t5,
    AsyncValue<T6> t6,
  ) {
    if (t1 is AsyncLoading ||
        t2 is AsyncLoading ||
        t3 is AsyncLoading ||
        t4 is AsyncLoading ||
        t5 is AsyncLoading ||
        t6 is AsyncLoading) {
      return const AsyncLoading();
    }
    try {
      return AsyncData(
        (
          t1.value as T1,
          t2.value as T2,
          t3.value as T3,
          t4.value as T4,
          t5.value as T5,
          t6.value as T6,
        ),
      );
    } on Exception catch (e, st) {
      return AsyncError(e, st);
    }
  }

  static AsyncValue<(T1, T2, T3, T4, T5, T6, T7)>
      group7<T1, T2, T3, T4, T5, T6, T7>(
    AsyncValue<T1> t1,
    AsyncValue<T2> t2,
    AsyncValue<T3> t3,
    AsyncValue<T4> t4,
    AsyncValue<T5> t5,
    AsyncValue<T6> t6,
    AsyncValue<T7> t7,
  ) {
    if (t1 is AsyncLoading ||
        t2 is AsyncLoading ||
        t3 is AsyncLoading ||
        t4 is AsyncLoading ||
        t5 is AsyncLoading ||
        t6 is AsyncLoading ||
        t7 is AsyncLoading) {
      return const AsyncLoading();
    }
    try {
      return AsyncData(
        (
          t1.value as T1,
          t2.value as T2,
          t3.value as T3,
          t4.value as T4,
          t5.value as T5,
          t6.value as T6,
          t7.value as T7,
        ),
      );
    } on Exception catch (e, st) {
      return AsyncError(e, st);
    }
  }

  static AsyncValue<(T1, T2, T3, T4, T5, T6, T7, T8)>
      group8<T1, T2, T3, T4, T5, T6, T7, T8>(
    AsyncValue<T1> t1,
    AsyncValue<T2> t2,
    AsyncValue<T3> t3,
    AsyncValue<T4> t4,
    AsyncValue<T5> t5,
    AsyncValue<T6> t6,
    AsyncValue<T7> t7,
    AsyncValue<T8> t8,
  ) {
    if (t1 is AsyncLoading ||
        t2 is AsyncLoading ||
        t3 is AsyncLoading ||
        t4 is AsyncLoading ||
        t5 is AsyncLoading ||
        t6 is AsyncLoading ||
        t7 is AsyncLoading ||
        t8 is AsyncLoading) {
      return const AsyncLoading();
    }
    try {
      return AsyncData(
        (
          t1.value as T1,
          t2.value as T2,
          t3.value as T3,
          t4.value as T4,
          t5.value as T5,
          t6.value as T6,
          t7.value as T7,
          t8.value as T8,
        ),
      );
    } on Exception catch (e, st) {
      return AsyncError(e, st);
    }
  }

  static AsyncValue<(T1, T2, T3, T4, T5, T6, T7, T8, T9)>
      group9<T1, T2, T3, T4, T5, T6, T7, T8, T9>(
    AsyncValue<T1> t1,
    AsyncValue<T2> t2,
    AsyncValue<T3> t3,
    AsyncValue<T4> t4,
    AsyncValue<T5> t5,
    AsyncValue<T6> t6,
    AsyncValue<T7> t7,
    AsyncValue<T8> t8,
    AsyncValue<T9> t9,
  ) {
    if (t1 is AsyncLoading ||
        t2 is AsyncLoading ||
        t3 is AsyncLoading ||
        t4 is AsyncLoading ||
        t5 is AsyncLoading ||
        t6 is AsyncLoading ||
        t7 is AsyncLoading ||
        t8 is AsyncLoading ||
        t9 is AsyncLoading) {
      return const AsyncLoading();
    }
    try {
      return AsyncData(
        (
          t1.value as T1,
          t2.value as T2,
          t3.value as T3,
          t4.value as T4,
          t5.value as T5,
          t6.value as T6,
          t7.value as T7,
          t8.value as T8,
          t9.value as T9,
        ),
      );
    } on Exception catch (e, st) {
      return AsyncError(e, st);
    }
  }

  static AsyncValue<(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10)>
      group10<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10>(
    AsyncValue<T1> t1,
    AsyncValue<T2> t2,
    AsyncValue<T3> t3,
    AsyncValue<T4> t4,
    AsyncValue<T5> t5,
    AsyncValue<T6> t6,
    AsyncValue<T7> t7,
    AsyncValue<T8> t8,
    AsyncValue<T9> t9,
    AsyncValue<T10> t10,
  ) {
    if (t1 is AsyncLoading ||
        t2 is AsyncLoading ||
        t3 is AsyncLoading ||
        t4 is AsyncLoading ||
        t5 is AsyncLoading ||
        t6 is AsyncLoading ||
        t7 is AsyncLoading ||
        t8 is AsyncLoading ||
        t9 is AsyncLoading ||
        t10 is AsyncLoading) {
      return const AsyncLoading();
    }
    try {
      return AsyncData(
        (
          t1.value as T1,
          t2.value as T2,
          t3.value as T3,
          t4.value as T4,
          t5.value as T5,
          t6.value as T6,
          t7.value as T7,
          t8.value as T8,
          t9.value as T9,
          t10.value as T10,
        ),
      );
    } on Exception catch (e, st) {
      return AsyncError(e, st);
    }
  }
}
