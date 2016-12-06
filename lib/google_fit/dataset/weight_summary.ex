defmodule GoogleFit.Dataset.WeightSummary do
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
    raise "Unknown weight summary format #{inspect unknown}"
  end
end
