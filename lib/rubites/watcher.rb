# frozen_string_literal: true

module Rubites
  # Watches one file by polling its mtime, which avoids a dependency on a
  # filesystem-notification gem.
  class Watcher
    DEBOUNCE = 0.15

    def watch(path)
      @seen = mtime(path)
      @changed_at = nil
    end

    # True once the file has changed and then stopped changing. Editors that
    # save atomically touch the path more than once, so the first event can
    # arrive while the file is still incomplete.
    def changed?(path)
      current = mtime(path)

      if current.nil?
        false
      elsif current != @seen
        note(current)
        false
      elsif settled?
        @changed_at = nil
        true
      else
        false
      end
    end

    private
      def note(mtime)
        @seen = mtime
        @changed_at = Time.now
      end

      def settled?
        @changed_at && Time.now - @changed_at >= DEBOUNCE
      end

      def mtime(path)
        File.mtime(path)
      rescue Errno::ENOENT
        nil
      end
  end
end
