# -*- coding: utf-8 -*-
require "favt/version"
require "twitter"
require "colorize"
require "yaml"

module Favt
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

      @options = options 
      @config = YAML.load_file(yaml_file)

      self.init_client()
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
        print Render.new(favorite, @options).to_s
      end
    end
  end
  
  class Render
   
    def initialize(favorite, options)
      @users = favorite["users"]
      @post = favorite["post"]
      @options = options
    end

    def render_users
      render = "■"
      
      if !@options["no_color"]
        render.red
      end
      
      @users.times do  
        print render
      end 
    end

    def post_colorize(render_dict)
      if !@options["no_color"]
        render_dict[:screen_name] = render_dict[:screen_name].green.bold
        render_dict[:post_url] = render_dict[:post_url].blue
      end  
      return render_dict
    end

    def render_post
      post = @post 

      post_template = {
        screen_name: "[#{post.user.screen_name}] ",
        post_text: "#{post.text}\n",
        post_url: "#{post.url}\n",
      }

      self.post_colorize(post_template).values.join
    end

    def to_s
      self.render_users
      self.render_post
    end
  end
end
