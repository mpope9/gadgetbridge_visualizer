defmodule GadgetbridgeVisualizerWeb.ActivityController do
  use GadgetbridgeVisualizerWeb, :controller

  alias GadgetbridgeVisualizer.DbUtils
  alias GadgetbridgeVisualizer.Steps
  alias GadgetbridgeVisualizer.Utils

  def index(conn, _params) do

    {datetime_start, datetime_end} = DbUtils.default_date_range()
    {steps_per_day_labels, steps_per_day_data} =
      Steps.per_diem(datetime_start, datetime_end)

    json_steps_per_day_labels = Jason.encode!(steps_per_day_labels)
    json_steps_per_day_data = Jason.encode!(steps_per_day_data)

    conn
    |> assign(:title, "Stats")
    |> assign(:sub_title, "Activity")
    # Activates side-bar section.
    |> assign(:activity_active, Utils.activation_class())
    # Page specific assigns.
    |> assign(:steps_per_day_labels, json_steps_per_day_labels)
    |> assign(:steps_per_day_data, json_steps_per_day_data)
    |> render("index.html")
  end

end
