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
      @render = @origin_render
      
      @render[:users][:template] =
        @origin_render[:users][:template] * @favorite["users"]
      @render[:screen_name][:template] =
        @origin_render[:screen_name][:template]
        .sub('#{post.user.screen_name}', post.user.screen_name)
      @render[:post_text][:template] =
        @origin_render[:post_text][:template]
        .sub('#{post.text}', post.text)
      @render[:post_url][:template] =
        @origin_render[:post_url][:template]
        .sub('#{post.url}', post.url.to_s)
    end
  
    def init_custom_render
      @custom_render = @config["custom_render"]

      # First Initialize Values
      users_dict = {
        template: '■',
        color: :red
      }

      screen_name_dict = {
        template: '[#{post.user.screen_name}]\n',
        color: :green
      } 
      
      post_text_dict = {
        template: '#{post.text}\n',
        color: :white
      }

      post_url_dict = {
        template: '#{post.url}\n',
        color: :blue
      }
      

      def build_render_dict(key, defalut_dict)
        if !@custom_render[key]
          defalut_dict
        else
          pre_dict = {
            template: @custom_render[key]["template"] || defalut_dict[:template],
            color:    @custom_render[key]["color"]    || defalut_dict[:color]
          }
          pre_dict[:color] = pre_dict[:color].to_sym
          return pre_dict
        end
      end
      
      if @custom_render
        users_dict       = build_render_dict "users", users_dict
        screen_name_dict = build_render_dict "screen_name", screen_name_dict
        post_text_dict   = build_render_dict "post_text", post_text_dict
        post_url_dict    = build_render_dict "post_url",  post_url_dict
      end
      
      @origin_render = {
        users: users_dict,
        screen_name: screen_name_dict,
        post_text: post_text_dict,
        post_url: post_url_dict
      }
      return self
    end

    def user_colorize
      if !@options["no_color"]
        @render[:users][:template] =
          @render[:users][:template]
          .colorize(@render[:users][:color])
      end
      return self
    end

    def post_colorize
      if !@options["no_color"]
        @render[:screen_name][:template] =
          @render[:screen_name][:template]
          .colorize(@render[:screen_name][:color])
        @render[:post_url][:template] =
          @render[:post_url][:template]
          .colorize(@render[:post_url][:color])
      end  
      return self
    end

    def to_only_template
      return @render.values.map {|d| d[:template]}
    end
    
    def to_s
      self
        .user_colorize
        .post_colorize
        .to_only_template
        .join
        .sub("\\n", "\n")
    end
  end
end

