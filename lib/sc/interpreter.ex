defmodule SC.Interpreter do
  @moduledoc """
  Core interpreter for SCXML state charts.

  Provides a synchronous, functional API for state chart execution.
  Documents are automatically validated before interpretation.
  """

  alias SC.{Configuration, Document, Event, StateChart}

  @doc """
  Initialize a state chart from a parsed document.

  Automatically validates the document and sets up the initial configuration.
  """
  @spec initialize(Document.t()) :: {:ok, StateChart.t()} | {:error, [String.t()], [String.t()]}
  def initialize(%Document{} = document) do
    case Document.Validator.validate(document) do
      {:ok, warnings} ->
        state_chart = StateChart.new(document, get_initial_configuration(document))
        # Log warnings if any (TODO: Use proper logging)
        if warnings != [], do: :ok
        {:ok, state_chart}

      {:error, errors, warnings} ->
        {:error, errors, warnings}
    end
  end

  @doc """
  Send an event to the state chart and return the new state.

  Processes the event according to SCXML semantics:
  1. Find enabled transitions for the current configuration
  2. Execute the first matching transition (if any)
  3. Update the configuration

  Returns the updated state chart. If no transitions match, returns the 
  state chart unchanged (silent handling as discussed).
  """
  @spec send_event(StateChart.t(), Event.t()) :: {:ok, StateChart.t()}
  def send_event(%StateChart{} = state_chart, %Event{} = event) do
    # For now, process the event immediately (synchronous)
    # Later we'll queue it and process via event loop
    enabled_transitions = find_enabled_transitions(state_chart, event)

    case enabled_transitions do
      [] ->
        # No matching transitions - return unchanged (silent handling)
        {:ok, state_chart}

      [transition | _rest] ->
        # Execute the first enabled transition
        new_config =
          execute_transition(state_chart.configuration, transition, state_chart.document)

        {:ok, StateChart.update_configuration(state_chart, new_config)}
    end
  end

  @doc """
  Get all currently active leaf states (not including ancestors).
  """
  @spec active_states(StateChart.t()) :: MapSet.t(String.t())
  def active_states(%StateChart{} = state_chart) do
    Configuration.active_states(state_chart.configuration)
  end

  @doc """
  Get all currently active states including ancestors.
  """
  @spec active_ancestors(StateChart.t()) :: MapSet.t(String.t())
  def active_ancestors(%StateChart{} = state_chart) do
    StateChart.active_states(state_chart)
  end

  @doc """
  Check if a specific state is currently active (including ancestors).
  """
  @spec active?(StateChart.t(), String.t()) :: boolean()
  def active?(%StateChart{} = state_chart, state_id) do
    active_ancestors(state_chart)
    |> MapSet.member?(state_id)
  end

  # Private helper functions

  defp get_initial_configuration(%Document{initial: nil, states: []}), do: %Configuration{}

  defp get_initial_configuration(
         %Document{initial: nil, states: [first_state | _rest]} = document
       ) do
    # No initial specified - use first state and enter it properly
    initial_states = enter_compound_state(first_state, document)
    Configuration.new(initial_states)
  end

  defp get_initial_configuration(%Document{initial: initial_id} = document) do
    case find_state_by_id(initial_id, document) do
      # Invalid initial state
      nil ->
        %Configuration{}

      state ->
        initial_states = enter_compound_state(state, document)
        Configuration.new(initial_states)
    end
  end

  # Enter a compound state by recursively entering its initial child states.
  # Returns a list of leaf state IDs that should be active.
  defp enter_compound_state(%SC.State{states: []} = state, _document) do
    # Atomic state - return its ID
    [state.id]
  end

  defp enter_compound_state(%SC.State{states: child_states, initial: initial_id}, document) do
    # Compound state - find and enter initial child (don't add compound state to active set)
    initial_child = get_initial_child_state(initial_id, child_states)

    case initial_child do
      # No valid child - compound state with no children is not active
      nil -> []
      child -> enter_compound_state(child, document)
    end
  end

  # Get the initial child state for a compound state
  defp get_initial_child_state(nil, [first_child | _rest]), do: first_child

  defp get_initial_child_state(initial_id, child_states) when is_binary(initial_id) do
    Enum.find(child_states, &(&1.id == initial_id))
  end

  defp get_initial_child_state(_initial_id, []), do: nil

  # Find a state by ID in the document (using the more efficient implementation below)

  defp find_enabled_transitions(%StateChart{} = state_chart, %Event{} = event) do
    # Get all currently active leaf states
    active_leaf_states = Configuration.active_states(state_chart.configuration)

    # Find transitions from these active states that match the event
    active_leaf_states
    |> Enum.flat_map(fn state_id ->
      case find_state_by_id(state_id, state_chart.document) do
        nil ->
          []

        state ->
          state.transitions
          |> Enum.filter(&Event.matches?(event, &1.event))
      end
    end)
    # Process in document order
    |> Enum.sort_by(& &1.document_order)
  end

  defp execute_transition(
         %Configuration{} = config,
         %SC.Transition{} = transition,
         %Document{} = document
       ) do
    case transition.target do
      # No target - stay in same state
      nil ->
        config

      target_id ->
        # Proper compound state transition:
        # 1. Find target state in document
        # 2. If compound, enter its initial children
        # 3. Return new configuration with leaf states only
        case find_state_by_id(target_id, document) do
          nil ->
            # Invalid target - stay in current state
            config

          target_state ->
            # For now: replace all active states with target and its children
            # TODO: Implement proper exit/entry sequence
            target_leaf_states = enter_compound_state(target_state, document)
            Configuration.new(target_leaf_states)
        end
    end
  end

  defp find_state_by_id(state_id, %Document{} = document) do
    collect_all_states(document)
    |> Enum.find(&(&1.id == state_id))
  end

  defp collect_all_states(%Document{states: states}) do
    collect_states_recursive(states)
  end

  defp collect_states_recursive(states) do
    Enum.flat_map(states, fn state ->
      [state | collect_states_recursive(state.states)]
    end)
  end
end
