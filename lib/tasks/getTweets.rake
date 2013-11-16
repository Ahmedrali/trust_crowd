require "json"

desc "Get the tweets for each problem and its corresponding alternatives and criteria"
task :getTweets => :environment do
    consumerkey       =  "KkY669R1jCF63JiYqC42Q"
    consumerSecret    =  "NIrAQp87Mgp9BsXutA1kgAChZr5cTARUlqZTlqC5YA"
    access_token = app_only_authentication(consumerkey, consumerSecret)
    if access_token
      do_search(access_token)
    end
end

# Exchange the Key and secret for an AccessToken instance.
def app_only_authentication(consumerkey, consumerSecret)
  basic = Base64.encode64("#{consumerkey}:#{consumerSecret}").gsub("\n","")
  access_token = getAccessToken("https://api.twitter.com/oauth2/token", basic)
  if access_token.include?("access_token")
    access_token = access_token["access_token"]
    return access_token
  else
    puts "Err: #{access_token}"
  end
end

# Used the search API
def do_search(access_token)
  
  problems = Problem.active.where("id > ?", (Tweet.last.problem rescue 0))
  
  problems.each do |problem|
    puts "Getting Tweets For '#{problem.name}' => #{problem.tw_hash}"
    # Get Tweets that talks just about the problem as a whole
    core_search(problem, problem, access_token)
    
    # Get Tweets that talks about each criterium
    problem.criteria.each do |criterium|
      core_search(problem, criterium, access_token)
    end
    
    # Get Tweets that talks about each alternative
    problem.alternatives.each do |alternative|
      core_search(problem, alternative, access_token)
    end
  end
  
end

# Get the tweets and save them
def core_search(problem, obj, access_token)
  tw_hash = obj.tw_hash
  query = "?q=##{tw_hash}&since_id=#{obj.last_tweet_id}&count=100&result_type=mixed"
  tweets = loop_search(query, access_token)
  puts tweets.keys.count
  unless tweets.keys.empty?
    saveTweets(problem, tw_hash, tweets, obj)
  end
end

# Get all tweets that match the query
def loop_search(query, access_token)
  tweets = {}
  while !query.nil? do
    puts query
    url = "https://api.twitter.com/1.1/search/tweets.json"
    result = getTweetsPage(url, query, access_token)
    if result and result["statuses"]
      result["statuses"].each_with_index do |s, i|
        tweets[s['id']] = {"created_at" => s['created_at'], "text" => s['text'], "retweet_count" => s["retweet_count"], "retweeted_id" => (s["retweeted_status"]["id"] rescue s["id"])}
      end
      query = result['search_metadata']['next_results']
    else
      puts "Err: #{result}"
      query = nil
    end
  end
  tweets
end

# Save the tweets for the correspondence problem/tw_hash
def saveTweets(problem, tw_hash, tweets, obj)
  Tweet.transaction do
    keys = tweets.keys.sort
    keys.each do |key|
      val = tweets[key]
      if val['retweet_count'] > 0 and Tweet.exists?(:problem_id => problem.id, :tweet_id => val['retweeted_id'], :tw_hash => tw_hash)
        tweet = Tweet.where(:problem_id => problem.id, :tweet_id => val['retweeted_id'], :tw_hash => tw_hash).first
        puts "Existance Tweets in '#{problem.name}':#{val['retweeted_id']}:#{tw_hash}:#{val['retweet_count']}:#{tweet.retweet_count}"
        tweet.retweet_count = val["retweet_count"]
        tweet.save
      else
        Tweet.create(
                    :problem_id     =>  problem.id,
                    :tweet_id       =>  key,
                    :tw_hash        =>  tw_hash,
                    :retweet_count  =>  val["retweet_count"],
                    :text           =>  val["text"],
                    :created_date   =>  Time.parse(val["created_at"])
                  )  
      end
    end
    obj.last_tweet_id = keys.last
    obj.save
  end
end

# Get the access token based on the key:secret
def getAccessToken(url, basic)
  require 'net/http'
  require 'net/https'
  require "uri"
  
  headers = { 
              "Authorization" => "Basic #{basic}",
              "Content-Type" => "application/x-www-form-urlencoded;charset=UTF-8"
            }
  url = URI.parse(url)
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  http.start do |http|
    req = Net::HTTP::Post.new(url.path, initheader = headers)
    req.body = "grant_type=client_credentials"
    resp = http.request(req)
    return JSON.parse(resp.body)
  end
end

# Get the actual tweets page
def getTweetsPage(url, query, access_token)
  require 'net/http'
  require 'net/https'
  require "uri"
  
  headers = { 
              "Authorization" => "Bearer #{access_token}",
            }
  url = URI.parse(url)
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  http.start do |http|
    req = Net::HTTP::Get.new("#{url.path}#{query}", initheader = headers)
    resp = http.request(req)
    return JSON.parse(resp.body) rescue {}
  end
end