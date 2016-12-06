defmodule GoogleFit.Application do
  @keys ~w[package_name version details_url name]a
  defstruct @keys

  @doc false
  def decode(nil), do: nil
  def decode(map = %{}) do
    %__MODULE__{} |> Map.merge(GoogleFit.Util.normalize_keys(map, @keys))
  end
end
