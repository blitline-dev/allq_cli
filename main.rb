require 'pty'
require 'tty'
require 'tty-table'
require 'allq_client'
require 'base64'
require 'lz4-ruby'
require 'awesome_print'

require_relative 'lib/base'
require_relative 'lib/stats'
require_relative 'lib/clear'
require_relative 'lib/throttle'
require_relative 'lib/peek'

def process
  arg = ARGV[0]


  prompt = TTY::Prompt.new
  pastel = Pastel.new
  actions = %w(stats stats_all peek clear_tube throttle exit)
	if arg.nil?
	  verb = prompt.enum_select("Action to perform?", actions)
  else 
    verb = actions[arg.to_i - 1]
  end

  if verb=="stats"
    Stats.new.process(:all)
  elsif verb=="stats_all"
    Stats.new.process(:each)
  elsif verb=="clear_tube"
    Clear.new.process
  elsif verb=="throttle"
    Throttle.new.process
  elsif verb=="peek"
    Peek.new.process
  elsif verb=="exit"
    exit 0
  end
end

process

