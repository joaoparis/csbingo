WebSocket message flow - cs-bingo

Purpose: simple reference for frontend and future contributors describing socket message shapes and server behavior for lobby flows.

Inbound messages (client -> server)

1) Join lobby
- Type: "join"
- Body example:
  {
    "type": "join",
    "id": "user-uuid",
    "nickname": "PlayerNick",
    "lobbyCode": "ABC123"
  }
- Behavior:
  - If lobby with lobbyCode doesn't exist, server creates it and sets the joining user as owner.
  - Server adds client to lobby, sends a direct lobby_update to the joining client immediately (so they receive state), then broadcasts a lobby_update to the rest of the lobby members.

2) Leave lobby
- Type: "leave"
- Body example:
  { "type": "leave", "id": "user-uuid", "lobbyCode": "ABC123" }
- Behavior:
  - Server removes user from lobby, transfers ownership if needed (random member), and broadcasts lobby_update. If lobby becomes empty it is deleted.

3) Message (lobby-scoped chat or events)
- Type: "message"
- Body: arbitrary JSON that will be broadcast to other members of the same lobby

Outbound messages (server -> clients)

1) Lobby update
- Type: "lobby_update"
- Body example:
  {
    "type": "lobby_update",
    "lobbyCode": "ABC123",
    "owner": "user-uuid",
    "users": [
      { "id": "user-uuid", "nickname": "PlayerNick" },
      { "id": "other-id", "nickname": "Other" }
    ]
  }
- Sent whenever membership or ownership changes (join, leave, disconnect, owner transfer).

2) Message
- Type: arbitrary (echoed as-is)
- Body: whatever the sender sent; delivered only to members of that lobby.

Notes and guarantees
- Nicknames are provided by the client at join time and are treated as ephemeral labels tied to the socket connection.
- User identity (id) is accepted as provided by the client. For stronger guarantees, upgrade to token/JWT validation on websocket upgrade.
- Owner selection on owner disconnect is random (simple policy). This can be changed later.

