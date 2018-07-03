require 'net/http'
require 'nokogiri'
require_relative 'table_creator'

WINDOW_SIZE = 10
ClanWarParticipants = Struct.new(:clan_war_ago, :day_1, :day_2)

def fetch_clan_members
  response = Net::HTTP.get(URI('https://statsroyale.com/clan/LU2VCPU'))
  Nokogiri::HTML(response).css('.clan__table .clan__rowContainer').map do |row|
    row.css('.clan__row:nth-child(2)').text.strip
  end
end

def fetch_clan_war_participants
  response = Net::HTTP.get(URI('https://statsroyale.com/clan/LU2VCPU/war/history'))

  extract_player_name = -> (el) { el.css('.clanParticipants__row:nth-child(2)').text.strip }

  Nokogiri::HTML(response).css('.clanWarHistory__modal').take(WINDOW_SIZE).map.with_index do |clan_war, index|
    day_1 = clan_war.css('.clanParticipants__rowContainer')
      .map(&extract_player_name)

    day_2 = clan_war
      .css('.clanParticipants__rowContainer')
      .select{ |el| el.css('.clanParticipants__row:nth-child(3)').text.strip != '0'}
      .map(&extract_player_name)

    ClanWarParticipants.new(WINDOW_SIZE - index, day_1, day_2)
  end
end

def get_lazy_members(members, participants)
  members - participants.map(&:day_2).flatten.uniq
end

members = fetch_clan_members
participants = fetch_clan_war_participants

lazy_shits = get_lazy_members(members, participants)
puts lazy_shits

# members = ['adi', 'bob', 'ciele']
# participants = [
#   ClanWarParticipants.new(1, ['adi', 'bob'], ['bob']),
#   ClanWarParticipants.new(2, ['adi', 'bob'], ['adi', 'bob']),
#   ClanWarParticipants.new(3, ['ciele', 'bob'], ['ciele']),
# ]

table_creator = TableCreator.new(members, participants)

File.write('table.txt', table_creator.create(:unicode))
File.write('table.md', table_creator.create(:markdown))
