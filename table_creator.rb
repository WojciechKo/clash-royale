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
      header: headings(config.war_day_header),
      rows: rows(config.transform_user, config.participate_sign)
    ).render(config.renderer, alignment: [:center], padding: [0, 1], width: 9999, &config.renderer_config)
  end

  def headings(war_day_header)
    day_headers = clan_wars_participants.map.with_index do |_el, index|
      war_ago = index + 1
      [war_day_header.call(war_ago, 1), war_day_header.call(war_ago, 2)]
    end.flatten

    headings = ['User'] + day_headers
  end

  def rows(transform_user, sign_mapper)
    members.map do |member|
      participations = clan_wars_participants.flat_map do |clan_war_participants|
        [clan_war_participants.day_1.include?(member),
         clan_war_participants.day_2.include?(member)]
      end

      participations.map!{ |participated| sign_mapper.call(participated) }

      [transform_user.call(member)] + participations
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
    def transform_user
      ->(user_name) { user_name }
    end

    def participate_sign
      ->(participated) { participated ? '+' : '-' }
    end

    def war_day_header
      ->(first, second) { "#{first}-#{second}" }
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
    def transform_user
      ->(user_name) { "``#{user_name}``" }
    end

    def participate_sign
      ->(participated) { participated ? '✅' : '❌' }
    end

    def war_day_header
      ->(first, second) { "#{first}&#8209;#{second}" }
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
