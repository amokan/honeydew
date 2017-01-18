defmodule Honeydew.QueueSupervisorTest do
  use ExUnit.Case
  alias Honeydew.Queue.ErlangQueue

  setup do
    pool = :erlang.unique_integer

    Honeydew.create_groups(pool)

    {:ok, supervisor} = Honeydew.QueueSupervisor.start_link(pool, ErlangQueue, [], 3, GenStage.DemandDispatcher, {Honeydew.FailureMode.Abandon, []})

    # on_exit fn ->
    #   Supervisor.stop(supervisor)
    #   Honeydew.delete_groups(pool)
    # end

    [supervisor: supervisor]
  end

  test "starts the correct number of queues", context do
    assert context[:supervisor]
    |> Supervisor.which_children
    |> Enum.count == 3
  end

  test "starts the given queue module", context do
    assert   {_, _, _, [ErlangQueue]} = context[:supervisor] |> Supervisor.which_children |> List.first
  end
end
