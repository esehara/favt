# -*- coding: utf-8 -*-
require "colorize"

module Render 
  class Render
    def initialize(favorite, options, config)
    
      @favorite = favorite
      @options = options
      @config = config

      self.init_custom_render
        .repack
    end
    
    def repack
      post = @favorite["post"]

      @render = {}
      @render[:users] = @origin_render[:users] * @favorite["users"]
      @render[:screen_name] = @origin_render[:screen_name]
        .sub('#{post.user.screen_name}', post.user.screen_name)
      @render[:post_text] = @origin_render[:post_text]
        .sub('#{post.text}', post.text)
      @render[:post_url] = @origin_render[:post_url]
        .sub('#{post.url}', post.url.to_s)
    end
  
    def init_custom_render
      custom_render = @config["custom_render"]

      # First Initialize Values
      
      users_str = '■'
      screen_name_str = '[#{post.user.screen_name}]\n'
      post_text_str = '#{post.text}\n'
      post_url_str =  '#{post.url}\n'

      if custom_render
        users_str = custom_render["users"] || users_str
        screen_name_str = custom_render["screen_name"] || screen_name_str
        post_text_str = custom_render["post_text"] || post_text_str
        post_url_str = custom_render["post_url"] || post_url_str
      end
      
      @origin_render = {
        users: users_str,
        screen_name: screen_name_str,
        post_text: post_text_str,
        post_url: post_url_str
      }
      return self
    end

    def user_colorize
      if !@options["no_color"]
        @render[:users] = @render[:users].red
      end
      return self
    end

    def post_colorize
      if !@options["no_color"]
        @render[:screen_name] = @render[:screen_name].green.bold
        @render[:post_url] = @render[:post_url].blue
      end  
      return @render
    end

    def to_s
      self
        .user_colorize
        .post_colorize
        .values.join
        .sub("\\n", "\n")
    end
  end
end

