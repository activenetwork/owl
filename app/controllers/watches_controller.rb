require 'lib/spark_pr.rb'

class WatchesController < ApplicationController
  
  NO_RESPONSE_TIME = 100
  
  before_filter :get_graph_cookies, :only => :response_graph
  
  layout 'admin'
  
  # GET /watches
  # GET /watches.xml
  def index
    
    unless params[:site].nil? or params[:site].blank?
      # lets you get watch status for multiple sites by passing ?site=1,2,3
      @watches = Site.find(params[:site].split(',')).collect { |site| site.watches }.flatten
    else
      @watches = Watch.active
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @watches }
      format.json { render :json => @watches.to_json( :methods => [:from_average, :since],
                                                      :except => [:created_at, :updated_at, :last_status_change_at, :status_id, :content_match, :active], 
                                                      :include => { :status => { :except => [:id] } } ) }
    end
  end

  # GET /watches/1
  # GET /watches/1.xml
  
  def show
    no_cache
    
    @watch = Watch.find(params[:id])
    
    if params[:view] == 'mini'
      render :partial => 'watch', :layout => false
    else
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @watch.to_json(:include => :status) }
        format.json { render :json => @watch.to_json(:include => :status, :methods => :from_average) }
      end
    end
  end

  # GET /watches/new
  # GET /watches/new.xml
  def new
    @watch = Watch.new(:site_id => params[:site])
    session[:return_to] = request.referer
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @watch }
    end
  end

  # GET /watches/1/edit
  def edit
    @watch = Watch.find(params[:id])
    @page_title = "Editing #{@watch.name} Watch"
    session[:return_to] = request.referer
  end

  # POST /watches
  # POST /watches.xml
  def create
    @watch = Watch.new(params[:watch])

    respond_to do |format|
      if @watch.save
        flash[:notice] = 'Watch was successfully created.'
        if params[:commit] == 'Create and Add Another'
          format.html { redirect_to new_watch_path(:site => @watch.site.id) }
          format.xml  { render :xml => @watch, :status => :created, :location => @watch }
        else
          format.html { redirect_to root_path }
          format.xml  { render :xml => @watch, :status => :created, :location => @watch }
        end
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @watch.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /watches/1
  # PUT /watches/1.xml
  def update
    @watch = Watch.find(params[:id])

    respond_to do |format|
      if @watch.update_attributes(params[:watch])
        flash[:notice] = 'Watch was successfully updated.'
        format.html { redirect_to root_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @watch.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /watches/1
  # DELETE /watches/1.xml
  def destroy
    @watch = Watch.find(params[:id])
    @watch.destroy

    respond_to do |format|
      format.html { redirect_to(root_path) }
      format.xml  { head :ok }
    end
  end
  
  
  # returns the response time graph for a given watch
  def response_graph
    
    no_cache
    
    if params[:type]
      # if params[:type] comes in then the user wanted to switch types, so save their preference
      set_graph_cookies(params[:id], params[:type])
      type = params[:type]
    else
      # otherwise, see what's in their cookie, or set one if it doesn't exist
      if this_graph_type = @graph_cookies[params[:id].to_s]
        type = this_graph_type
      else
        type = 'last_24'
        set_graph_cookies(params[:id], type)
      end
    end
    
    logger.debug("  TYPE: #{type}")
    key = Digest::MD5.hexdigest({ :id => params[:id], :type => type }.to_json)
  
    # if they didn't pass a type, assume it's the last 24 hours
    points = []
    case type
      when 'last_24'
        # showing graph for the last 24 hours. Get averages for each hour from the database
        png = data_cache(key, {:timeout => 1.hour}) do
          24.times do |num|
            points << (Response.average(:time, :conditions => ["watch_id = ? and time != 0 and created_at < ? and created_at > ?", params[:id], (num).hours.ago.to_s(:db), (num+1).hours.ago.to_s(:db)]) || NO_RESPONSE_TIME)
          end
          Spark.plot(points.reverse, :type => 'smooth', :has_min => true, :has_max => true, :has_last => 'true', :height => 40, :step => 10, :normalize => 'logarithmic' ) 
        end
      when 'last_1'
        png = data_cache(key, {:timeout => 2.minutes}) do
          # showing graph for the last hour. Get averages for every 2 minutes for the last hour from the database
          30.times do |num|
            points << (Response.average(:time, :conditions => ["watch_id = ? and time != 0 and created_at < ? and created_at > ?", params[:id], (num*2).minutes.ago.to_s(:db), (num*2+2).minutes.ago.to_s(:db)]) || NO_RESPONSE_TIME)
          end
          Spark.plot(points.reverse, :type => 'smooth', :has_min => true, :has_max => true, :has_last => 'true', :height => 40, :step => 8, :normalize => 'logarithmic' ) 
        end
    end
    send_data png, :type => 'image/png', :disposition => 'inline'
  end
  
  
  # copies alerts from one watch to another
  def copy
    if request.post? && params[:from] && params[:to]
      from = Watch.find(params[:from])
      to = Watch.find(params[:to])
      to.alerts.clear
      from.alerts.each do |alert|
        to.alerts.create(alert.attributes)
      end
      flash[:notice] = "Alerts copied"
      redirect_to(edit_watch_path(to))
    else
      raise InvalidRequest, "Some parameters were missing from your request"
    end
  end
  
  private
    
    def set_graph_cookies(id,type)
      cookies[:graphs] = { :value => (@graph_cookies.merge({ id => type })).to_json, :expires => 10.years.from_now }
    end
    
    def get_graph_cookies
      @graph_cookies = JSON.parse(cookies[:graphs] || "{}")
    end
  
end
