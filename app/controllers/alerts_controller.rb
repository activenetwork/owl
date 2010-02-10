class AlertsController < ApplicationController
  
  layout 'admin'
  
  # GET /alerts
  # GET /alerts.xml
  def index
    @alerts = Alert.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @alerts }
    end
  end

  # GET /alerts/1
  # GET /alerts/1.xml
  def show
    @alert = Alert.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @alert }
    end
  end

  # GET /alerts/new
  # GET /alerts/new.xml
  def new
    @alert = Alert.new(:watch_id => params[:watch])
    @page_title = "New Alert"
    if params[:watch]
      @page_title += " for #{@alert.watch.name}"
    end
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @alert }
    end
  end

  # GET /alerts/1/edit
  def edit
    @alert = Alert.find(params[:id])
    @page_title = "Editing #{@alert.alert_handler.name} Alert for #{@alert.watch.name}"
  end

  # POST /alerts
  # POST /alerts.xml
  def create
    @alert = Alert.new(params[:alert])

    respond_to do |format|
      if @alert.save
        # notify everyone added to this alert if it's an IM
        if @alert.type == :instant_message
          notify_alertees(@alert)
        end
        flash[:notice] = 'Alert was successfully created.'
        format.html { redirect_to(edit_watch_path(@alert.watch)) }
        format.xml  { render :xml => @alert, :status => :created, :location => @alert }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @alert.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /alerts/1
  # PUT /alerts/1.xml
  def update
    @alert = Alert.find(params[:id])

    respond_to do |format|
      if @alert.update_attributes(params[:alert])
        if @alert.type == :instant_message
          # send people an initial instant message so that the ActiveOwl user gets added to their contact list
          Delayed::Job.enqueue(Mouse::Alerts::InstantMessage.new(@alert.to, "You have been added as someone to notify if there is a problem with the following service - #{@alert.watch.site.name}: #{@alert.watch.name}"))
        end
        flash[:notice] = 'Alert was successfully updated.'
        format.html { redirect_to(edit_watch_path(@alert.watch)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @alert.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /alerts/1
  # DELETE /alerts/1.xml
  def destroy
    @alert = Alert.find(params[:id])
    @alert.destroy

    respond_to do |format|
      format.html { redirect_to(alerts_url) }
      format.xml  { head :ok }
    end
  end
  

end
