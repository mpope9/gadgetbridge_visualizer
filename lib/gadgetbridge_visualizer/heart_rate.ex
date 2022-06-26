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

  def rolling_heart_rate("hour", date_start, date_end) do
    Ecto.Adapters.SQL.query!(
      Repo, """
        SELECT
          DISTINCT STRFTIME('%Y-%m-%d %H:00:00', DATETIME(timestamp, 'unixepoch', 'localtime')) AS Hour,
          MAX(heart_rate) OVER (
              ORDER BY (timestamp / 3600) * 3600
              RANGE BETWEEN 1 PRECEDING AND CURRENT ROW
          ) AS Max,
          MIN(heart_rate) OVER (
              ORDER BY (timestamp / 3600) * 3600
              RANGE BETWEEN 1 PRECEDING AND CURRENT ROW
          ) AS Min,
          AVG(heart_rate) OVER (
              ORDER BY (timestamp / 3600) * 3600
              RANGE BETWEEN 1 PRECEDING AND CURRENT ROW
          ) AS Avg
        FROM MI_BAND_ACTIVITY_SAMPLE
        WHERE
          heart_rate != 255 AND
          heart_rate > 0 AND
          timestamp BETWEEN
            STRFTIME('%s', '#{date_start}', 'utc') AND
            STRFTIME('%s', '#{date_end}', 'utc')
        ORDER BY Hour;
      """)
      |> unzip4()
  end

  def rolling_heart_rate("day", date_start, date_end) do

    Ecto.Adapters.SQL.query!(
      Repo, """
        SELECT
          DISTINCT DATE(timestamp, 'unixepoch', 'localtime') as Day,
          MAX(heart_rate) OVER (
              ORDER BY DATE(timestamp, 'unixepoch', 'localtime')
              RANGE BETWEEN 1 PRECEDING AND CURRENT ROW
          ) AS Max,
          MIN(heart_rate) OVER (
              ORDER BY DATE(timestamp, 'unixepoch', 'localtime')
              RANGE BETWEEN 1 PRECEDING AND CURRENT ROW
          ) AS Min,
          AVG(heart_rate) OVER (
              ORDER BY DATE(timestamp, 'unixepoch', 'localtime')
              RANGE BETWEEN 1 PRECEDING AND CURRENT ROW
          ) AS Avg
        FROM MI_BAND_ACTIVITY_SAMPLE
        WHERE
          heart_rate != 255 AND
          heart_rate > 0 AND
          timestamp BETWEEN
            STRFTIME('%s', '#{date_start}', 'utc') AND
            STRFTIME('%s', '#{date_end}', 'utc')
        ORDER BY Day;
      """)
      |> unzip4()
  end

  def rolling_heart_rate("week", date_start, date_end) do
    Ecto.Adapters.SQL.query!(
      Repo, """
        SELECT
          DISTINCT DATE(DATE(timestamp, 'unixepoch', 'localtime'), 'weekday 0', '-1 days') AS Week,
          MAX(heart_rate) OVER (
              ORDER BY STRFTIME('%W', DATE(timestamp, 'unixepoch', 'localtime'))
              RANGE BETWEEN 1 PRECEDING AND CURRENT ROW
          ) AS Max,
          MIN(heart_rate) OVER (
              ORDER BY STRFTIME('%W', DATE(timestamp, 'unixepoch', 'localtime')) 
              RANGE BETWEEN 1 PRECEDING AND CURRENT ROW
          ) AS Min,
          AVG(heart_rate) OVER (
              ORDER BY STRFTIME('%W', DATE(timestamp, 'unixepoch', 'localtime')) 
              RANGE BETWEEN 1 PRECEDING AND CURRENT ROW
          ) AS Avg
        FROM MI_BAND_ACTIVITY_SAMPLE
        WHERE
          heart_rate != 255 AND
          heart_rate > 0 AND
          timestamp BETWEEN
            STRFTIME('%s', '#{date_start}', 'utc') AND
            STRFTIME('%s', '#{date_end}', 'utc')
        ORDER BY Week;
      """)
      |> unzip4()
  end

  defp unzip4(result) do
    {labels, max, min, avg} =
      result.rows
      |> Enum.reduce({[], [], [], []}, fn [date, max, min, avg], {dates, maxs, mins, avgs} ->
        {[date|dates], [max|maxs], [min|mins], [DbUtils.catch_nil_float(avg)|avgs]}
      end)
    {Enum.reverse(labels), Enum.reverse(max), Enum.reverse(min), Enum.reverse(avg)}
  end
end
