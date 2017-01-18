defmodule HoneydewTest do
  use ExUnit.Case

  test "queue_spec/2" do
    queue = :erlang.unique_integer

    spec =  Honeydew.queue_spec(queue, queue: {:abc, [1,2,3]}, dispatcher: {Dis.Patcher, [:a, :b]}, failure_mode: {Fail.Ure, [:a, :b]})
    assert spec == {Honeydew.QueueSupervisor,
                    {Honeydew.QueueSupervisor, :start_link,
                     [queue, :abc, [1, 2, 3], 1, {Dis.Patcher, [:a, :b]},
                      {Fail.Ure, [:a, :b]}]}, :permanent, :infinity, :supervisor,
                    [Honeydew.QueueSupervisor]}
  end

  test "queue_spec/2 defaults" do
    queue = :erlang.unique_integer
    spec =  Honeydew.queue_spec(queue)

    assert spec == {Honeydew.QueueSupervisor,
                    {Honeydew.QueueSupervisor, :start_link,
                     [queue, Honeydew.Queue.ErlangQueue, [], 1,
                      GenStage.DemandDispatcher, {Honeydew.FailureMode.Abandon, []}]},
                    :permanent, :infinity, :supervisor, [Honeydew.QueueSupervisor]}
  end

  test "worker_spec/2" do
    queue = :erlang.unique_integer

    spec = Honeydew.worker_spec(queue, {Worker, [1, 2, 3]}, num: 123, init_retry_secs: 5)
    assert spec == {Honeydew.WorkerSupervisor,
                    {Honeydew.WorkerSupervisor, :start_link,
                     [queue, Worker, [1, 2, 3], 123, 5, 10_000]}, :permanent,
                    :infinity, :supervisor, [Honeydew.WorkerSupervisor]}
  end

  test "worker_spec/2 defaults" do
    queue = :erlang.unique_integer

    spec =  Honeydew.worker_spec(queue, Worker)
    assert spec == {Honeydew.WorkerSupervisor,
                    {Honeydew.WorkerSupervisor, :start_link,
                     [queue, Worker, [], 10, 5, 10000]}, :permanent, :infinity,
                    :supervisor, [Honeydew.WorkerSupervisor]}
  end

  test "group/1" do
    assert Honeydew.group(:my_queue, :workers) == :"honeydew.workers.my_queue"
  end

  test "supervisor/1" do
    assert Honeydew.supervisor(:my_queue, :worker) == :"honeydew.worker_supervisor.my_queue"
  end

  test "supervisor/1 with global queue" do
    assert Honeydew.supervisor({:global, :my_queue}, :worker) == :"honeydew.worker_supervisor.global.my_queue"
  end

end
