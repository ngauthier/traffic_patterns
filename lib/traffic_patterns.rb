require 'slow_actions'

class TrafficPatterns < SlowActions

  def parse_file(*args)
    super(*args)
    find_exits
  end

  def find_exits
    sessions.each do |s|
      s.log_entries.inject do |previous, current|
        previous.action.exits ||= []
        p_exit = previous.action.exits.detect{|e| 
          e.destination == current
        }
        unless p_exit
          p_exit = TrafficPattern::Exit.new
          p_exit.frequency = 0
          p_exit.destination = current
          previous.action.exits << p_exit
        end
        p_exit.frequency += 1
        previous = current
      end
    end

    actions.each do |a|
      a.exits ||= []
      total_freq = a.exits.inject(0){|sum, e| sum += e.frequency}
      a.exits.each do |e|
        e.probability = e.frequency / total_freq
      end
    end
  end
end

class SlowActions::Action
  attr_accessor :exits
end

module TrafficPattern
  class Exit
    attr_accessor :probability
    attr_accessor :destination
    attr_accessor :frequency
  end
end

