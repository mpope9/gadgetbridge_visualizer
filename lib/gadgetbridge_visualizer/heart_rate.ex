defmodule GadgetbridgeVisualizer.HeartRate do
  @moduledoc """
  Wrapper around heart rate related data.
  """

  import Ecto.Query, only: [from: 2]

  alias GadgetbridgeVisualizer.Model.MiBandActivitySample
  alias GadgetbridgeVisualizer.DbUtils
  alias GadgetbridgeVisualizer.Repo

  @doc """
  Returns the avg heart rate for the given interval.

  TODO: Make this average resting heart rate...?
  """
  def avg(date_start, date_end) do
    query =
      from s in MiBandActivitySample,
        where: fragment("? BETWEEN strftime('%s', ?, 'utc') AND strftime('%s', ?, 'utc')", s.timestamp, ^date_start, ^date_end),
        where: s.heart_rate != 255,
        select: avg(s.heart_rate)

    DbUtils.catch_nil_float(Repo.all(query))
  end

  def max(date_start, date_end) do
    query =
      from s in MiBandActivitySample,
        where: fragment("? BETWEEN strftime('%s', ?, 'utc') AND strftime('%s', ?, 'utc')", s.timestamp, ^date_start, ^date_end),
        where: s.heart_rate != 255,
        select: max(s.heart_rate)

    DbUtils.catch_nil_float(Repo.all(query))
  end

  def min(date_start, date_end) do
    query =
      from s in MiBandActivitySample,
        where: fragment("? BETWEEN strftime('%s', ?, 'utc') AND strftime('%s', ?, 'utc')", s.timestamp, ^date_start, ^date_end),
        where: s.heart_rate != 255,
        where: s.heart_rate > 0,
        select: min(s.heart_rate)

    DbUtils.catch_nil_float(Repo.all(query))
  end

  def heart_rates(date_start, date_end) do
    query = 
      from s in MiBandActivitySample,
        where: fragment("? BETWEEN strftime('%s', ?, 'utc') AND strftime('%s', ?, 'utc')", s.timestamp, ^date_start, ^date_end),
        where: s.heart_rate != 255,
        select: {s.timestamp, s.heart_rate}

    Repo.all(query)
    |> Enum.map(fn {epoch, hr} ->
      d = DateTime.from_unix!(epoch)
      s = "#{d.year}/#{d.month}/#{d.day} #{d.hour}:#{d.minute}:#{d.second}"
      {s, hr}
    end)
    |> Enum.unzip
  end

  def rolling_heart_rate(date_start, date_end) do

    result =
      Ecto.Adapters.SQL.query!(
        Repo, """
          SELECT
            DISTINCT DATE(timestamp, 'unixepoch', 'localtime') as date,
            MAX(heart_rate) OVER (
                ORDER BY DATE(timestamp, 'unixepoch', 'localtime')
                RANGE BETWEEN 6 PRECEDING AND CURRENT ROW
            ) AS DailyMax,
            MIN(heart_rate) OVER (
                ORDER BY DATE(timestamp, 'unixepoch', 'localtime')
                RANGE BETWEEN 6 PRECEDING AND CURRENT ROW
            ) AS DailyMin,
            AVG(heart_rate) OVER (
                ORDER BY DATE(timestamp, 'unixepoch', 'localtime')
                RANGE BETWEEN 6 PRECEDING AND CURRENT ROW
            ) AS DailyAvg
          FROM MI_BAND_ACTIVITY_SAMPLE
          WHERE
            heart_rate != 255 AND
            heart_rate > 0 AND
            timestamp BETWEEN strftime('%s', '#{date_start}', 'utc') AND strftime('%s', '#{date_end}', 'utc')
          ORDER BY date;
        """
      )

    result.rows
    |> Enum.reduce({[], [], [], []}, fn [date, max, min, avg], {dates, maxs, mins, avgs} ->
      {[date|dates], [max|maxs], [min|mins], [DbUtils.catch_nil_float(avg)|avgs]}
    end)
  end

end
