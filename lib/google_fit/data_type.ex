defmodule GoogleFit.DataType do
  @moduledoc """
    This struct represents data type for a particular data source.
    It containts list of fields and their primitive type (integer, float or map)
  """

  defmodule Field do
    @moduledoc """
      This struct represents a single field of a data type
    """

    @keys ~w[name format optional]a
    defstruct @keys

    @doc false
    def decode(json_map = %{"name" => name, "format" => format}) do
      %__MODULE__{
        name: name,
        format: format,
        optional: json_map |> Map.get("optional", false)
      }
    end
  end

  defstruct name: nil, fields: []

  @doc false
  def decode(%{"field" => field_json, "name" => name}) do
    %__MODULE__{
      name: name,
      fields: Enum.map(field_json, &Field.decode/1)
    }
  end
end
