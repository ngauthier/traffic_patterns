require 'helper'

class TestTrafficPatterns < Test::Unit::TestCase
  context "traffic patterns" do
    setup do
      @tp = TrafficPatterns.new
    end
    context "run on a log file with one action leading to the next" do
      setup do
        @tp.parse_file(fixture_file('two_actions.log'))
      end
      should "have two actions" do
        assert_equal 2, @tp.actions.size
      end
      context "with the index action" do
        setup do
          @index = @tp.actions.detect{|a| a.name == "index"}
        end
        should "have one edge" do
          assert @index.exits.size == 1
        end
        should "have a probability of one to the next of 100%" do
          assert_equal 1.0, @index.exits.first.probability
        end
      end
      context "with the hunters_lodge action" do
        setup do
          @hl = @tp.actions.detect{|a| a.name == "static_hunters_lodge"}
        end
        should "not have an exit from the second to the first of 0%" do
          assert_equal 0, @hl.exits.size
        end
      end
    end

    context "run on a log file with four entries per two sessions" do
      setup do
        @tp.parse_file(fixture_file('four_actions.log'))
      end

      should "have two actions" do
        assert_equal 2, @tp.actions.size
      end
      context "with actions found" do
        setup do
          @index = @tp.actions.detect{|a| a.name == "index"}
          @hl = @tp.actions.detect{|a| a.name == "static_hunters_lodge"}
        end
        should "have two exits on index" do
          assert_equal 2, @index.exits.size
        end
        should "have one exit on hunters lodge" do
          assert_equal 1, @hl.exits.size
        end

        should "have p(index => index) = 0.50" do
          @exit = @index.exits.detect{|e|
            e.destination == @index
          }
          assert_not_nil @exit
          assert_equal 0.50, @exit.probability
        end
        should "have p(index => hl) = 0.50" do
          @exit = @index.exits.detect{|e|
            e.destination == @hl
          }
          assert_not_nil @exit
          assert_equal 0.50, @exit.probability
        end
        should "have p(hl => index) = 1.0" do
          @exit = @hl.exits.detect{|e|
            e.destination == @index
          }
          assert_not_nil @exit
          assert_equal 1.0, @exit.probability
        end
      end

    end
  end


  private

  def fixture_file(path_to_file)
    File.join(File.dirname(__FILE__), 'fixtures', path_to_file)
  end
end
