defmodule MyChat.Repo do
  use Ecto.Repo,
    otp_app: :my_chat,
    adapter: Ecto.Adapters.Postgres
end
