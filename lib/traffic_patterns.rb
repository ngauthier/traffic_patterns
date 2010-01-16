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
          e.destination == current.action
        }
        unless p_exit
          p_exit = TrafficPattern::Exit.new
          p_exit.frequency = 0
          p_exit.destination = current.action
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
        e.probability = e.frequency.to_f / total_freq.to_f
      end
    end
  end

  def to_png(file_path)    
    tp = self
    YUML::useCaseDiagram( :scruffy, :scale => 100 ) {
      tp.actions.each do |a|
        a.exits.each do |e|
          source = a.controller.name+"#"+a.name
          target = e.destination.controller.name+"#"+e.destination.name
          midpoint = "#{source}_#{target}_#{e.probability}"
          _(source) > _(midpoint)
          _(midpoint) >_(target)
        end
      end
    }.to_png( file_path )
  end

  def to_dot
    edges = []
    puts 'digraph traffic_patterns {'
    actions.each do |a|
      a.exits.each do |e|
        next if e.probability < 0.05
        begin
          source = a.controller.name+"#"+a.name
          source_label = source.dup
          target = e.destination.controller.name+"#"+e.destination.name
          target_label = target.dup
          [source, target].each{|s| s.gsub!(/[^a-z0-9\+]+/i, "x")}

          puts "#{source} [label=\"#{source_label}\"];"
          puts "#{target} [label=\"#{target_label}\"];"
        rescue NoMethodError
          next
        end
        edge = "#{source} -> #{target} [label=\"#{(e.probability*100).to_i}%\"];"
        unless edges.include? edge
          puts edge
          edges << edge
        end
      end
    end
    puts '}'
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

