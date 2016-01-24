defmodule TLRSS.FeedReader.FeedSpec do
  @moduledoc"""
  Module for specifying the structure of a FeedSpec. Kept here because it's
  convenient to refer to the FeedSpec as FeedSpec.t in the program and only
  changing in here when doing @specs.

  This is to be used wherever a specification for which
  feed to read is given, meaning it's for the startup
  of FeedReaders and the like.
  """
  @type t :: String.t
end
