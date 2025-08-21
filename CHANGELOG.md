# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

#### Eventless/Automatic Transitions
- **Eventless Transitions**: Full W3C SCXML support for transitions without event attributes that fire automatically
- **Automatic Transition Processing**: Microstep loop processes chains of eventless transitions until stable configuration
- **Cycle Detection**: Prevents infinite loops with configurable iteration limits (100 iterations default)
- **Parallel Region Preservation**: Proper SCXML semantics for transitions within and across parallel regions
- **Conflict Resolution**: Child state transitions take priority over ancestor transitions per W3C specification

#### Enhanced Parallel State Support
- **Parallel State Transitions**: Fixed regression where transitions within parallel regions affected unrelated parallel regions
- **Cross-Parallel Boundaries**: Proper exit semantics when transitions cross parallel region boundaries
- **SCXML Exit State Calculation**: Implements correct W3C exit set computation for complex state hierarchies
- **Sibling State Management**: Automatic exit of parallel siblings when transitions leave their shared parent

### Fixed
- **Regression Test**: Fixed parallel state test failure (`test/scion_tests/more_parallel/test1_test.exs`)
- **SCION Test Suite**: All 4 `cond_js` tests now pass (previously 3/4)
- **Parallel Interrupt Tests**: Fixed 6 parallel interrupt test failures in regression suite
- **Code Quality**: Resolved all `mix credo --strict` issues (predicate naming, unused variables, aliases)

### Technical Improvements
- **SCXML Terminology Alignment**: Updated codebase to use proper SCXML specification terminology
  - **Microstep/Macrostep Processing**: Execute microsteps (single transition sets) until stable macrostep completion
  - **Exit Set Computation**: Implements W3C SCXML exit set calculation algorithm for proper state exit semantics
  - **LCCA Computation**: Full Least Common Compound Ancestor algorithm for accurate transition conflict resolution
  - **NULL Transitions**: Added SCXML specification references while maintaining "eventless transitions" terminology
- **Feature Detection**: Added `eventless_transitions: :supported` to feature registry
- **Performance**: Optimized ancestor/descendant lookup using existing parent attributes
- **Test Coverage**: Enhanced with 10 comprehensive edge case tests covering LCCA, exit sets, and complex hierarchies
  - **Total Tests**: 444 tests (up from 434), including deep hierarchy and parallel region edge cases
  - **Coverage Improvement**: Interpreter module coverage increased from 70.4% to 83.0%
  - **Project Coverage**: Overall coverage improved from 89.0% to 92.3% (exceeds 90% minimum requirement)
- **Regression Testing**: All 63 regression tests pass (up from 62)

## [0.1.0] - 2025-08-20

### Added

#### Core SCXML Implementation

- **W3C SCXML Parser**: Full XML parser supporting SCXML 1.0 specification
- **State Machine Interpreter**: Synchronous, functional API for state chart execution
- **State Configuration Management**: Efficient tracking of active states with O(1) lookups
- **Event Processing**: Support for internal and external events with proper queueing
- **Document Validation**: Comprehensive validation with detailed error reporting

#### SCXML Elements Support

- **`<scxml>`**: Root element with version, initial state, and namespace support
- **`<state>`**: Compound and atomic states with nested hierarchy
- **`<initial>`**: Initial state pseudo-states for deterministic startup
- **`<transition>`**: Event-driven transitions with conditions and targets
- **`<data>`**: Data model elements for state machine variables

#### Conditional Expressions

- **`cond` Attribute**: Full support for conditional expressions on transitions
- **Predicator Integration**: Secure expression evaluation using predicator library v2.0.0
- **SCXML `In()` Function**: W3C-compliant state checking predicate
- **Logical Operations**: Support for AND, OR, NOT, and comparison operators
- **Event Data Access**: Conditions can access current event name and payload
- **Error Handling**: Invalid expressions gracefully handled per W3C specification
- **Modern Functions API**: Uses Predicator v2.0's improved custom functions approach

#### Performance Optimizations

- **Parse-time Compilation**: Conditional expressions compiled once during parsing
- **O(1) State Lookups**: Fast state and transition resolution using hash maps
- **Document Order Processing**: Deterministic transition selection
- **Memory Efficient**: Minimal memory footprint with optimized data structures

#### Developer Experience

- **Comprehensive Testing**: 426+ test cases covering all functionality
- **Integration Tests**: End-to-end testing with real SCXML documents
- **Type Safety**: Full Elixir typespec coverage for all public APIs
- **Documentation**: Detailed module and function documentation
- **Error Messages**: Clear, actionable error reporting with location information

#### Validation & Quality

- **State ID Validation**: Ensures unique and valid state identifiers
- **Transition Validation**: Validates target states exist and are reachable
- **Initial State Validation**: Enforces SCXML initial state constraints
- **Reachability Analysis**: Identifies unreachable states in state charts
- **Static Analysis**: Credo-compliant code with strict quality checks

#### Test Coverage

- **W3C Compliance**: Support for W3C SCXML test cases (excluded by default)
- **SCION Compatibility**: Integration with SCION test suite for validation
- **Unit Tests**: Comprehensive unit testing of all modules
- **Integration Tests**: Real-world SCXML document processing
- **Regression Tests**: Critical functionality protection

### Dependencies

- **saxy ~> 1.6**: Fast XML parser for SCXML document processing
- **predicator ~> 2.0**: Secure conditional expression evaluation (upgraded to v2.0 with improved custom functions API)
- **credo ~> 1.7**: Static code analysis (dev/test)
- **dialyxir ~> 1.4**: Static type checking (dev/test)
- **excoveralls ~> 0.18**: Test coverage analysis (test)

### Technical Specifications

- **Elixir**: Requires Elixir ~> 1.17
- **OTP**: Compatible with OTP 26+
- **Architecture**: Functional, immutable state machine implementation
- **Concurrency**: Thread-safe, stateless evaluation
- **Memory**: Efficient MapSet-based state tracking

### Examples

#### Basic State Machine

```xml
<?xml version="1.0" encoding="UTF-8"?>
<scxml xmlns="http://www.w3.org/2005/07/scxml" version="1.0" initial="idle">
  <state id="idle">
    <transition event="start" target="working"/>
  </state>
  <state id="working">
    <transition event="finish" target="done"/>
  </state>
  <state id="done"/>
</scxml>
```

#### Conditional Transitions

```xml
<state id="validation">
  <transition event="submit" cond="score > 80" target="approved"/>
  <transition event="submit" cond="score >= 60" target="review"/>
  <transition event="submit" target="rejected"/>
</state>
```

#### SCXML In() Function

```xml
<state id="processing">
  <transition event="check" cond="In('processing') AND progress > 50" target="almost_done"/>
  <transition event="check" target="continue_working"/>
</state>
```

#### Usage

```elixir
# Parse SCXML document
{:ok, document} = SC.Parser.SCXML.parse(scxml_string)

# Initialize state machine
{:ok, state_chart} = SC.Interpreter.initialize(document)

# Send events
event = %SC.Event{name: "start", data: %{}}
{:ok, new_state_chart} = SC.Interpreter.send_event(state_chart, event)

# Check active states
active_states = new_state_chart.configuration.active_states
```

### Notes

- This is the initial release of the SC SCXML library
- Full W3C SCXML 1.0 specification compliance for supported features
- Production-ready with comprehensive test coverage
- Built for high-performance state machine processing in Elixir applications
- Uses Predicator v2.0 with modern custom functions API (no global function registry)

---

## About

SC is a W3C SCXML (State Chart XML) implementation for Elixir, providing a robust, performant state machine engine for complex application workflows.

For more information, visit: <https://github.com/riddler/sc>
