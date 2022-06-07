defmodule GadgetbridgeVisualizerWeb.PageController do
  use GadgetbridgeVisualizerWeb, :controller

  alias GadgetbridgeVisualizer.HeartRate
  alias GadgetbridgeVisualizer.DbUtils
  alias GadgetbridgeVisualizer.Steps
  alias GadgetbridgeVisualizer.Utils

  @doc """
  Index, EG the 'Overview' page.

  Using quick-and-dirty tricks to embed the JS variables directly
  in the HTML.
  """
  def index(conn, _params) do

    {datetime_start, datetime_end} = DbUtils.default_date_range()
 
    heart_rate_avg = HeartRate.avg(datetime_start, datetime_end)
    steps_total = Steps.total(datetime_start, datetime_end)
    {heart_rate_labels, heart_rate_data} =
      HeartRate.heart_rates(datetime_start, datetime_end)

    heart_rate_labels_json = Jason.encode!(heart_rate_labels)
    heart_rate_data_json = Jason.encode!(heart_rate_data)

    conn
    # Section title.
    |> assign(:title, "Stats")
    |> assign(:sub_title, "Overview")
    # Activates side-bar section.
    |> assign(:overview_active, Utils.activation_class())
    # Page specific assigns.
    |> assign(:heart_rate_avg, heart_rate_avg)
    |> assign(:steps_total, steps_total)
    |> assign(:heart_rate_labels, heart_rate_labels_json)
    |> assign(:heart_rate_data, heart_rate_data_json)
    |> render("index.html")
  end

  def about(conn, _params) do
    conn
    # Section title.
    |> assign(:title, "System")
    |> assign(:sub_title, "About")
    # Activates side-bar section.
    |> assign(:about_active, Utils.activation_class())
    |> render("about.html")
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
