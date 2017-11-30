# Adaptateur IRC

Les messages (de la forme `%IRC.Event{:message, :sender, :chan}`) sont envoyés par `IRC.EventHandler` aux GenServers qui
ont appelé `IRC.EventHandler.subscribe`.  
Les messages sont de la forme `{:irc, %IRC.Event{}}`. On peut donc les capturer par

```Elixir

def handle_cast({:irc, %IRC.Event{}=message}, state) do
[…]
end
```
