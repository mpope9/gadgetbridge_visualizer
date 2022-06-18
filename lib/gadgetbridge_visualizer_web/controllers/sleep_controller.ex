defmodule GadgetbridgeVisualizerWeb.SleepController do
  use GadgetbridgeVisualizerWeb, :controller

  alias GadgetbridgeVisualizer.DbUtils
  alias GadgetbridgeVisualizer.Utils

  def index(conn, _params) do

    {datetime_start, datetime_end} =
      DbUtils.default_date_range(get_session(conn, :date_start), get_session(conn, :date_end))

    conn
    # Section title.
    |> assign(:title, "Stats")
    |> assign(:sub_title, "Sleep")
    # Form vals.
    |> assign(:date_start, datetime_start |> DateTime.to_date |> Date.to_string)
    |> assign(:date_end, datetime_end |> DateTime.to_date |> Date.to_string)
    # Activates side-bar section.
    |> assign(:sleep_active, Utils.activation_class())
    |> render("index.html")
  end
end
