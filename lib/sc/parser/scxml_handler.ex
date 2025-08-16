defmodule SC.Parser.SCXMLHandler do
  @moduledoc """
  SAX event handler for parsing SCXML documents with accurate location tracking.
  """

  @behaviour Saxy.Handler

  defstruct [
    :stack,      # Stack of parent elements for hierarchy tracking
    :result,     # Final SC.Document result
    :current_element,  # Current element being processed
    :line,       # Current line number
    :column,     # Current column number
    :xml_string,  # Original XML string for position tracking
    :element_counts  # Map tracking how many of each element type have been processed
  ]

  @impl Saxy.Handler
  def handle_event(:start_document, _prolog, state) do
    {:ok, state}
  end

  @impl Saxy.Handler
  def handle_event(:end_document, _data, state) do
    {:ok, state.result}
  end

  @impl Saxy.Handler
  def handle_event(:start_element, {name, attributes}, state) do
    # Update element counts first
    updated_counts = Map.update(state.element_counts, name, 1, &(&1 + 1))
    state = %{state | element_counts: updated_counts}

    location = get_location_info(state, name)

    case name do
      "scxml" ->
        handle_scxml_start(attributes, location, state)
      "state" ->
        handle_state_start(attributes, location, state)
      "transition" ->
        handle_transition_start(attributes, location, state)
      "datamodel" ->
        handle_datamodel_start(attributes, location, state)
      "data" ->
        handle_data_start(attributes, location, state)
      _ ->
        # Skip unknown elements but track them in stack
        {:ok, %{state | stack: [{name, nil} | state.stack]}}
    end
  end

  @impl Saxy.Handler
  def handle_event(:end_element, name, state) do
    case name do
      "scxml" ->
        {:ok, state}
      "state" ->
        handle_state_end(state)
      "transition" ->
        handle_transition_end(state)
      "datamodel" ->
        handle_datamodel_end(state)
      "data" ->
        handle_data_end(state)
      _ ->
        # Pop unknown element from stack
        {:ok, %{state | stack: tl(state.stack)}}
    end
  end

  @impl Saxy.Handler
  def handle_event(:characters, _chars, state) do
    # Ignore text content for now since SCXML elements don't have mixed content
    {:ok, state}
  end

  # Private helper functions

  defp get_location_info(state, element_name) do
    # For now, calculate position based on element name and stack context
    # This is a simplified approach that approximates location based on parsing order
    calculate_element_position(state.xml_string, element_name, state.stack, state.element_counts)
  end

  # Calculate approximate element position based on XML content and parsing context
  defp calculate_element_position(xml_string, element_name, _stack, element_counts) do
    occurrence = Map.get(element_counts, element_name, 1)
    case find_element_position(xml_string, element_name, occurrence) do
      {line, column} -> %{line: line, column: column}
      _ -> %{line: 1, column: 1}
    end
  end

  # Find the position of an element by searching the XML string
  # This implementation tracks occurrences to handle multiple elements with the same name
  defp find_element_position(xml_string, element_name, occurrence) when is_binary(xml_string) and is_binary(element_name) do
    lines = String.split(xml_string, "\n", parts: :infinity)
    find_element_occurrence(lines, element_name, occurrence, 1)
  end

  defp find_element_position(_xml_string, _element_name, _occurrence), do: {1, 1}

  defp find_element_occurrence([], _element_name, _occurrence, _line_num), do: {1, 1}

  defp find_element_occurrence([line | rest], element_name, target_occurrence, line_num) do
    # Look for the element as a complete tag, not just substring
    # Match <element followed by space, >, /, or end of line
    element_pattern = "<#{element_name}([ />]|$)"
    if Regex.match?(~r/#{element_pattern}/, line) do
      if target_occurrence <= 1 do
        column = case String.split(line, "<#{element_name}", parts: 2) do
          [prefix | _] -> String.length(prefix) + 1
          _ -> 1
        end
        {line_num, column}
      else
        find_element_occurrence(rest, element_name, target_occurrence - 1, line_num + 1)
      end
    else
      find_element_occurrence(rest, element_name, target_occurrence, line_num + 1)
    end
  end

  # Calculate the location of a specific attribute within the XML
  defp calculate_attribute_location(xml_string, attr_name, element_location) do
    lines = String.split(xml_string, "\n")
    find_attribute_location(lines, attr_name, element_location.line, element_location.line)
  end

  defp find_attribute_location(lines, attr_name, start_line, current_line) when current_line <= length(lines) do
    line = Enum.at(lines, current_line - 1)
    if line && String.contains?(line, "#{attr_name}=") do
      # Found the attribute - return this line number
      %{line: current_line, column: nil}
    else
      # Check next line (for multiline elements)
      find_attribute_location(lines, attr_name, start_line, current_line + 1)
    end
  end

  defp find_attribute_location(_lines, _attr_name, _start_line, _current_line) do
    # Fallback to element location if attribute not found
    %{line: nil, column: nil}
  end

  defp handle_scxml_start(attributes, location, state) do
    attrs_map = attributes_to_map(attributes)

    # Calculate attribute-specific locations
    name_location = calculate_attribute_location(state.xml_string, "name", location)
    initial_location = calculate_attribute_location(state.xml_string, "initial", location)
    datamodel_location = calculate_attribute_location(state.xml_string, "datamodel", location)
    version_location = calculate_attribute_location(state.xml_string, "version", location)

    document = %SC.Document{
      name: get_attr_value(attrs_map, "name"),
      initial: get_attr_value(attrs_map, "initial"),
      datamodel: get_attr_value(attrs_map, "datamodel"),
      version: get_attr_value(attrs_map, "version"),
      xmlns: get_attr_value(attrs_map, "xmlns"),
      states: [],
      datamodel_elements: [],
      # Location information
      source_location: location,
      name_location: name_location,
      initial_location: initial_location,
      datamodel_location: datamodel_location,
      version_location: version_location
    }

    {:ok, %{state |
      result: document,
      current_element: {:scxml, document},
      stack: [{"scxml", document} | state.stack]
    }}
  end

  defp handle_state_start(attributes, location, state) do
    attrs_map = attributes_to_map(attributes)

    # Calculate attribute-specific locations
    id_location = calculate_attribute_location(state.xml_string, "id", location)
    initial_location = calculate_attribute_location(state.xml_string, "initial", location)

    state_element = %SC.State{
      id: get_attr_value(attrs_map, "id"),
      initial: get_attr_value(attrs_map, "initial"),
      states: [],
      transitions: [],
      # Location information
      source_location: location,
      id_location: id_location,
      initial_location: initial_location
    }

    {:ok, %{state |
      current_element: {:state, state_element},
      stack: [{"state", state_element} | state.stack]
    }}
  end

  defp handle_transition_start(attributes, location, state) do
    attrs_map = attributes_to_map(attributes)

    # Calculate attribute-specific locations
    event_location = calculate_attribute_location(state.xml_string, "event", location)
    target_location = calculate_attribute_location(state.xml_string, "target", location)
    cond_location = calculate_attribute_location(state.xml_string, "cond", location)

    transition = %SC.Transition{
      event: get_attr_value(attrs_map, "event"),
      target: get_attr_value(attrs_map, "target"),
      cond: get_attr_value(attrs_map, "cond"),
      # Location information
      source_location: location,
      event_location: event_location,
      target_location: target_location,
      cond_location: cond_location
    }

    {:ok, %{state |
      current_element: {:transition, transition},
      stack: [{"transition", transition} | state.stack]
    }}
  end

  defp handle_datamodel_start(_attributes, _location, state) do
    {:ok, %{state | stack: [{"datamodel", nil} | state.stack]}}
  end

  defp handle_data_start(attributes, location, state) do
    attrs_map = attributes_to_map(attributes)

    # Calculate attribute-specific locations
    id_location = calculate_attribute_location(state.xml_string, "id", location)
    expr_location = calculate_attribute_location(state.xml_string, "expr", location)
    src_location = calculate_attribute_location(state.xml_string, "src", location)

    data_element = %SC.DataElement{
      id: get_attr_value(attrs_map, "id"),
      expr: get_attr_value(attrs_map, "expr"),
      src: get_attr_value(attrs_map, "src"),
      # Location information
      source_location: location,
      id_location: id_location,
      expr_location: expr_location,
      src_location: src_location
    }

    {:ok, %{state |
      current_element: {:data, data_element},
      stack: [{"data", data_element} | state.stack]
    }}
  end

  defp handle_state_end(state) do
    {_name, state_element} = hd(state.stack)
    parent_stack = tl(state.stack)

    case parent_stack do
      [{"scxml", document} | _rest] ->
        updated_document = %{document | states: document.states ++ [state_element]}
        updated_state = %{state |
          result: updated_document,
          stack: [{"scxml", updated_document} | tl(parent_stack)]
        }
        {:ok, updated_state}
      [{"state", parent_state} | rest] ->
        updated_parent = %{parent_state | states: parent_state.states ++ [state_element]}
        {:ok, %{state | stack: [{"state", updated_parent} | rest]}}
      _ ->
        {:ok, %{state | stack: parent_stack}}
    end
  end

  defp handle_transition_end(state) do
    {_name, transition} = hd(state.stack)
    parent_stack = tl(state.stack)

    case parent_stack do
      [{"state", parent_state} | rest] ->
        updated_parent = %{parent_state | transitions: parent_state.transitions ++ [transition]}
        {:ok, %{state | stack: [{"state", updated_parent} | rest]}}
      _ ->
        {:ok, %{state | stack: parent_stack}}
    end
  end

  defp handle_datamodel_end(state) do
    {:ok, %{state | stack: tl(state.stack)}}
  end

  defp handle_data_end(state) do
    {_name, data_element} = hd(state.stack)
    parent_stack = tl(state.stack)

    case parent_stack do
      [{"datamodel", _} | [{"scxml", document} | rest]] ->
        updated_document = %{document | datamodel_elements: document.datamodel_elements ++ [data_element]}
        updated_state = %{state |
          result: updated_document,
          stack: [{"datamodel", nil}, {"scxml", updated_document} | rest]
        }
        {:ok, updated_state}
      _ ->
        {:ok, %{state | stack: parent_stack}}
    end
  end

  defp attributes_to_map(attributes) do
    Enum.into(attributes, %{})
  end

  defp get_attr_value(attrs_map, name) do
    case Map.get(attrs_map, name) do
      "" -> nil
      value -> value
    end
  end
end