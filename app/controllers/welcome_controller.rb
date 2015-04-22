#encoding: utf-8
#$LOAD_PATH << '/home/azureuser/src/rubywhois/whois/lib'

require 'whois'

class WhoisFeature
	attr_accessor :domain
	attr_accessor :created_on
	attr_accessor :updated_on
	attr_accessor :expires_on
	attr_accessor :registrant_contact_email
	attr_accessor :technical_contact_email
	attr_accessor :admin_contact_email
	attr_accessor :registrant_contact_cc
	attr_accessor :technical_contact_cc
	attr_accessor :admin_contact_cc
	attr_accessor :nameservers
end

class WelcomeController < ApplicationController
  def index
	begin
		# Get Domain From parameter
		domain = params[:domain]

		# Use Rubywhois module to get whois info from whois server
		t = Whois.whois(domain)

		# Use the fetch result to set the response object
		w = WhoisFeature.new
		w.domain = domain
		w.created_on = t.created_on
		w.updated_on = t.updated_on
		w.expires_on = t.expires_on
		if (t.registrant_contact)
			w.registrant_contact_email = t.registrant_contact.email
			w.registrant_contact_cc = t.registrant_contact.country_code
		end
		if(t.admin_contact)
			w.admin_contact_email = t.admin_contact.email
			w.admin_contact_cc = t.admin_contact.country_code
		end
		if(t.technical_contact)
			w.technical_contact_email = t.technical_contact.email
			w.technical_contact_cc= t.technical_contact.country_code
		end
		w.nameservers = t.nameservers

		# Serialize the response object to json
		@Json = ActiveSupport::JSON.encode(w)
	rescue Exception => exc
		@Json = "#{Encoding.default_external}. #{exc.message}"#'{"error":{"message":"#{exc.message}","name":"WhoisServerNotAvailable"}}'
	end

	# return the json to the client
	respond_to do |format|
		format.html{render :json => @Json}
	end
  end
end
