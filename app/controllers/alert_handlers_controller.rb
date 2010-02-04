class AlertHandlersController < ApplicationController
  
  layout 'admin'
  
  # GET /alert_handlers
  # GET /alert_handlers.xml
  def index
    @alert_handlers = AlertHandler.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @alert_handlers }
    end
  end

  # GET /alert_handlers/1
  # GET /alert_handlers/1.xml
  def show
    @alert_handler = AlertHandler.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @alert_handler }
    end
  end

  # GET /alert_handlers/new
  # GET /alert_handlers/new.xml
  def new
    @alert_handler = AlertHandler.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @alert_handler }
    end
  end

  # GET /alert_handlers/1/edit
  def edit
    @alert_handler = AlertHandler.find(params[:id])
  end

  # POST /alert_handlers
  # POST /alert_handlers.xml
  def create
    @alert_handler = AlertHandler.new(params[:alert_handler])

    respond_to do |format|
      if @alert_handler.save
        flash[:notice] = 'AlertHandler was successfully created.'
        format.html { redirect_to(@alert_handler) }
        format.xml  { render :xml => @alert_handler, :status => :created, :location => @alert_handler }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @alert_handler.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /alert_handlers/1
  # PUT /alert_handlers/1.xml
  def update
    @alert_handler = AlertHandler.find(params[:id])

    respond_to do |format|
      if @alert_handler.update_attributes(params[:alert_handler])
        flash[:notice] = 'AlertHandler was successfully updated.'
        format.html { redirect_to(@alert_handler) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @alert_handler.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /alert_handlers/1
  # DELETE /alert_handlers/1.xml
  def destroy
    @alert_handler = AlertHandler.find(params[:id])
    @alert_handler.destroy

    respond_to do |format|
      format.html { redirect_to(alert_handlers_url) }
      format.xml  { head :ok }
    end
  end
end
