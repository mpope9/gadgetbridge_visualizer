defmodule GadgetbridgeVisualizer.Model.BaseActivitySummary do

  use Ecto.Schema

  schema "BASE_ACTIVITY_SUMMARY" do
    field :_id, :integer, primary_key: true
    field :name, :string
    field :start_time, :integer
    field :end_time, :integer
    field :activity_kind, :integer
    field :base_longitude, :integer
    field :base_latitude, :integer
    field :base_altitude, :integer
    field :gpx_track, :string
    field :device_id, :integer
    field :user_id, :integer
    field :summary_data, :binary
  end
end
