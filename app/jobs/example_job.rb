class ExampleJob
  include Sidekiq::Job
  def perform(*args)
    # Simulate a long-running task
    puts "Executing Sidekiq Job with args: #{args.inspect}"
    # Sleep for 10 seconds to mock job processing time
    sleep(10)
    # After the sleep, job continues
    puts "Job completed after sleeping for 10 seconds."
  end
end
