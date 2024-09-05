LIMIT = 1.0 / 0 # 1.0/0 in Ruby is infinite
# %w{rubygems hiredis redis/connection/hiredis}.each{|r| require r}
%w{rubygems time redis csv}.each{|r| require r}

$redis = Redis.new(:host => "127.0.0.1", :port => 6379)
$redis.flushall
count, start = 0, Time.now
CSV.foreach(ARGV[0], headers: true) do |line|
    count += 1
    next if count == 1
    isbn = line['isbn']
    title = line['title']
    next if isbn.nil? || title.nil?

    $redis.set(isbn, title.strip)

    # set LIMIT, if don't want to load all dataset
    break if count >= LIMIT
end

puts "#{count} elements per #{Time.now - start} seconds"