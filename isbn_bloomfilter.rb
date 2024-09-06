LIMIT = 10000
# LIMIT = 1.0 / 0 # 1.0/0 in Ruby is infinite
%w{rubygems time redis csv bloomfilter-rb}.each{|r| require r}
bloomfilter = BloomFilter::Redis.new(:size => 1000000)

$redis = Redis.new(:host => "127.0.0.1", :port => 6379)
$redis.flushall

count, start = 0, Time.now
CSV.foreach(ARGV[0], headers: true) do |line|
    count += 1
    next if count == 1

    title = line['title']
    next if title.nil?

    words = title.gsub(/[^\w\s]+/, '').downcase
    # highligt words
    words = words.split(' ')
    words.each do |word|
        # skip the word,if it is already in bloomfilter 
        next if bloomfilter.include?(word)
        # print previously unknown word
        puts word
        # add new word in bloomfilter
        bloomfilter.insert(word)
    end

    # set LIMIT, if don't want to load all dataset
    break if count >= LIMIT
end

puts "Contains Jabbyredis? #{bloomfilter.include?('jabbyredis')}"
puts "#{count} elements per #{Time.now - start} seconds"