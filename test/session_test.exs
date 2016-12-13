defmodule GoogleFitTest.Session do
  alias GoogleFit.Session
  alias Support.TestClient

  use ExUnit.Case
  doctest Session


  @start_iso "2011-03-04T08:07:30Z"
  @end_iso "2024-12-31T13:14:10Z"
  @start_dt DateTime.from_iso8601(@start_iso) |> elem(1)
  @end_dt DateTime.from_iso8601(@end_iso) |> elem(1)

  test "list function calls client with correct args" do
    test_client = %TestClient{id: "special snowflake"}

    {:error, {client, url, params}} = Session.list(test_client, @start_dt, @end_dt)

    assert url == "https://www.googleapis.com/fitness/v1/users/me/sessions"
    assert client == test_client
    assert params == %{startTime: @start_iso,  endTime: @end_iso}
  end

  test "decoding sessions" do
    input = %{
      "session" => [
        %{
          "id" => "id123",
          "name" => "Dave",
          "description" => "great session",
          "startTimeMillis" => "1299226050000",
          "endTimeMillis" => "1735650850000",
          "modifiedTimeMillis" => "86400000",
          "application" => %{
            "packageName" => "com.poop",
            "version" => "1.0",
            "detailsUrl" => "http://yourmom.com",
            "name" => "Bo"
          },
          "activityType" => 0,
          "activeTimeMillis" => 1500
        },
        %{
          "id" => "id456",
          "name" => "Dave",
          "description" => "great session",
          "startTimeMillis" => "1299226050000",
          "endTimeMillis" => "1735650850000",
          "modifiedTimeMillis" => "86400000",
          "application" => %{
            "packageName" => "com.poop",
            "version" => "1.0",
            "detailsUrl" => "http://yourmom.com",
            "name" => "Bo"
          },
          "activityType" => 0,
          "activeTimeMillis" => 1500
        }
      ]
    }
    sessions = Session.decode(input)
    assert length(sessions) == 2
    assert ["id123", "id456"] == Enum.map(sessions, &(&1.id))
    sessions |> Enum.each(fn s ->
      assert s.name == "Dave"
      assert s.description == "great session"
      assert DateTime.to_unix(s.start_time) == DateTime.to_unix(@start_dt)
      assert DateTime.to_unix(s.end_time) == DateTime.to_unix(@end_dt)
      assert DateTime.to_unix(s.modified_time) == 86400
      assert s.application == %GoogleFit.Application{
        details_url: "http://yourmom.com",
        name: "Bo",
        package_name: "com.poop",
        version: "1.0"
      }
      assert s.activity_type == GoogleFit.ActivityType.InVehicle
      assert s.active_time_millis == 1500
    end)

  end
end
