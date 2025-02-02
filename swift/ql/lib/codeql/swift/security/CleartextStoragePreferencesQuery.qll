/**
 * Provides a taint-tracking configuration for reasoning about cleartext
 * preferences storage vulnerabilities.
 */

import swift
import codeql.swift.security.SensitiveExprs
import codeql.swift.dataflow.DataFlow
import codeql.swift.dataflow.TaintTracking
import codeql.swift.security.CleartextStoragePreferencesExtensions

/**
 * A taint configuration from sensitive information to expressions that are
 * stored as preferences.
 */
deprecated class CleartextStorageConfig extends TaintTracking::Configuration {
  CleartextStorageConfig() { this = "CleartextStorageConfig" }

  override predicate isSource(DataFlow::Node node) { node.asExpr() instanceof SensitiveExpr }

  override predicate isSink(DataFlow::Node node) { node instanceof CleartextStoragePreferencesSink }

  override predicate isSanitizer(DataFlow::Node sanitizer) {
    sanitizer instanceof CleartextStoragePreferencesSanitizer
  }

  override predicate isAdditionalTaintStep(DataFlow::Node nodeFrom, DataFlow::Node nodeTo) {
    any(CleartextStoragePreferencesAdditionalTaintStep s).step(nodeFrom, nodeTo)
  }

  override predicate isSanitizerIn(DataFlow::Node node) {
    // make sources barriers so that we only report the closest instance
    this.isSource(node)
  }
}

/**
 * A taint configuration from sensitive information to expressions that are
 * stored as preferences.
 */
module CleartextStorageConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node node) { node.asExpr() instanceof SensitiveExpr }

  predicate isSink(DataFlow::Node node) { node instanceof CleartextStoragePreferencesSink }

  predicate isBarrier(DataFlow::Node sanitizer) {
    sanitizer instanceof CleartextStoragePreferencesSanitizer
  }

  predicate isAdditionalFlowStep(DataFlow::Node nodeFrom, DataFlow::Node nodeTo) {
    any(CleartextStoragePreferencesAdditionalTaintStep s).step(nodeFrom, nodeTo)
  }

  predicate isBarrierIn(DataFlow::Node node) {
    // make sources barriers so that we only report the closest instance
    isSource(node)
  }
}

/**
 * Detect taint flow of sensitive information to expressions that are stored
 * as preferences.
 */
module CleartextStorageFlow = TaintTracking::Global<CleartextStorageConfig>;
