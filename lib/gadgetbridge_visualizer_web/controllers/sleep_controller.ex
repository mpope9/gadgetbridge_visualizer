defmodule GadgetbridgeVisualizerWeb.SleepController do
  use GadgetbridgeVisualizerWeb, :controller

  alias GadgetbridgeVisualizer.Utils

  def index(conn, _params) do
    conn
    # Section title.
    |> assign(:title, "Stats")
    |> assign(:sub_title, "Sleep")
    # Activates side-bar section.
    |> assign(:sleep_active, Utils.activation_class())
    |> render("index.html")
  end
end
