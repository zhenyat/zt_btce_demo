class TickersJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    puts "ZT! Job - DONE!"
  end
end
