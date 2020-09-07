require 'pty'
require 'tty'
require 'tty-table'
require 'allq_rest'
require 'base64'
require 'awesome_print'

require_relative 'lib/base'
require_relative 'lib/stats'
require_relative 'lib/clear'
require_relative 'lib/clear_buried'
require_relative 'lib/throttle'
require_relative 'lib/peek'

def process
  arg = ARGV[0]

  prompt = TTY::Prompt.new
  pastel = Pastel.new
  actions = %w[stats stats_all peek clear_tube clear_buried throttle exit]
  verb = if arg.nil?
           prompt.enum_select('Action to perform?', actions)
         else
           actions[arg.to_i - 1]
         end

  if verb == 'stats'
    Stats.new.process(:all)
  elsif verb == 'stats_all'
    Stats.new.process(:each)
  elsif verb == 'clear_tube'
    Clear.new.process
  elsif verb == 'clear_buried'
    ClearBuried.new.process
  elsif verb == 'throttle'
    Throttle.new.process
  elsif verb == 'peek'
    Peek.new.process
  elsif verb == 'exit'
    exit 0
  end
end

def pre_check
  begin
    base = Base.new
    base.get_all_tube_names
  rescue => ex
    if ex.message.include?("Couldn't connect to server")
      puts "Couldn't connect to server. Are you sure you have the allq_rest running locally (in docker?) and it's available at #{base.base_url}"
      exit 1
    end
  end
end

pre_check
process
