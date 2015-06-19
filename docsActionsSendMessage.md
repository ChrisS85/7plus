# SendMessage #
This action sends a message to another program. It's the counterpart to [OnMessage](docsTriggersOnMessage.md), which reacts on received messages. This is used to control other programs.

| **Parameter** | **Description** |
|:--------------|:----------------|
|Send Mode      |"Post" sends the message without waiting for a return, while "Send" waits for a reply from the recipient. Depending on the message to be sent, you may need to use one of these settings. If you use "Send", you can use ${MessageResult} [placeholder](docsGenericPlaceholders.md) afterwards.|
|Message        |A number identifying the message to be send.|
|wParam         |A message parameter. Its meaning depends on the message that is sent.|
|lParam         |A message parameter. Its meaning depends on the message that is sent.|
|[WindowFilter controls](docsGenericWindowFilter.md)|Select the target window with these.|
|Control        |You can also send a message to a control in a window. In this case, enter a [ClassNN](docsGenericClassNN.md) or the text of the control here. If this is empty, the message will be send to the whole window.|