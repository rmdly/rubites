# frozen_string_literal: true

module Rubites
  module Views
    # Shows every exercise and its state, one row per level. Read-only, so the
    # in-order gating is unaffected.
    class Map < View
      GAP = 2

      needs :exercises, :progress, :current

      def lines
        body = ['', indent(rule('LEVEL MAP', "#{progress.count} / #{exercises.size} cleared")), '']
        body.concat(grid)
        body.concat(['', indent(key)])
        body.concat(this_exercise)
        body.concat(totals)

        Text.pad(body, rows - 2) << indent(paint('press any key to go back', Screen::FAINT))
      end

      private
        def grid
          exercises.group_by(&:level).flat_map { |level, group| level_rows(level, group) }
        end

        # A level wide enough to wrap keeps its label on the first row only, so
        # the continuation lines sit under its exercises.
        def level_rows(level, group)
          group.each_slice(per_row).each_with_index.map do |slice, row|
            indent(Text.ljust(row.zero? ? label(level) : '', label_width) + cells(slice))
          end
        end

        def label(level)
          paint("LEVEL #{level}", Screen::GREY)
        end

        def cells(slice)
          slice.map { |exercise| Text.ljust(cell(exercise), cell_width) }.join(' ').rstrip
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

        def label_width
          @label_width ||= exercises.map { |exercise| "LEVEL #{exercise.level}".length }.max + GAP
        end

        def cell_width
          @cell_width ||= exercises.map { |exercise| exercise.number.length }.max
        end

        def per_row
          [(inner - label_width + 1) / (cell_width + 1), 1].max
        end

        def key
          [
            paint('cleared', Screen::GREEN),
            paint('current', Screen::RUBY, bold: true),
            paint('locked', Screen::FAINT)
          ].join('   ')
        end

        def this_exercise
          stat = progress.stat(current) if current
          return [] unless stat && progress.solved?(current)

          ['', indent(paint("this exercise: #{stat.duration}, #{stat.runs} runs", Screen::GREY))]
        end

        def totals
          return [] if progress.count.zero?

          summary = "total: #{progress.total_duration} across #{progress.total_runs} runs"
          ['', indent(paint(summary, Screen::GREY))]
        end
    end
  end
end
