require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

require 'nesta/env'
Nesta::Env.root = ::File.expand_path('.', ::File.dirname(__FILE__))

require 'nesta/app'

use Rack::Codehighlighter, :coderay, :element => "pre>code", :markdown => true
use Rack::Cache, :verbose => true, :metastore => 'file:/home/kzurawel/rack/meta', :entitystore => 'file:/home/kzurawel/rack/entity'

run Nesta::App
