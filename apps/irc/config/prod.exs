use Mix.Config

config :logger, :console,
  level: :debug

config :irc, IRC.State,
  host: "irc.enst.rezosup.net",
  realname: "Ἑκάτερος",
  nickname: "Hecateros",
  pass: "",
  port: 6767,
  ssl?: true,
  username: "Hecateros",
  channels: []

