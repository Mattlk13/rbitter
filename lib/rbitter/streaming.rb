# encoding: utf-8

require 'twitter'

module Rbitter
  class DummyStreamClient
    def initialize(tokens); end

    def run(&operation_block)
      internal(&operation_block)
    end

    private
    def internal(&operation_block)
      tweets = [{
        "tweetid" => 1,
        "userid" => 1,
        "replyto" => nil,
        "tweet" => "test",
        "rt_count" => 0,
        "fav_count" => 0,
        "screen_name" => "twitter",
        "date" => "2015-01-01 12:11:10",
        "media_urls" => ["https://pbs.twimg.com/media/CEPWFtgUgAEmbcV.png"],
        "web_urls" => ["https://www.google.com/"]
      }]

      tweets.each { |tweet|
        yield tweet
      }
    end
  end

  class StreamClient
    def initialize(tokens)
      @t = Twitter::Streaming::Client.new do |object|
        object.consumer_key        = tokens['consumer_key']
        object.consumer_secret     = tokens['consumer_secret']
        object.access_token        = tokens['access_token']
        object.access_token_secret = tokens['access_token_secret']
      end
    end

    def run(&operation_block)
      begin
        internal(&operation_block)
      rescue EOFError => e
        puts "Network unreachable. Retry in 3 seconds..."
        sleep 3
        retry
      end
    end

    private
    def internal(&operation_block)
      @t.user do |tweet|
        if tweet.is_a?(Twitter::Tweet)
          if tweet.retweet?
            tweet = tweet.retweeted_tweet
          end

          text = tweet.full_text.gsub(/(\r\n|\n)/, '')

          # unpack uris and media links
          media_urls = Array.new
          web_urls = Array.new

          if tweet.entities?
            if tweet.media?
              tweet.media.each { |media|
                media_urls.push("#{media.media_uri_https}")
                text.gsub!("#{media.url}", "#{media.display_url}")
              }
            end

            text += " "
            text += media_urls.join(" ")

            if tweet.uris?
              tweet.uris.each { |uri|
                web_urls.push("#{uri.expanded_url}")
                text.gsub!("#{uri.url}", "#{uri.expanded_url}")
              }
            end
          end

          res = {
            "tweetid" => tweet.id,
            "userid" => tweet.user.id,
            "replyto" => tweet.in_reply_to_status_id? ? tweet.in_reply_to_status_id : nil,
            "tweet" => text,
            "rt_count" => tweet.retweet_count,
            "fav_count" => tweet.favorite_count,
            "screen_name" => tweet.user.screen_name,
            "date" => tweet.created_at,
            "media_urls" => media_urls,
            "web_urls" => web_urls
          }
          
          yield res
        end      
      end
    end
  end
end