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
    datamodel_elements: [],
    # Location information for validation
    source_location: nil,
    name_location: nil,
    initial_location: nil,
    datamodel_location: nil,
    version_location: nil
  ]

  @type t :: %__MODULE__{
          name: String.t() | nil,
          initial: String.t() | nil,
          datamodel: String.t() | nil,
          version: String.t() | nil,
          xmlns: String.t() | nil,
          states: [SC.State.t()],
          datamodel_elements: [SC.DataElement.t()],
          source_location: map() | nil,
          name_location: map() | nil,
          initial_location: map() | nil,
          datamodel_location: map() | nil,
          version_location: map() | nil
        }
end
