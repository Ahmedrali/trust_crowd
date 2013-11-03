require "json"

desc "Get the tweets for each problem and its corresponding lternatives and criteria"
task :getTweets => :environment do
    consumerkey       =  "KkY669R1jCF63JiYqC42Q"
    consumerSecret    =  "NIrAQp87Mgp9BsXutA1kgAChZr5cTARUlqZTlqC5YA"
    accessToken       =  "330615530-yzmnzjYesMbPdtEu4Qp3b0MMA65AQ2fGk0ljDJ2Y"
    accessTokenSecret =  "cl2Ttx802RjSWcR0yoJk8t1IlpQLol0eF5nowFmMo"
    access_token = prepare_access_token(accessToken, accessTokenSecret, consumerkey, consumerSecret)
    params = {"track" => "Egypt"}
    url = "https://stream.twitter.com/1.1/statuses/filter.json?track=Egypt"
    result = JSON.parse(access_token.request(:get, url).body)
    puts result
end

# Exchange your oauth_token and oauth_token_secret for an AccessToken instance.
def prepare_access_token(oauth_token, oauth_token_secret, consumerkey, consumerSecret)
  consumer = OAuth::Consumer.new(consumerkey, consumerSecret, { :site => "http://api.twitter.com"})
  token_hash = { :oauth_token => oauth_token,
                 :oauth_token_secret => oauth_token_secret
               }
  access_token = OAuth::AccessToken.from_hash(consumer, token_hash )
  return access_token
end

# Used the search API
def do_search(access_token)
  tweets = {}
  query = "?max_id=378894820992761855&q=%23Egypt&count=100&include_entities=1"
  while !query.nil? do
    puts query
    url = "https://api.twitter.com/1.1/search/tweets.json#{query}"
    result = JSON.parse(access_token.request(:get, url).body)
    result["statuses"].each_with_index do |s, i|
      tweets[s['id']] = s['created_at']
    end
    query = result['search_metadata']['next_results']
  end
  puts tweets.keys.count
end
