populate = fn ->

  nil
  # query = from c in Chan, join: l in Link, where: c.name == ^chan and l.url == ^url and c.id == l.chan_id, select: l

  # Core.insert_link(%{chan: "#ekta-bots", tags: ["fuzzing", "vim"], url: "https://github.com/junegunn/fzf.vim", title: "junegunn/fzf.vim: fzf vim"})
  # Core.insert_link(%{chan: "#ekta-bots", tags: ["elixir", "IoT"],  url: "https://www.dailydrip.com/blog/elixir-and-the-internet-of-things.html", title: "Elixir and the Internet of Things"})
  # Core.insert_link(%{chan: "#ekta-bots", tags: ["bootstrap"],      url: "https://getbootstrap.com/docs/4.0/components/badge/", title: "Badges ⋅Bootstrap"})
  # Core.insert_link(%{chan: "#ekta-bots", tags: ["elixir"],         url: "http://www.activesphere.com/blog/2017/11/28/stream", title: " A primer on Elixir Stream "})

  # Core.insert_link(%{chan: "#rezel",     tags:  ["musique"],       url: "https://www.youtube.com/watch?v=_eETuih2roA",       title: "Overwerk / State"})
  # Core.insert_link(%{chan: "#rezel",     tags:  ["elixir", "monitoring"], url: "https://hackernoon.com/a-tour-of-elixir-performance-monitoring-tools-aac2df726e8c", title: "A tour of Elixir perfs…"})
end

case Mix.env do
  :dev -> populate.()
end
