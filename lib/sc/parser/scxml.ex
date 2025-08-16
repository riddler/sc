defmodule SC.Parser.SCXML do
  @moduledoc """
  Parser for SCXML documents using SweetXml.
  """

  import SweetXml

  @doc """
  Parse an SCXML string into an SC.Document struct.
  """
  @spec parse(String.t()) :: {:ok, SC.Document.t()} | {:error, term()}
  def parse(xml_string) do
    try do
      document =
        xml_string
        |> xpath(~x"//scxml"e)
        |> parse_scxml()

      {:ok, document}
    rescue
      error -> {:error, error}
    catch
      :exit, reason -> {:error, reason}
    end
  end

  defp parse_scxml(scxml_element) do
    %SC.Document{
      name: scxml_element |> xpath(~x"./@name"s) |> empty_to_nil(),
      initial: scxml_element |> xpath(~x"./@initial"s) |> empty_to_nil(),
      datamodel: scxml_element |> xpath(~x"./@datamodel"s) |> empty_to_nil(),
      version: scxml_element |> xpath(~x"./@version"s) |> empty_to_nil(),
      xmlns: extract_xmlns(scxml_element),
      states: scxml_element |> xpath(~x"./state"el) |> Enum.map(&parse_state/1),
      datamodel_elements:
        scxml_element |> xpath(~x"./datamodel/data"el) |> Enum.map(&parse_data_element/1)
    }
  end

  defp parse_state(state_element) do
    %SC.State{
      id: state_element |> xpath(~x"./@id"s),
      initial: state_element |> xpath(~x"./@initial"s) |> empty_to_nil(),
      states: state_element |> xpath(~x"./state"el) |> Enum.map(&parse_state/1),
      transitions: state_element |> xpath(~x"./transition"el) |> Enum.map(&parse_transition/1)
    }
  end

  defp parse_transition(transition_element) do
    %SC.Transition{
      event: transition_element |> xpath(~x"./@event"s) |> empty_to_nil(),
      target: transition_element |> xpath(~x"./@target"s) |> empty_to_nil(),
      cond: transition_element |> xpath(~x"./@cond"s) |> empty_to_nil()
    }
  end

  defp parse_data_element(data_element) do
    %SC.DataElement{
      id: data_element |> xpath(~x"./@id"s),
      expr: data_element |> xpath(~x"./@expr"s) |> empty_to_nil(),
      src: data_element |> xpath(~x"./@src"s) |> empty_to_nil()
    }
  end

  # Extract xmlns from raw XML element since SweetXml doesn't handle it well
  defp extract_xmlns({:xmlElement, _, _, _, _, _, _, attributes, _, _, _, _}) do
    case Enum.find(attributes, fn
           {:xmlAttribute, :xmlns, _, _, _, _, _, _, _value, _} -> true
           _ -> false
         end) do
      {:xmlAttribute, :xmlns, _, _, _, _, _, _, value, _} -> to_string(value)
      nil -> nil
    end
  end

  # Helper to convert empty strings to nil
  defp empty_to_nil(""), do: nil
  defp empty_to_nil(value), do: value
end
