defmodule GoogleFit.Dataset do
  @moduledoc """
    This struct represents a span of time and the relevant data points for a data source
  """

  alias GoogleFit.{Request, DataSource, Dataset.Point}
  import GoogleFit.Util

  @enforce_keys ~w[data_source_id points start_time end_time]a
  defstruct @enforce_keys

  @path "datasets"
  @nano_factor 1_000_000_000

  def get(client = %{},
          %DataSource{id: ds_id},
          start_time = %DateTime{},
          end_time =  %DateTime{}) do

    time_range = "#{to_nanos(start_time)}-#{to_nanos(end_time)}"
    path = [DataSource.path, ds_id, @path, time_range] |> Enum.join("/")

    %Request{client: client, path: path} |>
      Request.process(&decode/1)
  end

  @doc false
  def decode(%{
    "dataSourceId" => id,
    "point" => points,
    "minStartTimeNs" => min_nanos,
    "maxEndTimeNs" => max_nanos
  }) do
    %__MODULE__{
      data_source_id: id,
      points: decode_points(points),
      start_time: from_nanos(min_nanos),
      end_time: from_nanos(max_nanos)
    }
  end

  def decode(%{
      "dataset" => [%{
        "dataSourceId" => id,
        "point" => points}],
      "startTimeMillis" => start_ms,
      "endTimeMillis" => end_ms
      }) do
    %__MODULE__{
      data_source_id: id,
      points: decode_points(points),
      start_time: from_millis(start_ms),
      end_time: from_millis(end_ms)
    }
  end

  defp decode_points(points), do: Enum.map(points, &Point.decode/1)
  def to_nanos(dt), do: DateTime.to_unix(dt) * @nano_factor
end
