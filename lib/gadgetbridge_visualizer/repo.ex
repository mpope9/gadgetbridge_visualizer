defmodule GadgetbridgeVisualizer.Repo do
  use Ecto.Repo,
    otp_app: :gadgetbridge_visualizer,
    adapter: Ecto.Adapters.SQLite3
end
