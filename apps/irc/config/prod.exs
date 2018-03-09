use Mix.Config

config :logger, :console,
  level: :debug

config :irc, IRC.State,
  host: "irc.enst.rezosup.net",
  name: "Ἑκάτερος",
  nick: "Hecateros",
  pass: "",
  port: 6767,
  ssl?: true,
  user: "Hecateros",
  channels: []

