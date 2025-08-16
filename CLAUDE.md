# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

**Testing:**
- `mix coveralls` - Run all tests with coverage reporting (ensure at least 90% coverage)
- `mix coveralls.detail` - Run tests with detailed coverage report showing uncovered lines
- `mix test` - Run all tests without coverage
- `mix test test/sc/location_test.exs` - Run location tracking tests
- `mix test test/sc/parser/scxml_test.exs` - Run specific SCXML parser tests

**Development:**
- `mix deps.get` - Install dependencies
- `mix compile` - Compile the project
- `mix docs` - Generate documentation
- `mix credo --strict` - Run static code analysis with strict mode (always run with tests)
- `mix format` - Format code according to Elixir standards
- `mix format --check-formatted` - Check if code is properly formatted

## Architecture

This is an Elixir implementation of SCXML (State Chart XML) state machines with a focus on W3C compliance.

The State Chart reference XML is here: https://www.w3.org/TR/scxml/

This project uses Elixir Structs for the data structures, and MapSets for sets.

Also use this initial Elixir implementation as reference: https://github.com/camshaft/ex_statechart

## Core Components

### Data Structures
- **`SC.Document`** - Root SCXML document structure with attributes like `name`, `initial`, `datamodel`, `version`, `xmlns`, plus collections of `states` and `datamodel_elements`
- **`SC.State`** - Individual state with `id`, optional `initial` state, nested `states` list, and `transitions` list
- **`SC.Transition`** - State transitions with optional `event`, `target`, and `cond` attributes
- **`SC.DataElement`** - Datamodel elements with required `id` and optional `expr` and `src` attributes

### Parsers
- **`SC.Parser.SCXML`** - Main SCXML parser using Saxy SAX parser for accurate location tracking
  - Parses XML strings into `SC.Document` structs with precise source location information
  - Event-driven SAX parsing for better memory efficiency and location tracking
  - Handles namespace declarations and XML attributes correctly
  - Supports nested states and hierarchical structures
  - Converts empty XML attributes to `nil` for cleaner data representation
  - Returns `{:ok, document}` or `{:error, reason}` tuples
- **`SC.Parser.SCXMLHandler`** - SAX event handler for SCXML parsing
  - Implements `Saxy.Handler` behavior for processing XML events
  - Tracks element occurrences and position information during parsing
  - Manages element stack for proper hierarchical document construction

### Test Infrastructure
- **`SC.Case`** - Test case template module for SCXML testing
  - Provides `test_scxml/4` function for testing state machine behavior
  - Used by both SCION and W3C test suites

### Location Tracking
All parsed SCXML elements include precise source location information for validation error reporting:

- **Element locations**: Each parsed element (`SC.Document`, `SC.State`, `SC.Transition`, `SC.DataElement`) includes a `source_location` field with line/column information
- **Attribute locations**: Individual attributes have dedicated location fields (e.g., `name_location`, `id_location`, `event_location`) for precise error reporting
- **Multiline support**: Accurately tracks locations for both single-line and multiline XML element definitions
- **SAX-based tracking**: Uses Saxy's event-driven parsing to maintain position information throughout the parsing process

## Dependencies

- **`saxy`** (~> 1.6) - Fast, memory-efficient SAX XML parser with position tracking support

## Development Dependencies

- **`credo`** (~> 1.7) - Static code analysis tool for code quality and consistency

## Tests

This project includes comprehensive test coverage:

### SCION Test Suite (`test/scion_tests/`)
- 127+ test files from the SCION project
- Module naming: `SCIONTest.Category.TestNameTest` (e.g., `SCIONTest.ActionSend.Send1Test`)
- Uses `SC.Case` for test infrastructure
- Tests cover basic state machines, transitions, parallel states, history, etc.

### W3C SCXML Test Suite (`test/scxml_tests/`)
- 59+ test files from W3C SCXML conformance tests
- Module naming: `Test.StateChart.W3.Category.TestName` (e.g., `Test.StateChart.W3.Events.Test396`)
- Uses `SC.Case` for test infrastructure
- Organized by SCXML specification sections (mandatory tests)

### Parser Tests (`test/sc/parser/scxml_test.exs`)
- Unit tests for `SC.Parser.SCXML`
- Tests parsing of simple documents, transitions, datamodels, nested states
- Validates error handling for invalid XML
- Ensures proper attribute handling (nil for empty values)

### Location Tracking Tests (`test/sc/location_test.exs`)
- Tests for precise source location tracking in SCXML documents
- Validates line number accuracy for elements and attributes
- Tests both single-line and multiline XML element definitions
- Ensures proper location tracking for nested elements and datamodel elements

## Code Style

- All generated files have no trailing whitespace
- Code is formatted using `mix format`
- Static code analysis with `mix credo --strict` - all issues resolved
- Type specs (`@spec`) are provided for all public functions
- Comprehensive documentation with `@moduledoc` and `@doc`
- Consistent naming for unused variables (meaningful names with `_` prefix)

## XML Format

Test files use triple-quote multiline strings for XML content:

```elixir
xml = """
<?xml version="1.0" encoding="UTF-8"?>
<scxml xmlns="http://www.w3.org/2005/07/scxml" version="1.0" initial="a">
    <state id="a"/>
</scxml>
"""
```

XML content within triple quotes uses 4-space base indentation.

## Implementation Status

✅ **Completed:**
- Core data structures (Document, State, Transition, DataElement) with location tracking
- SCXML parser using Saxy SAX parser for accurate position tracking
- Comprehensive test suite integration (SCION + W3C)
- Test infrastructure with SC.Case module
- XML parsing with namespace support and precise source location tracking
- Error handling for malformed XML
- Location tracking for elements and attributes (line numbers for validation errors)
- Support for both single-line and multiline XML element definitions

🚧 **Future Extensions:**
- More executable content elements (`<onentry>`, `<onexit>`, `<raise>`, `<assign>`)
- Parallel states (`<parallel>`)
- Final states (`<final>`)
- History states (`<history>`)
- Additional transition attributes (`type`)
- Script elements and datamodel evaluation
- State machine interpreter/runtime engine

The implementation follows the W3C SCXML specification closely and includes comprehensive test coverage from both W3C and SCION test suites.
