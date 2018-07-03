require 'net/http'
require 'nokogiri'
require 'selenium-webdriver'

class DataFetcher
  ClanWarParticipants = Struct.new(:clan_war_ago, :day_1, :day_2)

  def initialize(clan_hash)
    @clan_hash = clan_hash
  end

  def update_clan_info
    # options = Selenium::WebDriver::Firefox::Options.new
    # options.add_argument('--headless')
    driver = Selenium::WebDriver.for :firefox#, options: options

    driver.navigate.to "https://statsroyale.com/clan/#{@clan_hash}"
    element = driver.find_element(css: '.clan__refreshButton')
    driver.execute_script("arguments[0].click()", element)
    driver.quit
  end

  def fetch_clan_members
    response = Net::HTTP.get(URI("https://statsroyale.com/clan/#{@clan_hash}"))
    Nokogiri::HTML(response).css('.clan__table .clan__rowContainer').map do |row|
      row.css('.clan__row:nth-child(2)').text.strip
    end
  end

  def fetch_clan_war_participants(wars_count = 10)
    response = Net::HTTP.get(URI("https://statsroyale.com/clan/#{@clan_hash}/war/history"))

    extract_player_name = -> (el) { el.css('.clanParticipants__row:nth-child(2)').text.strip }

    Nokogiri::HTML(response).css('.clanWarHistory__modal').take(wars_count).map.with_index do |clan_war, index|
      day_1 = clan_war.css('.clanParticipants__rowContainer')
        .map(&extract_player_name)

      day_2 = clan_war
        .css('.clanParticipants__rowContainer')
        .select{ |el| el.css('.clanParticipants__row:nth-child(3)').text.strip != '0'}
        .map(&extract_player_name)

      ClanWarParticipants.new(wars_count - index, day_1, day_2)
    end
  end

  def mock_clan_members
    ['adi', 'bob', 'ciele']
  end

  def mock_clan_war_participants
    [
      ClanWarParticipants.new(1, ['adi', 'bob'], ['bob']),
      ClanWarParticipants.new(2, ['adi', 'bob'], ['adi', 'bob']),
      ClanWarParticipants.new(3, ['ciele', 'bob'], ['ciele']),
    ]
  end
end
