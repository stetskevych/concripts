#!/usr/bin/env ruby

# DONE: check for root
# WONT: logging
# DONE: get advice
# DONE: sanitize output
# TODO: collect citations in sqlite!
# TODO: arguments to pull from db (offline mode :) )

require 'open-uri'
require 'json'

raise 'Must not be run as root' if Process.uid == 0

ADVICE_URI = 'http://fucking-great-advice.ru/api/random'

class String
  def sanitize_html
    self.gsub('&nbsp;', ' ')
        .gsub('&#151;', '—')
        .gsub(/<\/?[^>]+>/, '')
  end
end

open ADVICE_URI do |f|
  hash = JSON.parse f.read
  puts hash["text"].sanitize_html
end

# vim: set ts=2 sw=2 et:
