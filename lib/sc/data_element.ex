defmodule SC.DataElement do
  @moduledoc """
  Represents a data element in an SCXML datamodel.
  """

  defstruct [
    :id,
    :expr,
    :src,
    # Location information for validation
    source_location: nil,
    id_location: nil,
    expr_location: nil,
    src_location: nil
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          expr: String.t() | nil,
          src: String.t() | nil,
          source_location: map() | nil,
          id_location: map() | nil,
          expr_location: map() | nil,
          src_location: map() | nil
        }
end
