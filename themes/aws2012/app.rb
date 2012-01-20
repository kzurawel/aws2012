require 'will_paginate'
require 'will_paginate/array'
require 'will_paginate/view_helpers/sinatra'

require 'base58'
require 'flickraw'
require 'twitter'
require 'nokogiri'
require 'open-uri'
require 'github_api'
require 'digest/sha1'

module Nesta
  class App
    use Rack::Static, :urls => ['/js','/img','/css'], :root => 'themes/aws2012/public'

    helpers WillPaginate::Sinatra::Helpers

    helpers do
      def body_class
        if request.path == "/"
          return "home"
        elsif request.path == "/portfolio"
          return "portfolio"
        elsif request.path.match(/^\/portfolio/)
          return "portfolioitem"
        elsif request.path == "/services"
          return "services"
        elsif request.path == "/contact"
          return "contact"
        elsif request.path == "/articles" || request.path == "/journal"
          return "category home"
        elsif request.path == "/about"
          return "about"
        else
          return "article"
        end
      end

      def latest_flickr(num_photos)
        require File.expand_path('apiconfig', File.dirname(__FILE__))
        apiconf = ApiConfig.new
        FlickRaw.api_key = apiconf.flickrapi
        FlickRaw.shared_secret = apiconf.flickrsecret
        photos = flickr.photos.search(:user_id => apiconf.flickrid, :per_page => num_photos, :page => 1)
        photoset = Array.new
        photos.each do |p|
          info = flickr.photos.getInfo(:photo_id => p.id, :secret => p.secret)
          item = {:title => info.title,
                  :thumbnail => FlickRaw.url_s(info),
                  :url => "http://flic.kr/p/#{Base58.encode(info.id.to_i)}",
                  :taken => Date.parse(info.dates.taken),
                }
          photoset << item
        end
        photoset
      end

      def github_repos(num_repos)
        require File.expand_path('apiconfig', File.dirname(__FILE__))
        apiconf = ApiConfig.new
        gh = Github::Repos.new
        repos = gh.repos(:user => apiconf.githubuser)
        repos.reverse!
        repolist = Array.new
        (0...num_repos).collect do |i|
          r = repos[i]
          item = {:name => r.name,
                  :description => r.description,
                  :url => r.url,
                  :pushed_at => r.pushed_at}
          repolist << item
        end
        repolist
      end

      def latest_tweets(num_tweets)
        require File.expand_path('apiconfig', File.dirname(__FILE__))
        apiconf = ApiConfig.new
        tweets = Twitter.user_timeline(apiconf.twitteruser, {:count => num_tweets, :include_rts => true})
        tweetlist = Array.new
        tweets.each do |t|
          gmttime = DateTime.parse(t.attrs['created_at'])
          time = DateTime.new(gmttime.year, gmttime.mon, gmttime.mday, gmttime.hour - 5, gmttime.min)
          item = {:user => t.attrs['user']['screen_name'],
                  :time => time,
                  :content => t.attrs['text'],
                  :img => t.attrs['user']['profile_image_url']}
          tweetlist << item
        end
        tweetlist
      end

      def fave_tweets(num_tweets)
        require File.expand_path('apiconfig', File.dirname(__FILE__))
        apiconf = ApiConfig.new
        tweets = Twitter.favorites(apiconf.twitteruser)
        tweetlist = Array.new
        (0...num_tweets).collect do |i|
          t = tweets[i]
          item = {:user => t.attrs['user']['screen_name'],
                  :time => DateTime.parse(t.attrs['created_at']),
                  :content => t.attrs['text'],
                  :img => t.attrs['user']['profile_image_url']}
          tweetlist << item
        end
        tweetlist
      end

      def latest_books(num_books)
        require File.expand_path('apiconfig', File.dirname(__FILE__))
        apiconf = ApiConfig.new
        doc = Nokogiri::XML(open("http://www.goodreads.com/review/list.xml?v=2&page=1&sort=date_read&order=d&shelf=read&id=#{apiconf.goodreadsid}&key=#{apiconf.goodreadsapi}&per_page=#{num_books}"))
        books = doc.search('book')
        booklist = Array.new
        books.each do |book|
          authors = book.search('authors')
          authorlist = Array.new
          authors.search('author').each do |a|
            authorlist << a.search('name').text
          end
          title = book.search('title').first.text
          if title.length > 40
            title = title[0...40] + "..."
          end
          item = {:title => title,
                  :link => book.search('link').first.text,
                  :cover => book.search('small_image_url').first.text,
                  :num_pages => book.search('num_pages'),
                  :pubyear => book.search('publication_year'),
                  :rating => book.parent.search('rating'),
                  :authors => authorlist}
          booklist << item
        end

        booklist
      end

      def latest_slideshows(num_shows)
        require File.expand_path('apiconfig', File.dirname(__FILE__))
        apiconf = ApiConfig.new
        now = Time.now.to_i.to_s
        doc = Nokogiri::XML(open("http://www.slideshare.net/api/2/get_slideshows_by_user?api_key=#{apiconf.slideshareapi}&ts=#{now}&hash=#{Digest::SHA1.hexdigest(apiconf.slidesharesecret + now)}&username_for=#{apiconf.slideshareuser}&limit=#{num_shows}"))
        shows = doc.search('Slideshow')
        showlist = Array.new
        shows.each do |show|
          item = {:title => show.search('Title').first.text,
                  :url => show.search('URL').text,
                  :thumb => show.search('ThumbnailSmallURL').text,
                  :date => Date.parse(show.search('Created').text)}
          showlist << item
        end
        showlist
      end

      def random_articles(page, howmany)
        pages = []
        howmany.times do
          articles = Nesta::Page.find_by_path('articles').articles
          articles += Nesta::Page.find_by_path('journal').articles
          test = page
          until (test != page) && (! pages.include?(test))
            test = articles[rand(articles.size)]
          end
          pages.push(test)
        end
        return pages
      end

      def random_article_summaries(pages)
        haml(:articlefooter, :format => :xhtml, :locals => { :pages => pages })
      end

      def navlink_current(path)
        if request.path.match(/^\/portfolio/)
          current = "portfolio"
        elsif request.path.match(/^\/services/)
          current = "services"
        elsif request.path.match(/^\/articles/)
          current = "articles"
        elsif request.path.match(/^\/journal/)
          current = "journal"
        elsif request.path.match(/^\/about/)
          current = "about"
        elsif request.path.match(/^\/contact/)
          current = "contact"
        end

        if path == current
          return 'current'
        else
          return ''
        end
      end

      def format_date(date)
        begin
          date.strftime("%d %b %Y")
        rescue
          return nil
        end
      end
    end

    # get '/css/:sheet.css' do
    #  content_type 'text/css', :charset => 'utf-8'
    #  cache stylesheet(params[:sheet].to_sym)
    # end

    get '/contact' do
      set_common_variables
      cache haml(:contact, :format => :xhtml)
    end

    post '/contact' do 
      require 'pony'
      require File.expand_path('emailconfig', File.dirname(__FILE__))
      mailconf = EmailConfig.new
      body = "Name: " + params[:name] + "\n"
      body += "Email: " + params[:email] + "\n"
      body += "Phone: " + params[:phone] + "\n"
      body += "Message: " + params[:message]
      Pony.mail(
        :from => params[:name] + "<" + params[:email] + ">",
        :to => mailconf.myemail,
        :subject => "[AWS]: " + params[:name] + " has contacted you",
        :body => body,
        :port => '587',
        :via => :smtp,
        :via_options => { 
          :address              => 'smtp.gmail.com', 
          :port                 => '587', 
          :enable_starttls_auto => true, 
          :user_name            => mailconf.username, 
          :password             => mailconf.password, 
          :authentication       => :plain, 
          :domain               => 'localhost.localdomain'
        })
      redirect '/success' 
    end

    post '/quickcontact' do
      require 'pony'
      require File.expand_path('emailconfig', File.dirname(__FILE__))
      mailconf = EmailConfig.new
      Pony.mail(
        :from => params[:qcemail],
        :to => mailconf.myemail,
        :subject => "[AWS]: Quick contact from " + params[:qcemail],
        :body => params[:qcemail],
        :port => '587',
        :via => :smtp,
        :via_options => {
          :address              => 'smtp.gmail.com',
          :port                 => '587',
          :enable_starttls_auto => true,
          :user_name            => mailconf.username,
          :password             => mailconf.password,
          :authentication       => :plain,
          :domain               => 'localhost.localdomain'
        })
      redirect '/success'
    end
  end
end
