defmodule SC.State do
  @moduledoc """
  Represents a state in an SCXML document.
  """

  defstruct [
    :id,
    :initial,
    states: [],
    transitions: []
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          initial: String.t() | nil,
          states: [SC.State.t()],
          transitions: [SC.Transition.t()]
        }
end
