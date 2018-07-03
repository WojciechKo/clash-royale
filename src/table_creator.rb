require 'tty-table'

class TableCreator
  def initialize(members, clan_wars_participants)
    @members = members
    @clan_wars_participants = clan_wars_participants
  end

  def create(config_name)
    config = Config.for(config_name)
    table(config) + "\n\n" + config.caption + "\n" + instruction  + "\n\n" + footer + "\n"
  end

  private

  attr_reader :members, :clan_wars_participants

  def table(config)
    TTY::Table.new(
      header: headings,
      rows: rows(config.transform_user, config.participate_sign)
    ).render(config.renderer, alignment: [:center], padding: [0, 1], width: 9999, &config.renderer_config)
  end

  def headings
    day_headers = (1 ..clan_wars_participants.size).map(&:to_s)

    headings = ['User'] + day_headers
  end

  def rows(transform_user, sign_mapper)
    members.map do |member|
      participations = clan_wars_participants.map do |clan_war_participants|
        if clan_war_participants.day_1.include?(member)
          if clan_war_participants.day_2.include?(member)
            :both
          else
            :day_1
          end
        else
          :none
        end
      end

      participations.map!{ |participated| sign_mapper.call(participated) }

      [transform_user.call(member)] + participations
    end
  end

  def instruction
    "Numbers in header means which clan war given column refers to, e.g. 4 means 4th war ago."
  end

  def footer
    "Created at #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
  end

  class Config
    def self.for(config_name)
      case config_name
      when :unicode then Unicode.new
      when :markdown then Markdown.new
      else raise 'Not implemented'
      end
    end

    class Unicode
      def transform_user
        ->(user_name) { user_name }
      end

      def participate_sign
        ->(participated) {
          case participated
          when :none then 'X'
          when :day_1 then '-'
          when :both then '+'
          end
        }
      end

      def caption
        <<~CAPTION
        X - Does not participated
        - - Participated only in the first day
        + - Partifipated in both days
        CAPTION
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
        ->(participated) {
          case participated
          when :none then '❌'
          when :day_1 then '☠️'
          when :both then '✅'
          end
        }
      end

      def caption
        <<~CAPTION
        ❌ - Does not participated  
        ☠️  - Participated only in the first day  
        ✅ - Partifipated in both days  
        CAPTION
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
end
