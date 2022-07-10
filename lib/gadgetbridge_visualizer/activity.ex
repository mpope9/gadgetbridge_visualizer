defmodule GadgetbridgeVisualizer.Activity do
  @moduledoc """
  Wrapper around activity related data.
  """

  import Ecto.Query, only: [from: 2]

  alias GadgetbridgeVisualizer.Model.BaseActivitySummary
  alias GadgetbridgeVisualizer.DbUtils
  alias GadgetbridgeVisualizer.Repo

  def activities(datetime_start, datetime_end) do
    query =
      from b in BaseActivitySummary,
        order_by: [desc: b._id],
      select: {
        b.name,
        b._id,
        b.start_time,
        b.end_time,
        (b.end_time / 1000 / 60) - (b.start_time / 1000 / 60),
        b.activity_kind
      }
    Repo.all(query)
    |> Enum.map(&adjust_row/1)
  end

  defp adjust_row({nil, id, unix_start, unix_end, minutes_total, kind}) do
    {:ok, name} = ExPurpleTiger.animal_hash("#{id}", separator: "", style: :titlecase)
    {name, unix_start, unix_end, minutes_total, kind}
  end
  defp adjust_row({name, _, unix_start, unix_end, minutes_total, kind}) do
    {name, unix_start, unix_end, minutes_total, kind}
  end
end
