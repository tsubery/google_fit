defmodule GoogleFit.Util do
  def atomize_keys(map = %{}) do
    transform_keys(map, &String.to_atom/1)
  end

  def underscorize_keys(map = %{}) do
    transform_keys(map, &Macro.underscore/1)
  end

  def transform_keys(map = %{}, fun) do
    Enum.reduce(map, %{},
      fn({k,v}, acc) ->
        Map.put(acc, fun.(k), v)
      end
    )
  end

  def transform_values(map = %{}, fun) do
    Enum.reduce(map, %{},
      fn({k,v}, acc) ->
        Map.put(acc, k, fun.(v))
      end
    )
  end

  def normalize_keys(map = %{}, keys) do
    map |>
      underscorize_keys |>
      transform_keys(&(String.replace(&1,~r/[^a-z]/i,"_"))) |>
      atomize_keys |>
      Map.split(keys) |>
      elem(0)
  end

  def from_nanos(str), do: to_datetime(str, :nanosecond)
  def from_millis(str), do: to_datetime(str, :millisecond)

  defp to_datetime(nil, _), do: nil
  defp to_datetime(str, unit) do
    str |> String.to_integer |> DateTime.from_unix!(unit)
  end

  def date_to_millis(date = %Date{}) do
    dt_iso = "#{Date.to_iso8601(date)}T00:00:00.000Z"
    case DateTime.from_iso8601(dt_iso) do
      {:ok, date_time, _offset } ->
         DateTime.to_unix(date_time) * 1_000
      error ->
        raise "Can't convert to millis #{inspect date} #{inspect error}"
    end
  end
end
