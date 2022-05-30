defmodule GadgetbridgeVisualizerWeb.PageController do
  use GadgetbridgeVisualizerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
