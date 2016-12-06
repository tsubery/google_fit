defmodule GoogleFit.Dataset.Point do
  alias GoogleFit.Dataset.{Nutrition, ActivitySummary, WeightSummary}
  alias GoogleFit.ActivityType
  import GoogleFit.Util

  @bmr_units :"kCal/day"
  @steps_units :steps
  @weight_units :kg
  @hydration_units :liters
  @calories_units :kcal
  @speed_units :"meters/second"
  @distance_units :meters
  @unknown_units :unknown

  @enforce_keys ~w[
    data_type_name start_time end_time modified_time
    origin_data_source_id unit value
  ]a
  defstruct @enforce_keys

  # @type unit :: @steps_units | @bmr_units | @weight_units |
  # @hydration_units | @calories_units | @speed_units | @distance_units

  @doc false
  def decode(json_map = %{}) do
    data_type_name = json_map["dataTypeName"]
    {value, unit} = decode_value(data_type_name, json_map["value"])

    %__MODULE__{
      data_type_name: data_type_name,
      start_time: json_map["startTimeNanos"] |> from_nanos,
      end_time: json_map["endTimeNanos"] |> from_nanos,
      modified_time: json_map["modifiedTimeMillis"] |> from_millis,
      origin_data_source_id: json_map["originDataSourceId"],
      unit: unit,
      value: value
    }
  end

  @doc false
  defp decode_value("com.google.calories.bmr", [%{"fpVal" => val}]) do
    {val, @bmr_units}
  end

  defp decode_value("com.google.calories.expended", [%{"fpVal" => val}]) do
    {val, @calories_units}
  end

  defp decode_value("com.google.weight", [%{"fpVal" => val}]) do
    {val, @weight_units}
  end

  defp decode_value("com.google.hydration", [%{"fpVal" => val}]) do
    {val, @hydration_units}
  end

  defp decode_value("com.google.speed", [%{"fpVal" => val}]) do
    {val, @speed_units}
  end

  defp decode_value("com.google.distance.delta", [%{"fpVal" => val}]) do
    {val, @distance_units}
  end

  defp decode_value("com.google.step_count.delta", [%{"intVal" => val}]) do
    {val, @steps_units}
  end

  defp decode_value("com.google.activity.segment", [%{"intVal" => code}]) do
    {ActivityType.find(code), ActivityType}
  end

  defp decode_value("com.google.nutrition", json_list) do
    val = Nutrition.decode(json_list)
    {val, Nutrition}
  end

  defp decode_value("com.google.activity.summary", json_list) do
    val = ActivitySummary.decode(json_list)
    {val, ActivitySummary}
  end

  defp decode_value("com.google.weight.summary", json_list) do
    val = WeightSummary.decode(json_list)
    {val, WeightSummary}
  end

  defp decode_value(_, json_map), do: {json_map, @unknown_units}
end
