# KeyIsDown #
This condition evaluates to true if the specified key is currently being held down.
The usable keys can be checked [here](http://www.autohotkey.com/docs/KeyList.htm).

The physical key state is the state of the actual keys being held down by the user, whereas the logical key state is the state most programs use. This means that a program can receive a keydown event, and thus believe that the key is pressed, while the physical key wasn't touched. In most cases, using the physical key state is the desired approach.

Toggle state can be used for keys such as Capslock, Roll and Num. In this case, the condition evaluates to true if the toggle key is activated.

# Usage examples #
  * This can be used to change the behavior of certain events. You can have an event perform different tasks when a key such as Shift is being held down.
  * This condition can also be employed to combine normal keys together. For example, you could make an event trigger when both Insert and Home buttons are being held down. This is not possible with the [Hotkey](docsTriggersHotkey.md) trigger alone.
  * If you need to use Capslock sometimes, but often forget to turn it off or activate it accidentally, you can start a [timer](docsTriggersTimer.md) event when capslock gets activated. The timer then deactivates capslock after a short time when it's still activated.