defmodule GadgetbridgeVisualizer.Model.MiBandActivitySample do

  use Ecto.Schema

  @primary_key false
  schema "MI_BAND_ACTIVITY_SAMPLE" do
    field :timestamp, :integer, primary_key: true
    field :device_id, :integer, primary_key: true
    field :user_id,   :integer
    field :raw_intensity, :integer
    field :steps,         :integer
    field :raw_kind,      :integer
    field :heart_rate,    :integer
  end

end
