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
  def default_date_range("", "") do
    datetime_latest = DateTime.from_unix!(latest_timestamp())
    today = DateTime.to_date(datetime_latest)
    time = DateTime.to_time(datetime_latest)

    datetime_earlier = DateTime.new!(Date.add(today, -1), time)

    {datetime_earlier, datetime_latest}
  end
  def default_date_range(date_start_string, date_end_string) do

    # Wow I dislike Elixir's date handling.
    datetime_latest = DateTime.from_unix!(latest_timestamp())
    date_latest = DateTime.to_date(datetime_latest)
    date_start = Date.from_iso8601!(date_start_string)
    date_end = Date.from_iso8601!(date_end_string)
    time_zero = Time.from_iso8601!("00:00:00")

    if date_end > date_latest do
      default_date_range("", "")
    else
      {DateTime.new!(date_start, time_zero), DateTime.new!(date_end, time_zero)}
    end
  end

  defp latest_timestamp() do
    query = 
      from s in MiBandActivitySample,
        select: max(s.timestamp)
    catch_nil_float(Repo.all(query))
  end

end
