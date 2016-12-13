defmodule GoogleFitTest.DataSource do
  alias GoogleFit.{DataSource, DataType}
  alias Support.TestClient

  use ExUnit.Case
  @test_client %TestClient{id: "special snowflake"}

  test "get" do
    {_, {client, url, params}} = DataSource.get(@test_client, "DeepThroat")

    assert url == "https://www.googleapis.com/fitness/v1/users/me/dataSources/DeepThroat"
    assert client == @test_client
    assert 0 == Enum.count(params)
  end

  test "list with no filter" do
    @test_client = %TestClient{id: "special snowflake"}

    {_, {client, url, params}} = DataSource.list(@test_client)

    assert url == "https://www.googleapis.com/fitness/v1/users/me/dataSources"
    assert client == @test_client
    assert 0 == Enum.count(params)
  end

  test "list with DataType filter" do
    @test_client = %TestClient{id: "special snowflake"}
    test_filter = %DataType{name: "Luna"}

    {_, {client, url, params}} = DataSource.list(@test_client, test_filter)

    assert url == "https://www.googleapis.com/fitness/v1/users/me/dataSources"
    assert client == @test_client
    assert params == %{dataTypeName: "Luna"}
  end

  test "decoding list of sources" do
    input = %{
      "dataSource" => [
        %{
          "dataStreamId" => "id123",
          "dataStreamName" => "Dave",
          "dataType" => %{
            "name" => "sleep",
            "field" => [
              %{"name" => "f15", "format" => "integer","optional" => true},
              %{"name" => "f16", "format" => "float"},
            ]
          },
          "device" => %{
            "uid" => "device id",
            "type" => "phone",
            "version" => "1.1",
            "model" => "S",
            "manufacturer" => "Evil corp"
          },
          "application" => %{
            "packageName" => "com.poop",
            "version" => "1.0",
            "detailsUrl" => "http://yourmom.com",
            "name" => "Bo"
          },
        },
        %{
          "dataStreamId" => "id456",
          "dataStreamName" => "Dave",
          "dataType" => %{
            "name" => "sleep",
            "field" => [
              %{"name" => "f15", "format" => "integer","optional" => true},
              %{"name" => "f16", "format" => "float"},
            ]
          },
          "device" => %{
            "uid" => "device id",
            "type" => "phone",
            "version" => "1.1",
            "model" => "S",
            "manufacturer" => "Evil corp"
          },
          "application" => %{
            "packageName" => "com.poop",
            "version" => "1.0",
            "detailsUrl" => "http://yourmom.com",
            "name" => "Bo"
          }
        }
      ]
    }
    sources = DataSource.decode(input)
    assert length(sources) == 2
    assert ["id123", "id456"] == Enum.map(sources, &(&1.id))
    sources |> Enum.each(fn s ->
      assert s.name == "Dave"
      assert s.application == %GoogleFit.Application{
        details_url: "http://yourmom.com",
        name: "Bo",
        package_name: "com.poop",
        version: "1.0"
      }
      assert s.data_type == %GoogleFit.DataType{
        name: "sleep",
        fields: [
          %GoogleFit.DataType.Field{format: "integer", name: "f15", optional: true},
          %GoogleFit.DataType.Field{format: "float", name: "f16", optional: false}
        ]
      }
      assert s.device == %GoogleFit.DataSource.Device{
        manufacturer: "Evil corp",
        model: "S",
        type: "phone",
        uid: "device id",
        version: "1.1"
      }

    end)

  end
end
