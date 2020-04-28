type
  StreamInputs* = enum
    SendHeaders,
    RecvHeaders,
    SendPushPromise,
    RecvPushPromise,
    SendEndStream,
    RecvEndStream,
    SendRstStream,
    RecvRstStream

      #         The lifecycle of a stream is shown in Figure 2.

      #                           +--------+
      #                   send PP |        | recv PP
      #                  ,--------|  idle  |--------.
      #                 /         |        |         \
      #                v          +--------+          v
      #         +----------+          |           +----------+
      #         |          |          | send H /  |          |
      #  ,------| reserved |          | recv H    | reserved |------.
      #  |      | (local)  |          |           | (remote) |      |
      #  |      +----------+          v           +----------+      |
      #  |          |             +--------+             |          |
      #  |          |     recv ES |        | send ES     |          |
      #  |   send H |     ,-------|  open  |-------.     | recv H   |
      #  |          |    /        |        |        \    |          |
      #  |          v   v         +--------+         v   v          |
      #  |      +----------+          |           +----------+      |
      #  |      |   half   |          |           |   half   |      |
      #  |      |  closed  |          | send R /  |  closed  |      |
      #  |      | (remote) |          | recv R    | (local)  |      |
      #  |      +----------+          |           +----------+      |
      #  |           |                |                 |           |
      #  |           | send ES /      |       recv ES / |           |
      #  |           | send R /       v        send R / |           |
      #  |           | recv R     +--------+   recv R   |           |
      #  | send R /  `----------->|        |<-----------'  send R / |
      #  | recv R                 | closed |               recv R   |
      #  `----------------------->|        |<----------------------'
      #                           +--------+

      #     send:   endpoint sends this frame
      #     recv:   endpoint receives this frame

      #     H:  HEADERS frame (with implied CONTINUATIONs)
      #     PP: PUSH_PROMISE frame (with implied CONTINUATIONs)
      #     ES: END_STREAM flag
      #     R:  RST_STREAM frame

      #                     Figure 2: Stream States
  StreamState* = enum
    Idle,
    ReversedLocal,
    ReversedRemote,
    Open,
    HalfClosedLocal,
    HalfClosedRemote,
    Closed
