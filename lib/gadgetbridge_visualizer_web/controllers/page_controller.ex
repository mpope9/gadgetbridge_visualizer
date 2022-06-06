defmodule GadgetbridgeVisualizerWeb.PageController do
  use GadgetbridgeVisualizerWeb, :controller

  alias GadgetbridgeVisualizer.HeartRate
  alias GadgetbridgeVisualizer.DbUtils
  alias GadgetbridgeVisualizer.Steps

  @doc """
  Index, EG the 'Overview' page.

  Using quick-and-dirty tricks to embed the JS variables directly
  in the HTML.
  """
  def index(conn, _params) do

    # Dummy Dates
    {:ok, now} = DateTime.now("Etc/UTC")
    today = DateTime.to_date(now)
    time = DateTime.to_time(now)

    {:ok, datetime_earlier} = DateTime.new(Date.add(today, -2), time)
    {:ok, datetime_today} = DateTime.new(today, time)
    # End dummy dates.
  
    heart_rate_avg = HeartRate.avg(datetime_earlier, datetime_today)
    steps_total = Steps.total(datetime_earlier, datetime_today)
    {heart_rate_labels, heart_rate_data} =
      HeartRate.heart_rates(datetime_earlier, datetime_today)

    heart_rate_labels_json = Jason.encode!(heart_rate_labels)
    heart_rate_data_json = Jason.encode!(heart_rate_data)

    conn
    |> assign(:heart_rate_avg, heart_rate_avg)
    |> assign(:steps_total, steps_total)
    |> assign(:heart_rate_labels, heart_rate_labels_json)
    |> assign(:heart_rate_data, heart_rate_data_json)
    |> render("index.html")
  end

  # Gets binary data from the request, merges databases.
  def update(conn, _params) do
    import_db = "/tmp/Gadgetbridge_#{random_str(10)}"

    {:ok, body, _conn} = Plug.Conn.read_body(conn)
    File.open!(import_db, [:write], fn file ->
      :ok = IO.binwrite(file, body)
    end)

    DbUtils.merge_sqlite(import_db)

    File.rm!(import_db)

    conn
    |> put_status(:created)
    |> json(%{ok: "ok"})
  end

  defp random_str(length) do
    for _ <- 1..length, into: "", do: <<Enum.random('0123456789abcdef')>>
  end
end
