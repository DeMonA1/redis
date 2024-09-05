BATCH_SIZE = 1000
LIMIT = 1.0 / 0 # 1.0/0 in Ruby is infinite
# %w{rubygems hiredis redis/connection/hiredis}.each{|r| require r}
%w{rubygems time redis csv}.each{|r| require r}

$redis = Redis.new(:host => "127.0.0.1", :port => 6379)
$redis.flushall

#send data like one updating package
def flush(batch)
    $redis.pipelined do
        batch.each do |saved_line|
            isbn = saved_line['isbn']
            title = saved_line['title']
            next if isbn.nil? || title.nil?
            $redis.set(isbn, title.strip)
        end
    end
    batch.clear
end

batch = []
count, start = 0, Time.now
CSV.foreach(ARGV[0], headers: true) do |line|
    count += 1
    next if count == 1

    # put lines in an array
    batch << line

    #when there are BATCH_SIZE elements in an array - reset it
    if batch.size == BATCH_SIZE
        flush(batch)
        puts "#{count-1} elements"
    end

    # set LIMIT, if don't want to load all dataset
    break if count >= LIMIT
end

# reset left values
flush(batch)

puts "#{count} elements per #{Time.now - start} seconds"