class GetTradesJob < ApplicationJob
#  self.queue_adapter = :delayed_job
  queue_as :default
  
  RUN_EVERY = 1.minute

  def perform
    # Do something later
#    last_id = Trade.last.id
#    puts "ZT Job.#{Time.now}: #{last_id}"
    n = 0
    while n < 5 do
      trade = Trade.last
      puts "ZT Job.#{Time.now}: #{trade.id} - #{trade.pair_id}"
      n += 1
      sleep(20)
    end
    
#    self.class.perform_later(wait: RUN_EVERY)
  end
end
