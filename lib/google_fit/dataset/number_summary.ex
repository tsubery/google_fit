defmodule GoogleFit.Dataset.NumberSummary do
  @moduledoc """
    This module represents daily aggregation for numeric data types
  """

  alias GoogleFit.Dataset.ValueFormatError

  defstruct ~w[average maximum minimum]a

  @doc false
  def decode([
    %{"fpVal" => avg},
    %{"fpVal" => max},
    %{"fpVal" => min}
   ]) do
  %__MODULE__{
    average: avg,
    maximum: max,
    minimum: min
  }
  end

  @doc false
  def decode(unknown) do
    raise ValueFormatError, message: "Unknown number summary format #{inspect unknown}"
  end
end
