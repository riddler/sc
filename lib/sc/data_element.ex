defmodule SC.DataElement do
  @moduledoc """
  Represents a data element in an SCXML datamodel.
  """

  defstruct [
    :id,
    :expr,
    :src
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          expr: String.t() | nil,
          src: String.t() | nil
        }
end
