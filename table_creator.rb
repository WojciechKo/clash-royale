require 'terminal-table'

class TableCreator
  def initialize(members, clan_wars_participants)
    @members = members
    @clan_wars_participants = clan_wars_participants
  end

  def create
    instruction + table.to_s
  end

  private

  attr_reader :members, :clan_wars_participants

  def table
    Terminal::Table.new(
      headings: headings,
      rows: rows,
      style: {all_separators: true, alignment: :center}
    )
  end

  def headings
    day_headers = clan_wars_participants.map.with_index do |_el, index|
      war_ago = index + 1
      ["#{war_ago}-1", "#{war_ago}-2"]
    end.flatten

    headings = ['User'] + day_headers
  end

  def rows
    members.map do |member|
      participations = clan_wars_participants.flat_map do |clan_war_participants|
        [clan_war_participants.day_1.include?(member),
         clan_war_participants.day_2.include?(member)]
      end

      participations.map!(&method(:participance_sign))

      [member] + participations
    end
  end

  def participance_sign(bool)
    bool ? "+" : "-"
  end

  def instruction
    <<~INSTRUCTION
      3-1 means 1st day of 3rd clan war ago
      8-2 means 2nd day of 8th clan war ago

      Created at #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}

    INSTRUCTION
  end
end
