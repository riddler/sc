# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

**Testing:**
- `mix test` - Run all tests
- `mix test test/sc/parser/scxml_test.exs` - Run specific SCXML parser tests

**Development:**
- `mix deps.get` - Install dependencies
- `mix compile` - Compile the project
- `mix docs` - Generate documentation
- `mix credo` - Run static code analysis
- `mix test --cover` - Run tests with coverage using ExCoveralls
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
- **`SC.Parser.SCXML`** - Main SCXML parser using SweetXml library
  - Parses XML strings into `SC.Document` structs
  - Handles namespace declarations (custom xmlns extraction)
  - Supports nested states and hierarchical structures
  - Converts empty XML attributes to `nil` for cleaner data representation
  - Returns `{:ok, document}` or `{:error, reason}` tuples

### Test Infrastructure
- **`SC.Case`** - Test case template module for SCXML testing
  - Provides `test_scxml/4` function for testing state machine behavior
  - Used by both SCION and W3C test suites

## Dependencies

- **`sweet_xml`** (~> 0.7) - XML parsing library built on `:xmerl` with Elixir-friendly API

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

## Code Style

- All generated files have no trailing whitespace
- Code is formatted using `mix format`
- Type specs are provided for all public structs
- Comprehensive documentation with `@moduledoc` and `@doc`

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
- Core data structures (Document, State, Transition, DataElement)
- Basic SCXML parser with SweetXml
- Comprehensive test suite integration (SCION + W3C)
- Test infrastructure with SC.Case module
- XML parsing with namespace support
- Error handling for malformed XML

🚧 **Future Extensions:**
- More executable content elements (`<onentry>`, `<onexit>`, `<raise>`, `<assign>`)
- Parallel states (`<parallel>`)
- Final states (`<final>`)
- History states (`<history>`)
- Additional transition attributes (`type`)
- Script elements and datamodel evaluation
- State machine interpreter/runtime engine

The implementation follows the W3C SCXML specification closely and includes comprehensive test coverage from both W3C and SCION test suites.
