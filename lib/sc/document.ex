defmodule SC.Document do
  @moduledoc """
  Represents a parsed SCXML document.
  """

  defstruct [
    :name,
    :initial,
    :datamodel,
    :version,
    :xmlns,
    states: [],
    datamodel_elements: []
  ]

  @type t :: %__MODULE__{
          name: String.t() | nil,
          initial: String.t() | nil,
          datamodel: String.t() | nil,
          version: String.t() | nil,
          xmlns: String.t() | nil,
          states: [SC.State.t()],
          datamodel_elements: [SC.DataElement.t()]
        }
end
