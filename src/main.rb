require_relative 'table_creator'
require_relative 'data_fetcher'

clan_hash = '2OPOLP'

fetcher = DataFetcher.new(clan_hash)
fetcher.update_clan_info

members = fetcher.fetch_clan_members
participants = fetcher.fetch_clan_war_participants

table_creator = TableCreator.new(members, participants)

File.write('outcome.txt', table_creator.create(:unicode))
File.write('outcome.md', table_creator.create(:markdown))
