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

describe Alex::Network, '.new' do
  it 'returns an instance of Alex::Network' do
    expect(Alex::Network.new).to be_an Alex::Network
  end
end

describe Alex::Network, '#analyze' do
  it 'returns a Hash with tag information' do
    expect(Alex::Network.new.analyze(278_300)).to be_a Hash
  end
end
