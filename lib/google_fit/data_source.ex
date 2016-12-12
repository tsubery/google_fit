defmodule GoogleFit.DataSource do
  @moduledoc """
    This struct represents a single source of data in the platform.
    It could be a single sensor or app that reports data or a source that is
    derived from one or more other sources by merger and/or aggregation
  """

  alias GoogleFit.{Application, DataType, Request}
  @keys ~w[id name type data_type device application]a
  defstruct @keys

  @path "/dataSources"

  def path, do: @path

  def get(client = %{}, id) do
    req = %Request{client: client, path: "#{@path}/#{id}"}

    Request.process(req, &decode/1)
  end

  def list(client = %{}, data_type_name_filter \\ nil) do
    params = data_type_name_filter && %{dataTypeName: data_type_name_filter}

    req = %Request{client: client, path: @path, params: params}

    Request.process(req, &decode/1)
  end

  defmodule Device do
    @moduledoc """
      This struct represents details about a device that is reporting data to a data source
    """

    @keys ~w[uid type version model manufacturer]a
    defstruct @keys

    @doc false
    def decode(nil), do: nil
    def decode(map = %{}) do
      %__MODULE__{} |> Map.merge(GoogleFit.Util.normalize_keys(map, @keys))
    end
  end

  @doc false
  def decode(%{"dataSource" => json_map}) do
    json_map |> Enum.map(&decode/1)
  end

  def decode(ds_map = %{"dataStreamId" => id}) do

    application = Application.decode(ds_map["application"])
    data_type = DataType.decode(ds_map["dataType"])
    device = Device.decode(ds_map["device"])

    %__MODULE__{
      name: ds_map["dataStreamName"],
      type: ds_map["type"],
      application: application,
      data_type: data_type,
      device: device,
      id: id
    }
  end
end
