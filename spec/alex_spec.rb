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

describe Alex::Agent, '.new' do
  it 'returns an instance of Alex::Agent' do
    expect(Alex::Agent.new).to be_an Alex::Agent
  end
end

describe Alex::Agent, '#network' do
  it 'return the attached network' do
    expect(Alex::Agent.new.network).to be_a RubyFann::Standard
  end
end

describe Alex::Agent, '#rate' do
  it 'saves a rating/post pair' do
    Alex::Agent.new.rate(4387, 1)
    pg = PG::Connection.new(dbname: 'alex')
    test = pg.exec('SELECT post_id FROM e621.votes WHERE post_id = 4387 '\
                   'AND vote = 1;').first
    t_value = { 'post_id' => '4387' }
    expect(test).to eq t_value
  end
end

describe Alex::Agent, '#train' do
  it 'trains the attached network with saved data' do
    Alex::Agent.new.train
  end
end

describe Alex::Agent, '#show' do
  it 'retusn a post ID to present to user' do
    expect(Alex::Agent.new.show).to be_an Integer
  end
end
