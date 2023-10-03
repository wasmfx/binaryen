;; NOTE: Assertions have been generated by update_lit_checks.py --all-items and should not be edited.

;; RUN: wasm-as %s -all -g -o %t.wasm
;; RUN: wasm-dis %t.wasm -all -o %t.wast
;; RUN: wasm-as %s -all -o %t.nodebug.wasm
;; RUN: wasm-dis %t.nodebug.wasm -all -o %t.nodebug.wast
;; RUN: wasm-opt %t.wast -all -o %t.text.wast -g -S
;; RUN: cat %t.wast | filecheck %s --check-prefix=CHECK-BINARY
;; RUN: cat %t.nodebug.wast | filecheck %s --check-prefix=CHECK-NODEBUG
;; RUN: cat %t.text.wast | filecheck %s --check-prefix=CHECK-TEXT
(module
 ;; CHECK-BINARY:      (type $ft (func (param i32) (result i32)))
 ;; CHECK-TEXT:      (type $ft (func (param i32) (result i32)))
 (type $ft (func (param i32) (result i32)))
 ;; CHECK-BINARY:      (type $ct (cont $ft))
 ;; CHECK-TEXT:      (type $ct (cont $ft))
 (type $ct (cont $ft))
 ;; CHECK-BINARY:      (type $2 (func (result i32)))

 ;; CHECK-BINARY:      (type $3 (func (param (ref $ct)) (result i32)))

 ;; CHECK-BINARY:      (tag $t (result i32))
 ;; CHECK-TEXT:      (type $2 (func (result i32)))

 ;; CHECK-TEXT:      (type $3 (func (param (ref $ct)) (result i32)))

 ;; CHECK-TEXT:      (tag $t (result i32))
 (tag $t (result i32))

 ;; CHECK-BINARY:      (func $go (type $3) (param $x (ref $ct)) (result i32)
 ;; CHECK-BINARY-NEXT:  (drop
 ;; CHECK-BINARY-NEXT:   (block $label$1 (result (ref $ct))
 ;; CHECK-BINARY-NEXT:    (return
 ;; CHECK-BINARY-NEXT:     (resume $ct
 ;; CHECK-BINARY-NEXT:      (tag $t $label$1)
 ;; CHECK-BINARY-NEXT:      (i32.const 123)
 ;; CHECK-BINARY-NEXT:      (local.get $x)
 ;; CHECK-BINARY-NEXT:     )
 ;; CHECK-BINARY-NEXT:    )
 ;; CHECK-BINARY-NEXT:   )
 ;; CHECK-BINARY-NEXT:  )
 ;; CHECK-BINARY-NEXT:  (i32.const 123)
 ;; CHECK-BINARY-NEXT: )
 ;; CHECK-TEXT:      (func $go (type $3) (param $x (ref $ct)) (result i32)
 ;; CHECK-TEXT-NEXT:  (drop
 ;; CHECK-TEXT-NEXT:   (block $label$1 (result (ref $ct))
 ;; CHECK-TEXT-NEXT:    (return
 ;; CHECK-TEXT-NEXT:     (resume $ct
 ;; CHECK-TEXT-NEXT:      (tag $t $label$1)
 ;; CHECK-TEXT-NEXT:      (i32.const 123)
 ;; CHECK-TEXT-NEXT:      (local.get $x)
 ;; CHECK-TEXT-NEXT:     )
 ;; CHECK-TEXT-NEXT:    )
 ;; CHECK-TEXT-NEXT:   )
 ;; CHECK-TEXT-NEXT:  )
 ;; CHECK-TEXT-NEXT:  (i32.const 123)
 ;; CHECK-TEXT-NEXT: )
 (func $go (param $x (ref $ct)) (result i32)
   (drop
    (block $handler (result (ref $ct))
     (return
      (resume $ct
       ;; CHECK-BINARY:           (tag $t $label$1)
       ;; CHECK-TEXT:           (tag $t $label$1)
       (tag $t $handler)
       (i32.const 123)
       (local.get $x)
      )
     )
    )
   )
   (i32.const 123)
 )
)
;; CHECK-NODEBUG:      (type $0 (func (param i32) (result i32)))

;; CHECK-NODEBUG:      (type $1 (cont $0))

;; CHECK-NODEBUG:      (type $2 (func (result i32)))

;; CHECK-NODEBUG:      (type $3 (func (param (ref $1)) (result i32)))

;; CHECK-NODEBUG:      (tag $tag$0 (result i32))

;; CHECK-NODEBUG:      (func $0 (type $3) (param $0 (ref $1)) (result i32)
;; CHECK-NODEBUG-NEXT:  (drop
;; CHECK-NODEBUG-NEXT:   (block $label$1 (result (ref $1))
;; CHECK-NODEBUG-NEXT:    (return
;; CHECK-NODEBUG-NEXT:     (resume $1
;; CHECK-NODEBUG-NEXT:      (tag $tag$0 $label$1)
;; CHECK-NODEBUG-NEXT:      (i32.const 123)
;; CHECK-NODEBUG-NEXT:      (local.get $0)
;; CHECK-NODEBUG-NEXT:     )
;; CHECK-NODEBUG-NEXT:    )
;; CHECK-NODEBUG-NEXT:   )
;; CHECK-NODEBUG-NEXT:  )
;; CHECK-NODEBUG-NEXT:  (i32.const 123)
;; CHECK-NODEBUG-NEXT: )

;; CHECK-NODEBUG:           (tag $tag$0 $label$1)
