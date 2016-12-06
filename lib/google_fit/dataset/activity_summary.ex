defmodule GoogleFit.Dataset.ActivitySummary do
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
    raise "Unknown activity summary format #{inspect unknown}"
  end
end
