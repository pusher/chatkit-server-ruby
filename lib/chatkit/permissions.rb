module Chatkit
  ROOM_SCOPE = "room"
  GLOBAL_SCOPE = "global"

  JOIN_ROOM = "room:join"
  LEAVE_ROOM = "room:leave"
  ADD_ROOM_MEMBER = "room:members:add"
  REMOVE_ROOM_MEMBER = "room:members:remove"
  CREATE_ROOM = "room:create"
  DELETE_ROOM = "room:delete"
  UPDATE_ROOM = "room:update"
  CREATE_MESSAGE = "message:create"
  CREATE_TYPING_EVENT = "room:typing_indicator:create"
  SUBSCRIBE_PRESENCE = "presence:subscribe"
  UPDATE_USER = "user:update"
  GET_ROOM_MESSAGES = "room:messages:get"
  GET_USER = "user:get"
  GET_ROOM = "room:get"
  GET_USER_ROOMS = "user:rooms:get"
  CREATE_FILE = "file:create"
  GET_FILE = "file:get"

  VALID_PERMISSIONS = {
    room: [
      JOIN_ROOM,
      LEAVE_ROOM,
      ADD_ROOM_MEMBER,
      REMOVE_ROOM_MEMBER,
      DELETE_ROOM,
      UPDATE_ROOM,
      CREATE_MESSAGE,
      CREATE_TYPING_EVENT,
      GET_ROOM_MESSAGES,
      CREATE_FILE,
      GET_FILE
    ],
    global: [
      JOIN_ROOM,
      LEAVE_ROOM,
      ADD_ROOM_MEMBER,
      REMOVE_ROOM_MEMBER,
      CREATE_ROOM,
      DELETE_ROOM,
      UPDATE_ROOM,
      CREATE_MESSAGE,
      CREATE_TYPING_EVENT,
      SUBSCRIBE_PRESENCE,
      UPDATE_USER,
      GET_ROOM_MESSAGES,
      GET_USER,
      GET_ROOM,
      GET_USER_ROOMS,
      CREATE_FILE,
      GET_FILE
    ]
  }
end