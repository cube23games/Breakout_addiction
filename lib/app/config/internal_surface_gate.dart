class InternalSurfaceGate {
  const InternalSurfaceGate._();

  // Keep internal QA/admin surfaces out of the normal public app flow.
  // This is intentionally a getter instead of a const false so flutter analyze
  // does not mark gated UI blocks as dead code.
  static bool get showDevSurfaces => false;
}
