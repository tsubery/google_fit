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
    %Request{client: client, path: "#{@path}/#{id}"}
    |> Request.process(&decode/1)
  end

  def list(client = %{}) do
    %Request{client: client, path: @path}
    |> Request.process(&decode/1)
  end

  def list(client = %{}, %DataType{name: dtn}) do
    %Request{client: client, path: @path, params: %{dataTypeName: dtn}}
    |> Request.process(&decode/1)
  end

  defmodule Device do
    @moduledoc """
      This struct represents details about a device that is reporting data to a data source
    """
    defstruct ~w[uid type version model manufacturer]a

    @doc false
    def decode(map = %{}) do
      %__MODULE__{
        uid: map["uid"],
        model: map["model"],
        type: map["type"],
        version: map["version"],
        manufacturer: map["manufacturer"]
      }
    end
  end

  @doc false
  def decode(%{"dataSource" => json_map}) do
    json_map |> Enum.map(&decode/1)
  end

  def decode(ds_map = %{"dataStreamId" => id, "dataType" => type}) do
    %__MODULE__{
      name: ds_map["dataStreamName"],
      type: ds_map["type"],
      application: Application.decode(ds_map["application"]),
      data_type: DataType.decode(type),
      device: ds_map["device"] && Device.decode(ds_map["device"]),
      id: id
    }
  end
end
