defmodule GadgetbridgeVisualizer.DbUtils do
  @moduledoc """
  Wrapper around steps related data.
  """

  import Ecto.Query, only: [from: 2]

  alias GadgetbridgeVisualizer.Model.MiBandActivitySample
  alias GadgetbridgeVisualizer.Repo

  def catch_nil_float(nil), do: 0.0
  def catch_nil_float([value]) when is_integer(value), do: value
  def catch_nil_float([value]) do
    :erlang.float_to_binary(value, [decimals: 2])
  end

  def merge_sqlite(file) do
    Ecto.Adapters.SQL.query!(
      Repo, """
        attach '#{file}' as toMerge;

        BEGIN;
        insert into MI_BAND_ACTIVITY_SAMPLE select * from toMerge.MI_BAND_ACTIVITY_SAMPLE;
        COMMIT;

        detatch toMerge;
      """
    )
  end

  # Get the latest timestamp from the DB to calculate the
  # latest day of data.
  def default_date_range() do
    datetime_latest = DateTime.from_unix!(latest_timestamp())
    today = DateTime.to_date(datetime_latest)
    time = DateTime.to_time(datetime_latest)

    datetime_earlier = DateTime.new!(Date.add(today, -9), time)

    {datetime_earlier, datetime_latest}
  end

  defp latest_timestamp() do
    query = 
      from s in MiBandActivitySample,
        select: max(s.timestamp)
    catch_nil_float(Repo.all(query))
  end

end
