defmodule SC.Parser.SCXML.FinalStateTest do
  use ExUnit.Case

  alias SC.Parser.SCXML

  test "parses final state correctly" do
    xml = """
    <?xml version="1.0" encoding="UTF-8"?>
    <scxml xmlns="http://www.w3.org/2005/07/scxml" version="1.0" initial="s1">
      <state id="s1">
        <transition target="final_state" event="done"/>
      </state>
      <final id="final_state"/>
    </scxml>
    """

    {:ok, document} = SCXML.parse(xml)

    # Find the final state
    final_state = Enum.find(document.states, &(&1.id == "final_state"))

    assert final_state != nil
    assert final_state.type == :final
    assert final_state.id == "final_state"
    assert final_state.initial == nil
    assert final_state.states == []
    assert final_state.transitions == []
  end

  test "parses final state with transitions" do
    xml = """
    <?xml version="1.0" encoding="UTF-8"?>
    <scxml xmlns="http://www.w3.org/2005/07/scxml" version="1.0" initial="s1">
      <state id="s1">
        <transition target="final_state" event="done"/>
      </state>
      <final id="final_state">
        <transition target="s1" event="restart"/>
      </final>
    </scxml>
    """

    {:ok, document} = SCXML.parse(xml)

    # Find the final state
    final_state = Enum.find(document.states, &(&1.id == "final_state"))

    assert final_state != nil
    assert final_state.type == :final
    assert final_state.id == "final_state"
    assert length(final_state.transitions) == 1

    transition = hd(final_state.transitions)
    assert transition.target == "s1"
    assert transition.event == "restart"
  end
end
