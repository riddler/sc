defmodule SC.Case do
  # alias StateChart.{Configuration,Event}
  use ExUnit.CaseTemplate, async: true

  using do
    quote do
      import unquote(__MODULE__)
    end
  end

  def test_scxml(_xml, _description, _conf, _events) do
    IO.puts("TODO: need to implement")
    # datamodels = %{
    #   "ecmascript" => StateChart.DataModel.ECMA,
    #   "elixir" => StateChart.DataModel.Elixir,
    #   "null" => StateChart.DataModel.Null
    # }
    #
    # opts = %{datamodels: datamodels}
    #
    # doc = StateChart.SCXML.parse(xml, opts)
    # context = %{}
    #
    # StateChart.interpret(doc, context)
    # # TODO
    # |> loop(conf, events)
  end

  # defp loop({:await, int, context}, conf, [{event, next} | events]) do
  #   assert_configuration(int, conf)
  #   StateChart.handle_event(int, event, context)
  #   |> loop(next, events)
  # end
  # defp loop({:await, int, _context}, conf, []) do
  #   assert_configuration(int, conf)
  #   assert false, "End of events and not done"
  # end
  # defp loop({:done, int, _context}, conf, []) do
  #   assert_configuration(int, conf)
  #   :ok
  # end
  # defp loop({:done, int, _context}, conf, events) do
  #   assert_configuration(int, conf)
  #   expected = []
  #   actual = Enum.map(events, fn({event, _}) -> Event.new(event) end)
  #   assert expected == actual
  # end
  #
  # defp assert_configuration(int, expected) do
  #   expected = MapSet.new(expected)
  #   actual = Configuration.active_states(int)
  #   assert expected == actual
  # end
end
