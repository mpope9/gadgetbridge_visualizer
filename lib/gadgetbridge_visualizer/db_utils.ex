defmodule GadgetbridgeVisualizer.DbUtils do
  @moduledoc """
  Wrapper around steps related data.
  """

  alias GadgetbridgeVisualizer.Repo

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
