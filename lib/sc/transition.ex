defmodule SC.Transition do
  @moduledoc """
  Represents a transition in an SCXML state.
  """

  defstruct [
    :event,
    :target,
    :cond
  ]

  @type t :: %__MODULE__{
          event: String.t() | nil,
          target: String.t() | nil,
          cond: String.t() | nil
        }
end
