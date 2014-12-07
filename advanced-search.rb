require 'rubygems'
require 'sinatra'
require 'google/api_client'
require 'retriable'
require 'json'
require 'sass'

#HTTP Authentication for all App requests

use Rack::Auth::Basic, "Access Required!" do |username, password|
  username == 'admin' and password == 'a16z'
end


get '/' do
	#Custom Search Engine ID:
	cx = '017660767296246807512:b9eqedymv9g'
	#Public API Key:
	key = 'AIzaSyAZbO6L9SuDO2d1M8sQCOi39APzVi7rUdM'

	client = Google::APIClient.new(
  		:application_name => 'a16z-market-research-tool',
  		:application_version => '1.0.0',
  		:key => key,
  		:authorization => nil)

	search = client.discovered_api('customsearch', 'v1')  

	#Search Query: Testing to see if we can search for basic terms.
	q = "retail, energy, government, high-tech"

	#Additional API definitions:
	orTerms = 'CEO'
	exactTerms = 'microsoft'
	@num = 10

	#Restricts search results to limited values: d, w, m, y[number]
	dateRestrict = 'y[2]'

	#Backend values (Don't modify!)

	#Host language that sets the user interface language. This improves performance and quality of the search.
	lr = 'lang_en'
	hl = 'en'
	googlehost = 'google.com'
	pp = 'true'

	#Search algorithm
	response = client.execute(
				:api_method => search.cse.list,
				:application_name => 'a16z-market-research-tool',
				:parameters => {
					cx: cx,
					key: key,
					q: q, 
					orTerms: orTerms,
					exactTerms: exactTerms,
					num: @num,
					dateRestrict: dateRestrict,
					lr: lr,
					hl: hl,
					googlehost: googlehost,
					prettyPrint: pp
				}
			)

	# JSON.parse(response.body)
	p JSON.parse(response.body)
	
	#Saving Titles, Snippets & Links
	i = 0
	@response_titles = []
	@response_snippets = []
	@response_links = []
	response.data['items'].each do |x|
		@response_titles[i] = x['title']
		@response_snippets[i] = x['snippet']
		@response_links[i] = x['link']
		i += 1
	end

	erb :index,  :locals => {:num => @num,
							:response_titles => @response_titles, 
							:response_snippets => @response_snippets,
							:response_links => @response_links
							}
end


# EXTRA INFO:

# require ‘google/api_client’
# client = Google::APIClient.new

# Load API definitions prior to use:
# urlshortener = client.discovered_api(‘urlshortener’)

# By calling the API user issues requests against an existing instance of a Custom Search Engine. Created in control panel.

# JSON/Atom Custom Search API requires the use of an API key.



# GET https://www.googleapis.com/customsearch/v1?parameters




