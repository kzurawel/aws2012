require 'will_paginate'
require 'will_paginate/array'

module Nesta
  class App
    use Rack::Static, :urls => ['/js','/img','/css'], :root => 'themes/aws2012/public'

    helpers do
      def body_class
        if request.path == "/"
          return "home"
        elsif request.path.match(/^\/portfolio/)
          return "portfolio"
        elsif request.path == "/services"
          return "services"
        elsif request.path == "/contact"
          return "contact"
        elsif request.path == "/articles" || request.path == "/journal"
          return "category"
        else
          return "article"
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

  end
end
