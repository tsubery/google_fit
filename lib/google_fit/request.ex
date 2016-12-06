defmodule GoogleFit.Request do
  @base_url "https://www.googleapis.com/fitness/v1/users/me"
  @json_headers [{"content-type", "application/json"}]

  defstruct client: nil, path: "", params: [], body: "", method: :get

  def process(%__MODULE__{
    method: :get,
    client: client = %{ __struct__: http_lib},
    params: params,
    path: path
  }, decoder) do
    http_lib.get(client, url(path), [], params: params) |>
    handle_reply(decoder)
  end

  def process(%__MODULE__{
    method: :post,
    client: client = %{ __struct__: http_lib},
    body: body,
    path: path
  }, decoder) do

    http_lib.post(client, url(path), body, @json_headers)
    |> handle_reply(decoder)
  end

  defp handle_reply({:ok, %{body: body, status_code: 200}}, decoder) do
    {:ok, decoder.(body)}
  end

  defp handle_reply({_, error}, _), do: {:error, error}

  defp url(path) when is_binary(path), do: @base_url <> path
end
