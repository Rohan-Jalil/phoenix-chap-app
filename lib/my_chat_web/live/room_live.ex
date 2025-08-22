defmodule MyChatWeb.RoomLive do
  use MyChatWeb, :live_view
  alias MyChat.Chat

  def mount(_params, _session, socket) do
    room = "lobby"
    if connected?(socket), do: Chat.subscribe(room)

    msgs = Chat.list_messages(room)
    username = "user" <> Integer.to_string(Enum.random(1000..9999))

    {:ok,
      socket
      |> assign(room: room, username: username)
      |> stream(:messages, msgs)}
  end

  def handle_event("send", %{"username" => u, "body" => b}, socket) do
    _ = Chat.create_message(%{username: u, body: b, room: socket.assigns.room})
    {:noreply, assign(socket, :username, u)}
  end

  def handle_info({:new_message, msg}, socket) do
    {:noreply, stream_insert(socket, :messages, msg)}
  end

  # tiny helper for timestamps if you want it later
  defp hhmm(%NaiveDateTime{} = dt), do: Calendar.strftime(dt, "%H:%M")
  defp hhmm(_), do: ""


  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto p-6 space-y-4">
      <h1 class="text-2xl font-bold">Simple Chat — <span class="font-mono"><%= @room %></span></h1>

      <div id="messages"
           phx-update="stream"
           class="border rounded h-80 overflow-y-auto p-3 space-y-2">
        <div :for={{id, m} <- @streams.messages} id={id} class="text-sm">
          <span class="font-semibold"><%= m.username %></span>:
          <span><%= m.body %></span>
        </div>
      </div>

      <form phx-submit="send" class="flex gap-2">
        <input type="text" name="username" value={@username} required
               class="flex-1 border rounded p-2" placeholder="Your name" />
        <input type="text" name="body" required autofocus
               class="flex-[2] border rounded p-2" placeholder="Type a message…" />
        <button type="submit" class="border rounded px-4">Send</button>
      </form>
    </div>
    """
  end
end

