# -*- coding: utf-8 -*-
require "twitter"
require "yaml"

module Client
  class TwitterClient
    def init_client
      keys = @config["client"]
      @client = Twitter::REST::Client.new do |config|
        config.consumer_key = keys["consumer_key"]
        config.consumer_secret = keys["consumer_secret"]
        config.access_token = keys["access_token"]
        config.access_token_secret = keys["access_token_secret"]
      end
    end
    
    def initialize(options)
      yaml_file = options["config_file"] || "config.yaml"      
      @render = options["render"] || Favt::Render
      @options = options 
      @config = YAML.load_file(yaml_file)
      self.init_client
    end

    def favorites_from_user
      users = self.target_users
      return users.flat_map do |user|
        @client.favorites user
      end
    end

    def take(set_fav_posts)
      show_count = @options["show_count"].to_i || 0
      if show_count != 0
        return set_fav_posts.take(show_count)
      end
      return set_fav_posts
    end

    def target_users
      if !@options["user"]
        return @config["users"]
      end
      return [@options["user"]]
    end

    def favorite_posts
      show_fav_posts = self.to_set(self.favorites_from_user.sort do
        |prev_post, next_post| next_post.id <=> prev_post.id
      end)
      
      return self.take(show_fav_posts)
    end
    
    def to_set(favorites)
      favorites_dict = {}
      favorites.each do |favorite|
        if !(favorites_dict.key? favorite.id)
          favorites_dict[favorite.id] = {
            "users" => 1, "post" => favorite}
        else
          favorites_dict[favorite.id]["users"] += 1
        end
      end
      return favorites_dict
    end

    def render
      self.favorite_posts.each do |_, favorite|
        print @render.new(favorite, @options, @config).to_s
        print "\n"
      end
    end
  end
end
