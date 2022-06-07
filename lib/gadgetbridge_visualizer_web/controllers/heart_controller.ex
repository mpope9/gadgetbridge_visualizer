defmodule GadgetbridgeVisualizerWeb.HeartController do
  use GadgetbridgeVisualizerWeb, :controller

  alias GadgetbridgeVisualizer.HeartRate
  alias GadgetbridgeVisualizer.DbUtils
  alias GadgetbridgeVisualizer.Utils

  def index(conn, _params) do

    {datetime_start, datetime_end} = DbUtils.default_date_range()
    heart_rate_avg = HeartRate.avg(datetime_start, datetime_end)
    heart_rate_max = HeartRate.max(datetime_start, datetime_end)
    heart_rate_min = HeartRate.min(datetime_start, datetime_end)

    {heart_rate_labels, heart_rate_data} =
      HeartRate.heart_rates(datetime_start, datetime_end)

    heart_rate_labels_json = Jason.encode!(heart_rate_labels)
    heart_rate_data_json = Jason.encode!(heart_rate_data)

    conn
    # Section title.
    |> assign(:title, "Stats")
    |> assign(:sub_title, "Heart Rate")
    # Activates side-bar section.
    |> assign(:heart_rate_active, Utils.activation_class())
    # Page specific assigns.
    |> assign(:heart_rate_avg, heart_rate_avg)
    |> assign(:heart_rate_max, heart_rate_max)
    |> assign(:heart_rate_min, heart_rate_min)
    |> assign(:heart_rate_labels, heart_rate_labels_json)
    |> assign(:heart_rate_data, heart_rate_data_json)
    |> render("index.html")
  end

end
