class TalksController < ApplicationController
  before_filter :require_user, :except => [ :index, :show ]
  #before_filter :require_admin, :only => [ :new, :create ]
  before_filter :is_admin_or_owner, :only => [ :edit, :update, :destroy ]

  # GET /talks
  # GET /talks.xml
  def index
    @talks = params[:topic_id] ? Topic.find(params[:topic_id]).talks : Talk.all_approved

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @talks }
      format.rss
    end
  end

  # GET /talks/1
  # GET /talks/1.xml
  def show
    @talk = Talk.find(params[:id], :include => [:users, :topic, :comments, :votes])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @talk }
    end
  end

  # GET /talks/new
  # GET /talks/new.xml
  def new
    @talk = Talk.new
    @talk.topic = Topic.find(params[:topic_id]) if params[:topic_id]
    @user = current_user||User.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @talk }
    end
  end

  # GET /talks/1/edit
  def edit
    @talk = Talk.find(params[:id])
    @user = User.new
  end

  # POST /talks
  # POST /talks.xml
  def create
    @talk = Talk.new(params[:talk])

    if current_user
      @user = current_user
    else
      @user_session = UserSession.new(params[:user])
      if @user_session.save
        @user = current_user
        flash[:warn] = 'Registreringen finnes allerede.'
        flash[:registration_already_exists] = true
      else
        @user = User.new(params[:user])
        @user.create_registration(:ticket_type => "speaker",
            :includes_dinner => params[:registration_includes_dinner])
        if not @user.save and @user.registration.save
          respond_to do |format|
            format.html { render :action => "new" }
            format.xml  { render :xml => @talk.errors, :status => :unprocessable_entity }
          end
          return
        end
      end
    end

    @talk.users << @user

    respond_to do |format|
      if @talk.save
        flash[:notice] = "Forslaget er publisert"
        SmidigMailer.deliver_talk_confirmation(@talk, talk_url(@talk))
        format.html { redirect_to(@talk) }
        format.xml  { render :xml => @talk, :status => :created, :location => @talk }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @talk.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /talks/1
  # PUT /talks/1.xml
  def update
    @talk = current_user.is_admin ? Talk.find(params[:id]) : current_user.talks.find(params[:id])

    respond_to do |format|
      if @talk.update_attributes(params[:talk])
        flash[:notice] = 'Forslaget er endret.'
        format.html { redirect_to(@talk) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @talk.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /talks/1
  # DELETE /talks/1.xml
  def destroy
    @talk = current_user.is_admin ? Talk.find(params[:id]) : current_user.talks.find(params[:id])
    @talk.destroy

    respond_to do |format|
      format.html { redirect_to(talks_url) }
      format.xml  { head :ok }
    end
  end

protected
  def login_required
    return unless current_user
    flash[:error] = "Vennligst logg inn"
    access_denied
  end

  def is_admin_or_owner
    talk = Talk.find(params[:id])
    unless current_user.is_admin? || talk.users.include?(current_user)
      flash[:error] = "Du må være administrator eller eier for å endre siden."
      access_denied
    end
  end

end
