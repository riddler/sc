defmodule SC.ActionExecutor do
  @moduledoc """
  Executes SCXML actions during state transitions.

  This module handles the execution of executable content like <log>, <raise>, 
  and other actions that occur during onentry and onexit processing.
  """

  alias SC.{Document, LogAction, RaiseAction}
  require Logger

  @doc """
  Execute onentry actions for a list of states being entered.
  """
  @spec execute_onentry_actions([String.t()], Document.t()) :: :ok
  def execute_onentry_actions(entering_states, document) do
    entering_states
    |> Enum.each(fn state_id ->
      case Document.find_state(document, state_id) do
        %{onentry_actions: [_first | _rest] = actions} ->
          execute_actions(actions, state_id, :onentry)

        _other_state ->
          :ok
      end
    end)
  end

  @doc """
  Execute onexit actions for a list of states being exited.
  """
  @spec execute_onexit_actions([String.t()], Document.t()) :: :ok
  def execute_onexit_actions(exiting_states, document) do
    exiting_states
    |> Enum.each(fn state_id ->
      case Document.find_state(document, state_id) do
        %{onexit_actions: [_first | _rest] = actions} ->
          execute_actions(actions, state_id, :onexit)

        _other_state ->
          :ok
      end
    end)
  end

  # Private functions

  defp execute_actions(actions, state_id, phase) do
    actions
    |> Enum.each(fn action ->
      execute_single_action(action, state_id, phase)
    end)
  end

  defp execute_single_action(%LogAction{} = log_action, state_id, phase) do
    # Execute log action by evaluating the expression and logging the result
    label = log_action.label || "Log"

    # For now, treat expr as a literal value (full expression evaluation comes in Phase 2)
    message = evaluate_simple_expression(log_action.expr)

    # Use Elixir's Logger to output the log message
    Logger.info("#{label}: #{message} (state: #{state_id}, phase: #{phase})")
  end

  defp execute_single_action(%RaiseAction{} = raise_action, state_id, phase) do
    # Execute raise action by generating an internal event
    # For now, we'll just log that the event would be raised
    # Full event queue integration will come in a future phase
    event = raise_action.event || "anonymous_event"

    Logger.info("Raising event '#{event}' (state: #{state_id}, phase: #{phase})")

    # NEXT: Add to interpreter's internal event queue when event processing is implemented
  end

  defp execute_single_action(unknown_action, state_id, phase) do
    Logger.debug(
      "Unknown action type #{inspect(unknown_action)} in state #{state_id} during #{phase}"
    )
  end

  # Simple expression evaluator for basic literals
  # This will be replaced with full expression evaluation in Phase 2
  defp evaluate_simple_expression(expr) when is_binary(expr) do
    case expr do
      # Handle quoted strings like 'pass', 'fail'
      "'" <> rest ->
        case String.split(rest, "'", parts: 2) do
          [content, _remainder] -> content
          _other -> expr
        end

      # Handle double-quoted strings
      "\"" <> rest ->
        case String.split(rest, "\"", parts: 2) do
          [content, _remainder] -> content
          _other -> expr
        end

      # Return as-is for other expressions (numbers, identifiers, etc.)
      _other_expr ->
        expr
    end
  end

  defp evaluate_simple_expression(nil), do: ""
  defp evaluate_simple_expression(other), do: inspect(other)
end
