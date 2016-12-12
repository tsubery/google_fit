defmodule GoogleFit.Dataset.Point do
  @moduledoc """
    This struct represents a datapoint in a dataset
  """

  alias GoogleFit.Dataset.{Nutrition, ActivitySummary, WeightSummary}
  alias GoogleFit.ActivityType
  import GoogleFit.Util

  @enforce_keys ~w[data_type_name start_time end_time modified_time origin_data_source_id unit value]a
  defstruct @enforce_keys

  @doc false
  def decode(json_map = %{"dataTypeName" => data_type_name}) do
    {value, unit} = data_type_name |>
      String.replace_prefix("com.google.","") |>
      decode_value(json_map["value"])

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

  @numeric_names ~w[calories.expended distance.delta calories.bmr hydration weight speed step_count.delta]
  @numeric_units ~w[kCal meters kCal/day liters kg meters/second steps]a
  @numeric_map Enum.zip(@numeric_names, @numeric_units) |> Map.new
  def decode_value(dtn, [%{"fpVal" => val}]) when dtn in @numeric_names do
    {val, Map.fetch!(@numeric_map, dtn)}
  end

  def decode_value(dtn, [%{"intVal" => val}]) when dtn in @numeric_names do
    {val, Map.fetch!(@numeric_map, dtn)}
  end

  @decoder_names ~w[nutrition nutrition.summary activity.summary weight.summary activity.segment]
  @decoder_modules [Nutrition, Nutrition, ActivitySummary, WeightSummary, ActivityType]
  @decoder_map Enum.zip(@decoder_names, @decoder_modules) |> Map.new
  @doc false
  def decode_value(dtn, json_list) when dtn in @decoder_names do
    module = Map.fetch!(@decoder_map, dtn)
    {module.decode(json_list), module}
  end

  @unknown_units :unknown
  def decode_value(_, json_map), do: {json_map, @unknown_units}
end
