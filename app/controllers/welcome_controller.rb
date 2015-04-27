#encoding: utf-8
$LOAD_PATH << '/home/azureuser/src/rubywhois/whois/lib'

require 'whois'

class WhoisFeature
    attr_accessor :domain, :created_on, :updated_on, :expires_on, :registrant_org, :related_email, :related_country, :nameserver_count
end

class WelcomeController < ApplicationController
  def index
    begin
        # Get Domain From parameter
        domain = params[:domain]
        
        db_w = get_domain_info_by_domain(domain)

        # Use Rubywhois module to get whois info from whois server
        if db_w.nil?
            t = Whois.whois(domain)
            
            org = get_contact_org_by_order(t.registrant_contact, t.admin_contact, t.technical_contact)
            email = get_contact_email_by_order(t.registrant_contact, t.admin_contact, t.technical_contact)
            country = get_contact_country_by_order(t.registrant_contact, t.admin_contact, t.technical_contact)
            nameserver_count = t.nameservers.nil? ? 0 : t.nameservers.count
            db_w = Domain.create(:domain => domain, :create_time => t.created_on, :updated_time => t.updated_on,
                                 :expires_time => t.expires_on, :registrant_org => org, :related_email => email,
                                 :related_country => country, :nameserver_count => nameserver_count)
        end

        # Use the fetch result to set the response object
        w = WhoisFeature.new
        
        w.domain = domain
        w.created_on = db_w.create_time
        w.updated_on = db_w.updated_time
        w.expires_on = db_w.expires_time
        w.registrant_org = db_w.registrant_org
        w.related_email = db_w.related_email
        w.related_country = db_w.related_country
        w.nameserver_count = db_w.nameserver_count

        # Serialize the response object to json
        @Json = ActiveSupport::JSON.encode(w)
    rescue Exception => exc
        @Json = {"error":{"message":"#{exc.message}","name":"WhoisServerNotAvailable"}}
    end

    # return the json to the client
    respond_to do |format|
        format.html{render :json => @Json}
    end
  end

  def get_contact_email_by_order(c1, c2, c3)
      if c1 and c1.email
          c1.email
      elsif c2 and c2.email
          c2.email
      elsif c3 and c3.email
          c3.email
      else 
          "null"
      end
  end

  def get_contact_country_by_order(c1, c2, c3)
      if c1 and c1.country_code
          c1.country_code
      elsif c2 and c2.country_code
          c2.country_code
      elsif c3 and c3.country_code
          c3.country_code
      else 
          "null"
      end
  end

  def get_contact_org_by_order(c1, c2, c3)
      if c1 and c1.organization
          c1.organization
      elsif c2 and c2.organization
          c2.organization
      elsif c3 and c3.organization
          c3.organization
      else 
          "null"
      end
  end

  def get_domain_info_by_domain(domain)
      begin
          db_w = Domain.find_by_domain(domain)
      rescue Exception => exp
          db_w = nil
      end
  end
end
