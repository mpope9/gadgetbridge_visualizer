defmodule GadgetbridgeVisualizerWeb.PageController do
  use GadgetbridgeVisualizerWeb, :controller

  alias GadgetbridgeVisualizer.HeartRate

  @doc """
  Index, EG the 'Overview' page.

  Using quick-and-dirty tricks to embed the JS variables directly
  in the HTML.
  """
  def index(conn, _params) do

    # Dummy Dates
    {:ok, now} = DateTime.now("Etc/UTC")
    today = DateTime.to_date(now)
    time = DateTime.to_time(now)

    {:ok, datetime_earlier} = DateTime.new(Date.add(today, -5), time)
    {:ok, datetime_today} = DateTime.new(today, time)
    # End dummy dates.
  
    avg_heart_rate = HeartRate.avg(datetime_earlier, datetime_today)

    conn = assign(conn, :avg_heart_rate, avg_heart_rate)
    render(conn, "index.html")
  end
end
