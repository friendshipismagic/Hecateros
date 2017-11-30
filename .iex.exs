alias IRC.State
import Ecto.Query
alias Core.{Repo, Link, Tag, Chan}

attributes = %{chan: "#ekta-bots", tags: ["fuzzing", "vim"], url: "https://github.com/junegunn/fzf.vim", title: "junegunn/fzf.vim: fzf vim"}
