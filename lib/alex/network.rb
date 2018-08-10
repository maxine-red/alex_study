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
# @since 0.1.0
module Alex
  # Class for managing network analysis.
  # @author Maxine Michalski
  # @since 0.1.0
  class Network
    # @author Maxine Michalski
    #
    # Initializer for Network class
    def initialize
      net_file = "#{File.dirname(__FILE__)}/../../data/alex.net"
      data = File.read(net_file).split("\n")
      @network = RubyFann::Standard.new(filename: net_file)
      @pg = PG::Connection.new(dbname: 'alex')
      @pg.type_map_for_results = PG::BasicTypeMapForResults.new(@pg)
      data = data[-1].split(/\(|\)/)
      data.shift(3)
      data.reject! { |t| t == ' ' }
      data.map! do |t|
        t = t.split(/,\s/)
        [t[0].to_i, t[1].to_f]
      end
      @weights = []
      data.each do |l, v|
        @weights[l] = [] if @weights[l].nil?
        @weights[l] << v
      end
    end

    # @author Maxine Michalski
    #
    # Analyze a given post and see why Alex chosen it.
    #
    # @notice Only works with one category outputs right now
    #
    # return [Hash] Hash with various information on why Alex thinks this post
    # is (dis-)liked
    def analyze(id)
      data = @pg.exec('SELECT rank, tag FROM '\
                      'e621.post_tags JOIN e621.ranked_tags ON '\
                      'rank <= $1 AND ranked_tags.id = tag_id '\
                      'WHERE post_id = $2;',
                      [@network.get_num_input, id]).map do |r|
                        [r['rank'] - 1, r['tag']]
                      end
      inputs = data.map(&:first)
      hidden = Array.new(@network.get_layer_array[1]) { [] }
      inputs.each do |i|
        @weights[i].each.with_index do |w, hid|
          hidden[hid] << w
        end
      end
      tags = {}
      tag_ids, tag_influences = process_network(hidden)
      tag_ids.compact.each do |t|
        tags.store(data[t][1], tag_influences[t])
      end
      tags
    end

    private

    def process_network(hidden)
      tag_weights = hidden.dup
      hidden_influencer = process_hidden(hidden)
      tag_influences = Array.new(tag_weights.first.count, 0)
      hidden_influencer.each do |h|
        tag_weights[h].each.with_index do |t, i|
          tag_influences[i] += t
        end
      end
      ti_abs = tag_influences.map(&:abs)
      tag_ids = []
      16.times do
        tid = ti_abs.index(ti_abs.max)
        if tid
          ti_abs.delete_at(tid)
          tag_ids << tid
        end
      end
      [tag_ids, tag_influences]
    end

    def process_hidden(hidden)
      hidden_layer_size = @network.get_layer_array[1]
      hidden.map! do |w|
        Math.tanh(w.inject(:+))
      end
      offset = (@network.get_num_input + 1)
      hidden_weights = []
      hidden_layer_size.times do |h|
        hidden_weights << @weights[offset + h].first * hidden[h]
      end
      hidden_weights.map!(&:abs)
      hidden_influencer = []
      4.times do
        hid = hidden_weights.index(hidden_weights.max)
        hidden_weights.delete_at(hid)
        hidden_influencer << hid
      end
      hidden_influencer
    end
  end
end
