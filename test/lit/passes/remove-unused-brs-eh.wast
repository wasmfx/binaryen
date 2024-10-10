;; NOTE: Assertions have been generated by update_lit_checks.py and should not be edited.
;; RUN: foreach %s %t wasm-opt -all --remove-unused-brs -S -o - | filecheck %s

(module
  ;; CHECK:      (tag $e)
  (tag $e)
  ;; CHECK:      (tag $f)
  (tag $f)
  ;; CHECK:      (tag $g)
  (tag $g)

  ;; CHECK:      (func $throw-caught-all (type $0)
  ;; CHECK-NEXT:  (block $catch
  ;; CHECK-NEXT:   (try_table (catch_all $catch)
  ;; CHECK-NEXT:    (nop)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $throw-caught-all
    (block $catch
      (try_table (catch_all $catch)
        ;; This throw can be a br. After that, it can also be removed, as we
        ;; flow to that block anyhow.
        (throw $e)
      )
    )
  )

  ;; CHECK:      (func $throw-caught-all-no-flow (type $0)
  ;; CHECK-NEXT:  (block $catch
  ;; CHECK-NEXT:   (try_table (catch_all $catch)
  ;; CHECK-NEXT:    (br $catch)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (unreachable)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $throw-caught-all-no-flow
    (block $catch
      (try_table (catch_all $catch)
        (throw $e)
      )
      ;; Block the flow, so that after the throw is optimized to a br, the br
      ;; remains.
      (unreachable)
    )
  )

  ;; CHECK:      (func $throw-caught-all-more (type $2) (param $x i32)
  ;; CHECK-NEXT:  (block $catch
  ;; CHECK-NEXT:   (try_table (catch_all $catch)
  ;; CHECK-NEXT:    (br_if $catch
  ;; CHECK-NEXT:     (local.get $x)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $throw-caught-all-more (param $x i32)
    (block $catch
      (try_table (catch_all $catch)
        ;; Look into nested children. After we turn the throw into a br, it also
        ;; fuses with the if into a br_if.
        (if
          (local.get $x)
          (then
            (throw $e)
          )
        )
      )
    )
  )

  ;; CHECK:      (func $throw-caught-precise (type $0)
  ;; CHECK-NEXT:  (block $catch
  ;; CHECK-NEXT:   (try_table (catch $e $catch)
  ;; CHECK-NEXT:    (nop)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $throw-caught-precise
    (block $catch
      ;; We can still optimize here, even though we replaced the catch_all with
      ;; a precise tag, because the tag matches.
      (try_table (catch $e $catch)
        (throw $e)
      )
    )
  )

  ;; CHECK:      (func $throw-caught-precise-later (type $0)
  ;; CHECK-NEXT:  (block $fail
  ;; CHECK-NEXT:   (block $catch
  ;; CHECK-NEXT:    (try_table (catch $f $fail) (catch $e $catch)
  ;; CHECK-NEXT:     (nop)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (call $throw-caught-precise-later)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $throw-caught-precise-later
    (block $fail
      (block $catch
        ;; We can still optimize here, by looking through the tags til we find
        ;; ours.
        (try_table (catch $f $fail) (catch $e $catch)
          (throw $e)
        )
      )
      ;; Add an effect here, so the two blocks are not mergeable.
      (call $throw-caught-precise-later)
    )
  )

  ;; CHECK:      (func $throw-caught-all-later (type $0)
  ;; CHECK-NEXT:  (block $fail
  ;; CHECK-NEXT:   (block $catch
  ;; CHECK-NEXT:    (try_table (catch $f $fail) (catch_all $catch)
  ;; CHECK-NEXT:     (nop)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (call $throw-caught-precise-later)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $throw-caught-all-later
    (block $fail
      (block $catch
        ;; We can still optimize here, by looking through the tags til we find
        ;; the catch_all
        (try_table (catch $f $fail) (catch_all $catch)
          (throw $e)
        )
      )
      ;; Add an effect here, so the two blocks are not mergeable.
      (call $throw-caught-precise-later)
    )
  )

  ;; CHECK:      (func $throw-caught-fail (type $0)
  ;; CHECK-NEXT:  (block $catch
  ;; CHECK-NEXT:   (try_table (catch $f $catch)
  ;; CHECK-NEXT:    (throw $e)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $throw-caught-fail
    (block $catch
      ;; The tag does *not* match.
      (try_table (catch $f $catch)
        (throw $e)
      )
    )
  )

  ;; CHECK:      (func $throw-caught-outer (type $0)
  ;; CHECK-NEXT:  (block $fail
  ;; CHECK-NEXT:   (block $catch
  ;; CHECK-NEXT:    (try_table (catch $e $catch)
  ;; CHECK-NEXT:     (try_table (catch $f $fail)
  ;; CHECK-NEXT:      (br $catch)
  ;; CHECK-NEXT:     )
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:    (unreachable)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (call $throw-caught-precise-later)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $throw-caught-outer
    (block $fail
      (block $catch
        (try_table (catch $e $catch)
          (try_table (catch $f $fail)
            ;; This throw can be a br, thanks to the outer try.
            (throw $e)
          )
        )
        ;; Block the flow, so that the br above remains.
        (unreachable)
      )
      ;; Add an effect here, so the two blocks are not mergeable.
      (call $throw-caught-precise-later)
    )
  )

  ;; CHECK:      (func $throw-catch-all-ref (type $1) (result exnref)
  ;; CHECK-NEXT:  (block $catch (result exnref)
  ;; CHECK-NEXT:   (try_table (catch_all_ref $catch)
  ;; CHECK-NEXT:    (throw $e)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $throw-catch-all-ref (result exnref)
    (block $catch (result exnref)
      (try_table (catch_all_ref $catch)
        ;; This is caught with a ref, so we do not optimize.
        (throw $e)
      )
    )
  )

  ;; CHECK:      (func $throw-caught-ref (type $1) (result exnref)
  ;; CHECK-NEXT:  (block $catch (result exnref)
  ;; CHECK-NEXT:   (try_table (catch_ref $e $catch)
  ;; CHECK-NEXT:    (throw $e)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $throw-caught-ref (result exnref)
    (block $catch (result exnref)
      (try_table (catch_ref $e $catch)
        ;; As above, but without catch_all.
        (throw $e)
      )
    )
  )

  ;; CHECK:      (func $throw-caught-ref-later-all (type $1) (result exnref)
  ;; CHECK-NEXT:  (block $outer (result exnref)
  ;; CHECK-NEXT:   (block $catch
  ;; CHECK-NEXT:    (try_table (catch_ref $e $outer) (catch_all $catch)
  ;; CHECK-NEXT:     (throw $e)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:    (unreachable)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (unreachable)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $throw-caught-ref-later-all (result exnref)
    (block $outer (result exnref)
      (block $catch
        (try_table (catch_ref $e $outer) (catch_all $catch)
          ;; This is caught with a ref, before we reach the catch all, so we do
          ;; not optimize.
          (throw $e)
        )
        (unreachable)
      )
      (unreachable)
    )
  )

  ;; CHECK:      (func $throw-multi (type $0)
  ;; CHECK-NEXT:  (block $outer
  ;; CHECK-NEXT:   (block $middle
  ;; CHECK-NEXT:    (block $inner
  ;; CHECK-NEXT:     (try_table (catch $e $outer) (catch $f $middle) (catch_all $inner)
  ;; CHECK-NEXT:      (br $outer)
  ;; CHECK-NEXT:      (br $middle)
  ;; CHECK-NEXT:      (br $inner)
  ;; CHECK-NEXT:      (unreachable)
  ;; CHECK-NEXT:     )
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:    (call $throw-caught-precise-later)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (call $throw-caught-precise-later)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $throw-multi
    (block $outer
      (block $middle
        (block $inner
          (try_table (catch $e $outer) (catch $f $middle) (catch_all $inner)
            ;; Multiple throws, optimizable in different ways.
            (throw $e)
            (throw $f)
            (throw $g)
            ;; Prevent the br we optimize to at the end from getting optimized
            ;; out.
            (unreachable)
          )
        )
        ;; Add an effect here, so the two blocks are not mergeable.
        (call $throw-caught-precise-later)
      )
      (call $throw-caught-precise-later)
    )
  )

  ;; CHECK:      (func $throw-mixed (type $0)
  ;; CHECK-NEXT:  (block $catch
  ;; CHECK-NEXT:   (try_table (catch_all $catch)
  ;; CHECK-NEXT:    (try
  ;; CHECK-NEXT:     (do
  ;; CHECK-NEXT:      (throw $e)
  ;; CHECK-NEXT:     )
  ;; CHECK-NEXT:     (catch_all
  ;; CHECK-NEXT:      (unreachable)
  ;; CHECK-NEXT:     )
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $throw-mixed
    ;; When we see mixed Trys and TryTables, we do not optimize (we would need
    ;; to analyze if the Trys catch the exceptions and not the TryTables, but
    ;; we don't bother to handle this odd case of mixing the old and new
    ;; styles of code).
    (block $catch
      (try_table (catch_all $catch)
        (try
          (do
            ;; This throw is caught by the Try, not the TryTable.
            (throw $e)
          )
          (catch_all
            (unreachable)
          )
        )
      )
    )
  )

  ;; CHECK:      (func $threading (type $0)
  ;; CHECK-NEXT:  (block $outer
  ;; CHECK-NEXT:   (block $middle
  ;; CHECK-NEXT:    (block $inner
  ;; CHECK-NEXT:     (try_table (catch $e $outer) (catch $f $outer) (catch_all $outer)
  ;; CHECK-NEXT:      (nop)
  ;; CHECK-NEXT:     )
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $threading
    (block $outer
      (block $middle
        (block $inner
          ;; All the branch targets here will turn into "outer", see below.
          (try_table (catch $e $outer) (catch $f $middle) (catch_all $inner)
          )
        )
        ;; Jumping to inner is the same as middle, as there is nothing
        ;; between them.
      )
      ;; Jumping to middle is the same as outer, as we jump there anyhow.
      (br $outer)
    )
  )

  ;; CHECK:      (func $threading-2 (type $0)
  ;; CHECK-NEXT:  (block $outer
  ;; CHECK-NEXT:   (block $middle
  ;; CHECK-NEXT:    (block $inner
  ;; CHECK-NEXT:     (try_table (catch $e $outer) (catch $f $middle) (catch_all $outer)
  ;; CHECK-NEXT:      (nop)
  ;; CHECK-NEXT:     )
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:    (br $outer)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (unreachable)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $threading-2
    (block $outer
      (block $middle
        (block $inner
          (try_table (catch $e $outer) (catch $f $middle) (catch_all $inner)
            ;; Only inner will turn into outer.
          )
        )
        ;; Skip over middle, so jumps to inner go to outer.
        (br $outer)
      )
      ;; Stop execution between middle and outer. We should still optimize
      ;; inner to outer.
      (unreachable)
    )
  )
)

(module
  ;; CHECK:      (import "a" "b" (func $effect (type $2) (result i32)))
  (import "a" "b" (func $effect (result i32)))

  ;; CHECK:      (tag $e (param i32))
  (tag $e (param i32))

  ;; CHECK:      (tag $multi (param i32 f64))
  (tag $multi (param i32 f64))

  ;; CHECK:      (func $throw-caught-all (type $1) (param $x i32)
  ;; CHECK-NEXT:  (block $catch
  ;; CHECK-NEXT:   (try_table (catch_all $catch)
  ;; CHECK-NEXT:    (drop
  ;; CHECK-NEXT:     (call $effect)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:    (br $catch)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $throw-caught-all (param $x i32)
    (block $catch
      (try_table (catch_all $catch)
        ;; This throw can be a br. The call must be kept in a drop.
        (throw $e
          (call $effect)
        )
      )
    )
  )

  ;; CHECK:      (func $throw-br-contents (type $2) (result i32)
  ;; CHECK-NEXT:  (block $catch (result i32)
  ;; CHECK-NEXT:   (try_table (result i32) (catch $e $catch)
  ;; CHECK-NEXT:    (i32.const 42)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $throw-br-contents (result i32)
    (block $catch (result i32)
      (try_table (catch $e $catch)
        ;; This throw is not caught by catch_all as above, so the value must be
        ;; sent as a value on the br we optimize it to. That br can also be
        ;; optimized away by letting the value flow out.
        (throw $e
          (i32.const 42)
        )
      )
    )
  )

  ;; CHECK:      (func $throw-br-contents-multi (type $0) (result i32 f64)
  ;; CHECK-NEXT:  (block $catch (type $0) (result i32 f64)
  ;; CHECK-NEXT:   (try_table (type $0) (result i32 f64) (catch $multi $catch)
  ;; CHECK-NEXT:    (tuple.make 2
  ;; CHECK-NEXT:     (i32.const 42)
  ;; CHECK-NEXT:     (f64.const 3.14159)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $throw-br-contents-multi (result i32 f64)
    ;; As above, but now with a multivalue tag.
    (block $catch (result i32 f64)
      (try_table (catch $multi $catch)
        (throw $multi
          (i32.const 42)
          (f64.const 3.14159)
        )
      )
    )
  )

  ;; CHECK:      (func $no-flow-through-throw (type $4)
  ;; CHECK-NEXT:  (block $label
  ;; CHECK-NEXT:   (try_table (catch_all $label)
  ;; CHECK-NEXT:    (drop
  ;; CHECK-NEXT:     (if (result i32)
  ;; CHECK-NEXT:      (i32.const 0)
  ;; CHECK-NEXT:      (then
  ;; CHECK-NEXT:       (br $label)
  ;; CHECK-NEXT:      )
  ;; CHECK-NEXT:      (else
  ;; CHECK-NEXT:       (i32.const 42)
  ;; CHECK-NEXT:      )
  ;; CHECK-NEXT:     )
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:    (br $label)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $no-flow-through-throw
    ;; The throw here can turn into a break. While doing so, we must clear all
    ;; the currently-flowing things, namely the br in the if arm. If we do not
    ;; do so then it will try to flow out through the drop that we add for the
    ;; throw's value, which is impossible.
    (block $label
      (try_table (catch_all $label)
        (throw $e
          (if (result i32)
            (i32.const 0)
            (then
              (br $label)
            )
            (else
              (i32.const 42)
            )
          )
        )
      )
    )
  )
)
