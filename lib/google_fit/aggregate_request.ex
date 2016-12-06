defmodule GoogleFit.AggregateRequest do
  alias __MODULE__, as: Self
  alias GoogleFit.{Request, DataSource, DataType, Util, Dataset}

  defstruct body: %{}

  @path "/dataset:aggregate"

  @day_millis 24*60*60*1000
  @duration_millis %{
    "day" => @day_millis,
    "week" => @day_millis*7,
    "month" => @day_millis*31
  }

  def by_time(start_date = %Date{}, end_date = %Date{}, period, filter)
    when period in ["day", "month", "week"] do

    %Self{}
    |> agg_range(start_date, end_date)
    |> agg_bucket(period)
    |> agg_by(filter)
  end

  def get(client=%{}, %Self{body: body}) do
    %Request{client: client, body: body, method: :post, path: @path}
    |> Request.process(&decode/1)
  end

  defp agg_by(%Self{body: body}, %DataSource{id: ds_id}) do
    %Self{ body: Map.put(body, "aggregateBy", [ %{"dataSourceId": ds_id} ])}
  end

  defp agg_by(%Self{body: body}, %DataType{name: name}) do
    %Self{ body: Map.put(body, "aggregateBy", [ %{"dataTypeName": name} ])}
  end

  defp agg_by(%Self{}, other) do
    raise "Unsupported aggregation filter type #{inspect other}"
  end

  defp agg_range(%Self{body: body}, start_date, end_date) do
    range = %{
      "startTimeMillis": start_date |> Util.date_to_millis,
      "endTimeMillis": end_date |> Util.date_to_millis
    }
    %Self{ body: Map.merge(body,range)}
  end

  defp agg_bucket(%Self{body: body}, period) do
    bucket = %{
      "durationMillis": Map.fetch!(@duration_millis, period),
       #As of now, 'period' parameter is required but ignored by the server
      "period": %{ "type": "day" }
    }
    %Self{ body: Map.put(body, "bucketByTime", [ bucket ])}
  end

  def decode(%{"bucket" => list}), do: Enum.map(list, &Dataset.decode/1)
end
