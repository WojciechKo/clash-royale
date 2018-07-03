require 'tty-table'

class TableCreator
  def initialize(members, clan_wars_participants)
    @members = members
    @clan_wars_participants = clan_wars_participants
  end

  def create(config_name)
    config = Config.for(config_name)
    instruction + table(config) + footer
  end

  private

  attr_reader :members, :clan_wars_participants

  def table(config)
    TTY::Table.new(
      header: headings,
      rows: rows(config.participate_sign)
    ).render(config.renderer, alignment: [:center], padding: [0, 1], &config.renderer_config)
  end

  def table_md
    TTY::Table.new(
      header: headings,
      rows: rows
    ).render(:basic, alignment: [:center], padding: [0, 1]) do |renderer|
      renderer.border do
        left '|'
        right '|'
        center '|'
        mid '-'
        mid_left '|'
        mid_mid '|'
        mid_right '|'
      end
    end
  end

  def table_unicode
    TTY::Table.new(
      header: headings,
      rows: rows
    ).render(:unicode, alignment: [:center], padding: [0, 1]) do |renderer|
      renderer.border do
        separator :each_row
      end
    end
  end

  def headings
    day_headers = clan_wars_participants.map.with_index do |_el, index|
      war_ago = index + 1
      ["#{war_ago}-1", "#{war_ago}-2"]
    end.flatten

    headings = ['User'] + day_headers
  end

  def rows(sign_mapper)
    members.map do |member|
      participations = clan_wars_participants.flat_map do |clan_war_participants|
        [clan_war_participants.day_1.include?(member),
         clan_war_participants.day_2.include?(member)]
      end

      participations.map!{ |participated| sign_mapper.call(participated) }

      [member] + participations
    end
  end

  def instruction
    <<~INSTRUCTION
      3-1 means 1st day of 3rd clan war ago
      8-2 means 2nd day of 8th clan war ago

    INSTRUCTION
  end

  def footer
    "\n\nCreated at #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
  end

  class Config
    def self.for(config_name)
      case config_name
      when :unicode then Unicode.new
      when :markdown then Markdown.new
      else raise 'Not implemented'
      end
    end
  end

  class Unicode
    def participate_sign
      ->(participated) { participated ? '+' : '-' }
    end

    def renderer
      :unicode
    end

    def renderer_config
      Proc.new do |renderer|
        renderer.border do
          separator :each_row
        end
      end
    end
  end

  class Markdown
    def participate_sign
      ->(participated) { participated ? '✅' : '❌' }
    end

    def renderer
      :basic
    end

    def renderer_config
      Proc.new do |renderer|
        renderer.border do
          left '|'
          right '|'
          center '|'
          mid '-'
          mid_left '|'
          mid_mid '|'
          mid_right '|'
        end
      end
    end
  end
end
