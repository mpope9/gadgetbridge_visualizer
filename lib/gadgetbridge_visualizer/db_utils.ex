defmodule GadgetbridgeVisualizer.DbUtils do
  @moduledoc """
  Wrapper around steps related data.
  """

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

end
