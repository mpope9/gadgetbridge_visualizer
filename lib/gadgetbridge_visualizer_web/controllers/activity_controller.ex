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
        nil -> Steps.per_diem(datetime_start, datetime_end)
        "hour" -> Steps.per_hour(datetime_start, datetime_end)
        "day" -> Steps.per_diem(datetime_start, datetime_end)
        "week" -> Steps.per_week(datetime_start, datetime_end)
        "month" -> Steps.per_month(datetime_start, datetime_end)
        "year" -> Steps.per_year(datetime_start, datetime_end)
      end

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

    activity_steps_grouping = get_activity_steps_grouping(conn)

    conn_new =
      conn
      |> assign(:activity_grouping_hour_active, @activity_grouping_is_white)
      |> assign(:activity_grouping_day_active, @activity_grouping_is_white)
      |> assign(:activity_grouping_week_active, @activity_grouping_is_white)
      |> assign(:activity_grouping_month_active, @activity_grouping_is_white)
      |> assign(:activity_grouping_year_active, @activity_grouping_is_white)

    case activity_steps_grouping do
      "hour" -> assign(conn_new, :activity_grouping_hour_active, @activity_grouping_is_primary)
      "day" -> assign(conn_new, :activity_grouping_day_active, @activity_grouping_is_primary)
      "week" -> assign(conn_new, :activity_grouping_week_active, @activity_grouping_is_primary)
      "month" -> assign(conn_new, :activity_grouping_month_active, @activity_grouping_is_primary)
      "year" -> assign(conn_new, :activity_grouping_year_active, @activity_grouping_is_primary)
    end
  end

  defp get_activity_steps_grouping(conn) do
    case get_session(conn, :activity_steps_grouping) do
      nil -> "day"
      grouping -> grouping
    end
  end
end
