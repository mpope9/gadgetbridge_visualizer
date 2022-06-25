defmodule GadgetbridgeVisualizerWeb.HeartController do
  use GadgetbridgeVisualizerWeb, :controller

  alias GadgetbridgeVisualizer.HeartRate
  alias GadgetbridgeVisualizer.DbUtils
  alias GadgetbridgeVisualizer.Utils

  @heart_rate_unit_is_white "dropdown-item button is_white"
  @heart_rate_unit_is_primary "dropdown-item button is-primary"

  def index(conn, _params) do

    {datetime_start, datetime_end} =
      DbUtils.default_date_range(get_session(conn, :date_start), get_session(conn, :date_end))
    heart_rate_avg = HeartRate.avg(datetime_start, datetime_end)
    heart_rate_max = HeartRate.max(datetime_start, datetime_end)
    heart_rate_min = HeartRate.min(datetime_start, datetime_end)

    heart_rate_use_raw =
      case get_heart_rate_unit(conn) do
        nil ->
          true

        "raw" ->
          true

        _ ->
          false
      end

    # Initialize vars to empty, init based on user flag as an optimization
    # (Less data for rolling, less calc for raw)
    {
      heart_rate_labels,
      heart_rate_data,
      rolling_labels,
      rolling_maxs,
      rolling_mins,
      rolling_avgs
    } = case heart_rate_use_raw do

      true ->

        {labels, data} =
          HeartRate.heart_rates(datetime_start, datetime_end)
        {labels, data, [], [], [], []}

      false ->

        {labels, max, min, avg} =
          HeartRate.rolling_heart_rate(datetime_start, datetime_end)
        {[], [], labels, max, min, avg}

    end

    heart_rate_labels_json = Jason.encode!(heart_rate_labels)
    heart_rate_data_json = Jason.encode!(heart_rate_data)

    heart_rate_chart_rolling_labels_json = Jason.encode!(rolling_labels)
    heart_rate_chart_maxs_json = Jason.encode!(rolling_maxs)
    heart_rate_chart_mins_json = Jason.encode!(rolling_mins)
    heart_rate_chart_avgs_json = Jason.encode!(rolling_avgs)

    conn
    # Section title.
    |> assign(:title, "Stats")
    |> assign(:sub_title, "Heart Rate")
    # Form vals.
    |> assign(:date_start, datetime_start |> DateTime.to_date |> Date.to_string)
    |> assign(:date_end, datetime_end |> DateTime.to_date |> Date.to_string)
    # Activates side-bar section.
    |> assign(:heart_rate_active, Utils.activation_class())
    # Page specific assigns.
    |> assign(:heart_rate_unit, get_heart_rate_unit(conn))
    ## Main heart rate chart.
    |> assign(:heart_rate_avg, heart_rate_avg)
    |> assign(:heart_rate_max, heart_rate_max)
    |> assign(:heart_rate_min, heart_rate_min)
    |> assign(:heart_rate_labels, heart_rate_labels_json)
    |> assign(:heart_rate_data, heart_rate_data_json)
    ## Rolling avgs chart.
    |> assign(:heart_rate_use_raw, heart_rate_use_raw)
    |> assign(:heart_rate_chart_rolling_labels, heart_rate_chart_rolling_labels_json)
    |> assign(:heart_rate_chart_maxs, heart_rate_chart_maxs_json)
    |> assign(:heart_rate_chart_mins, heart_rate_chart_mins_json)
    |> assign(:heart_rate_chart_avgs, heart_rate_chart_avgs_json)
    |> assign_active_heart_rate_unit()
    |> render("index.html")
  end

  def set_heart_rate_unit(conn, params) do

    %{
      "heart_rate_unit" => heart_rate_unit,
      "current_path"    => current_path
    } = params

    conn
    |> put_session(:heart_rate_unit, heart_rate_unit)
    |> redirect(to: current_path)
  end

  defp assign_active_heart_rate_unit(conn) do

    conn_new =
      conn
      |> assign(:heart_rate_raw_active, @heart_rate_unit_is_white)
      |> assign(:heart_rate_hourly_active, @heart_rate_unit_is_white)
      |> assign(:heart_rate_daily_active, @heart_rate_unit_is_white)
      |> assign(:heart_rate_weekly_active, @heart_rate_unit_is_white)

    active_key = get_active_key(get_heart_rate_unit(conn))

    assign(conn_new, active_key, @heart_rate_unit_is_primary)
  end

  defp get_active_key("raw"), do: :heart_rate_raw_active
  defp get_active_key("hour"), do: :heart_rate_hourly_active
  defp get_active_key("day"), do: :heart_rate_daily_active 
  defp get_active_key("week"), do: :heart_rate_hourly_active

  defp get_heart_rate_unit(conn) do
    case get_session(conn, :heart_rate_unit) do
      nil -> "raw"
      unit -> unit
    end
  end

end
