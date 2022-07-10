defmodule GadgetbridgeVisualizerWeb.ActivityController do
  use GadgetbridgeVisualizerWeb, :controller

  alias GadgetbridgeVisualizer.HeartRate
  alias GadgetbridgeVisualizer.Activity
  alias GadgetbridgeVisualizer.DbUtils
  alias GadgetbridgeVisualizer.Steps
  alias GadgetbridgeVisualizer.Utils

  @activity_grouping_is_white "dropdown-item button is_white"
  @activity_grouping_is_primary "dropdown-item button is-primary"

  def index(conn, _params) do

    {datetime_start, datetime_end} =
      DbUtils.default_date_range(get_session(conn, :date_start), get_session(conn, :date_end))

    step_fun = get_step_fun(get_session(conn, :activity_steps_grouping))
    {steps_per_day_labels, steps_per_day_data} = step_fun.(datetime_start, datetime_end)

    steps_total = Steps.total(datetime_start, datetime_end)
    days_total = Date.diff(DateTime.to_date(datetime_end), DateTime.to_date(datetime_start))

    {activities, duration_max} =
      Activity.activities(datetime_start, datetime_end)
      |> Enum.map(&map_row_data_to_activity/1)
      |> get_max_duration()

    # Transform values into JSON.
    json_steps_per_day_labels = Jason.encode!(steps_per_day_labels)
    json_steps_per_day_data = Jason.encode!(steps_per_day_data)

    conn
    ## Root-required values.
    |> assign(:title, "Stats")
    |> assign(:sub_title, "Activity")
    # Form vals.
    |> assign(:date_start, datetime_start |> DateTime.to_date |> Date.to_string)
    |> assign(:date_end, datetime_end |> DateTime.to_date |> Date.to_string)
    # Activates side-bar section.
    |> assign(:activity_active, Utils.activation_class())
    # Page specific assigns.
    |> assign(:steps_per_day_labels, json_steps_per_day_labels)
    |> assign(:steps_per_day_data, json_steps_per_day_data)
    |> assign(:activity_grouping_unit, get_activity_steps_grouping(conn))
    |> assign_active_activity_steps_grouping()
    |> assign(:steps_total, steps_total)
    |> assign(:days_total, days_total)
    |> render("index.html",
      activities: activities,
      duration_max: duration_max)
  end

  def set_activity_steps_grouping(conn, params) do

    %{
      "activity_steps_grouping" => activity_steps_grouping,
      "current_path"            => current_path
    } = params

    conn
    |> put_session(:activity_steps_grouping, activity_steps_grouping)
    |> redirect(to: current_path)
  end

  defp assign_active_activity_steps_grouping(conn) do

    conn_new =
      conn
      |> assign(:activity_grouping_hour_active, @activity_grouping_is_white)
      |> assign(:activity_grouping_day_active, @activity_grouping_is_white)
      |> assign(:activity_grouping_week_active, @activity_grouping_is_white)
      |> assign(:activity_grouping_month_active, @activity_grouping_is_white)
      |> assign(:activity_grouping_year_active, @activity_grouping_is_white)

    active_key = get_active_key(get_activity_steps_grouping(conn))

    assign(conn_new, active_key, @activity_grouping_is_primary)
  end

  defp get_active_key("hour"), do:  :activity_grouping_hour_active
  defp get_active_key("day"), do: :activity_grouping_day_active
  defp get_active_key("week"), do: :activity_grouping_week_active
  defp get_active_key("month"), do: :activity_grouping_month_active
  defp get_active_key("year"), do: :activity_grouping_year_active

  defp get_activity_steps_grouping(conn) do
    case get_session(conn, :activity_steps_grouping) do
      nil -> "day"
      grouping -> grouping
    end
  end

  defp get_step_fun(nil), do: &Steps.per_diem/2
  defp get_step_fun("hour"), do: &Steps.per_hour/2
  defp get_step_fun("day"), do: &Steps.per_diem/2
  defp get_step_fun("week"), do: &Steps.per_week/2
  defp get_step_fun("month"), do: &Steps.per_month/2
  defp get_step_fun("year"), do: &Steps.per_year/2

  defp map_row_data_to_activity(value) do
    {name, unix_start, unix_end, minutes_total, activity_kind} = value

    dt_start = DateTime.from_unix!(unix_start, :millisecond) |> DateTime.to_date
    dt_end = DateTime.from_unix!(unix_end, :millisecond) |> DateTime.to_date

    heart_rate_max = HeartRate.max(unix_start, unix_end)
    heart_rate_min = HeartRate.min(unix_start, unix_end)

    {name, dt_start, dt_end, minutes_total, activity_kind,
      heart_rate_max, heart_rate_min}
  end

  defp get_max_duration(activities) do
    duration_max =
      activities
      |> Enum.reduce(0, fn
        {_, _, _, minutes_total, _, _, _}, acc when minutes_total > acc -> minutes_total
        {_, _, _, _, _, _, _}, acc -> acc
      end)
    {activities, duration_max}
  end
end
