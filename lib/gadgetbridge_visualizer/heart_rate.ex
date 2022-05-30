defmodule GadgetbridgeVisualizer.HeartRate do
  @moduledoc """
  Wrapper around heart rate related data.
  """

  import Ecto.Query, only: [from: 2]

  alias GadgetbridgeVisualizer.Model.MiBandActivitySample
  alias GadgetbridgeVisualizer.Repo

  @doc """
  Returns the avg heart rate for the given interval.

  TODO: Make this average resting heart rate...?
  """
  def avg(start_date, end_date) do
    query =
      from s in MiBandActivitySample,
        where: fragment("? BETWEEN strftime('%s', ?, 'utc') AND strftime('%s', ?, 'utc')", s.timestamp, ^start_date, ^end_date),
        where: s.heart_rate != 255,
        select: avg(s.heart_rate)

    [avg] = Repo.all(query)
    :erlang.float_to_binary(avg, [decimals: 2])
  end

end
