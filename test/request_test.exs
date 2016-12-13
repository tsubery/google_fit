defmodule GoogleFitTest.Request do
  alias GoogleFit.Request
  use ExUnit.Case

  defmodule ErrorClient do
    defstruct []
    def get(_,_,_,_), do: {:error, "errorsss"}
  end

  def fail_decoder(_body), do: raise "sum ting wong"
  def ok_decoer("body"), do: "works"

  test "when request fails does not call decoder" do
    req = %Request{client: %ErrorClient{}}
    {:error, reason} = Request.process(req, &fail_decoder/1)
    assert reason == "errorsss"
  end

  defmodule NotFoundClient do
    defstruct []
    def reply404(), do: %{status_code: 404, body: ""}
    def get(_,_,_,_), do: {:ok, reply404()}
  end

  test "when request succeed with status_code of 404" do
    req = %Request{client: %NotFoundClient{}}
    {:error, reason} = Request.process(req, &fail_decoder/1)
    assert reason == NotFoundClient.reply404
  end

  defmodule OkClient do
    defstruct []
    def reply200(), do: %{status_code: 200, body: "body"}
    def get(_,_,_,_), do: {:ok, reply200()}
  end

  test "when request has status code of 200 calls decoder" do
    req = %Request{client: %OkClient{}}
    assert_raise(RuntimeError, "sum ting wong", fn ->
      Request.process(req, &fail_decoder/1)
    end)
  end

  test "200 status code and working decoder" do
    req = %Request{client: %OkClient{}}
    {:ok, "works"} = Request.process(req, &ok_decoer/1)
  end
end
