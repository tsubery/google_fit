defmodule GoogleFit.DataType do
  defmodule Field do
    @keys ~w[name format optional]a
    defstruct @keys

    @doc false
    def decode(json_map = %{}) do
      %__MODULE__{} |> Map.merge(GoogleFit.Util.normalize_keys(json_map, @keys))
    end
  end

  defstruct name: nil, fields: []

  @doc false
  def decode(json_map = %{}) do
    fields = Map.fetch!(json_map, "field") |>
      Enum.map(&Field.decode/1)
    %__MODULE__{
      name: json_map["name"],
      fields: fields
    }
  end
end
