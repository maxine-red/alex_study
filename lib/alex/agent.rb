# frozen_string_literal: true

#  Copyright 2018 Maxine Michalski <maxine@furfind.net>
#
#  This file is part of alex.
#
#  alex is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  alex is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with alex.  If not, see <http://www.gnu.org/licenses/>.

# Namespace for all classes in this gem.
# @author Maxine Michalski
module Alex
  # Main class for agent creation and management.
  # @author Maxine Michalski
  class Agent
    # @author Maxine Michalski
    # @return [RubyFann::Standard] Network attached to this agent.
    attr_reader :network
    # @author Maxine Michalski
    #
    # Initializer methodd for agent Alex.
    def initialize
      @net_file = "#{File.dirname(__FILE__)}/../../data/alex.net"
      @network = RubyFann::Standard.new(filename: @net_file)
      @dir = File.expand_path('~/.alex')
      @pg = PG::Connection.new(dbname: 'alex')
      @pg.type_map_for_results = PG::BasicTypeMapForResults.new(@pg)
    end

    # @author Maxine Michalski
    #
    # Safe a vote/post pair to file.
    #
    # @notice This method clips input ratings
    def rate(post_id, vote = nil)
      return rate_yourself(post_id) if vote.nil?
      vote = clip(vote)
      id = @pg.exec('SELECT post_id, vote FROM e621.votes WHERE post_id = $1;',
                    [post_id]).first
      if id.nil?
        @pg.exec('INSERT INTO e621.votes (post_id, vote) VALUES ($1, $2);',
                 [post_id, vote])
      else
        @pg.exec('UPDATE e621.votes SET vote = $2 WHERE post_id = $1;',
                 [post_id, vote])
      end
    end

    # @author Maxine Michalski
    #
    # Taining method for attached network.
    def train
      puts 'Collecting data... (this may take some time)'
      data = gather_data
      train, test = create_data(data.uniq.shuffle)
      puts "\e[1mTrain set size: #{train.length}\e[0m",
           "\e[1mTest set size: #{test.length}\e[0m"
      do_train(train)
      do_test(test)
    end

    def show
      data = @pg.exec('SELECT post_tags.post_id, array_agg(rank) as tags FROM '\
                      'e621.post_tags LEFT JOIN e621.votes ON votes.post_id = '\
                      'post_tags.post_id JOIN e621.ranked_tags ON '\
                      'rank <= $1 AND ranked_tags.id = tag_id '\
                      'WHERE votes.post_id IS NULL '\
                      'GROUP BY post_tags.post_id ORDER BY post_tags.post_id;',
                      [@network.get_num_input]).to_a
      data.shuffle.each do |r|
        tags = Array.new(@network.get_num_input, 0.0)
        r['tags'].each do |t|
          tags[t - 1] = 1.0
        end
        return r['post_id'] if @network.run(tags).first > 0.95
      end
    end

    private

    def rate_yourself(id)
      @pg.exec('SELECT array_agg(rank) as tags FROM '\
               'e621.post_tags JOIN e621.ranked_tags ON '\
               'rank <= $1 AND ranked_tags.id = tag_id WHERE post_id = $2'\
               'GROUP BY post_id;',
               [@network.get_num_input, id]).map do |r|
                 tags = Array.new(@network.get_num_input, 0.0)
                 r['tags'].each do |t|
                   tags[t - 1] = 1.0
                 end
                 (@network.run(tags).first * 100).round(2)
               end.first
    end

    def gather_data
      @pg.exec('SELECT array_agg(rank) as tags, vote FROM '\
               'e621.votes JOIN e621.post_tags ON votes.post_id = '\
               'post_tags.post_id JOIN e621.ranked_tags ON '\
               'rank <= $1 AND ranked_tags.id = tag_id GROUP BY '\
               'vote, votes.post_id;',
               [@network.get_num_input]).map do |r|
                 tags = Array.new(@network.get_num_input, 0.0)
                 r['tags'].each do |t|
                   tags[t - 1] = 1.0
                 end
                 vote = Array.new(@network.get_num_output) do |i|
                   i.succ == r['vote'].abs ? r['vote'].to_f : 0.0
                 end
                 [tags, vote]
               end
    end

    def do_train(train)
      s = Time.now
      @network.train_on_data(train, 2**10, 16, 0.001)
      time_spent = (Time.now - s).round(4)
      puts "Training took #{time_spent}s"
      @network.save(@net_file)
    end

    def do_test(test)
      correct = 0
      test.each do |data, desired_result|
        result = @network.run(data).first.round
        correct += 1 if result == desired_result.first
      end
      percent = (correct * 100.0 / test.count).round(2)
      puts "\e[1mResult is: #{percent}% correct predictions\e[0m"
    end

    def create_data(test_set)
      r = 0.75
      train_size = (test_set.count * r).ceil
      train_set = test_set.shift(train_size)
      train = RubyFann::TrainData.new(inputs: train_set.map(&:first),
                                      desired_outputs: train_set.map(&:last))
      [train, test_set]
    end

    # @author Maxine Michalski
    #
    # Helper method to clip inputs into a fixed range
    #
    # @return [Integer] clipped number
    def clip(int)
      if int < -1
        -1
      elsif int > 1
        1
      else
        int
      end
    end
  end
end
