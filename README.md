# TLRSS

Auto-downloader for torrent files (mainly) for TorrentLeech's crappy RSS feed.

## Instructions

Create a file in the config directory called 'rss_settings.exs':


    use Mix.Config
    
    config :tlrss,
    download_dir: System.user_home! <> "/dir/to/download/to",
    filters: [
      ~r{^The Simpsons S2\dE2\d 1080p}i,
      ~r{^The Big Bang Theory S09E\d\d .* 720p}i,
      ~r{^Silicon Valley S03E\d\d 720p}i,
    ],
    feeds: [
      "http://rss.torrentleech.org/your-rss-feed-key-here",
    ]

The given filters will be applied to every new incoming RSS item
and the matching ones will be downloaded to the directory specified
for downloading.

This is best done in tandem with a 'watch-directory' setting in whichever
torrent client you use, so that the torrents start automatically once
they're downloaded.
