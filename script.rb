require_relative 'table_creator'
require_relative 'data_fetcher'

fetcher = DataFetcher.new
fetcher.update_clan_info

members = fetcher.fetch_clan_members
participants = fetcher.fetch_clan_war_participants

table_creator = TableCreator.new(members, participants)

File.write('table.txt', table_creator.create(:unicode))
File.write('table.md', table_creator.create(:markdown))
