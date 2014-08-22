require 'net/http'

desc "Call the OMP App for evaluating the tweets and store their polarities"
task :evalTweets => :environment do
    Tweet.all.each do |tweet|
      url = "http://localhost:8000"
      url = "http://blooming-bastion-5776.herokuapp.com/"
      url = URI.parse(url)
      http = Net::HTTP.new(url.host, url.port)
      http.start do |http|
        req = Net::HTTP::Post.new("/taggingList")
        req.body = [tweet.text].to_json
        resp = http.request(req)
        resp = JSON.parse(resp.body)
        resp.each do |r|
          tweet.polarity =  r[1]
          tweet.save
        end
      end
    end
end