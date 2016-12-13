defmodule GoogleFitTest.Dataset do
  alias GoogleFit.{Dataset, DataSource}
  alias Support.TestClient

  use ExUnit.Case
  @test_client %TestClient{id: "special snowflake"}

  @start_iso "2011-03-04T08:07:30Z"
  @end_iso "2024-12-31T13:14:10Z"
  @start_dt DateTime.from_iso8601(@start_iso) |> elem(1)
  @end_dt DateTime.from_iso8601(@end_iso) |> elem(1)

  test "get" do
    ds = %DataSource{id: "news"}
    {_, {client, url, params}} = Dataset.get(@test_client, ds, @start_dt, @end_dt)
    assert url ==
      "https://www.googleapis.com/fitness/v1/users/me/dataSources/news/datasets/1299226050000000000-1735650850000000000"
    assert client == @test_client
    assert 0 == Enum.count(params)
  end

  def decoding_works(input) do
    dataset = Dataset.decode(input)

    assert dataset.data_source_id == "id123"
    assert DateTime.to_unix(dataset.start_time) == 1299226050
    assert DateTime.to_unix(dataset.end_time) == 1735650850

    [p1, p2] = dataset.points
    assert p1.data_type_name == "com.google.weight"
    assert p1.origin_data_source_id == "earth"
    assert DateTime.to_unix(p1.start_time) == DateTime.to_unix(@start_dt)
    assert DateTime.to_unix(p1.end_time) == DateTime.to_unix(@end_dt)
    assert p1.modified_time == nil
    assert p1.value == 201
    assert p1.unit == :kg

    assert p2.data_type_name == "com.google.weight"
    assert p2.origin_data_source_id == "mars"
    assert DateTime.to_unix(p2.start_time) == 1735650840
    assert DateTime.to_unix(p2.end_time) == 1735650450
    assert DateTime.to_unix(p2.modified_time) == 1735650850
    assert p2.value == 99.5
    assert p2.unit == :kg
  end

  test "decoding dataset" do
    input = %{
      "dataSourceId" => "id123",
      "minStartTimeNs" => "1299226050000000000",
      "maxEndTimeNs" => "1735650850000000000",
      "point" => [%{
        "dataTypeName" => "com.google.weight",
        "startTimeNanos" => "1299226050000000000",
        "endTimeNanos" => "1735650850000000000",
        "modifiedTimeMillis" => nil,
        "originDataSourceId" => "earth",
        "value" => [%{"intVal" => 201}],
        }, %{
        "dataTypeName" => "com.google.weight",
        "startTimeNanos" => "1735650840000000000",
        "endTimeNanos" => "1735650450000000000",
        "modifiedTimeMillis" => "1735650850000",
        "originDataSourceId" => "mars",
        "value" => [%{"intVal" => 99.5}]
      }]
    }
    decoding_works(input)
  end

  test "decoding aggregated dataset" do
    input = %{
      "startTimeMillis" => "1299226050000",
      "endTimeMillis" => "1735650850000",
      "dataset" => [%{
        "dataSourceId" => "id123",
        "point" => [%{
          "dataTypeName" => "com.google.weight",
          "startTimeNanos" => "1299226050000000000",
          "endTimeNanos" => "1735650850000000000",
          "modifiedTimeMillis" => nil,
          "originDataSourceId" => "earth",
          "value" => [%{"intVal" => 201}],
          }, %{
          "dataTypeName" => "com.google.weight",
          "startTimeNanos" => "1735650840000000000",
          "endTimeNanos" => "1735650450000000000",
          "modifiedTimeMillis" => "1735650850000",
          "originDataSourceId" => "mars",
          "value" => [%{"intVal" => 99.5}]
        }]
      }]
    }
    decoding_works(input)
  end
end
