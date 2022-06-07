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

  # TODO: like...transform the int to a date brah
  #def per_diem(start_date, end_date) do
  #  query =
  #    from s in MiBandActivitySample,
  #      where: fragment("? BETWEEN strftime('%s', ?, 'utc') AND strftime('%s', ?, 'utc')", s.timestamp, ^start_date, ^end_date),
  #      group_by: 1,
  #      select: {s.timestamp, sum(s.steps)}

  #  Repo.all(query)
  #end
end
