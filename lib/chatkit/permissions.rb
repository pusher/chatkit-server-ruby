module Chatkit
  ROOM_SCOPE = "room"
  GLOBAL_SCOPE = "global"

  JOIN_ROOM = "join_room"
  LEAVE_ROOM = "leave_room"
  ADD_ROOM_MEMBER = "add_room_member"
  REMOVE_ROOM_MEMBER = "remove_room_member"
  CREATE_ROOM = "create_room"
  DELETE_ROOM = "delete_room"
  UPDATE_ROOM = "update_room"
  ADD_MESSAGE = "add_message"
  CREATE_TYPING_EVENT = "create_typing_event"
  SUBSCRIBE_PRESENCE = "subscribe_presence"
  UPDATE_USER = "update_user"
  GET_ROOM_MESSAGES = "get_room_messages"
  GET_USER = "get_user"
  GET_ROOM = "get_room"
  GET_USER_ROOMS = "get_user_rooms"

  VALID_PERMISSIONS = {
    room: [
      JOIN_ROOM,
      LEAVE_ROOM,
      ADD_ROOM_MEMBER,
      REMOVE_ROOM_MEMBER,
      DELETE_ROOM,
      UPDATE_ROOM,
      ADD_MESSAGE,
      CREATE_TYPING_EVENT,
      SUBSCRIBE_PRESENCE,
      GET_ROOM_MESSAGES,
    ],
    global: [
      JOIN_ROOM,
      LEAVE_ROOM,
      ADD_ROOM_MEMBER,
      REMOVE_ROOM_MEMBER,
      CREATE_ROOM,
      DELETE_ROOM,
      UPDATE_ROOM,
      ADD_MESSAGE,
      CREATE_TYPING_EVENT,
      SUBSCRIBE_PRESENCE,
      UPDATE_USER,
      GET_ROOM_MESSAGES,
      GET_USER,
      GET_ROOM,
      GET_USER_ROOMS,
    ]
  }
end