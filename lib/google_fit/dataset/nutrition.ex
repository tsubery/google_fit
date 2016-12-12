defmodule GoogleFit.Dataset.Nutrition do
  @moduledoc """
    This struct represents a nutrition datapoint value
  """

  import GoogleFit.Util

  @meal_types %{
    0 => Unknown,
    1 => Breakfast,
    2 => Lunch,
    3 => Dinner,
    4 => Snack
  }
  @keys ~w[
    meal_type food_item calories fat_total fat_saturated fat_unsaturated
    fat_polyunsaturated fat_monounsaturated fat_trans cholesterol sodium
    potassium carbs_total dietary_fiber sugar protein vitamin_a vitamin_c
    calcium
    ]a

  defstruct @keys

  @doc false
  def decode(json_list) do
    json_list |> Enum.reduce(%__MODULE__{}, &decode/2)
  end

  defp decode(%{"mapVal" => list}, acc = %__MODULE__{})
  when length(list) > 0 do
    new_map = list |>
      Enum.reduce(%{},&decode_kv/2) |>
      normalize_keys(@keys) |>
      transform_values(&(Map.fetch!(&1,"fpVal")))
    Map.merge(acc, new_map)
  end

  @doc false
  defp decode(%{"intVal" => meal_type_code}, acc = %__MODULE__{}) do
    %{acc | :meal_type => Map.fetch!(@meal_types, meal_type_code)}
  end

  @doc false
  defp decode(%{"stringVal" => food_item}, acc = %__MODULE__{}) do
    %{acc | :food_item => food_item}
  end

  @doc false
  defp decode(unknown, _ = %__MODULE__{}) do
    raise "Unknown nutritional format #{inspect unknown}"
  end

  defp decode_kv(%{"key" => k, "value" => v}, acc) do
    Map.put(acc, k, v)
  end

end
