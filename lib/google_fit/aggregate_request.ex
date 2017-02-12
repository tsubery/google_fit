defmodule GoogleFit.AggregateRequest do
  @moduledoc """
    This module is used to wrap request for aggregated data.
  """

  alias __MODULE__, as: Self
  alias GoogleFit.{Request, DataSource, DataType, Util, Dataset}

  defstruct body: %{}

  @path "/dataset:aggregate"

  @day_millis 24 * 60 * 60 * 1000
  @duration_millis %{
    "day" => @day_millis,
    "week" => @day_millis * 7,
    "month" => @day_millis * 31
  }

  @doc """
    This function is used to build aggregation request for data that is
    aggregated by time period. e.g. Data about daily/weekly totals.
  """

  def by_time(start_date = %Date{}, end_date = %Date{}, period, filter)
    when period in ["day", "month", "week"] do

    %Self{}
    |> agg_range(start_date, end_date)
    |> agg_bucket(period)
    |> agg_by(filter)
  end

  @doc """
    This function makes an api call to request aggregated data from google.
  """

  def get(client = %{}, %Self{body: body}, opts \\ []) do
    %Request{client: client, body: body, method: :post, path: @path}
    |> Request.process(Keyword.get(opts, :decoder, &decode/1))
  end

  @doc false
  defp agg_by(%Self{body: body}, %DataSource{id: ds_id}) do
    %Self{body: Map.put(body, "aggregateBy", [%{"dataSourceId": ds_id}])}
  end

  defp agg_by(%Self{body: body}, %DataType{name: name}) do
    %Self{body: Map.put(body, "aggregateBy", [%{"dataTypeName": name}])}
  end

  defp agg_by(%Self{}, other) do
    raise "Unsupported aggregation filter type #{inspect other}"
  end

  @doc false
  defp agg_range(%Self{body: body}, start_date, end_date) do
    range = %{
      "startTimeMillis": start_date |> Util.date_to_millis,
      "endTimeMillis": end_date |> Util.date_to_millis
    }
    %Self{body: Map.merge(body,range)}
  end

  @doc false
  defp agg_bucket(%Self{body: body}, period) do
    bucket = %{
      "durationMillis": Map.fetch!(@duration_millis, period),
       #As of now, 'period' parameter is required but ignored by the server
      "period": %{"type": period}
    }
    %Self{body: Map.put(body, "bucketByTime", [bucket])}
  end

  @doc false
  def decode(%{"bucket" => list}), do: Enum.map(list, &Dataset.decode/1)
end
