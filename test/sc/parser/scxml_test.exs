defmodule SC.Parser.SCXMLTest do
  use ExUnit.Case, async: true

  alias SC.Document
  alias SC.Parser.SCXML

  describe "parse/1" do
    test "parses simple SCXML document" do
      xml = """
      <?xml version="1.0" encoding="UTF-8"?>
      <scxml xmlns="http://www.w3.org/2005/07/scxml" version="1.0" initial="a">
        <state id="a"/>
      </scxml>
      """

      assert {:ok, %Document{} = doc} = SCXML.parse(xml)
      assert doc.xmlns == "http://www.w3.org/2005/07/scxml"
      assert doc.version == "1.0"
      assert doc.initial == "a"
      assert length(doc.states) == 1

      state = hd(doc.states)
      assert state.id == "a"
      assert state.initial == nil
      assert state.states == []
      assert state.transitions == []
    end

    test "parses SCXML with transition" do
      xml = """
      <?xml version="1.0" encoding="UTF-8"?>
      <scxml xmlns="http://www.w3.org/2005/07/scxml" version="1.0" initial="a">
        <state id="a">
          <transition event="go" target="b"/>
        </state>
        <state id="b"/>
      </scxml>
      """

      assert {:ok, %Document{} = doc} = SCXML.parse(xml)
      assert length(doc.states) == 2

      [state_a, state_b] = doc.states
      assert state_a.id == "a"
      assert state_b.id == "b"

      assert length(state_a.transitions) == 1
      transition = hd(state_a.transitions)
      assert transition.event == "go"
      assert transition.target == "b"
      assert transition.cond == nil
    end

    test "parses SCXML with datamodel" do
      xml = """
      <?xml version="1.0" encoding="UTF-8"?>
      <scxml xmlns="http://www.w3.org/2005/07/scxml" version="1.0" datamodel="elixir">
        <datamodel>
          <data id="counter" expr="0"/>
          <data id="name"/>
        </datamodel>
        <state id="start"/>
      </scxml>
      """

      assert {:ok, %Document{} = doc} = SCXML.parse(xml)
      assert doc.datamodel == "elixir"
      assert length(doc.datamodel_elements) == 2

      [counter, name] = doc.datamodel_elements
      assert counter.id == "counter"
      assert counter.expr == "0"
      assert counter.src == nil

      assert name.id == "name"
      assert name.expr == nil
    end

    test "parses nested states" do
      xml = """
      <?xml version="1.0" encoding="UTF-8"?>
      <scxml xmlns="http://www.w3.org/2005/07/scxml" version="1.0" initial="parent">
        <state id="parent" initial="child1">
          <state id="child1">
            <transition event="next" target="child2"/>
          </state>
          <state id="child2"/>
        </state>
      </scxml>
      """

      assert {:ok, %Document{} = doc} = SCXML.parse(xml)
      assert length(doc.states) == 1

      parent = hd(doc.states)
      assert parent.id == "parent"
      assert parent.initial == "child1"
      assert length(parent.states) == 2

      [child1, child2] = parent.states
      assert child1.id == "child1"
      assert child2.id == "child2"

      assert length(child1.transitions) == 1
      transition = hd(child1.transitions)
      assert transition.event == "next"
      assert transition.target == "child2"
    end

    test "handles empty attributes as nil" do
      xml = """
      <?xml version="1.0" encoding="UTF-8"?>
      <scxml xmlns="http://www.w3.org/2005/07/scxml" version="1.0">
        <state id="test">
          <transition target="end"/>
        </state>
        <state id="end"/>
      </scxml>
      """

      assert {:ok, %Document{} = doc} = SCXML.parse(xml)
      assert doc.initial == nil

      state = hd(doc.states)
      assert state.initial == nil

      transition = hd(state.transitions)
      assert transition.event == nil
      assert transition.cond == nil
      assert transition.target == "end"
    end

    test "returns error for invalid XML" do
      xml = "<invalid><unclosed>"

      assert {:error, _reason} = SCXML.parse(xml)
    end
  end
end
