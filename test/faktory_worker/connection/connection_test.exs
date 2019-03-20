defmodule FaktoryWorker.Connection.ConnectionTest do
  use ExUnit.Case, async: true

  import Mox
  import FaktoryWorker.ConnectionHelpers

  alias FaktoryWorker.Connection

  setup :verify_on_exit!

  describe "open/1" do
    test "should open and setup a faktory connection with the default config" do
      connection_mox()

      opts = [socket_handler: FaktoryWorker.SocketMock]

      {:ok, %Connection{} = connection} = Connection.open(opts)

      assert connection.host == "localhost"
      assert connection.port == 7419
      assert connection.socket == :test_socket
    end

    test "should open and setup a faktory connection with user defined config" do
      connection_mox()

      opts = [host: "test-host", port: 5002, socket_handler: FaktoryWorker.SocketMock]

      {:ok, %Connection{} = connection} = Connection.open(opts)

      assert connection.host == "test-host"
      assert connection.port == 5002
      assert connection.socket == :test_socket
    end

    test "should return an error if the returned faktory version is not supported" do
      opts = [socket_handler: FaktoryWorker.SocketMock]

      expect(FaktoryWorker.SocketMock, :connect, fn host, port ->
        {:ok,
         %Connection{
           host: host,
           port: port,
           socket: :test_socket,
           socket_handler: FaktoryWorker.SocketMock
         }}
      end)

      expect(FaktoryWorker.SocketMock, :recv, fn _ ->
        {:ok, "+HI {\"v\":1}\r\n"}
      end)

      {:error, reason} = Connection.open(opts)

      assert reason == "Only Faktory version '2' is supported (connected to Faktory version '1')."
    end

    test "should return a socket error" do
      opts = [socket_handler: FaktoryWorker.SocketMock]

      expect(FaktoryWorker.SocketMock, :connect, fn _, _ ->
        {:error, :econnrefused}
      end)

      {:error, reason} = Connection.open(opts)

      assert reason == :econnrefused
    end
  end

  describe "send_command/2" do
    test "should call into the socket handler" do
      expect(FaktoryWorker.SocketMock, :send, fn _, "HELLO {\"v\":1}\r\n" ->
        :called_handler
      end)

      connection = %Connection{
        host: "localhost",
        port: 1234,
        socket: :test_socket,
        socket_handler: FaktoryWorker.SocketMock
      }

      assert :called_handler == Connection.send_command(connection, {:hello, 1})
    end
  end

  describe "recv/1" do
    test "should call into the socket handler" do
      expect(FaktoryWorker.SocketMock, :recv, fn _ ->
        :called_handler
      end)

      connection = %Connection{
        host: "localhost",
        port: 1234,
        socket: :test_socket,
        socket_handler: FaktoryWorker.SocketMock
      }

      assert :called_handler == Connection.recv(connection)
    end
  end
end