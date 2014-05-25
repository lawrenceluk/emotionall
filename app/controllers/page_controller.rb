require 'soundcloud'

class PageController < ApplicationController
	before_filter :twitter_connect, only: [:home]

	def home
		@paramtype = params[:r]
		@paramtype ||= "twitter"
		@query = params[:q]
		@query ||= "happy"
		if @paramtype == "twitter"
			@results = @client.search(@query, :result_type => "mixed", :lang => "en") rescue return
		elsif @paramtype == "soundcloud"
			@client = Soundcloud.new(:client_id => 'f7457254feab5150a8660918c2b5aa95')
			tracks = @client.get('/tracks', :tag_list => @query, :licence => 'cc-by-sa', :limit => 5)
			@tracks = []
			tracks.each do |track|
				if track.embeddable_by == "all"
					@tracks << track
				end
			end
		elsif @paramtype == "flickr"
			response = HTTParty.get 'https://secure.flickr.com/services/rest/?method=flickr.photos.search&api_key=9b06fd153003ef07e8ebaec3832f717e&' +
      'text='+@query+'&safe_search=1&content_type=1&sort=interestingness-desc&per_page=12'
      @urls = []
      photos = response["rsp"]["photos"]["photo"]
       photos.each do|photo|
	      str = "http://farm" + photo["farm"] +
	        ".static.flickr.com/" + photo["server"] +
	        "/" + photo["id"] +
	        "_" + photo["secret"] +
	        ".jpg"
	      @urls << str
      end
		end
	end

  def twitter_connect
		@client ||= Twitter::REST::Client.new do |config|
			# please don't mess
		  config.consumer_key        = "6BjPgljvKQWo0vn829GNwA"
		  config.consumer_secret     = "KIyJs8A0i74IkNNaeaUL7K2Nqxfg7y3EReHhMmCc"
		  config.access_token        = ""
		  config.access_token_secret = ""
		end
  end

end
