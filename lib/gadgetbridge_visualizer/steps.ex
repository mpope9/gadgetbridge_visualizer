defmodule GadgetbridgeVisualizer.Steps do
  @moduledoc """
  Wrapper around steps related data.
  """

  import Ecto.Query, only: [from: 2]

  alias GadgetbridgeVisualizer.Model.MiBandActivitySample
  alias GadgetbridgeVisualizer.DbUtils
  alias GadgetbridgeVisualizer.Repo

  @doc """
  Returns total steps in the interval.
  """
  def total(start_date, end_date) do
    query =
      from s in MiBandActivitySample,
        where: fragment("? BETWEEN strftime('%s', ?, 'utc') AND strftime('%s', ?, 'utc')", s.timestamp, ^start_date, ^end_date),
        select: sum(s.steps)

    DbUtils.catch_nil_float(Repo.all(query))
  end

  def per_hour(start_date, end_date) do
    query =
      from s in MiBandActivitySample,
        where: fragment("? BETWEEN strftime('%s', ?, 'utc') AND strftime('%s', ?, 'utc')", s.timestamp, ^start_date, ^end_date),
        group_by: 1,
        select: {
          fragment("strftime('%Y-%m-%dT%H:00:00.000', datetime(?, 'unixepoch'))", s.timestamp), 
          sum(s.steps)
        }

    Repo.all(query)
    |> Enum.unzip
  end

  def per_diem(start_date, end_date) do
    query =
      from s in MiBandActivitySample,
        where: fragment("? BETWEEN strftime('%s', ?, 'utc') AND strftime('%s', ?, 'utc')", s.timestamp, ^start_date, ^end_date),
        group_by: 1,
        select: {
          fragment("date(?, 'unixepoch')", s.timestamp), 
          sum(s.steps)
        }

    Repo.all(query)
    |> Enum.unzip
  end

  def per_week(start_date, end_date) do
    query =
      from s in MiBandActivitySample,
        where: fragment("? BETWEEN strftime('%s', ?, 'utc') AND strftime('%s', ?, 'utc')", s.timestamp, ^start_date, ^end_date),
        group_by: 1,
        select: {
          fragment("strftime('%W', date(? , 'unixepoch'), '+1 day')", s.timestamp), 
          fragment("max(date(date(?, 'unixepoch'), 'weekday 0', '-7 day'))", s.timestamp),
          sum(s.steps)
        }

    Repo.all(query)
    |> Enum.map(fn {_, d, v} -> {d, v} end)
    |> Enum.unzip
  end

  def per_month(start_date, end_date) do
    query =
      from s in MiBandActivitySample,
        where: fragment("? BETWEEN strftime('%s', ?, 'utc') AND strftime('%s', ?, 'utc')", s.timestamp, ^start_date, ^end_date),
        group_by: 1,
        select: {
          fragment("strftime('%Y-%m-01T00:00:00.000', datetime(?, 'unixepoch'))", s.timestamp), 
          sum(s.steps)
        }

    Repo.all(query)
    |> Enum.unzip
  end

  def per_year(start_date, end_date) do
    query =
      from s in MiBandActivitySample,
        where: fragment("? BETWEEN strftime('%s', ?, 'utc') AND strftime('%s', ?, 'utc')", s.timestamp, ^start_date, ^end_date),
        group_by: 1,
        select: {
          fragment("strftime('%Y-01-01T00:00:00.000', datetime(?, 'unixepoch'))", s.timestamp), 
          sum(s.steps)
        }

    Repo.all(query)
    |> Enum.unzip
  end

end
