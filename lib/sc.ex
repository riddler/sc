defmodule SC do
  @moduledoc """
  ⚠️ **DEPRECATED**: This package has been renamed to **Statifier**.

  ## Migration

  This `sc` package is deprecated. Please migrate to the new `statifier` package:

  ```elixir
  # In mix.exs
  def deps do
    [
      {:statifier, "~> 1.1"}  # ✅ Use this instead
      # {:sc, "~> 1.0"}      # ❌ Deprecated
    ]
  end
  ```

  ## Code Migration

  Simply replace `SC.` with `Statifier.` throughout your codebase:

  ```elixir
  # Old (deprecated)
  {:ok, document} = SC.parse(xml)
  {:ok, state_chart} = SC.interpret(document)

  # New (current)
  {:ok, document} = Statifier.parse(xml)
  {:ok, state_chart} = Statifier.interpret(document)
  ```

  **New Repository**: https://github.com/riddler/statifier
  **Documentation**: https://hexdocs.pm/statifier
  """

  alias SC.{Interpreter, Parser.SCXML, Validator}

  @deprecated "Use Statifier.parse/1 instead. Add {:statifier, \"~> 1.1\"} to deps and replace SC with Statifier."
  defdelegate parse(source_string), to: SCXML

  @deprecated "Use Statifier.validate/1 instead. Add {:statifier, \"~> 1.1\"} to deps and replace SC with Statifier."
  defdelegate validate(document), to: Validator

  @deprecated "Use Statifier.interpret/1 instead. Add {:statifier, \"~> 1.1\"} to deps and replace SC with Statifier."
  defdelegate interpret(document), to: Interpreter, as: :initialize
end
