// 'unsafe_without_unsafe' warnings that are covered by an 'unsafe' expression
// are still emitted into SARIF, carrying an in-source suppression.

// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend -typecheck -strict-memory-safety -serialize-diagnostics=sarif -serialize-diagnostics-path %t/diags.sarif %s
// RUN: %FileCheck --input-file=%t/diags.sarif %s

// REQUIRES: swift_sarif

@unsafe func unsafeFn() { }

func test() {
  unsafe unsafeFn()
  unsafeFn()
}

// The covered use (line 13) is a suppressed result. The suppression's location
// is the 'unsafe' keyword (columns 3 through 9).
// CHECK: "results" : [
// CHECK: "startLine" : 13
// CHECK: "message" : {
// CHECK-NEXT: "text" : "expression uses unsafe constructs but is not marked with 'unsafe'"
// CHECK: "ruleId" : "unsafe_without_unsafe"
// CHECK: "suppressions" : [
// CHECK: "kind" : "inSource"
// CHECK: "endColumn" : 9
// CHECK: "endLine" : 13
// CHECK: "startColumn" : 3
// CHECK: "startLine" : 13
// CHECK: "swift/suppressionKind" : "unsafeExpr"

// The note attached to the covered warning is not itself suppressed. (Notes are
// emitted as their own results.) The uncovered use (line 14) is an ordinary,
// unsuppressed warning.
// CHECK: "ruleId" : "note_reference_to_unsafe_decl"
// CHECK-NOT: "suppressions"
// CHECK: "startLine" : 14
// CHECK: "ruleId" : "unsafe_without_unsafe"
// CHECK-NOT: "suppressions"
// CHECK: "ruleId" : "note_reference_to_unsafe_decl"
// CHECK-NOT: "suppressions"
