# OR Condition Branch #
An OR condition may be used to logically combine the conditions before and after this condition with a boolean OR operator. Normally conditions are implicitly evaluated with AND operations, meaning that all conditions must be fulfilled. The AND operation takes precedence and is evaluated first.

7plus employs a short circuit mechanism that stops evaluation once one of the condition groups beneath an OR operator evaluate to true.

This condition/operator is popularly used to create hotkeys that work on multiple windows.