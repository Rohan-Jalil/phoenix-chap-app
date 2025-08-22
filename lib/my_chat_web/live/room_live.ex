defmodule MyChatWeb.RoomLive do
  use MyChatWeb, :live_view
  alias MyChat.Chat
  alias MyChat.Accounts

  @impl true
  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    # Load the logged-in user
    user = Accounts.get_user_by_session_token(user_token)

    if connected?(socket), do: Chat.subscribe("lobby")

    messages = Chat.list_messages("lobby")

    {:ok,
      socket
      |> assign(:room, "lobby")
      |> assign(:username, user.email)
      |> stream(:messages, messages)}
  end

  @impl true
  def handle_event("send", %{"body" => body}, socket) do
    username = socket.assigns.username
    room = socket.assigns.room

    # Create and broadcast message
    _ = Chat.create_message(%{username: username, body: body, room: room})

    {:noreply, socket}
  end

  @impl true
  def handle_info({:new_message, msg}, socket) do
    {:noreply, stream_insert(socket, :messages, msg)}
  end

  # optional helper for timestamp display
  defp hhmm(%NaiveDateTime{} = dt), do: Calendar.strftime(dt, "%H:%M")
  defp hhmm(_), do: ""

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto p-6 space-y-4">
      <h1 class="text-2xl font-bold">Chat Room — <span class="font-mono"><%= @room %></span></h1>

      <div id="messages"
           phx-update="stream"
           class="border rounded h-80 overflow-y-auto p-3 space-y-2">
        <div :for={{id, m} <- @streams.messages} id={id} class="text-sm">
          <span class="font-semibold"><%= m.username %></span>:
          <span><%= m.body %></span>
          <span class="text-gray-400 text-xs ml-2"><%= hhmm(m.inserted_at) %></span>
        </div>
      </div>

      <form phx-submit="send" class="flex gap-2">
        <input type="text" name="body" required autofocus
               class="flex-1 border rounded p-2" placeholder="Type a message…" />
        <button type="submit" class="border rounded px-4">Send</button>
      </form>
    </div>
    """
  end
end
