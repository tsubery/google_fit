defmodule GoogleFit.Dataset.ActivitySummary do
  @moduledoc """
    This struct represents a aggregated activity datapoint value
  """
  alias GoogleFit.Dataset.ValueFormatError

  defstruct ~w[
    activity duration_millis num_segments
    ]a

  @doc false
  def decode([
    %{"intVal" => activity_code},
    %{"intVal" => duration_millis},
    %{"intVal" => num_segments}
   ]) do
  %__MODULE__{
    activity: GoogleFit.ActivityType.find(activity_code),
    duration_millis: duration_millis,
    num_segments: num_segments
  }
  end

  @doc false
  def decode(unknown) do
    raise ValueFormatError, message: "Unknown activity summary format #{inspect unknown}"
  end
end
