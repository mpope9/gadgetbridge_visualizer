defmodule GadgetbridgeVisualizerWeb.ActivityController do
  use GadgetbridgeVisualizerWeb, :controller

  alias GadgetbridgeVisualizer.Steps
  alias GadgetbridgeVisualizer.Utils

  def index(conn, _params) do
    conn
    |> assign(:title, "Stats")
    |> assign(:sub_title, "Activity")
    # Activates side-bar section.
    |> assign(:activity_active, Utils.activation_class())
    |> render("index.html")
  end

end
