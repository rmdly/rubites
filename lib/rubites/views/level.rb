# frozen_string_literal: true

module Rubites
  module Views
    class Level < View
      PANEL_LINES = 8
      GAP = 2
      LABEL = 16
      ERROR_ROOM = 58

      needs :level, :cleared, :total, :status, :result, :difference, :flash, :hint, :author, :tally

      def lines
        body = header
        body.concat(wrapped(level.prose, Screen::WHITE))
        body.concat(narration)
        body << ''
        body.concat(panels)
        body << ''
        body << indent(paint(status.text, status.colour))
        body.concat(difference_lines)
        body.concat(flash_line)
        body.concat(hint_lines)

        Text.pad(body, rows - 2) << indent(footer)
      end

      private
        def header
          [
            '',
            indent(rule('RUBITES', "#{username} · #{Time.now.strftime('%H:%M')}")),
            '',
            indent(heading),
            indent(progress_bar),
            ''
          ]
        end

        def heading
          left = [
            paint("LEVEL #{level.number}", Screen::RUBY, bold: true),
            paint('·', Screen::FAINT),
            paint(level.title, Screen::WHITE, bold: true)
          ].join(' ')
          right = paint("#{cleared} / #{total}", Screen::GREY)

          "#{Text.ljust(left, inner - Text.width(right))}#{right}"
        end

        def progress_bar
          label = " #{percent}%"
          width = [inner - label.length, 1].max
          filled = total.zero? ? 0 : (cleared.to_f / total * width).round

          paint('█' * filled, Screen::RUBY) +
            paint('░' * (width - filled), Screen::FAINT) +
            paint(label, Screen::GREY)
        end

        def percent
          total.zero? ? 0 : (cleared.to_f / total * 100).round
        end

        def narration
          return [] unless level.narrator

          ['', *wrapped(level.narrator, Screen::NARRATOR, italic: true)]
        end

        def panels
          width = (inner - GAP) / 2
          left = panel('expected', level.expected_lines, width, Screen::GREY)
          right = panel('yours', output, width, output_colour)

          [left.size, right.size].max.times.map do |index|
            indent("#{Text.ljust(left[index] || '', width)}#{' ' * GAP}#{right[index] || ''}")
          end
        end

        def panel(title, content, width, colour)
          shown = content.empty? ? ['-'] : content
          # Report how many lines were dropped rather than truncating silently.
          visible = shown.first(PANEL_LINES)
          visible += ["… +#{shown.size - PANEL_LINES} more"] if shown.size > PANEL_LINES

          [panel_top(title, width), *panel_rows(visible, width, colour), panel_bottom(width)]
        end

        def panel_top(title, width)
          paint("┌─ #{title} #{'─' * [width - title.length - 5, 0].max}┐", Screen::FAINT)
        end

        def panel_rows(visible, width, colour)
          edge = paint('│', Screen::FAINT)

          visible.map do |line|
            "#{edge} #{Text.ljust(paint(Text.clip(line, width - 4), colour), width - 4)} #{edge}"
          end
        end

        def panel_bottom(width)
          paint("└#{'─' * (width - 2)}┘", Screen::FAINT)
        end

        def output
          if result.nil?
            ['-']
          elsif result.lines.empty?
            ['(nothing printed)']
          else
            result.lines
          end
        end

        def output_colour
          if result.nil?
            Screen::GREY
          elsif result.passed?
            Screen::GREEN
          else
            Screen::RUBY
          end
        end

        def difference_lines
          return [] unless difference&.positioned?

          room = inner - LABEL - MARGIN
          [
            labelled('expected', difference.expected, Screen::GREY, room),
            labelled('yours', difference.actual, Screen::RUBY, room),
            *caret(room)
          ]
        end

        def labelled(label, text, colour, room)
          indent("#{paint(label.rjust(LABEL - MARGIN), Screen::FAINT)}  #{paint(Text.clip(text.to_s, room), colour)}")
        end

        def caret(room)
          column = difference.column
          return [] unless column && column <= room

          ["#{' ' * (LABEL + MARGIN + column - 1)}#{paint('^', Screen::YELLOW, bold: true)}"]
        end

        def flash_line
          return [] unless flash&.showing?

          [indent(paint(flash.message, Screen::YELLOW, dim: true))]
        end

        def hint_lines
          return [] unless hint && level.hint

          ['', *wrapped("hint: #{level.hint}", Screen::YELLOW)]
        end

        def footer
          right = paint(activity, Screen::FAINT)
          "#{Text.ljust(shortcuts, inner - Text.width(right))}#{right}"
        end

        def shortcuts
          keys.map { |key, label| "#{paint("[#{key}]", Screen::RUBY)} #{paint(label, Screen::GREY)}" }.join('  ')
        end

        def keys
          basic = [%w[h hint], %w[r rerun], %w[m map]]
          basic += [%w[n next], %w[p prev]] if author
          basic + [%w[q quit]]
        end

        # Includes an age that updates every second, so a live screen is
        # distinguishable from a stale one even when the result does not change.
        def activity
          if tally.ran?
            verb = tally.trigger == :rerun ? 'reran' : 'ran'
            "#{verb} #{Duration.ago(tally.ran_at)} · run #{tally.runs}"
          else
            'watching for save'
          end
        end
    end
  end
end
