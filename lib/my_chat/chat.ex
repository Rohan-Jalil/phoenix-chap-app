defmodule MyChat.Chat do
  @moduledoc false
  import Ecto.Query, warn: false
  alias MyChat.Repo
  alias MyChat.Chat.Message

  @topic "room:"

  def subscribe(room), do:
    Phoenix.PubSub.subscribe(MyChat.PubSub, @topic <> room)

  defp broadcast_new({:ok, msg}) do
    Phoenix.PubSub.broadcast(MyChat.PubSub, @topic <> msg.room, {:new_message, msg})
    {:ok, msg}
  end
  defp broadcast_new(other), do: other

  def list_messages(room, limit \\ 50) do
    Message
    |> where([m], m.room == ^room)
    |> order_by([m], desc: m.inserted_at)
    |> limit(^limit)
    |> Repo.all()
    |> Enum.reverse()
  end

  def create_message(attrs) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
    |> broadcast_new()
  end
end
