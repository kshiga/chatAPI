class EventsController < ApplicationController
  skip_before_filter  :verify_authenticity_token
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  def ui
    render 'ui'
  end

  # GET /events
  # GET /events.json
  def index
    if(params.has_key?(:from) && params.has_key?(:to))
      @from = DateTime.iso8601(params[:from])
      @to = DateTime.iso8601(params[:to])
      @events = Event.where(:date => @from..@to)
    else
      @events = Event.all
    end

    events_json

    render json: @events_json_data
  end

  def summary
    if(params.has_key?(:from) && params.has_key?(:to) && params.has_key?(:by))
      @events = []
      @from = DateTime.iso8601(params[:from])
      @to = DateTime.iso8601(params[:to])
      @by = params[:by]

      case @by
      when "minute"
        @from = @from.beginning_of_minute
        @to =  @to.beginning_of_minute

      when "hour"
        @from = @from.beginning_of_hour
        @to =  @to.beginning_of_hour
      when "date"
        @from = @from.beginning_of_day
        @to =  @to.beginning_of_day
      else
        @divisions = 0
      end

      time_diff

      (0..@divisions).each do |t|
        @start = @from
        @from = @from.advance(@advance)
        @events.push(({"date" => @start.strftime("%Y/%m/%d %H:%M:%SZ")}).merge(Event.where(:date => @start..@from).group(:action).count.to_h))
      end
    else
      @events = Event.group(:action).count
    end
    render json: @events
  end

  # GET /events/1
  # GET /events/1.json
  def show
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params.to_h.merge({'action' => params[:type]}))

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render json: {"status" => "ok"}, status: :ok, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:action, :user, :otheruser, :message, :date)
    end

    def events_json
      @events_json_data = Array.new()
      @events.each do |e|
        @events_json_data.push(e.getJSONData)
      end
    end

    def time_diff
      seconds_diff = ((@to - @from) * 24 * 60 * 60).to_i.abs
      case @by
      when "minute"
         @divisions = seconds_diff / 60
         @advance = {:minutes => +1}
      when "hour"
          @divisions = seconds_diff / 3600
          @advance = {:hours => +1}
      when "date"
         @advance = {:days => +1}
      else
         @divisions = 0
      end

   end
end
