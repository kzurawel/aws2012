require 'will_paginate'
require 'will_paginate/array'
require 'will_paginate/view_helpers/sinatra'

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
