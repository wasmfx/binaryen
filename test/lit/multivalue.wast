;; NOTE: Assertions have been generated by update_lit_checks.py and should not be edited.
;; RUN: wasm-opt %s -all --roundtrip -S -o - | filecheck %s

;; Test basic lowering of tuple.make, tuple.extract, and tuple variables and
;; that they round trip through the binary format correctly.

(module
 ;; CHECK:      (import "env" "pair" (func $pair (type $0) (result i32 i64)))
 (import "env" "pair" (func $pair (result i32 i64)))
 ;; CHECK:      (global $g1 (mut i32) (i32.const 0))
 (global $g1 (mut (i32 i64)) (tuple.make 2 (i32.const 0) (i64.const 0)))
 ;; CHECK:      (global $g2 (mut i64) (i64.const 0))
 (global $g2 (i32 i64) (tuple.make 2 (i32.const 0) (i64.const 0)))

 ;; CHECK:      (func $triple (type $5) (result i32 i64 f32)
 ;; CHECK-NEXT:  (tuple.make 3
 ;; CHECK-NEXT:   (i32.const 42)
 ;; CHECK-NEXT:   (i64.const 7)
 ;; CHECK-NEXT:   (f32.const 13)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $triple (result i32 i64 f32)
  (tuple.make 3
   (i32.const 42)
   (i64.const 7)
   (f32.const 13)
  )
 )

 ;; CHECK:      (func $get-first (type $6) (result i32)
 ;; CHECK-NEXT:  (local $0 (i32 i64 f32))
 ;; CHECK-NEXT:  (local $1 i64)
 ;; CHECK-NEXT:  (local $2 i32)
 ;; CHECK-NEXT:  (local.set $0
 ;; CHECK-NEXT:   (call $triple)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (block (result i32)
 ;; CHECK-NEXT:   (local.set $2
 ;; CHECK-NEXT:    (tuple.extract 3 0
 ;; CHECK-NEXT:     (local.get $0)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (drop
 ;; CHECK-NEXT:    (block (result i64)
 ;; CHECK-NEXT:     (local.set $1
 ;; CHECK-NEXT:      (tuple.extract 3 1
 ;; CHECK-NEXT:       (local.get $0)
 ;; CHECK-NEXT:      )
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:     (drop
 ;; CHECK-NEXT:      (tuple.extract 3 2
 ;; CHECK-NEXT:       (local.get $0)
 ;; CHECK-NEXT:      )
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:     (local.get $1)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (local.get $2)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $get-first (result i32)
  (tuple.extract 3 0
   (call $triple)
  )
 )

 ;; CHECK:      (func $get-second (type $3) (result i64)
 ;; CHECK-NEXT:  (local $0 i64)
 ;; CHECK-NEXT:  (local $1 (i32 i64 f32))
 ;; CHECK-NEXT:  (local $2 i64)
 ;; CHECK-NEXT:  (local $3 i32)
 ;; CHECK-NEXT:  (local.set $1
 ;; CHECK-NEXT:   (call $triple)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (block (result i32)
 ;; CHECK-NEXT:    (local.set $3
 ;; CHECK-NEXT:     (tuple.extract 3 0
 ;; CHECK-NEXT:      (local.get $1)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:    (local.set $0
 ;; CHECK-NEXT:     (block (result i64)
 ;; CHECK-NEXT:      (local.set $2
 ;; CHECK-NEXT:       (tuple.extract 3 1
 ;; CHECK-NEXT:        (local.get $1)
 ;; CHECK-NEXT:       )
 ;; CHECK-NEXT:      )
 ;; CHECK-NEXT:      (drop
 ;; CHECK-NEXT:       (tuple.extract 3 2
 ;; CHECK-NEXT:        (local.get $1)
 ;; CHECK-NEXT:       )
 ;; CHECK-NEXT:      )
 ;; CHECK-NEXT:      (local.get $2)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:    (local.get $3)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (local.get $0)
 ;; CHECK-NEXT: )
 (func $get-second (result i64)
  (tuple.extract 3 1
   (call $triple)
  )
 )

 ;; CHECK:      (func $get-third (type $7) (result f32)
 ;; CHECK-NEXT:  (local $0 f32)
 ;; CHECK-NEXT:  (local $1 (i32 i64 f32))
 ;; CHECK-NEXT:  (local $2 i64)
 ;; CHECK-NEXT:  (local $3 i32)
 ;; CHECK-NEXT:  (local.set $1
 ;; CHECK-NEXT:   (call $triple)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (block (result i32)
 ;; CHECK-NEXT:    (local.set $3
 ;; CHECK-NEXT:     (tuple.extract 3 0
 ;; CHECK-NEXT:      (local.get $1)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:    (drop
 ;; CHECK-NEXT:     (block (result i64)
 ;; CHECK-NEXT:      (local.set $2
 ;; CHECK-NEXT:       (tuple.extract 3 1
 ;; CHECK-NEXT:        (local.get $1)
 ;; CHECK-NEXT:       )
 ;; CHECK-NEXT:      )
 ;; CHECK-NEXT:      (local.set $0
 ;; CHECK-NEXT:       (tuple.extract 3 2
 ;; CHECK-NEXT:        (local.get $1)
 ;; CHECK-NEXT:       )
 ;; CHECK-NEXT:      )
 ;; CHECK-NEXT:      (local.get $2)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:    (local.get $3)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (local.get $0)
 ;; CHECK-NEXT: )
 (func $get-third (result f32)
  (tuple.extract 3 2
   (call $triple)
  )
 )

 ;; CHECK:      (func $reverse (type $4) (result f32 i64 i32)
 ;; CHECK-NEXT:  (local $x i32)
 ;; CHECK-NEXT:  (local $1 i64)
 ;; CHECK-NEXT:  (local $2 i64)
 ;; CHECK-NEXT:  (local $3 f32)
 ;; CHECK-NEXT:  (local $4 f32)
 ;; CHECK-NEXT:  (local $5 (i32 i64 f32))
 ;; CHECK-NEXT:  (local $6 i64)
 ;; CHECK-NEXT:  (local $7 i32)
 ;; CHECK-NEXT:  (local.set $5
 ;; CHECK-NEXT:   (call $triple)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (local.set $x
 ;; CHECK-NEXT:   (block (result i32)
 ;; CHECK-NEXT:    (local.set $7
 ;; CHECK-NEXT:     (tuple.extract 3 0
 ;; CHECK-NEXT:      (local.get $5)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:    (local.set $1
 ;; CHECK-NEXT:     (block (result i64)
 ;; CHECK-NEXT:      (local.set $6
 ;; CHECK-NEXT:       (tuple.extract 3 1
 ;; CHECK-NEXT:        (local.get $5)
 ;; CHECK-NEXT:       )
 ;; CHECK-NEXT:      )
 ;; CHECK-NEXT:      (local.set $3
 ;; CHECK-NEXT:       (tuple.extract 3 2
 ;; CHECK-NEXT:        (local.get $5)
 ;; CHECK-NEXT:       )
 ;; CHECK-NEXT:      )
 ;; CHECK-NEXT:      (local.get $6)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:    (local.get $7)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (tuple.make 3
 ;; CHECK-NEXT:   (local.get $3)
 ;; CHECK-NEXT:   (local.get $1)
 ;; CHECK-NEXT:   (local.get $x)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $reverse (result f32 i64 i32)
  (local $x (i32 i64 f32))
  (local.set $x
   (call $triple)
  )
  (tuple.make 3
   (tuple.extract 3 2
    (local.get $x)
   )
   (tuple.extract 3 1
    (local.get $x)
   )
   (tuple.extract 3 0
    (local.get $x)
   )
  )
 )

 ;; CHECK:      (func $unreachable (type $3) (result i64)
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (i32.const 42)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (i64.const 7)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (unreachable)
 ;; CHECK-NEXT: )
 (func $unreachable (result i64)
  (tuple.extract 3 1
   (tuple.make 3
    (i32.const 42)
    (i64.const 7)
    (unreachable)
   )
  )
 )

 ;; Test multivalue globals
 ;; CHECK:      (func $global (type $0) (result i32 i64)
 ;; CHECK-NEXT:  (local $0 i64)
 ;; CHECK-NEXT:  (local $1 i32)
 ;; CHECK-NEXT:  (global.set $g1
 ;; CHECK-NEXT:   (block (result i32)
 ;; CHECK-NEXT:    (local.set $1
 ;; CHECK-NEXT:     (i32.const 42)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:    (global.set $g2
 ;; CHECK-NEXT:     (i64.const 7)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:    (local.get $1)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (global.get $g2)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (tuple.make 2
 ;; CHECK-NEXT:   (global.get $global$2)
 ;; CHECK-NEXT:   (global.get $global$3)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $global (result i32 i64)
  (global.set $g1
   (tuple.make 2
    (i32.const 42)
    (i64.const 7)
   )
  )
  (drop
   (tuple.extract 2 1
    (global.get $g1)
   )
  )
  (global.get $g2)
 )

 ;; Test lowering of multivalue drops
 ;; CHECK:      (func $drop-call (type $1)
 ;; CHECK-NEXT:  (local $0 (i32 i64))
 ;; CHECK-NEXT:  (local $1 i32)
 ;; CHECK-NEXT:  (local.set $0
 ;; CHECK-NEXT:   (call $pair)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (block (result i32)
 ;; CHECK-NEXT:    (local.set $1
 ;; CHECK-NEXT:     (tuple.extract 2 0
 ;; CHECK-NEXT:      (local.get $0)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:    (drop
 ;; CHECK-NEXT:     (tuple.extract 2 1
 ;; CHECK-NEXT:      (local.get $0)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:    (local.get $1)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $drop-call
  (tuple.drop 2
   (call $pair)
  )
 )

 ;; CHECK:      (func $drop-tuple-make (type $1)
 ;; CHECK-NEXT:  (local $0 i32)
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (block (result i32)
 ;; CHECK-NEXT:    (local.set $0
 ;; CHECK-NEXT:     (i32.const 42)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:    (drop
 ;; CHECK-NEXT:     (i64.const 42)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:    (local.get $0)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $drop-tuple-make
  (tuple.drop 2
   (tuple.make 2
    (i32.const 42)
    (i64.const 42)
   )
  )
 )

 ;; CHECK:      (func $drop-block (type $1)
 ;; CHECK-NEXT:  (local $0 (i32 i64))
 ;; CHECK-NEXT:  (local $1 i32)
 ;; CHECK-NEXT:  (local.set $0
 ;; CHECK-NEXT:   (block $label$1 (type $0) (result i32 i64)
 ;; CHECK-NEXT:    (tuple.make 2
 ;; CHECK-NEXT:     (i32.const 42)
 ;; CHECK-NEXT:     (i64.const 42)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (block (result i32)
 ;; CHECK-NEXT:    (local.set $1
 ;; CHECK-NEXT:     (tuple.extract 2 0
 ;; CHECK-NEXT:      (local.get $0)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:    (drop
 ;; CHECK-NEXT:     (tuple.extract 2 1
 ;; CHECK-NEXT:      (local.get $0)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:    (local.get $1)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $drop-block
  (tuple.drop 2
   (block $block (result i32 i64)
    (tuple.make 2
     (i32.const 42)
     (i64.const 42)
    )
   )
  )
 )

 ;; Test multivalue control structures
 ;; CHECK:      (func $mv-return (type $0) (result i32 i64)
 ;; CHECK-NEXT:  (return
 ;; CHECK-NEXT:   (tuple.make 2
 ;; CHECK-NEXT:    (i32.const 42)
 ;; CHECK-NEXT:    (i64.const 42)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $mv-return (result i32 i64)
  (return
   (tuple.make 2
    (i32.const 42)
    (i64.const 42)
   )
  )
 )

 ;; CHECK:      (func $mv-return-in-block (type $0) (result i32 i64)
 ;; CHECK-NEXT:  (return
 ;; CHECK-NEXT:   (tuple.make 2
 ;; CHECK-NEXT:    (i32.const 42)
 ;; CHECK-NEXT:    (i64.const 42)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $mv-return-in-block (result i32 i64)
  (block (result i32 i64)
   (return
    (tuple.make 2
     (i32.const 42)
     (i64.const 42)
    )
   )
  )
 )

 ;; CHECK:      (func $mv-block-break (type $0) (result i32 i64)
 ;; CHECK-NEXT:  (local $0 (i32 i64))
 ;; CHECK-NEXT:  (local.set $0
 ;; CHECK-NEXT:   (block $label$1 (type $0) (result i32 i64)
 ;; CHECK-NEXT:    (br $label$1
 ;; CHECK-NEXT:     (tuple.make 2
 ;; CHECK-NEXT:      (i32.const 42)
 ;; CHECK-NEXT:      (i64.const 42)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (tuple.make 2
 ;; CHECK-NEXT:   (tuple.extract 2 0
 ;; CHECK-NEXT:    (local.get $0)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (tuple.extract 2 1
 ;; CHECK-NEXT:    (local.get $0)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $mv-block-break (result i32 i64)
  (block $l (result i32 i64)
   (br $l
    (tuple.make 2
     (i32.const 42)
     (i64.const 42)
    )
   )
  )
 )

 ;; CHECK:      (func $mv-block-br-if (type $0) (result i32 i64)
 ;; CHECK-NEXT:  (local $0 (i32 i64))
 ;; CHECK-NEXT:  (local $1 (i32 i64))
 ;; CHECK-NEXT:  (local.set $1
 ;; CHECK-NEXT:   (block $label$1 (type $0) (result i32 i64)
 ;; CHECK-NEXT:    (local.set $0
 ;; CHECK-NEXT:     (br_if $label$1
 ;; CHECK-NEXT:      (tuple.make 2
 ;; CHECK-NEXT:       (i32.const 42)
 ;; CHECK-NEXT:       (i64.const 42)
 ;; CHECK-NEXT:      )
 ;; CHECK-NEXT:      (i32.const 1)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:    (tuple.make 2
 ;; CHECK-NEXT:     (tuple.extract 2 0
 ;; CHECK-NEXT:      (local.get $0)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:     (tuple.extract 2 1
 ;; CHECK-NEXT:      (local.get $0)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (tuple.make 2
 ;; CHECK-NEXT:   (tuple.extract 2 0
 ;; CHECK-NEXT:    (local.get $1)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (tuple.extract 2 1
 ;; CHECK-NEXT:    (local.get $1)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $mv-block-br-if (result i32 i64)
  (block $l (result i32 i64)
   (br_if $l
    (tuple.make 2
     (i32.const 42)
     (i64.const 42)
    )
    (i32.const 1)
   )
  )
 )

 ;; CHECK:      (func $mv-if (type $2) (result i32 i64 externref)
 ;; CHECK-NEXT:  (local $0 (i32 i64 externref))
 ;; CHECK-NEXT:  (local.set $0
 ;; CHECK-NEXT:   (if (type $2) (result i32 i64 externref)
 ;; CHECK-NEXT:    (i32.const 1)
 ;; CHECK-NEXT:    (tuple.make 3
 ;; CHECK-NEXT:     (i32.const 42)
 ;; CHECK-NEXT:     (i64.const 42)
 ;; CHECK-NEXT:     (ref.null noextern)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:    (tuple.make 3
 ;; CHECK-NEXT:     (i32.const 42)
 ;; CHECK-NEXT:     (i64.const 42)
 ;; CHECK-NEXT:     (ref.null noextern)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (tuple.make 3
 ;; CHECK-NEXT:   (tuple.extract 3 0
 ;; CHECK-NEXT:    (local.get $0)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (tuple.extract 3 1
 ;; CHECK-NEXT:    (local.get $0)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (tuple.extract 3 2
 ;; CHECK-NEXT:    (local.get $0)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $mv-if (result i32 i64 externref)
  (if (result i32 i64 externref)
   (i32.const 1)
   (tuple.make 3
    (i32.const 42)
    (i64.const 42)
    (ref.null extern)
   )
   (tuple.make 3
    (i32.const 42)
    (i64.const 42)
    (ref.null extern)
   )
  )
 )

 ;; CHECK:      (func $mv-loop (type $0) (result i32 i64)
 ;; CHECK-NEXT:  (local $0 (i32 i64))
 ;; CHECK-NEXT:  (local.set $0
 ;; CHECK-NEXT:   (loop $label$1 (type $0) (result i32 i64)
 ;; CHECK-NEXT:    (tuple.make 2
 ;; CHECK-NEXT:     (i32.const 42)
 ;; CHECK-NEXT:     (i64.const 42)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (tuple.make 2
 ;; CHECK-NEXT:   (tuple.extract 2 0
 ;; CHECK-NEXT:    (local.get $0)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (tuple.extract 2 1
 ;; CHECK-NEXT:    (local.get $0)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $mv-loop (result i32 i64)
  (loop (result i32 i64)
   (tuple.make 2
    (i32.const 42)
    (i64.const 42)
   )
  )
 )

 ;; CHECK:      (func $mv-switch (type $0) (result i32 i64)
 ;; CHECK-NEXT:  (local $0 (i32 i64))
 ;; CHECK-NEXT:  (local $1 (i32 i64))
 ;; CHECK-NEXT:  (local.set $1
 ;; CHECK-NEXT:   (block $label$1 (type $0) (result i32 i64)
 ;; CHECK-NEXT:    (local.set $0
 ;; CHECK-NEXT:     (block $label$2 (type $0) (result i32 i64)
 ;; CHECK-NEXT:      (br_table $label$1 $label$2
 ;; CHECK-NEXT:       (tuple.make 2
 ;; CHECK-NEXT:        (i32.const 42)
 ;; CHECK-NEXT:        (i64.const 42)
 ;; CHECK-NEXT:       )
 ;; CHECK-NEXT:       (i32.const 0)
 ;; CHECK-NEXT:      )
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:    (tuple.make 2
 ;; CHECK-NEXT:     (tuple.extract 2 0
 ;; CHECK-NEXT:      (local.get $0)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:     (tuple.extract 2 1
 ;; CHECK-NEXT:      (local.get $0)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (tuple.make 2
 ;; CHECK-NEXT:   (tuple.extract 2 0
 ;; CHECK-NEXT:    (local.get $1)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (tuple.extract 2 1
 ;; CHECK-NEXT:    (local.get $1)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $mv-switch (result i32 i64)
  (block $a (result i32 i64)
   (block $b (result i32 i64)
    (br_table $a $b
     (tuple.make 2
      (i32.const 42)
      (i64.const 42)
     )
     (i32.const 0)
    )
   )
  )
 )
)
