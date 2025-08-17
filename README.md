# SC - SCXML State Machine Implementation

[![CI](https://github.com/johnnyt/sc/workflows/CI/badge.svg)](https://github.com/johnnyt/sc/actions)
[![Coverage](https://codecov.io/gh/johnnyt/sc/branch/main/graph/badge.svg)](https://codecov.io/gh/johnnyt/sc)

An Elixir implementation of SCXML (State Chart XML) state machines with a focus on W3C compliance.

## Features

- ✅ **Complete SCXML Parser** - Converts XML documents to structured data with precise location tracking
- ✅ **State Machine Interpreter** - Runtime engine for executing SCXML state machines
- ✅ **Comprehensive Validation** - Document validation with detailed error reporting
- ✅ **Hierarchical States** - Support for nested states and ancestor computation
- ✅ **Event Processing** - Internal and external event queues per SCXML specification
- ✅ **Test Infrastructure** - Compatible with SCION and W3C test suites

## Current Status

**SCION Test Results:** 107/225 tests passing (47.6% pass rate)

### Working Features
- Basic state transitions and event-driven changes
- Simple hierarchical states with proper initial configuration
- Document validation and error reporting
- SAX-based XML parsing with accurate location tracking

### Planned Features
- Parallel states (`<parallel>`)
- History states (`<history>`) 
- Conditional transitions with expression evaluation
- Executable content (`<script>`, `<assign>`, `<send>`, etc.)
- Enhanced validation for complex SCXML constructs

## Installation

Add `sc` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sc, "~> 0.1.0"}
  ]
end
```

## Usage

### Basic Example

```elixir
# Parse SCXML document
xml = """
<?xml version="1.0" encoding="UTF-8"?>
<scxml xmlns="http://www.w3.org/2005/07/scxml" version="1.0" initial="start">
  <state id="start">
    <transition event="go" target="end"/>
  </state>
  <state id="end"/>
</scxml>
"""

{:ok, document} = SC.Parser.SCXML.parse(xml)

# Initialize state chart
{:ok, state_chart} = SC.Interpreter.initialize(document)

# Check active states
active_states = SC.Interpreter.active_states(state_chart)
# Returns: MapSet.new(["start"])

# Send event
event = SC.Event.new("go")
{:ok, new_state_chart} = SC.Interpreter.send_event(state_chart, event)

# Check new active states
active_states = SC.Interpreter.active_states(new_state_chart)
# Returns: MapSet.new(["end"])
```

### Document Validation

```elixir
{:ok, document} = SC.Parser.SCXML.parse(xml)

case SC.Document.Validator.validate(document) do
  {:ok, warnings} -> 
    # Document is valid, warnings are non-fatal
    IO.puts("Valid document with #{length(warnings)} warnings")
  {:error, errors, warnings} ->
    # Document has validation errors
    IO.puts("Validation failed with #{length(errors)} errors")
end
```

## Development

### Requirements

- Elixir 1.17+ 
- Erlang/OTP 26+

### Setup

```bash
mix deps.get
mix compile
```

### Code Quality Workflow

The project maintains high code quality through automated checks:

```bash
# 1. Format code
mix format

# 2. Run tests with coverage (must maintain 90%+)
mix coveralls

# 3. Static code analysis  
mix credo --strict

# 4. Type checking
mix dialyzer
```

### Running Tests

```bash
# All tests
mix test

# With coverage
mix coveralls

# SCION basic tests
mix test --include scion --include spec:basic --exclude scxml_w3

# Specific test file
mix test test/sc/parser/scxml_test.exs
```

## Architecture

### Core Components

- **`SC.Parser.SCXML`** - SAX-based XML parser with location tracking
- **`SC.Interpreter`** - Synchronous state machine interpreter 
- **`SC.StateChart`** - Runtime container with event queues
- **`SC.Configuration`** - Active state management (leaf states only)
- **`SC.Document.Validator`** - Comprehensive document validation
- **`SC.Event`** - Event representation with origin tracking

### Data Structures

- **`SC.Document`** - Root SCXML document with states and metadata
- **`SC.State`** - Individual states with transitions and nesting
- **`SC.Transition`** - State transitions with events and targets
- **`SC.DataElement`** - Datamodel elements with expressions

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes following the code quality workflow
4. Add tests for new functionality
5. Ensure all CI checks pass
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

### Code Style

- All code is formatted with `mix format`
- Static analysis with Credo (strict mode)
- Type checking with Dialyzer
- Comprehensive test coverage (90%+ required)
- Detailed documentation with `@moduledoc` and `@doc`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [W3C SCXML Specification](https://www.w3.org/TR/scxml/) - Official specification
- [SCION Test Suite](https://github.com/jbeard4/SCION) - Comprehensive test cases
- [ex_statechart](https://github.com/camshaft/ex_statechart) - Reference implementation

