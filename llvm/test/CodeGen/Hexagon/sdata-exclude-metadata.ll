; RUN: llc -mtriple=hexagon < %s | FileCheck %s

;; A definition of the exclude (!exclude) or metadata (!metadata_section_kind)
;; section kind is not small data, even if its section has a small-data name.
;; Code does not access such a global relative to GP, and its section does not
;; get the SHF_HEX_GPREL ("s") flag.

@exclude_var = global i32 1, section ".sdata", !exclude !0
@metadata_var = global i32 2, section ".sdata", !metadata_section_kind !0
;; The next global is regular small data, for contrast.
@small_var = global i32 3, section ".sdata"
;; A declaration has no section kind, so its section name decides.
@extern_var = external global i32, section ".sdata"

; CHECK-LABEL: load_exclude_var:
; CHECK:       memw(##exclude_var)
define i32 @load_exclude_var() {
  %v = load i32, ptr @exclude_var
  ret i32 %v
}

; CHECK-LABEL: load_metadata_var:
; CHECK:       memw(##metadata_var)
define i32 @load_metadata_var() {
  %v = load i32, ptr @metadata_var
  ret i32 %v
}

; CHECK-LABEL: load_small_var:
; CHECK:       memw(gp+#small_var)
define i32 @load_small_var() {
  %v = load i32, ptr @small_var
  ret i32 %v
}

; CHECK-LABEL: load_extern_var:
; CHECK:       memw(gp+#extern_var)
define i32 @load_extern_var() {
  %v = load i32, ptr @extern_var
  ret i32 %v
}

;; The .sdata section already exists with the small-data flags, so the first
;; two globals get unique sections.
; CHECK:       .section .sdata,"e",@progbits,unique,[[#]]{{$}}
; CHECK-NEXT:  .globl exclude_var{{$}}
; CHECK:       .section .sdata,"",@progbits,unique,[[#]]{{$}}
; CHECK-NEXT:  .globl metadata_var{{$}}
; CHECK:       .section .sdata.4,"aws",@progbits{{$}}
; CHECK-NEXT:  .globl small_var{{$}}

!0 = !{}
