defmodule RegressionTest do
  alias GoogleFit.{Session, Dataset, DataSource, DataType, AggregateRequest}
  require IEx
  use ExUnit.Case
  doctest GoogleFit

  @moduletag :external
  @nutrition_ds_id "raw:com.google.nutrition:com.sillens.shapeupclub:"
  @steps_ds_id "derived:com.google.step_count.delta:com.google.android.gms:estimated_steps"
  @regression_dir "test/regression_data"
  @init_reg_repo ~c[
    (cd #{@regression_dir} && test -d .git && git reset --hard && git clean -d -f) ||
    (cd #{@regression_dir} && git init && git add . && git commit -am "init")
  ]
  @check_reg_repo ~c[cd #{@regression_dir} && git status -s]

  setup_all do
    File.mkdir_p(@regression_dir)
    if nil == System.get_env("CI") do
      :os.cmd(@init_reg_repo)

      on_exit fn ->
        :os.cmd(@check_reg_repo) |> IO.puts
      end
    else
      IO.puts "Skipping regression git"
    end
    :ok
  end

  def same_as_before(key, content) do
    file = "#{@regression_dir}/#{key}.json"
    encoded = Poison.encode!(content)
               |> String.replace(~r/([{},])/,"\\1\n")

    if System.get_env("WRITE_REGRESSION") do
      File.write!(file, encoded)
    end
    case File.read(file) do
      {:ok, reference} ->
        assert encoded == reference
      {:error, reason} ->
        raise "Couldn't read reference file #{file} because #{reason}. Try setting WRITE_REGRESSION in environment"
    end
  end

  def client do
    token = %OAuth2.AccessToken{
      refresh_token: System.get_env("MY_GFIT_REFRESH_TOKEN") || raise("missing_env")
    }
    oc = OAuth2.Client.new(
    [
      token: token,
      strategy: OAuth2.Strategy.Refresh,
      client_id: System.get_env("GOOGLE_CLIENT_ID") || raise("missing env"),
      client_secret: System.get_env("GOOGLE_CLIENT_SECRET") || raise("missing_env"),
      site: "https://accounts.google.com",
      redirect_uri: "https://tbd.com/auth/callback",
      authorize_url: "https://accounts.google.com/o/oauth2/v2/auth",
      token_url: "https://www.googleapis.com/oauth2/v4/token",
      scope: ~s{
        https://www.googleapis.com/auth/fitness.nutrition.read,
        https://www.googleapis.com/auth/fitness.activity.read,
        https://www.googleapis.com/auth/fitness.body.read,
      }
    ])
    {:ok, client} = OAuth2.Client.refresh_token(oc, [], [], [])
    client
  end

  test "sessions get" do
    {:ok, start_time, 0} = DateTime.from_iso8601("2016-11-29T13:23:13.00000Z")
    {:ok, end_time, 0} = DateTime.from_iso8601("2016-11-29T13:23:15.00000Z")
    {:ok, sessions} = Session.list(client(), start_time, end_time)
    sunday_sleep = %Session{
      name: "Sleep",
      id: "f7ef3033640afcd77ab4be85ef852a7d"
    } = hd(sessions)
    assert sunday_sleep.application.package_name == "com.urbandroid.sleep"
    assert same_as_before("sessions", sessions)
  end

  test "nutrition dataset" do
    {:ok, start_ts, 0} = DateTime.from_iso8601("2016-12-11T00:00:00Z")
    {:ok, end_ts, 0} = DateTime.from_iso8601("2016-12-18T00:00:00Z")
    {:ok, ds = %Dataset{}} =
      Dataset.get(client(),
                  %DataSource{id: @nutrition_ds_id},
                  start_ts,
                  end_ts
                )
    assert length(ds.points) == 72
    assert same_as_before("nutrition_ds", ds)
  end
  test "steps dataset" do
    {:ok, start_ts, 0} = DateTime.from_iso8601("2016-12-01T23:04:08Z")
    {:ok, end_ts, 0} = DateTime.from_iso8601("2016-12-05T23:04:08Z")
    {:ok, ds = %Dataset{}} =
      Dataset.get(client(),
                  %DataSource{id: @steps_ds_id},
                  start_ts,
                  end_ts
                )
    assert length(ds.points) == 663
    assert same_as_before("steps_ds", ds)
  end

  def test_steps_ds(steps_source = %DataSource{}) do
    assert steps_source
    assert steps_source.type == "derived"
    assert steps_source.name == "estimated_steps"

    dt_fields = steps_source.data_type.fields
    assert hd(dt_fields).name == "steps"
  end

  test "data_source get" do
    {:ok, ds } = DataSource.get(client(), @steps_ds_id)
    assert same_as_before("steps_data_source", ds)
    test_steps_ds(ds)
  end

  test "data_sources list" do
    {:ok, data_sources} = DataSource.list(client())
    assert length(data_sources) == 167
    assert same_as_before("data_sources", data_sources)

    test_steps_ds (data_sources |> Enum.find(&(&1.id == @steps_ds_id)))
  end

  test "aggregate" do
    {:ok, date1} = Date.from_iso8601("2016-11-15")
    {:ok, date2} = Date.from_iso8601("2016-12-10")
    supported_types = %{
      weight: %DataType{name: "com.google.weight"},
      steps: %DataType{name: "com.google.step_count.delta"},
      activity: %DataType{name: "com.google.activity.segment"},
      calories: %DataType{name: "com.google.calories.expended"},
      nutrition: %DataSource{id: @nutrition_ds_id},
      steps_ds_id: %DataSource{id: @steps_ds_id},
    }
    supported_periods = ["day", "week", "month"]

    test_client = client()
    supported_periods |> Enum.each( fn period ->
      supported_types |> Enum.map(fn {name, filter} ->
        agg = AggregateRequest.by_time(date1, date2, period, filter)
        {:ok, datasets} = AggregateRequest.get(test_client, agg)
        # IO.puts "period: #{period}, name: #{name}, #{length(datasets)}"
        assert same_as_before("agg_#{period}_#{name}", datasets)
      end)
    end)
  end
end
