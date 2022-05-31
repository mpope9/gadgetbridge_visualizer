defmodule GadgetbridgeVisualizer.Steps do
  @moduledoc """
  Wrapper around steps related data.
  """

  import Ecto.Query, only: [from: 2]

  alias GadgetbridgeVisualizer.Model.MiBandActivitySample
  alias GadgetbridgeVisualizer.Repo

  @doc """
  Returns total steps in the interval.
  """
  def total(start_date, end_date) do
    query =
      from s in MiBandActivitySample,
        where: fragment("? BETWEEN strftime('%s', ?, 'utc') AND strftime('%s', ?, 'utc')", s.timestamp, ^start_date, ^end_date),
        select: sum(s.steps)

    [avg] = Repo.all(query)
    avg
  end

end
