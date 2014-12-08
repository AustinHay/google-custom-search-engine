
require 'rubygems'
require 'sinatra'
require 'google/api_client'
require 'retriable'
require 'json'
require 'sass'
require 'CSV'

#HTTP Authentication for all App requests

use Rack::Auth::Basic, "Access Required!" do |username, password|
  username == 'admin' and password == 'admin'
end

get '/' do

### DATA SCRAPER ###
@scraped_data = []

csv_raw_data = File.read('public/data/input_data.csv')
csv_new_data = CSV.parse(csv_raw_data, :headers => true)
	i = 0
	csv_new_data.by_col!().each do |col|
		@scraped_data[i] = col
		i+=1
	end

	## Remove NIL values, reformat into columns, join each as a single string
	@raw_queries = []
	i=0
	@scraped_data.each do |col|
		@raw_queries[i] = col[1].compact.join(", ")	
		i+=1
	end 
#raw_queries is an array with all the possible query terms. Now you can assign each index to a different Google API variable.




### GOOGLE CUSTOM SEARCH ENGINE ###

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

	## INSERTION OF QUERY VALUES ##

	##SET COLUMN PARAMETERS
	req = 0
	#Basic, required Search Query term (q):
	p q = @raw_queries[req]
	@raw_queries.delete_at(req)

	#OR TERMS: add depth to search
	orTerms = []
	@raw_queries.each do |x|
		orTerms = orTerms.push(x)
	end
	p orTerms = orTerms.compact.join(", ").to_s

	# exactTerms = ''
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
					# exactTerms: exactTerms,
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





