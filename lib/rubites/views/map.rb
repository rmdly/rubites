# frozen_string_literal: true

module Rubites
  module Views
    # Shows every level and its state. Read-only, so the in-order gating is
    # unaffected.
    class Map < View
      CELL = 6

      needs :exercises, :progress, :current

      def lines
        body = ['', indent(rule('LEVEL MAP', "#{progress.count} / #{exercises.size} cleared")), '']
        body.concat(grid)
        body.concat(['', indent(key)])
        body.concat(this_level)
        body.concat(totals)

        Text.pad(body, rows - 2) << indent(paint('press any key to go back', Screen::FAINT))
      end

      private
        def grid
          exercises.each_slice(per_row).map do |row|
            indent(row.map { |exercise| cell(exercise) }.join(' '))
          end
        end

        def per_row
          [(inner + 1) / CELL, 1].max
        end

        def cell(exercise)
          if exercise.basename == current&.basename
            paint(exercise.number, Screen::RUBY, bold: true)
          elsif progress.solved?(exercise)
            paint(exercise.number, Screen::GREEN)
          else
            paint(exercise.number, Screen::FAINT)
          end
        end

        def key
          [
            paint('cleared', Screen::GREEN),
            paint('current', Screen::RUBY, bold: true),
            paint('locked', Screen::FAINT)
          ].join('   ')
        end

        def this_level
          stat = progress.stat(current) if current
          return [] unless stat && progress.solved?(current)

          ['', indent(paint("this level: #{stat.duration}, #{stat.runs} runs", Screen::GREY))]
        end

        def totals
          return [] if progress.count.zero?

          summary = "total: #{progress.total_duration} across #{progress.total_runs} runs"
          ['', indent(paint(summary, Screen::GREY))]
        end
    end
  end
end
