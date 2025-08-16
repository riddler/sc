defmodule SC.Configuration do
  @moduledoc """
  Represents the current active states in an SCXML state chart.

  Only stores leaf (atomic) states - parent states are considered active
  when any of their children are active. Use active_ancestors/2 to compute
  the full set of active states including ancestors.
  """

  defstruct active_states: MapSet.new()

  @type t :: %__MODULE__{
          active_states: MapSet.t(String.t())
        }

  @doc """
  Get the set of active leaf states.
  """
  @spec active_states(t()) :: MapSet.t(String.t())
  def active_states(%__MODULE__{active_states: states}) do
    states
  end

  @doc """
  Add a leaf state to the active configuration.
  """
  @spec add_state(t(), String.t()) :: t()
  def add_state(%__MODULE__{} = config, state_id) when is_binary(state_id) do
    %{config | active_states: MapSet.put(config.active_states, state_id)}
  end

  @doc """
  Remove a leaf state from the active configuration.
  """
  @spec remove_state(t(), String.t()) :: t()
  def remove_state(%__MODULE__{} = config, state_id) when is_binary(state_id) do
    %{config | active_states: MapSet.delete(config.active_states, state_id)}
  end

  @doc """
  Check if a specific leaf state is active.
  """
  @spec active?(t(), String.t()) :: boolean()
  def active?(%__MODULE__{} = config, state_id) when is_binary(state_id) do
    MapSet.member?(config.active_states, state_id)
  end

  @doc """
  Compute all active states including ancestors for the given document.

  This function traverses the document hierarchy to find all parent states
  that should be considered active when their children are active.
  """
  @spec active_ancestors(t(), SC.Document.t()) :: MapSet.t(String.t())
  def active_ancestors(%__MODULE__{} = config, %SC.Document{} = document) do
    config.active_states
    |> Enum.reduce(MapSet.new(), fn state_id, acc ->
      ancestors = get_state_ancestors(state_id, document)
      MapSet.union(acc, MapSet.new([state_id | ancestors]))
    end)
  end

  # Private helper to find all ancestor state IDs for a given state
  defp get_state_ancestors(state_id, document) do
    case find_state_parent(state_id, document.states, []) do
      nil -> []
      parent_id -> [parent_id | get_state_ancestors(parent_id, document)]
    end
  end

  # Recursively search for the parent of a state
  defp find_state_parent(_target_id, [], _path), do: nil

  defp find_state_parent(target_id, [state | rest], path) do
    current_path = if path == [], do: state.id, else: "#{Enum.join(path, ".")}.#{state.id}"

    if Enum.any?(state.states, &(&1.id == target_id or "#{current_path}.#{&1.id}" == target_id)) do
      # Check if target is a direct child of this state
      current_path
    else
      # Recursively search nested states
      nested_result = find_state_parent(target_id, state.states, path ++ [state.id])

      case nested_result do
        nil -> find_state_parent(target_id, rest, path)
        result -> result
      end
    end
  end
end
