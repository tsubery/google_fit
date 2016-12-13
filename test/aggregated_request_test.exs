defmodule GoogleFitTest.AggregateRequest do
  alias GoogleFit.{AggregateRequest, DataSource, DataType}

  use ExUnit.Case
  @start_iso "2011-03-04"
  @end_iso "2024-12-31"
  @start_date Date.from_iso8601(@start_iso) |> elem(1)
  @end_date Date.from_iso8601(@end_iso) |> elem(1)

  test "by_time & data source & day" do
    ds = %DataSource{id: "news"}
    req = AggregateRequest.by_time(@start_date, @end_date, "day", ds)

    assert req.body == %{
      :startTimeMillis => 1299196800000,
      :endTimeMillis => 1735603200000,
      "aggregateBy" => [%{dataSourceId: "news"}],
      "bucketByTime" => [%{
        durationMillis: 86400000,
        period: %{type: "day"}
      }]
    }
  end

  test "by_time period of week" do
    ds = %DataSource{id: "news"}
    req = AggregateRequest.by_time(@start_date, @end_date, "week", ds)

    assert req.body == %{
      :startTimeMillis => 1299196800000,
      :endTimeMillis => 1735603200000,
      "aggregateBy" => [%{dataSourceId: "news"}],
      "bucketByTime" => [%{
        durationMillis: 7*86400000,
        period: %{type: "week"}
      }]
    }
  end

  test "by_time data type" do
    ds = %DataType{name: "com.poop.now"}
    req = AggregateRequest.by_time(@start_date, @end_date, "day", ds)

    assert req.body == %{
      :startTimeMillis => 1299196800000,
      :endTimeMillis => 1735603200000,
      "aggregateBy" => [%{"dataTypeName": "com.poop.now"}],
      "bucketByTime" => [%{
        durationMillis: 86400000,
        period: %{type: "day"}
      }]
    }
  end

  test "by time in the 70s" do
    ds = %DataType{name: "com.poop.now"}
    req = AggregateRequest.by_time(~D[1970-01-01], ~D[1970-01-11], "day", ds)

    assert req.body == %{
      :startTimeMillis => 0,
      :endTimeMillis => 10*86_400_000,
      "aggregateBy" => [%{"dataTypeName": "com.poop.now"}],
      "bucketByTime" => [%{
        durationMillis: 86400000,
        period: %{type: "day"}
      }]
    }
  end
end
