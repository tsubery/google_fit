defmodule GoogleFit.Session do
  @moduledoc """
    This module represents a span of time where the user has been engaged
    in a single activity.
    A session can be composed of multiple segments with various activity types.
    For example soccer could have rest in half-time.
  """
  alias GoogleFit.{Application, Request}
  import GoogleFit.Util

  @path "/sessions"
  @enforce_keys ~w[
    id name description start_time end_time modified_time application
    activity_type active_time_millis
  ]a

  defstruct @enforce_keys

  def list(client = %{}, start_time = %DateTime{}, end_time =  %DateTime{}) do
    params = %{
      startTime: google_iso8601(start_time),
      endTime: google_iso8601(end_time)
    }
    req = %Request{client: client, path: @path, params: params}
    Request.process(req, &decode/1)
  end

  @doc false
  def decode(%{"session" => sessions}) do
    sessions |> Enum.map(&decode_session/1)
  end

  defp decode_session(map = %{
    "id" => id,
    "startTimeMillis" => start_ms,
    "endTimeMillis" => end_ms
  }) do
    %__MODULE__{
      id: id,
      name: map["name"],
      description: map["description"],
      start_time: from_millis(start_ms),
      end_time: from_millis(end_ms),
      modified_time: from_millis(map["modifiedTimeMillis"]),
      application: Application.decode(map["application"]),
      activity_type: GoogleFit.ActivityType.find(map["activityType"]),
      active_time_millis: map["activeTimeMillis"],
    }
  end
  def google_iso8601(datetime) do
    datetime
    |> DateTime.to_iso8601
    |> String.replace(~r/:(\d\d)Z/,":\\1.000Z")
  end
end
