defmodule GadgetbridgeVisualizerWeb.ActivityController do
  use GadgetbridgeVisualizerWeb, :controller

  alias GadgetbridgeVisualizer.DbUtils
  alias GadgetbridgeVisualizer.Steps
  alias GadgetbridgeVisualizer.Utils

  @activity_grouping_is_white "dropdown-item button is_white"
  @activity_grouping_is_primary "dropdown-item button is-primary"

  def index(conn, _params) do

    {datetime_start, datetime_end} =
      DbUtils.default_date_range(get_session(conn, :date_start), get_session(conn, :date_end))

    {steps_per_day_labels, steps_per_day_data} =
      case get_session(conn, :activity_steps_grouping) do
        nil ->
          Steps.per_diem(datetime_start, datetime_end)

        "hour" ->
          Steps.per_hour(datetime_start, datetime_end)

        "day" ->
          Steps.per_diem(datetime_start, datetime_end)

        "week" ->
          Steps.per_week(datetime_start, datetime_end)

        "month" ->
          Steps.per_month(datetime_start, datetime_end)

        "year" ->
          Steps.per_year(datetime_start, datetime_end)
      end

    steps_total = Steps.total(datetime_start, datetime_end)
    days_total = Date.diff(DateTime.to_date(datetime_end), DateTime.to_date(datetime_start))

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
    |> render("index.html")
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
end
